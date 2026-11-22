-- Módulo 1: identidad y acceso.
-- Distribuidores (tenant), perfiles, bodegas, membresías, invitaciones,
-- freno de canjes y tokens de notificaciones. Spec: secciones 6.1 y 7.
--
-- Orden: esquema privado, enums, tablas, índices, triggers, funciones
-- auxiliares, permisos, políticas, funciones públicas.

-- ---------------------------------------------------------------------------
-- Esquema privado: funciones auxiliares de seguridad. No se expone en la API.
-- ---------------------------------------------------------------------------
create schema privado;
revoke all on schema privado from public;
grant usage on schema privado to authenticated;

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------
create type public.estado_distribuidor as enum ('prueba', 'activo', 'suspendido', 'cancelado');
create type public.rol_membresia as enum ('admin', 'vendedor', 'repartidor', 'cliente');
create type public.estado_membresia as enum ('activa', 'suspendida');

-- ---------------------------------------------------------------------------
-- Tablas
-- ---------------------------------------------------------------------------
create table public.distribuidores (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  slug text not null unique,
  rubro text,
  documento text,
  telefono text,
  estado public.estado_distribuidor not null default 'prueba',
  moneda text not null default 'PEN' check (length(moneda) = 3),
  zona_horaria text not null default 'America/Lima',
  config_tema jsonb not null default '{}',
  creado_en timestamptz not null default now(),
  actualizado_en timestamptz not null default now()
);

create table public.perfiles (
  id uuid primary key references auth.users (id) on delete cascade,
  nombre text not null default '',
  telefono text,
  es_super_admin boolean not null default false,
  creado_en timestamptz not null default now(),
  actualizado_en timestamptz not null default now()
);

-- Bodega o tienda cliente de un distribuidor.
create table public.clientes_negocio (
  id uuid primary key default gen_random_uuid(),
  distribuidor_id uuid not null references public.distribuidores (id),
  nombre_negocio text not null,
  documento text,
  direccion text,
  referencia text,
  telefono text,
  activo boolean not null default true,
  creado_en timestamptz not null default now(),
  actualizado_en timestamptz not null default now(),
  unique (id, distribuidor_id)
);

-- Vínculo persona–distribuidor. Un solo rol por distribuidor. La bodega es
-- obligatoria para el rol cliente y nula para el resto; la clave foránea
-- compuesta impide apuntar a una bodega de otro distribuidor.
create table public.membresias (
  id uuid primary key default gen_random_uuid(),
  perfil_id uuid not null references public.perfiles (id) on delete cascade,
  distribuidor_id uuid not null references public.distribuidores (id),
  rol public.rol_membresia not null,
  estado public.estado_membresia not null default 'activa',
  cliente_negocio_id uuid,
  creado_en timestamptz not null default now(),
  actualizado_en timestamptz not null default now(),
  unique (perfil_id, distribuidor_id),
  foreign key (cliente_negocio_id, distribuidor_id)
    references public.clientes_negocio (id, distribuidor_id),
  check ((rol = 'cliente') = (cliente_negocio_id is not null))
);

-- Código de un solo uso para vincular una cuenta a un distribuidor.
-- Una invitación cuenta como usada cuando usada_en no es nulo (usada_por
-- puede quedar nulo si se borra la cuenta que la canjeó).
create table public.invitaciones (
  id uuid primary key default gen_random_uuid(),
  distribuidor_id uuid not null references public.distribuidores (id),
  codigo text not null unique,
  rol public.rol_membresia not null,
  cliente_negocio_id uuid,
  creada_por uuid references public.perfiles (id) on delete set null,
  vence_en timestamptz not null,
  usada_por uuid references public.perfiles (id) on delete set null,
  usada_en timestamptz,
  revocada_en timestamptz,
  creado_en timestamptz not null default now(),
  actualizado_en timestamptz not null default now(),
  foreign key (cliente_negocio_id, distribuidor_id)
    references public.clientes_negocio (id, distribuidor_id),
  check ((rol = 'cliente') = (cliente_negocio_id is not null))
);

-- Registro de canjes para frenar a quien intenta adivinar códigos.
create table public.intentos_canje (
  id uuid primary key default gen_random_uuid(),
  perfil_id uuid not null references public.perfiles (id) on delete cascade,
  exitoso boolean not null,
  creado_en timestamptz not null default now()
);

create table public.dispositivos_push (
  id uuid primary key default gen_random_uuid(),
  perfil_id uuid not null references public.perfiles (id) on delete cascade,
  token text not null unique,
  plataforma text not null check (plataforma in ('android', 'ios', 'web')),
  creado_en timestamptz not null default now(),
  actualizado_en timestamptz not null default now()
);

alter table public.distribuidores enable row level security;
alter table public.perfiles enable row level security;
alter table public.clientes_negocio enable row level security;
alter table public.membresias enable row level security;
alter table public.invitaciones enable row level security;
alter table public.intentos_canje enable row level security;
alter table public.dispositivos_push enable row level security;

-- ---------------------------------------------------------------------------
-- Índices: toda clave foránea y las columnas usadas en RLS.
-- membresias (perfil_id, distribuidor_id) ya lo cubre su unique.
-- ---------------------------------------------------------------------------
create index clientes_negocio_distribuidor_idx on public.clientes_negocio (distribuidor_id);
create index membresias_distribuidor_idx on public.membresias (distribuidor_id);
create index membresias_cliente_negocio_idx on public.membresias (cliente_negocio_id, distribuidor_id);
create index invitaciones_distribuidor_idx on public.invitaciones (distribuidor_id);
create index invitaciones_cliente_negocio_idx on public.invitaciones (cliente_negocio_id, distribuidor_id);
create index invitaciones_creada_por_idx on public.invitaciones (creada_por);
create index invitaciones_usada_por_idx on public.invitaciones (usada_por);
create index intentos_canje_perfil_idx on public.intentos_canje (perfil_id, creado_en);
create index dispositivos_push_perfil_idx on public.dispositivos_push (perfil_id);

-- ---------------------------------------------------------------------------
-- Triggers
-- ---------------------------------------------------------------------------
create function privado.tg_actualizado_en() returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.actualizado_en := now();
  return new;
end $$;

create trigger distribuidores_actualizado_en before update on public.distribuidores
  for each row execute function privado.tg_actualizado_en();
create trigger perfiles_actualizado_en before update on public.perfiles
  for each row execute function privado.tg_actualizado_en();
create trigger clientes_negocio_actualizado_en before update on public.clientes_negocio
  for each row execute function privado.tg_actualizado_en();
create trigger membresias_actualizado_en before update on public.membresias
  for each row execute function privado.tg_actualizado_en();
create trigger invitaciones_actualizado_en before update on public.invitaciones
  for each row execute function privado.tg_actualizado_en();
create trigger dispositivos_push_actualizado_en before update on public.dispositivos_push
  for each row execute function privado.tg_actualizado_en();

-- Crea el perfil al registrarse la cuenta en auth.users.
create function privado.tg_crear_perfil() returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.perfiles (id, nombre, telefono)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'nombre', ''), new.phone);
  return new;
end $$;

create trigger crear_perfil after insert on auth.users
  for each row execute function privado.tg_crear_perfil();

-- ---------------------------------------------------------------------------
-- Funciones auxiliares de seguridad
-- Una membresía cuenta solo si está activa y, si es de cliente, su bodega
-- está activa.
-- ---------------------------------------------------------------------------
create function privado.es_super_admin() returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    (select p.es_super_admin from public.perfiles p where p.id = auth.uid()),
    false)
$$;

create function privado.es_miembro(p_distribuidor uuid) returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.membresias m
    left join public.clientes_negocio c
      on c.id = m.cliente_negocio_id and c.distribuidor_id = m.distribuidor_id
    where m.perfil_id = auth.uid()
      and m.distribuidor_id = p_distribuidor
      and m.estado = 'activa'
      and (m.rol <> 'cliente' or c.activo)
  )
$$;

create function privado.tiene_rol(p_distribuidor uuid, p_roles public.rol_membresia[])
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.membresias m
    left join public.clientes_negocio c
      on c.id = m.cliente_negocio_id and c.distribuidor_id = m.distribuidor_id
    where m.perfil_id = auth.uid()
      and m.distribuidor_id = p_distribuidor
      and m.estado = 'activa'
      and m.rol = any (p_roles)
      and (m.rol <> 'cliente' or c.activo)
  )
$$;

-- Bodega de quien llama en ese distribuidor; nulo si no es cliente activo.
create function privado.mi_cliente_en(p_distribuidor uuid) returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select m.cliente_negocio_id
  from public.membresias m
  join public.clientes_negocio c
    on c.id = m.cliente_negocio_id and c.distribuidor_id = m.distribuidor_id
  where m.perfil_id = auth.uid()
    and m.distribuidor_id = p_distribuidor
    and m.estado = 'activa'
    and m.rol = 'cliente'
    and c.activo
$$;

-- true si quien llama es personal activo (admin, vendedor o repartidor) de
-- algún distribuidor donde p_perfil tiene membresía.
create function privado.comparte_distribuidor_como_personal(p_perfil uuid) returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.membresias yo
    join public.membresias otro on otro.distribuidor_id = yo.distribuidor_id
    where yo.perfil_id = auth.uid()
      and yo.estado = 'activa'
      and yo.rol in ('admin', 'vendedor', 'repartidor')
      and otro.perfil_id = p_perfil
  )
$$;

-- Cuenta los admin activos de un distribuidor, sin contar una membresía.
-- Uso interno de las funciones de membresía.
create function privado.otros_admin_activos(p_distribuidor uuid, p_excluir uuid)
returns bigint
language sql
stable
set search_path = ''
as $$
  select count(*)
  from public.membresias m
  where m.distribuidor_id = p_distribuidor
    and m.rol = 'admin'
    and m.estado = 'activa'
    and m.id <> p_excluir
$$;

-- Código de 8 caracteres sin ambiguos (sin 0, O, 1, I, L). Usa los bytes
-- aleatorios de gen_random_uuid(); salta los bytes 6 y 8 (bits fijos de
-- versión y variante) y descarta valores >= 240 para no sesgar el módulo 30.
create function privado.generar_codigo_invitacion() returns text
language plpgsql
volatile
set search_path = ''
as $$
declare
  c_alfabeto constant text := 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  v_bytes bytea;
  v_byte integer;
  v_codigo text := '';
  i integer;
begin
  while length(v_codigo) < 8 loop
    v_bytes := uuid_send(gen_random_uuid());
    for i in 0..15 loop
      continue when i in (6, 8);
      v_byte := get_byte(v_bytes, i);
      continue when v_byte >= 240;
      v_codigo := v_codigo || substr(c_alfabeto, v_byte % 30 + 1, 1);
      exit when length(v_codigo) = 8;
    end loop;
  end loop;
  return v_codigo;
end $$;

-- ---------------------------------------------------------------------------
-- Permisos de tablas (explícitos, sin depender de los privilegios por defecto)
-- ---------------------------------------------------------------------------
revoke all on public.distribuidores, public.perfiles, public.clientes_negocio,
  public.membresias, public.invitaciones, public.intentos_canje,
  public.dispositivos_push
  from anon, authenticated;

grant select on public.distribuidores to authenticated;
grant update (nombre, telefono, config_tema) on public.distribuidores to authenticated;

grant select on public.perfiles to authenticated;
grant update (nombre) on public.perfiles to authenticated;

grant select, insert, update on public.clientes_negocio to authenticated;

grant select on public.membresias to authenticated;
grant select on public.invitaciones to authenticated;

-- intentos_canje: sin ningún grant.

-- El registro y la reasignación van por registrar_dispositivo().
grant select, delete on public.dispositivos_push to authenticated;

-- ---------------------------------------------------------------------------
-- Permisos de funciones: execute revocado a public y anon en todas.
-- ---------------------------------------------------------------------------
revoke execute on function
  privado.tg_actualizado_en(),
  privado.tg_crear_perfil(),
  privado.es_super_admin(),
  privado.es_miembro(uuid),
  privado.tiene_rol(uuid, public.rol_membresia[]),
  privado.mi_cliente_en(uuid),
  privado.comparte_distribuidor_como_personal(uuid),
  privado.otros_admin_activos(uuid, uuid),
  privado.generar_codigo_invitacion()
  from public, anon;

-- Auxiliares usadas en políticas RLS.
grant execute on function
  privado.es_super_admin(),
  privado.es_miembro(uuid),
  privado.tiene_rol(uuid, public.rol_membresia[]),
  privado.mi_cliente_en(uuid),
  privado.comparte_distribuidor_como_personal(uuid)
  to authenticated;

-- ---------------------------------------------------------------------------
-- Políticas
-- ---------------------------------------------------------------------------
create policy distribuidores_select on public.distribuidores
  for select to authenticated
  using ((select privado.es_super_admin()) or (select privado.es_miembro(id)));

create policy distribuidores_update on public.distribuidores
  for update to authenticated
  using ((select privado.tiene_rol(id, '{admin}')))
  with check ((select privado.tiene_rol(id, '{admin}')));

create policy perfiles_select on public.perfiles
  for select to authenticated
  using (
    id = (select auth.uid())
    or (select privado.es_super_admin())
    or (select privado.comparte_distribuidor_como_personal(id))
  );

create policy perfiles_update on public.perfiles
  for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

create policy clientes_negocio_select on public.clientes_negocio
  for select to authenticated
  using (
    (select privado.es_super_admin())
    or (select privado.tiene_rol(distribuidor_id, '{admin,vendedor}'))
    or id = (select privado.mi_cliente_en(distribuidor_id))
  );

create policy clientes_negocio_insert on public.clientes_negocio
  for insert to authenticated
  with check ((select privado.tiene_rol(distribuidor_id, '{admin,vendedor}')));

create policy clientes_negocio_update on public.clientes_negocio
  for update to authenticated
  using ((select privado.tiene_rol(distribuidor_id, '{admin,vendedor}')))
  with check ((select privado.tiene_rol(distribuidor_id, '{admin,vendedor}')));

create policy membresias_select on public.membresias
  for select to authenticated
  using (
    perfil_id = (select auth.uid())
    or (select privado.es_super_admin())
    or (select privado.tiene_rol(distribuidor_id, '{admin,vendedor}'))
  );

create policy invitaciones_select on public.invitaciones
  for select to authenticated
  using (
    (select privado.es_super_admin())
    or (select privado.tiene_rol(distribuidor_id, '{admin}'))
    or (rol = 'cliente' and (select privado.tiene_rol(distribuidor_id, '{vendedor}')))
  );

create policy dispositivos_push_select on public.dispositivos_push
  for select to authenticated
  using (perfil_id = (select auth.uid()));

create policy dispositivos_push_delete on public.dispositivos_push
  for delete to authenticated
  using (perfil_id = (select auth.uid()));

-- ---------------------------------------------------------------------------
-- Funciones públicas
-- ---------------------------------------------------------------------------

-- Crea una invitación con código generado. Admin: cualquier rol de su
-- distribuidor. Vendedor: solo rol cliente. Super Admin: cualquier
-- distribuidor.
create function public.crear_invitacion(
  p_distribuidor_id uuid,
  p_rol public.rol_membresia,
  p_cliente_negocio_id uuid default null,
  p_dias_vigencia integer default 7
) returns public.invitaciones
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_invitacion public.invitaciones;
  v_intento integer := 0;
begin
  if v_uid is null then
    raise exception 'Se requiere una sesión' using errcode = '42501';
  end if;

  if not (
    privado.es_super_admin()
    or privado.tiene_rol(p_distribuidor_id, '{admin}')
    or (p_rol = 'cliente' and privado.tiene_rol(p_distribuidor_id, '{vendedor}'))
  ) then
    raise exception 'No puede crear esta invitación' using errcode = '42501';
  end if;

  if p_rol is null or p_dias_vigencia is null or p_dias_vigencia < 1 then
    raise exception 'Parámetros inválidos' using errcode = '22023';
  end if;

  if (p_rol = 'cliente') <> (p_cliente_negocio_id is not null) then
    raise exception 'La bodega es obligatoria para el rol cliente y no aplica a otros roles'
      using errcode = '22023';
  end if;

  if p_cliente_negocio_id is not null and not exists (
    select 1 from public.clientes_negocio c
    where c.id = p_cliente_negocio_id and c.distribuidor_id = p_distribuidor_id
  ) then
    raise exception 'La bodega no pertenece a este distribuidor' using errcode = '42501';
  end if;

  -- Reintenta si el código generado ya existe (muy improbable).
  loop
    v_intento := v_intento + 1;
    begin
      insert into public.invitaciones
        (distribuidor_id, codigo, rol, cliente_negocio_id, creada_por, vence_en)
      values
        (p_distribuidor_id, privado.generar_codigo_invitacion(), p_rol,
         p_cliente_negocio_id, v_uid, now() + make_interval(days => p_dias_vigencia))
      returning * into v_invitacion;
      return v_invitacion;
    exception when unique_violation then
      if v_intento >= 5 then
        raise;
      end if;
    end;
  end loop;
end $$;

-- Revoca una invitación sin usar. Mismos permisos que crear_invitacion.
create function public.revocar_invitacion(p_invitacion_id uuid) returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_inv public.invitaciones;
begin
  if v_uid is null then
    raise exception 'Se requiere una sesión' using errcode = '42501';
  end if;

  select * into v_inv from public.invitaciones where id = p_invitacion_id for update;

  if not found or not (
    privado.es_super_admin()
    or privado.tiene_rol(v_inv.distribuidor_id, '{admin}')
    or (v_inv.rol = 'cliente' and privado.tiene_rol(v_inv.distribuidor_id, '{vendedor}'))
  ) then
    raise exception 'No puede revocar esta invitación' using errcode = '42501';
  end if;

  if v_inv.usada_en is not null then
    raise exception 'La invitación ya fue usada' using errcode = 'P0006';
  end if;

  if v_inv.revocada_en is null then
    update public.invitaciones set revocada_en = now() where id = p_invitacion_id;
  end if;
end $$;

-- Canjea un código y crea la membresía. Si el código no sirve devuelve null
-- (no lanza error: así el intento queda registrado y el freno funciona).
-- Solo lanza 42501 sin sesión y P0005 con 5 fallos en 15 minutos.
create function public.canjear_invitacion(p_codigo text) returns uuid
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_inv public.invitaciones;
  v_membresia uuid;
begin
  if v_uid is null then
    raise exception 'Se requiere una sesión' using errcode = '42501';
  end if;

  -- Serializa los canjes de una misma cuenta: sin esto, varias llamadas en
  -- paralelo leerían el conteo antes de que ninguna registre su intento y
  -- todas pasarían el freno. Clave (1, hash del uid): el 1 reserva el espacio
  -- de claves de este freno frente a otros usos de bloqueos consultivos.
  perform pg_advisory_xact_lock(1, hashtext(v_uid::text));

  if (select count(*) from public.intentos_canje i
      where i.perfil_id = v_uid
        and not i.exitoso
        and i.creado_en > now() - interval '15 minutes') >= 5 then
    raise exception 'Demasiados intentos de canje; espere unos minutos'
      using errcode = 'P0005';
  end if;

  select * into v_inv
  from public.invitaciones
  where codigo = upper(trim(p_codigo))
  for update;

  if found
     and v_inv.usada_en is null
     and v_inv.revocada_en is null
     and v_inv.vence_en > now()
     and (v_inv.rol <> 'cliente' or exists (
       select 1 from public.clientes_negocio c
       where c.id = v_inv.cliente_negocio_id
         and c.distribuidor_id = v_inv.distribuidor_id
         and c.activo))
  then
    -- Si ya tiene membresía en el distribuidor (activa o suspendida), no se crea.
    insert into public.membresias (perfil_id, distribuidor_id, rol, cliente_negocio_id)
    values (v_uid, v_inv.distribuidor_id, v_inv.rol, v_inv.cliente_negocio_id)
    on conflict (perfil_id, distribuidor_id) do nothing
    returning id into v_membresia;
  end if;

  if v_membresia is not null then
    update public.invitaciones
    set usada_por = v_uid, usada_en = now()
    where id = v_inv.id;
  end if;

  insert into public.intentos_canje (perfil_id, exitoso)
  values (v_uid, v_membresia is not null);

  return v_membresia;
end $$;

-- Suspende o reactiva una membresía. Solo admin del distribuidor.
create function public.cambiar_estado_membresia(
  p_membresia_id uuid,
  p_estado public.estado_membresia
) returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_distribuidor uuid;
  v_m public.membresias;
begin
  if v_uid is null then
    raise exception 'Se requiere una sesión' using errcode = '42501';
  end if;

  select m.distribuidor_id into v_distribuidor
  from public.membresias m where m.id = p_membresia_id;

  if v_distribuidor is null or not privado.tiene_rol(v_distribuidor, '{admin}') then
    raise exception 'No puede cambiar esta membresía' using errcode = '42501';
  end if;

  if p_estado is null then
    raise exception 'Estado inválido' using errcode = '22023';
  end if;

  -- Serializa los cambios de membresía de un distribuidor (regla del último admin).
  perform 1 from public.distribuidores d where d.id = v_distribuidor for update;
  select * into v_m from public.membresias m where m.id = p_membresia_id for update;

  -- Revalida con las filas ya bloqueadas: quien llama pudo perder el rol de
  -- admin (o la membresía desaparecer) mientras esperaba el bloqueo.
  if not found or not privado.tiene_rol(v_distribuidor, '{admin}') then
    raise exception 'No puede cambiar esta membresía' using errcode = '42501';
  end if;

  if v_m.rol = 'admin' and v_m.estado = 'activa' and p_estado <> 'activa'
     and privado.otros_admin_activos(v_distribuidor, v_m.id) = 0 then
    raise exception 'El distribuidor se quedaría sin ningún admin activo'
      using errcode = 'P0006';
  end if;

  update public.membresias set estado = p_estado where id = p_membresia_id;
end $$;

-- Cambia el rol de una membresía de personal. Solo admin del distribuidor y
-- solo entre admin, vendedor y repartidor.
create function public.cambiar_rol_membresia(
  p_membresia_id uuid,
  p_rol public.rol_membresia
) returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_distribuidor uuid;
  v_m public.membresias;
begin
  if v_uid is null then
    raise exception 'Se requiere una sesión' using errcode = '42501';
  end if;

  select m.distribuidor_id into v_distribuidor
  from public.membresias m where m.id = p_membresia_id;

  if v_distribuidor is null or not privado.tiene_rol(v_distribuidor, '{admin}') then
    raise exception 'No puede cambiar esta membresía' using errcode = '42501';
  end if;

  perform 1 from public.distribuidores d where d.id = v_distribuidor for update;
  select * into v_m from public.membresias m where m.id = p_membresia_id for update;

  -- Revalida con las filas ya bloqueadas: quien llama pudo perder el rol de
  -- admin (o la membresía desaparecer) mientras esperaba el bloqueo.
  if not found or not privado.tiene_rol(v_distribuidor, '{admin}') then
    raise exception 'No puede cambiar esta membresía' using errcode = '42501';
  end if;

  if p_rol is null
     or p_rol not in ('admin', 'vendedor', 'repartidor')
     or v_m.rol not in ('admin', 'vendedor', 'repartidor') then
    raise exception 'Solo se cambia el rol entre admin, vendedor y repartidor'
      using errcode = '22023';
  end if;

  if v_m.rol = 'admin' and v_m.estado = 'activa' and p_rol <> 'admin'
     and privado.otros_admin_activos(v_distribuidor, v_m.id) = 0 then
    raise exception 'El distribuidor se quedaría sin ningún admin activo'
      using errcode = 'P0006';
  end if;

  update public.membresias set rol = p_rol where id = p_membresia_id;
end $$;

-- Registra el token de notificaciones del dispositivo para quien llama. Si el
-- token ya existía (otra cuenta en el mismo dispositivo), se reasigna.
create function public.registrar_dispositivo(p_token text, p_plataforma text) returns void
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

  if coalesce(trim(p_token), '') = '' or p_plataforma is null
     or p_plataforma not in ('android', 'ios', 'web') then
    raise exception 'Token o plataforma inválidos' using errcode = '22023';
  end if;

  insert into public.dispositivos_push (perfil_id, token, plataforma)
  values (v_uid, trim(p_token), p_plataforma)
  on conflict (token) do update
    set perfil_id = excluded.perfil_id,
        plataforma = excluded.plataforma;
end $$;

revoke execute on function
  public.crear_invitacion(uuid, public.rol_membresia, uuid, integer),
  public.revocar_invitacion(uuid),
  public.canjear_invitacion(text),
  public.cambiar_estado_membresia(uuid, public.estado_membresia),
  public.cambiar_rol_membresia(uuid, public.rol_membresia),
  public.registrar_dispositivo(text, text)
  from public, anon;

grant execute on function
  public.crear_invitacion(uuid, public.rol_membresia, uuid, integer),
  public.revocar_invitacion(uuid),
  public.canjear_invitacion(text),
  public.cambiar_estado_membresia(uuid, public.estado_membresia),
  public.cambiar_rol_membresia(uuid, public.rol_membresia),
  public.registrar_dispositivo(text, text)
  to authenticated;
