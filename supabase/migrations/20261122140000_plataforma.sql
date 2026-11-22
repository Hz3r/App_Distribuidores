-- Módulo 5: plataforma.
-- Planes, suscripciones de los distribuidores y sus pagos, y las funciones
-- del Super Admin para dar de alta un distribuidor, cambiar su estado
-- (suspender, reactivar) y registrar el pago de un periodo. Todo lo de este
-- módulo lo escribe solo el Super Admin; el admin del distribuidor lee su
-- suscripción y sus pagos. Spec: secciones 6.5 y 7.
--
-- Orden: enums, tablas, índices, triggers, permisos, políticas, funciones
-- públicas.

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------
create type public.estado_suscripcion as enum ('prueba', 'activa', 'vencida', 'cancelada');

-- ---------------------------------------------------------------------------
-- Tablas
-- ---------------------------------------------------------------------------

-- Oferta comercial de la plataforma. No es una tabla de un distribuidor: no
-- lleva distribuidor_id. limites guarda topes del plan (por ejemplo
-- {"max_clientes": 50}); en este proyecto solo se guardan, no se hacen
-- cumplir.
create table public.planes (
  id uuid primary key default gen_random_uuid(),
  codigo text not null unique check (btrim(codigo) <> ''),
  nombre text not null check (btrim(nombre) <> ''),
  precio_mensual_centimos bigint not null check (precio_mensual_centimos >= 0),
  moneda text not null default 'PEN' check (length(moneda) = 3),
  limites jsonb not null default '{}' check (jsonb_typeof(limites) = 'object'),
  activo boolean not null default true,
  creado_en timestamptz not null default now(),
  actualizado_en timestamptz not null default now()
);

-- Plan de un distribuidor en un periodo. A lo sumo una vigente (prueba o
-- activa) por distribuidor: índice único parcial más abajo. proveedor_pago y
-- referencia_externa quedan nulos por ahora; están para conectar una
-- pasarela sin cambiar la tabla.
create table public.suscripciones (
  id uuid primary key default gen_random_uuid(),
  distribuidor_id uuid not null references public.distribuidores (id),
  plan_id uuid not null references public.planes (id),
  estado public.estado_suscripcion not null,
  periodo_inicio date not null,
  periodo_fin date not null,
  proveedor_pago text,
  referencia_externa text,
  creado_en timestamptz not null default now(),
  actualizado_en timestamptz not null default now(),
  unique (id, distribuidor_id),
  check (periodo_fin >= periodo_inicio)
);

-- Pago de un periodo de una suscripción. Nunca se edita ni se borra. La
-- clave hacia la suscripción es compuesta con distribuidor_id: imposible
-- cruzar distribuidores.
create table public.pagos_suscripcion (
  id uuid primary key default gen_random_uuid(),
  distribuidor_id uuid not null references public.distribuidores (id),
  suscripcion_id uuid not null,
  monto_centimos bigint not null check (monto_centimos > 0),
  metodo text not null check (btrim(metodo) <> ''),
  periodo_inicio date not null,
  periodo_fin date not null,
  registrado_por uuid references public.perfiles (id) on delete set null,
  referencia_externa text,
  nota text,
  creado_en timestamptz not null default now(),
  foreign key (suscripcion_id, distribuidor_id)
    references public.suscripciones (id, distribuidor_id),
  check (periodo_fin >= periodo_inicio)
);

alter table public.planes enable row level security;
alter table public.suscripciones enable row level security;
alter table public.pagos_suscripcion enable row level security;

-- ---------------------------------------------------------------------------
-- Índices: toda clave foránea y las columnas usadas en RLS.
-- ---------------------------------------------------------------------------
create unique index suscripciones_vigente_unica on public.suscripciones (distribuidor_id)
  where estado in ('prueba', 'activa');
create index suscripciones_distribuidor_idx on public.suscripciones (distribuidor_id);
create index suscripciones_plan_idx on public.suscripciones (plan_id);
create index pagos_suscripcion_distribuidor_idx on public.pagos_suscripcion (distribuidor_id);
create index pagos_suscripcion_suscripcion_idx
  on public.pagos_suscripcion (suscripcion_id, distribuidor_id);
create index pagos_suscripcion_registrado_por_idx on public.pagos_suscripcion (registrado_por);

-- ---------------------------------------------------------------------------
-- Triggers
-- ---------------------------------------------------------------------------
create trigger planes_actualizado_en before update on public.planes
  for each row execute function privado.tg_actualizado_en();
create trigger suscripciones_actualizado_en before update on public.suscripciones
  for each row execute function privado.tg_actualizado_en();

-- ---------------------------------------------------------------------------
-- Permisos de tablas (explícitos, sin depender de los privilegios por defecto)
-- planes: todos leen; insert y update solo el Super Admin (por política).
-- suscripciones y pagos_suscripcion: solo lectura; se escriben únicamente
-- con las funciones de abajo.
-- ---------------------------------------------------------------------------
revoke all on public.planes, public.suscripciones, public.pagos_suscripcion
  from anon, authenticated;

grant select on public.planes to authenticated;
grant insert (id, codigo, nombre, precio_mensual_centimos, moneda, limites, activo)
  on public.planes to authenticated;
grant update (codigo, nombre, precio_mensual_centimos, moneda, limites, activo)
  on public.planes to authenticated;

grant select on public.suscripciones to authenticated;
grant select on public.pagos_suscripcion to authenticated;

-- ---------------------------------------------------------------------------
-- Políticas
-- ---------------------------------------------------------------------------
create policy planes_select on public.planes
  for select to authenticated
  using (true);

create policy planes_insert on public.planes
  for insert to authenticated
  with check ((select privado.es_super_admin()));

create policy planes_update on public.planes
  for update to authenticated
  using ((select privado.es_super_admin()))
  with check ((select privado.es_super_admin()));

create policy suscripciones_select on public.suscripciones
  for select to authenticated
  using (
    (select privado.es_super_admin())
    or (select privado.tiene_rol(distribuidor_id, '{admin}'))
  );

create policy pagos_suscripcion_select on public.pagos_suscripcion
  for select to authenticated
  using (
    (select privado.es_super_admin())
    or (select privado.tiene_rol(distribuidor_id, '{admin}'))
  );

-- ---------------------------------------------------------------------------
-- Funciones públicas (solo Super Admin)
-- ---------------------------------------------------------------------------

-- Da de alta un distribuidor (spec 6.5): el distribuidor en estado prueba,
-- su suscripción en prueba por 30 días desde hoy (fecha en la zona horaria
-- del distribuidor) y una invitación de rol admin vigente 7 días, creada a
-- nombre del Super Admin. Quien canjea el código es el primer admin.
-- Devuelve {"distribuidor_id": "<uuid>", "invitacion_codigo": "<código>"}.
--
-- El slug se guarda sin espacios y en minúsculas, y debe tener la forma
-- ^[a-z0-9]+(-[a-z0-9]+)*$ (palabras de a-z y 0-9 unidas por un guion).
--
-- Errores: 42501 sin sesión o sin ser Super Admin; 22023 nombre vacío, slug
-- vacío o sin forma de slug, o plan inexistente o inactivo; 23505 slug
-- repetido.
create function public.crear_distribuidor(
  p_nombre text,
  p_slug text,
  p_rubro text,
  p_plan_codigo text,
  p_documento text default null,
  p_telefono text default null
) returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_plan uuid;
  v_slug text := lower(btrim(p_slug));
  v_distribuidor public.distribuidores;
  v_hoy date;
  v_invitacion public.invitaciones;
begin
  if v_uid is null then
    raise exception 'Se requiere una sesión' using errcode = '42501';
  end if;

  if not privado.es_super_admin() then
    raise exception 'Solo el Super Admin crea distribuidores' using errcode = '42501';
  end if;

  if nullif(btrim(p_nombre), '') is null or nullif(v_slug, '') is null then
    raise exception 'Indique el nombre y el slug' using errcode = '22023';
  end if;

  if v_slug !~ '^[a-z0-9]+(-[a-z0-9]+)*$' then
    raise exception 'El slug solo admite a-z, 0-9 y guiones entre palabras'
      using errcode = '22023';
  end if;

  select pl.id into v_plan
  from public.planes pl
  where pl.codigo = p_plan_codigo and pl.activo;

  if v_plan is null then
    raise exception 'Plan inexistente o inactivo' using errcode = '22023';
  end if;

  -- Un slug repetido falla aquí con 23505 (unique de distribuidores.slug).
  insert into public.distribuidores (nombre, slug, rubro, documento, telefono, estado)
  values (btrim(p_nombre), v_slug, p_rubro, p_documento, p_telefono, 'prueba')
  returning * into v_distribuidor;

  v_hoy := (now() at time zone v_distribuidor.zona_horaria)::date;

  insert into public.suscripciones
    (distribuidor_id, plan_id, estado, periodo_inicio, periodo_fin)
  values
    (v_distribuidor.id, v_plan, 'prueba', v_hoy, v_hoy + 30);

  -- crear_invitacion revalida que quien llama sea Super Admin, genera el
  -- código, reintenta si choca y fija creada_por y la vigencia de 7 días.
  v_invitacion := public.crear_invitacion(v_distribuidor.id, 'admin');

  return jsonb_build_object(
    'distribuidor_id', v_distribuidor.id,
    'invitacion_codigo', v_invitacion.codigo);
end $$;

-- Cambia el estado de un distribuidor (spec 6.5): suspender, reactivar,
-- cancelar. Es la única vía, porque distribuidores.estado no se puede editar
-- desde la API. Con el distribuidor suspendido, crear_pedido rechaza pedidos
-- nuevos (P0003); lo demás sigue igual.
--
-- Errores: 42501 sin sesión o sin ser Super Admin; 22023 estado nulo; P0002
-- distribuidor inexistente.
create function public.cambiar_estado_distribuidor(
  p_distribuidor_id uuid,
  p_estado public.estado_distribuidor
) returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'Se requiere una sesión' using errcode = '42501';
  end if;

  if not privado.es_super_admin() then
    raise exception 'Solo el Super Admin cambia el estado de un distribuidor'
      using errcode = '42501';
  end if;

  if p_estado is null then
    raise exception 'Estado inválido' using errcode = '22023';
  end if;

  update public.distribuidores set estado = p_estado where id = p_distribuidor_id;

  if not found then
    raise exception 'Distribuidor inexistente' using errcode = 'P0002';
  end if;
end $$;

-- Registra el pago de un periodo de una suscripción y la deja activa con ese
-- periodo (también si estaba vencida). Bloquea la suscripción para que dos
-- pagos simultáneos no se pisen. Una suscripción cancelada no se reactiva
-- con un pago, y si el distribuidor ya tiene otra suscripción vigente no se
-- activa una segunda: las dos son P0006 y no queda nada registrado. El
-- índice único parcial suscripciones_vigente_unica sigue de resguardo.
-- No cambia distribuidores.estado: eso va por cambiar_estado_distribuidor.
--
-- Errores: 42501 sin sesión o sin ser Super Admin; P0002 suscripción
-- inexistente; 22023 monto nulo o menor o igual a cero, método vacío, o
-- periodo nulo o invertido; P0006 suscripción cancelada o distribuidor con
-- otra suscripción vigente.
create function public.registrar_pago_suscripcion(
  p_suscripcion_id uuid,
  p_monto_centimos bigint,
  p_metodo text,
  p_periodo_inicio date,
  p_periodo_fin date,
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
  v_suscripcion public.suscripciones;
  v_pago uuid;
begin
  if v_uid is null then
    raise exception 'Se requiere una sesión' using errcode = '42501';
  end if;

  if not privado.es_super_admin() then
    raise exception 'Solo el Super Admin registra pagos de suscripción'
      using errcode = '42501';
  end if;

  if p_monto_centimos is null or p_monto_centimos <= 0 then
    raise exception 'El monto debe ser mayor a cero' using errcode = '22023';
  end if;

  if nullif(btrim(p_metodo), '') is null then
    raise exception 'Indique el método de pago' using errcode = '22023';
  end if;

  if p_periodo_inicio is null or p_periodo_fin is null or p_periodo_fin < p_periodo_inicio then
    raise exception 'Periodo inválido' using errcode = '22023';
  end if;

  select * into v_suscripcion
  from public.suscripciones s
  where s.id = p_suscripcion_id
  for update;

  if not found then
    raise exception 'Suscripción inexistente' using errcode = 'P0002';
  end if;

  if v_suscripcion.estado = 'cancelada' then
    raise exception 'La suscripción está cancelada' using errcode = 'P0006';
  end if;

  if exists (
    select 1 from public.suscripciones s
    where s.distribuidor_id = v_suscripcion.distribuidor_id
      and s.id <> v_suscripcion.id
      and s.estado in ('prueba', 'activa')
  ) then
    raise exception 'El distribuidor ya tiene otra suscripción vigente' using errcode = 'P0006';
  end if;

  insert into public.pagos_suscripcion
    (distribuidor_id, suscripcion_id, monto_centimos, metodo, periodo_inicio, periodo_fin,
     registrado_por, referencia_externa, nota)
  values
    (v_suscripcion.distribuidor_id, v_suscripcion.id, p_monto_centimos, btrim(p_metodo),
     p_periodo_inicio, p_periodo_fin, v_uid, p_referencia, p_nota)
  returning id into v_pago;

  update public.suscripciones
  set estado = 'activa',
      periodo_inicio = p_periodo_inicio,
      periodo_fin = p_periodo_fin
  where id = v_suscripcion.id;

  return v_pago;
end $$;

revoke execute on function
  public.crear_distribuidor(text, text, text, text, text, text),
  public.cambiar_estado_distribuidor(uuid, public.estado_distribuidor),
  public.registrar_pago_suscripcion(uuid, bigint, text, date, date, text, text)
  from public, anon;

grant execute on function
  public.crear_distribuidor(text, text, text, text, text, text),
  public.cambiar_estado_distribuidor(uuid, public.estado_distribuidor),
  public.registrar_pago_suscripcion(uuid, bigint, text, date, date, text, text)
  to authenticated;
