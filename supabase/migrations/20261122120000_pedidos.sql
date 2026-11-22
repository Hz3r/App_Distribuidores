-- Módulo 3: pedidos.
-- Pedidos, sus líneas y su línea de tiempo, el correlativo por distribuidor
-- y la función crear_pedido (reserva de stock, precio, crédito e
-- idempotencia). Agrega a clientes_negocio las condiciones de crédito.
-- Spec: secciones 6.3 y 7.
--
-- Orden: enums, tablas, índices, triggers, permisos, políticas, funciones
-- públicas.

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------
create type public.estado_pedido as enum
  ('recibido', 'confirmado', 'en_camino', 'listo_recojo', 'entregado', 'cancelado');
create type public.despacho_pedido as enum ('recojo', 'reparto');
create type public.condicion_pago as enum ('contado', 'credito');
create type public.metodo_pago as enum ('efectivo', 'billetera_digital', 'transferencia');
create type public.estado_pago as enum ('pendiente', 'parcial', 'pagado');

-- ---------------------------------------------------------------------------
-- Tablas
-- Las hijas apuntan al padre con clave foránea compuesta (x_id,
-- distribuidor_id): imposible cruzar distribuidores. Las claves hacia el
-- catálogo y las bodegas son restrict (sin acción): se desactivan, no se
-- borran.
-- ---------------------------------------------------------------------------

-- Condiciones de crédito de la bodega. No existe crédito sin límite: los
-- "is not null" hacen falta porque un check con resultado nulo se acepta.
alter table public.clientes_negocio
  add column credito_habilitado boolean not null default false,
  add column limite_credito_centimos bigint,
  add column plazo_credito_dias integer,
  add constraint clientes_negocio_credito_check
    check (not credito_habilitado
           or (limite_credito_centimos is not null and plazo_credito_dias is not null
               and limite_credito_centimos > 0 and plazo_credito_dias > 0));

-- Correlativo de pedidos por distribuidor. Lo crea crear_pedido la primera
-- vez que hace falta. Sin acceso directo para nadie.
create table public.contadores_pedido (
  distribuidor_id uuid primary key references public.distribuidores (id),
  ultimo_numero integer not null default 0 check (ultimo_numero >= 0),
  creado_en timestamptz not null default now(),
  actualizado_en timestamptz not null default now()
);

-- Pedido de una bodega. Nace con saldo igual al total; vence_en se fija al
-- entregar un pedido a crédito.
create table public.pedidos (
  id uuid primary key default gen_random_uuid(),
  distribuidor_id uuid not null references public.distribuidores (id),
  numero integer not null check (numero > 0),
  cliente_id uuid not null,
  creado_por uuid references public.perfiles (id) on delete set null,
  repartidor_id uuid references public.perfiles (id) on delete set null,
  estado public.estado_pedido not null default 'recibido',
  despacho public.despacho_pedido not null,
  direccion_entrega text,
  nota_cliente text,
  total_centimos bigint not null check (total_centimos >= 0),
  condicion_pago public.condicion_pago not null,
  metodo_pago public.metodo_pago,
  estado_pago public.estado_pago not null default 'pendiente',
  saldo_pendiente_centimos bigint not null,
  vence_en date,
  motivo_cancelacion text,
  clave_idempotencia uuid not null,
  entregado_en timestamptz,
  creado_en timestamptz not null default now(),
  actualizado_en timestamptz not null default now(),
  unique (id, distribuidor_id),
  unique (distribuidor_id, numero),
  unique (cliente_id, clave_idempotencia),
  foreign key (cliente_id, distribuidor_id)
    references public.clientes_negocio (id, distribuidor_id),
  constraint pedidos_saldo_check
    check (0 <= saldo_pendiente_centimos and saldo_pendiente_centimos <= total_centimos)
);

-- Líneas del pedido, con copia del nombre, el factor y el precio del momento
-- de la compra. Una línea por presentación (crear_pedido consolida).
create table public.pedido_items (
  id uuid primary key default gen_random_uuid(),
  distribuidor_id uuid not null references public.distribuidores (id),
  pedido_id uuid not null,
  presentacion_id uuid not null,
  producto_id uuid not null,
  nombre_producto text not null,
  nombre_presentacion text not null,
  factor integer not null check (factor > 0),
  cantidad integer not null check (cantidad > 0),
  precio_unitario_centimos bigint not null check (precio_unitario_centimos >= 0),
  subtotal_centimos bigint not null,
  creado_en timestamptz not null default now(),
  unique (pedido_id, presentacion_id),
  foreign key (pedido_id, distribuidor_id)
    references public.pedidos (id, distribuidor_id),
  foreign key (presentacion_id, distribuidor_id)
    references public.presentaciones (id, distribuidor_id),
  foreign key (producto_id, distribuidor_id)
    references public.productos (id, distribuidor_id),
  constraint pedido_items_subtotal_check
    check (subtotal_centimos = precio_unitario_centimos * cantidad)
);

-- Línea de tiempo del pedido: una fila por cambio de estado. El primer
-- evento (al crear) no tiene estado anterior.
create table public.pedido_eventos (
  id uuid primary key default gen_random_uuid(),
  distribuidor_id uuid not null references public.distribuidores (id),
  pedido_id uuid not null,
  estado_anterior public.estado_pedido,
  estado_nuevo public.estado_pedido not null,
  hecho_por uuid references public.perfiles (id) on delete set null,
  nota text,
  creado_en timestamptz not null default now(),
  foreign key (pedido_id, distribuidor_id)
    references public.pedidos (id, distribuidor_id)
);

-- La clave foránea que el módulo 2 dejó pendiente.
alter table public.movimientos_stock
  add foreign key (pedido_id, distribuidor_id)
    references public.pedidos (id, distribuidor_id);

alter table public.contadores_pedido enable row level security;
alter table public.pedidos enable row level security;
alter table public.pedido_items enable row level security;
alter table public.pedido_eventos enable row level security;

-- ---------------------------------------------------------------------------
-- Índices: toda clave foránea y las columnas usadas en RLS.
-- pedidos (distribuidor_id) lo cubre su unique con numero; pedido_items
-- (pedido_id), su unique con presentacion_id; movimientos_stock (pedido_id)
-- ya tiene índice desde el módulo 2.
-- ---------------------------------------------------------------------------
create index pedidos_cliente_idx on public.pedidos (cliente_id, distribuidor_id);
create index pedidos_creado_por_idx on public.pedidos (creado_por);
create index pedidos_repartidor_idx on public.pedidos (repartidor_id);
create index pedido_items_distribuidor_idx on public.pedido_items (distribuidor_id);
create index pedido_items_presentacion_idx on public.pedido_items (presentacion_id, distribuidor_id);
create index pedido_items_producto_idx on public.pedido_items (producto_id, distribuidor_id);
create index pedido_eventos_distribuidor_idx on public.pedido_eventos (distribuidor_id);
create index pedido_eventos_pedido_idx on public.pedido_eventos (pedido_id, distribuidor_id);
create index pedido_eventos_hecho_por_idx on public.pedido_eventos (hecho_por);

-- ---------------------------------------------------------------------------
-- Triggers
-- ---------------------------------------------------------------------------
create trigger contadores_pedido_actualizado_en before update on public.contadores_pedido
  for each row execute function privado.tg_actualizado_en();
create trigger pedidos_actualizado_en before update on public.pedidos
  for each row execute function privado.tg_actualizado_en();

-- Amplía la protección de clientes_negocio (módulo 2) a las condiciones de
-- crédito. Con sesión:
-- - id y distribuidor_id no cambian para nadie, ni siquiera el admin;
-- - solo el admin asigna o cambia lista_precios_id (también al crear);
-- - solo el admin habilita el crédito o fija límite y plazo (también al
--   crear).
-- Sin sesión (rol de servicio, migraciones, seed) no aplica. Conserva los
-- permisos de execute del módulo 2.
create or replace function privado.tg_clientes_negocio_protege_campos() returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if auth.uid() is null then
    return new;
  end if;

  if tg_op = 'UPDATE' then
    if new.id is distinct from old.id
       or new.distribuidor_id is distinct from old.distribuidor_id then
      raise exception 'El id y el distribuidor de una bodega no cambian'
        using errcode = '42501';
    end if;

    if new.lista_precios_id is distinct from old.lista_precios_id
       and not privado.tiene_rol(old.distribuidor_id, '{admin}') then
      raise exception 'Solo el admin cambia la lista de precios de una bodega'
        using errcode = '42501';
    end if;

    if (new.credito_habilitado is distinct from old.credito_habilitado
        or new.limite_credito_centimos is distinct from old.limite_credito_centimos
        or new.plazo_credito_dias is distinct from old.plazo_credito_dias)
       and not privado.tiene_rol(old.distribuidor_id, '{admin}') then
      raise exception 'Solo el admin cambia el crédito de una bodega'
        using errcode = '42501';
    end if;
  else
    if new.lista_precios_id is not null
       and not privado.tiene_rol(new.distribuidor_id, '{admin}') then
      raise exception 'Solo el admin asigna la lista de precios de una bodega'
        using errcode = '42501';
    end if;

    if (new.credito_habilitado
        or new.limite_credito_centimos is not null
        or new.plazo_credito_dias is not null)
       and not privado.tiene_rol(new.distribuidor_id, '{admin}') then
      raise exception 'Solo el admin asigna el crédito de una bodega'
        using errcode = '42501';
    end if;
  end if;

  return new;
end $$;

-- ---------------------------------------------------------------------------
-- Permisos de tablas (explícitos, sin depender de los privilegios por defecto)
-- Nadie escribe pedidos, líneas ni eventos directamente: todo pasa por
-- funciones. Las columnas de crédito de clientes_negocio quedan bajo el grant
-- de tabla del módulo 1; el trigger de protección limita quién las cambia.
-- ---------------------------------------------------------------------------
revoke all on public.contadores_pedido, public.pedidos, public.pedido_items,
  public.pedido_eventos
  from anon, authenticated;

-- contadores_pedido: sin ningún grant.
grant select on public.pedidos to authenticated;
grant select on public.pedido_items to authenticated;
grant select on public.pedido_eventos to authenticated;

-- ---------------------------------------------------------------------------
-- Políticas
-- Admin y vendedor leen todos los pedidos del distribuidor; el repartidor,
-- los asignados a él mientras siga siendo repartidor activo; el cliente, los
-- de su bodega. Líneas y eventos se ven si se ve su pedido.
-- ---------------------------------------------------------------------------
create policy pedidos_select on public.pedidos
  for select to authenticated
  using (
    (select privado.es_super_admin())
    or (select privado.tiene_rol(distribuidor_id, '{admin,vendedor}'))
    or (repartidor_id = (select auth.uid())
        and (select privado.tiene_rol(distribuidor_id, '{repartidor}')))
    or cliente_id = (select privado.mi_cliente_en(distribuidor_id))
  );

-- El exists consulta pedidos con su propia política (RLS aplica dentro).
create policy pedido_items_select on public.pedido_items
  for select to authenticated
  using (
    (select privado.tiene_rol(distribuidor_id, '{admin,vendedor}'))
    or exists (
      select 1 from public.pedidos p
      where p.id = pedido_items.pedido_id
        and p.distribuidor_id = pedido_items.distribuidor_id)
  );

create policy pedido_eventos_select on public.pedido_eventos
  for select to authenticated
  using (
    (select privado.tiene_rol(distribuidor_id, '{admin,vendedor}'))
    or exists (
      select 1 from public.pedidos p
      where p.id = pedido_eventos.pedido_id
        and p.distribuidor_id = pedido_eventos.distribuidor_id)
  );

-- El repartidor lee las bodegas de sus pedidos asignados (se suma, con OR, a
-- clientes_negocio_select del módulo 1).
create policy clientes_negocio_select_repartidor on public.clientes_negocio
  for select to authenticated
  using (
    (select privado.tiene_rol(distribuidor_id, '{repartidor}'))
    and exists (
      select 1 from public.pedidos p
      where p.cliente_id = clientes_negocio.id
        and p.distribuidor_id = clientes_negocio.distribuidor_id
        and p.repartidor_id = (select auth.uid()))
  );

-- El cliente lee el perfil del repartidor de sus pedidos (se suma, con OR, a
-- perfiles_select del módulo 1).
create policy perfiles_select_repartidor_de_mis_pedidos on public.perfiles
  for select to authenticated
  using (
    exists (
      select 1 from public.pedidos p
      where p.repartidor_id = perfiles.id
        and p.cliente_id = (select privado.mi_cliente_en(p.distribuidor_id)))
  );

-- ---------------------------------------------------------------------------
-- Funciones públicas
-- ---------------------------------------------------------------------------

-- Crea un pedido en una sola transacción (spec 6.3). Los parámetros con
-- valor por defecto van al final; la app los pasa por nombre.
--
-- - Cliente: la bodega es la de su membresía; p_cliente_id nulo o igual.
-- - Admin o vendedor: p_cliente_id obligatorio y de ese distribuidor.
-- - Nadie más crea pedidos.
--
-- Bloqueos, siempre en el mismo orden para evitar bloqueos mutuos: la fila
-- de la bodega, luego los productos por id ascendente, luego el contador del
-- distribuidor. El bloqueo de la bodega serializa sus pedidos: así la
-- idempotencia y las reglas de crédito no tienen carreras.
--
-- Errores: 42501 sin permiso o bodega ajena; 22023 parámetro o ítems mal
-- formados; P0002 presentación inexistente, inactiva (o su producto) o de
-- otro distribuidor; P0001 stock insuficiente; P0003 distribuidor fuera de
-- prueba/activo o bodega inactiva; P0004 crédito no habilitado, límite
-- excedido o deuda vencida.
create function public.crear_pedido(
  p_distribuidor_id uuid,
  p_items jsonb,
  p_clave_idempotencia uuid,
  p_cliente_id uuid default null,
  p_despacho public.despacho_pedido default 'recojo',
  p_condicion_pago public.condicion_pago default 'contado',
  p_metodo_pago public.metodo_pago default null,
  p_nota text default null
) returns uuid
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  c_max_integer constant bigint := 2147483647;
  v_uid uuid := auth.uid();
  v_cliente uuid;
  v_bodega public.clientes_negocio;
  v_distribuidor public.distribuidores;
  v_pedido uuid;
  v_presentaciones uuid[];
  v_cantidades bigint[];
  v_item record;
  v_producto_actual uuid;
  v_reservado bigint;
  v_unidades bigint;
  v_linea public.pedido_items;
  v_lineas public.pedido_items[] := '{}';
  v_total bigint := 0;
  v_deuda bigint;
  v_hoy date;
  v_numero integer;
begin
  if v_uid is null then
    raise exception 'Se requiere una sesión' using errcode = '42501';
  end if;

  -- 1. Bodega y permiso.
  v_cliente := privado.mi_cliente_en(p_distribuidor_id);
  if v_cliente is not null then
    if p_cliente_id is not null and p_cliente_id <> v_cliente then
      raise exception 'No puede pedir a nombre de otra bodega' using errcode = '42501';
    end if;
  elsif privado.tiene_rol(p_distribuidor_id, '{admin,vendedor}') then
    if p_cliente_id is null then
      raise exception 'Indique la bodega del pedido' using errcode = '22023';
    end if;
    if not exists (
      select 1 from public.clientes_negocio c
      where c.id = p_cliente_id and c.distribuidor_id = p_distribuidor_id
    ) then
      raise exception 'La bodega no pertenece a este distribuidor' using errcode = '42501';
    end if;
    v_cliente := p_cliente_id;
  else
    raise exception 'No puede crear pedidos en este distribuidor' using errcode = '42501';
  end if;

  if p_clave_idempotencia is null or p_despacho is null or p_condicion_pago is null then
    raise exception 'Faltan la clave de idempotencia, el despacho o la condición de pago'
      using errcode = '22023';
  end if;

  -- Primer bloqueo: la bodega.
  select * into v_bodega
  from public.clientes_negocio c
  where c.id = v_cliente and c.distribuidor_id = p_distribuidor_id
  for update;

  if not found or not v_bodega.activo then
    raise exception 'La bodega está inactiva' using errcode = 'P0003';
  end if;

  select * into v_distribuidor
  from public.distribuidores d where d.id = p_distribuidor_id;

  if v_distribuidor.estado not in ('prueba', 'activo') then
    raise exception 'El distribuidor no está recibiendo pedidos' using errcode = 'P0003';
  end if;

  -- 2. Idempotencia: la misma clave de la misma bodega devuelve el pedido
  -- existente, sin revisar los ítems.
  select p.id into v_pedido
  from public.pedidos p
  where p.cliente_id = v_cliente and p.clave_idempotencia = p_clave_idempotencia;

  if v_pedido is not null then
    return v_pedido;
  end if;

  -- 3. Forma de p_items, antes de convertir tipos: arreglo no vacío de
  -- objetos con presentacion_id (texto con forma de uuid) y cantidad (número
  -- entero entre 1 y el máximo de integer).
  if p_items is null or jsonb_typeof(p_items) <> 'array' then
    raise exception 'Los ítems deben ser un arreglo' using errcode = '22023';
  end if;
  if jsonb_array_length(p_items) = 0 then
    raise exception 'El pedido no tiene ítems' using errcode = '22023';
  end if;
  if exists (
    select 1
    from jsonb_array_elements(p_items) as e (item)
    where jsonb_typeof(e.item) <> 'object'
       or jsonb_typeof(e.item -> 'presentacion_id') is distinct from 'string'
       or privado.uuid_o_nulo(e.item ->> 'presentacion_id') is null
       or jsonb_typeof(e.item -> 'cantidad') is distinct from 'number'
       or case
            when (e.item ->> 'cantidad') ~ '^[1-9][0-9]{0,9}$'
            then (e.item ->> 'cantidad')::bigint > c_max_integer
            else true
          end
  ) then
    raise exception 'Ítem inválido: se espera {"presentacion_id": uuid, "cantidad": entero > 0}'
      using errcode = '22023';
  end if;

  -- Consolida los ítems de una misma presentación sumando cantidades.
  select array_agg(c.presentacion_id order by c.presentacion_id),
         array_agg(c.cantidad order by c.presentacion_id)
  into v_presentaciones, v_cantidades
  from (
    select (e.item ->> 'presentacion_id')::uuid as presentacion_id,
           sum((e.item ->> 'cantidad')::bigint)::bigint as cantidad
    from jsonb_array_elements(p_items) as e (item)
    group by 1
  ) c;

  if exists (select 1 from unnest(v_cantidades) as q (cantidad) where q.cantidad > c_max_integer) then
    raise exception 'Cantidad demasiado grande' using errcode = '22023';
  end if;

  -- 4. Segundo bloqueo: los productos involucrados, por id ascendente. Solo
  -- se bloquean productos de este distribuidor.
  perform 1
  from public.productos p
  where p.distribuidor_id = p_distribuidor_id
    and p.id in (
      select pr.producto_id
      from public.presentaciones pr
      where pr.id = any (v_presentaciones)
        and pr.distribuidor_id = p_distribuidor_id)
  order by p.id
  for update;

  -- Con los productos ya bloqueados: cada presentación existe, es de este
  -- distribuidor y está activa, igual que su producto.
  if (select count(*)
      from public.presentaciones pr
      join public.productos p
        on p.id = pr.producto_id and p.distribuidor_id = pr.distribuidor_id
      where pr.id = any (v_presentaciones)
        and pr.distribuidor_id = p_distribuidor_id
        and pr.activo
        and p.activo) <> cardinality(v_presentaciones) then
    raise exception 'Presentación inexistente, inactiva o de otro distribuidor'
      using errcode = 'P0002';
  end if;

  -- 5. Stock y precio por línea. Se recorre por producto para acumular lo
  -- reservado por varias presentaciones del mismo producto.
  for v_item in
    select pr.id as presentacion_id, pr.nombre as nombre_presentacion, pr.factor,
           p.id as producto_id, p.nombre as nombre_producto,
           p.stock_fisico - p.stock_comprometido as disponible,
           i.cantidad::integer as cantidad
    from unnest(v_presentaciones, v_cantidades) as i (presentacion_id, cantidad)
    join public.presentaciones pr on pr.id = i.presentacion_id
    join public.productos p
      on p.id = pr.producto_id and p.distribuidor_id = pr.distribuidor_id
    order by p.id, pr.id
  loop
    if v_item.producto_id is distinct from v_producto_actual then
      v_producto_actual := v_item.producto_id;
      v_reservado := 0;
    end if;

    v_unidades := v_item.cantidad::bigint * v_item.factor;
    if v_reservado + v_unidades > v_item.disponible then
      raise exception 'Stock insuficiente de %', v_item.nombre_producto
        using errcode = 'P0001';
    end if;
    v_reservado := v_reservado + v_unidades;

    v_linea.presentacion_id := v_item.presentacion_id;
    v_linea.producto_id := v_item.producto_id;
    v_linea.nombre_producto := v_item.nombre_producto;
    v_linea.nombre_presentacion := v_item.nombre_presentacion;
    v_linea.factor := v_item.factor;
    v_linea.cantidad := v_item.cantidad;
    v_linea.precio_unitario_centimos :=
      privado.precio_para(v_item.presentacion_id, v_cliente, v_item.cantidad);
    v_linea.subtotal_centimos := v_linea.precio_unitario_centimos * v_item.cantidad;
    v_lineas := v_lineas || v_linea;
    v_total := v_total + v_linea.subtotal_centimos;
  end loop;

  -- 6. Crédito, con la fila de la bodega ya bloqueada. "Hoy" es la fecha en
  -- la zona horaria del distribuidor.
  if p_condicion_pago = 'credito' then
    if not v_bodega.credito_habilitado then
      raise exception 'La bodega no tiene crédito habilitado' using errcode = 'P0004';
    end if;

    v_hoy := (now() at time zone v_distribuidor.zona_horaria)::date;

    if exists (
      select 1 from public.pedidos p
      where p.cliente_id = v_cliente
        and p.condicion_pago = 'credito'
        and p.estado <> 'cancelado'
        and p.saldo_pendiente_centimos > 0
        and p.vence_en < v_hoy
    ) then
      raise exception 'La bodega tiene deuda vencida' using errcode = 'P0004';
    end if;

    select coalesce(sum(p.saldo_pendiente_centimos), 0) into v_deuda
    from public.pedidos p
    where p.cliente_id = v_cliente
      and p.condicion_pago = 'credito'
      and p.estado <> 'cancelado';

    if v_deuda + v_total > v_bodega.limite_credito_centimos then
      raise exception 'El pedido excede el límite de crédito de la bodega'
        using errcode = 'P0004';
    end if;
  end if;

  -- 7. Tercer bloqueo: el contador (se crea si no existe). El update lo
  -- bloquea y asigna el número.
  insert into public.contadores_pedido (distribuidor_id)
  values (p_distribuidor_id)
  on conflict (distribuidor_id) do nothing;

  update public.contadores_pedido
  set ultimo_numero = ultimo_numero + 1
  where distribuidor_id = p_distribuidor_id
  returning ultimo_numero into v_numero;

  insert into public.pedidos
    (distribuidor_id, numero, cliente_id, creado_por, despacho, direccion_entrega,
     nota_cliente, total_centimos, condicion_pago, metodo_pago,
     saldo_pendiente_centimos, clave_idempotencia)
  values
    (p_distribuidor_id, v_numero, v_cliente, v_uid, p_despacho, v_bodega.direccion,
     p_nota, v_total, p_condicion_pago, p_metodo_pago,
     v_total, p_clave_idempotencia)
  returning id into v_pedido;

  insert into public.pedido_items
    (distribuidor_id, pedido_id, presentacion_id, producto_id, nombre_producto,
     nombre_presentacion, factor, cantidad, precio_unitario_centimos, subtotal_centimos)
  select p_distribuidor_id, v_pedido, l.presentacion_id, l.producto_id, l.nombre_producto,
         l.nombre_presentacion, l.factor, l.cantidad, l.precio_unitario_centimos,
         l.subtotal_centimos
  from unnest(v_lineas) as l;

  -- Reserva: sube el comprometido y registra el movimiento, por línea.
  foreach v_linea in array v_lineas loop
    perform privado.aplicar_movimiento_stock(
      v_linea.producto_id, 'reserva', 0, v_linea.cantidad * v_linea.factor, v_pedido, null);
  end loop;

  insert into public.pedido_eventos (distribuidor_id, pedido_id, estado_anterior, estado_nuevo, hecho_por)
  values (p_distribuidor_id, v_pedido, null, 'recibido', v_uid);

  return v_pedido;
end $$;

revoke execute on function
  public.crear_pedido(uuid, jsonb, uuid, uuid, public.despacho_pedido,
                      public.condicion_pago, public.metodo_pago, text)
  from public, anon;

grant execute on function
  public.crear_pedido(uuid, jsonb, uuid, uuid, public.despacho_pedido,
                      public.condicion_pago, public.metodo_pago, text)
  to authenticated;
