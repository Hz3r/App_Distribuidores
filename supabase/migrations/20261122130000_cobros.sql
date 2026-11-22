-- Módulo 4: cobros.
-- Pagos totales o parciales de un pedido, su anulación, y la regla que
-- impide cancelar un pedido con pagos activos. El saldo y el estado de pago
-- viven en pedidos (módulo 3); aquí solo los mueven registrar_pago y
-- anular_pago. Spec: secciones 6.4 y 7.
--
-- Orden: tablas, índices, triggers, funciones auxiliares, permisos,
-- políticas, funciones públicas.

-- ---------------------------------------------------------------------------
-- Tablas
-- ---------------------------------------------------------------------------

-- Pago de un pedido. Nunca se borra ni se edita: anularlo llena anulado_en y
-- anulado_por y agrega la nota de la anulación. cliente_id es la bodega del
-- pedido (copia que fija registrar_pago). Las claves hacia el pedido y la
-- bodega son compuestas con distribuidor_id: imposible cruzar distribuidores.
create table public.pagos (
  id uuid primary key default gen_random_uuid(),
  distribuidor_id uuid not null references public.distribuidores (id),
  pedido_id uuid not null,
  cliente_id uuid not null,
  monto_centimos bigint not null check (monto_centimos > 0),
  metodo public.metodo_pago not null,
  referencia text,
  nota text,
  registrado_por uuid references public.perfiles (id) on delete set null,
  anulado_en timestamptz,
  anulado_por uuid references public.perfiles (id) on delete set null,
  creado_en timestamptz not null default now(),
  actualizado_en timestamptz not null default now(),
  foreign key (pedido_id, distribuidor_id)
    references public.pedidos (id, distribuidor_id),
  foreign key (cliente_id, distribuidor_id)
    references public.clientes_negocio (id, distribuidor_id),
  -- Quien anuló puede quedar nulo si se borra su perfil; la fecha, no.
  constraint pagos_anulacion_check
    check (anulado_por is null or anulado_en is not null)
);

alter table public.pagos enable row level security;

-- ---------------------------------------------------------------------------
-- Índices: toda clave foránea y las columnas usadas en RLS.
-- ---------------------------------------------------------------------------
create index pagos_distribuidor_idx on public.pagos (distribuidor_id);
create index pagos_pedido_idx on public.pagos (pedido_id, distribuidor_id);
create index pagos_cliente_idx on public.pagos (cliente_id, distribuidor_id);
create index pagos_registrado_por_idx on public.pagos (registrado_por);
create index pagos_anulado_por_idx on public.pagos (anulado_por);

-- ---------------------------------------------------------------------------
-- Triggers
-- ---------------------------------------------------------------------------
create trigger pagos_actualizado_en before update on public.pagos
  for each row execute function privado.tg_actualizado_en();

-- ---------------------------------------------------------------------------
-- Funciones auxiliares
-- ---------------------------------------------------------------------------

-- Estado de pago según el saldo: 0 → pagado; igual al total → pendiente;
-- cualquier otro → parcial. Uso interno de registrar_pago y anular_pago.
create function privado.estado_pago_segun(p_saldo bigint, p_total bigint)
returns public.estado_pago
language sql
immutable
set search_path = ''
as $$
  select case
           when p_saldo = 0 then 'pagado'
           when p_saldo = p_total then 'pendiente'
           else 'parcial'
         end::public.estado_pago
$$;

revoke execute on function privado.estado_pago_segun(bigint, bigint) from public, anon;

-- Reemplaza la del módulo 3: no se cancela un pedido con pagos sin anular
-- (primero hay que anularlos). La llama cambiar_estado_pedido con el pedido
-- ya bloqueado; registrar_pago bloquea el mismo pedido antes de insertar, así
-- que no se cuela un pago entre esta validación y la cancelación.
-- Error: P0006.
create or replace function privado.validar_cancelacion(p_pedido uuid) returns void
language plpgsql
volatile
set search_path = ''
as $$
begin
  if exists (
    select 1 from public.pagos g
    where g.pedido_id = p_pedido and g.anulado_en is null
  ) then
    raise exception 'El pedido tiene pagos activos: anúlelos antes de cancelar'
      using errcode = 'P0006';
  end if;
end $$;

revoke execute on function privado.validar_cancelacion(uuid) from public, anon;

-- ---------------------------------------------------------------------------
-- Permisos de tablas (explícitos, sin depender de los privilegios por defecto)
-- Nadie escribe pagos directamente: todo pasa por funciones.
-- ---------------------------------------------------------------------------
revoke all on public.pagos from anon, authenticated;

grant select on public.pagos to authenticated;

-- ---------------------------------------------------------------------------
-- Políticas
-- Admin y vendedor leen todos los pagos del distribuidor; los demás, los
-- pagos de los pedidos que ven (el repartidor, sus pedidos asignados; la
-- bodega, los suyos; el Super Admin, todos). El exists consulta pedidos con
-- su propia política (RLS aplica dentro).
-- ---------------------------------------------------------------------------
create policy pagos_select on public.pagos
  for select to authenticated
  using (
    (select privado.tiene_rol(distribuidor_id, '{admin,vendedor}'))
    or exists (
      select 1 from public.pedidos p
      where p.id = pagos.pedido_id
        and p.distribuidor_id = pagos.distribuidor_id)
  );

-- ---------------------------------------------------------------------------
-- Funciones públicas
-- ---------------------------------------------------------------------------

-- Registra un pago total o parcial de un pedido (spec 6.4): admin, vendedor
-- o el repartidor asignado (si sigue siendo repartidor activo). Baja el
-- saldo y actualiza estado_pago en un solo update del pedido.
--
-- Bloqueo: la fila del pedido, antes de leer el saldo. Así dos pagos
-- simultáneos no superan el saldo, y una cancelación en curso espera.
--
-- Errores: 42501 sin sesión o rol sin permiso para cobrar (por ejemplo, la
-- bodega); P0002 pedido inexistente o que quien llama no puede ver; P0006
-- pedido cancelado; 22023 método nulo, o monto nulo, menor o igual a cero o
-- mayor al saldo.
create function public.registrar_pago(
  p_pedido_id uuid,
  p_monto_centimos bigint,
  p_metodo public.metodo_pago,
  p_referencia text default null,
  p_nota text default null
) returns uuid
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_pedido public.pedidos;
  v_saldo bigint;
  v_pago uuid;
begin
  if v_uid is null then
    raise exception 'Se requiere una sesión' using errcode = '42501';
  end if;

  -- Primera lectura, sin bloqueo: quien no puede ver el pedido no llega a
  -- bloquear su fila.
  select * into v_pedido from public.pedidos p where p.id = p_pedido_id;

  if not found
     or not privado.ve_pedido(v_pedido.distribuidor_id, v_pedido.cliente_id,
                              v_pedido.repartidor_id) then
    raise exception 'Pedido inexistente' using errcode = 'P0002';
  end if;

  if not (privado.tiene_rol(v_pedido.distribuidor_id, '{admin,vendedor}')
          or (coalesce(v_pedido.repartidor_id = v_uid, false)
              and privado.tiene_rol(v_pedido.distribuidor_id, '{repartidor}'))) then
    raise exception 'No puede registrar pagos de este pedido' using errcode = '42501';
  end if;

  -- Bloqueo del pedido.
  select * into v_pedido from public.pedidos p where p.id = p_pedido_id for update;

  -- Revalida con la fila ya bloqueada: quien llama pudo perder su rol, o el
  -- pedido cambiar de repartidor o de estado, mientras esperaba el bloqueo.
  if not privado.ve_pedido(v_pedido.distribuidor_id, v_pedido.cliente_id,
                           v_pedido.repartidor_id) then
    raise exception 'Pedido inexistente' using errcode = 'P0002';
  end if;

  if not (privado.tiene_rol(v_pedido.distribuidor_id, '{admin,vendedor}')
          or (coalesce(v_pedido.repartidor_id = v_uid, false)
              and privado.tiene_rol(v_pedido.distribuidor_id, '{repartidor}'))) then
    raise exception 'No puede registrar pagos de este pedido' using errcode = '42501';
  end if;

  if v_pedido.estado = 'cancelado' then
    raise exception 'No se registran pagos en un pedido cancelado' using errcode = 'P0006';
  end if;

  if p_metodo is null then
    raise exception 'Indique el método de pago' using errcode = '22023';
  end if;

  if p_monto_centimos is null or p_monto_centimos <= 0 then
    raise exception 'El monto debe ser mayor a cero' using errcode = '22023';
  end if;

  if p_monto_centimos > v_pedido.saldo_pendiente_centimos then
    raise exception 'El monto supera el saldo pendiente (% céntimos)',
      v_pedido.saldo_pendiente_centimos
      using errcode = '22023';
  end if;

  insert into public.pagos
    (distribuidor_id, pedido_id, cliente_id, monto_centimos, metodo, referencia, nota,
     registrado_por)
  values
    (v_pedido.distribuidor_id, v_pedido.id, v_pedido.cliente_id, p_monto_centimos, p_metodo,
     p_referencia, p_nota, v_uid)
  returning id into v_pago;

  v_saldo := v_pedido.saldo_pendiente_centimos - p_monto_centimos;

  update public.pedidos
  set saldo_pendiente_centimos = v_saldo,
      estado_pago = privado.estado_pago_segun(v_saldo, v_pedido.total_centimos)
  where id = v_pedido.id;

  return v_pago;
end $$;

revoke execute on function
  public.registrar_pago(uuid, bigint, public.metodo_pago, text, text)
  from public, anon;

grant execute on function
  public.registrar_pago(uuid, bigint, public.metodo_pago, text, text)
  to authenticated;

-- Anula un pago (spec 6.4): solo el admin del distribuidor. El pago no se
-- borra: se marca anulado, se agrega la nota a pagos.nota y el monto vuelve
-- al saldo del pedido, con estado_pago recalculado en un solo update.
--
-- Bloqueos, en este orden: el pedido, su bodega y el pago. El pedido antes
-- de leer el saldo, como registrar_pago. La bodega, porque crear_pedido la
-- bloquea antes de leer la deuda a crédito: así un pedido nuevo no se crea
-- con la deuda leída antes de que esta anulación la suba. Pedido y luego
-- bodega es el mismo orden que sigue registrar_pago (la clave foránea de
-- pagos hacia la bodega toma un bloqueo compartido sobre ella al insertar);
-- crear_pedido no bloquea pedidos existentes, así que no hay bloqueos
-- mutuos.
--
-- Errores: 42501 sin sesión o sin rol de admin; P0002 pago inexistente o de
-- un pedido que quien llama no puede ver; 22023 nota nula o vacía; P0006
-- pago ya anulado.
create function public.anular_pago(
  p_pago_id uuid,
  p_nota text
) returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_pago public.pagos;
  v_pedido public.pedidos;
  v_saldo bigint;
begin
  if v_uid is null then
    raise exception 'Se requiere una sesión' using errcode = '42501';
  end if;

  -- Primera lectura, sin bloqueo (mismo criterio que registrar_pago).
  select * into v_pago from public.pagos g where g.id = p_pago_id;

  if found then
    select * into v_pedido
    from public.pedidos p
    where p.id = v_pago.pedido_id and p.distribuidor_id = v_pago.distribuidor_id;
  end if;

  if v_pago.id is null
     or not privado.ve_pedido(v_pedido.distribuidor_id, v_pedido.cliente_id,
                              v_pedido.repartidor_id) then
    raise exception 'Pago inexistente' using errcode = 'P0002';
  end if;

  if not privado.tiene_rol(v_pago.distribuidor_id, '{admin}') then
    raise exception 'Solo el admin anula pagos' using errcode = '42501';
  end if;

  if nullif(btrim(p_nota), '') is null then
    raise exception 'Indique el motivo de la anulación' using errcode = '22023';
  end if;

  -- Bloqueos: pedido, bodega, pago.
  select * into v_pedido from public.pedidos p where p.id = v_pedido.id for update;

  perform 1
  from public.clientes_negocio c
  where c.id = v_pedido.cliente_id and c.distribuidor_id = v_pedido.distribuidor_id
  for update;

  select * into v_pago from public.pagos g where g.id = p_pago_id for update;

  -- Revalida con las filas ya bloqueadas.
  if not privado.tiene_rol(v_pago.distribuidor_id, '{admin}') then
    raise exception 'Solo el admin anula pagos' using errcode = '42501';
  end if;

  if v_pago.anulado_en is not null then
    raise exception 'El pago ya está anulado' using errcode = 'P0006';
  end if;

  update public.pagos
  set anulado_en = now(),
      anulado_por = v_uid,
      nota = concat_ws(E'\n', v_pago.nota, 'Anulado: ' || btrim(p_nota))
  where id = v_pago.id;

  v_saldo := v_pedido.saldo_pendiente_centimos + v_pago.monto_centimos;

  update public.pedidos
  set saldo_pendiente_centimos = v_saldo,
      estado_pago = privado.estado_pago_segun(v_saldo, v_pedido.total_centimos)
  where id = v_pedido.id;
end $$;

revoke execute on function public.anular_pago(uuid, text) from public, anon;

grant execute on function public.anular_pago(uuid, text) to authenticated;
