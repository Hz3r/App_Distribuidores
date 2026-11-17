-- =============================================================================
-- BORRADOR (pendiente de revisión conjunta, ver docs/contrato.md).
-- NO aplicar al proyecto remoto (db push) hasta que ambos socios lo aprueben.
-- Multi-tenant: toda tabla de negocio lleva distribuidor_id y RLS activo.
-- Montos en céntimos (enteros).
-- =============================================================================

-- ---------- Tipos ----------
create type rol_usuario as enum ('admin', 'cliente', 'repartidor');
create type tipo_presentacion as enum ('botella', 'six_pack', 'caja');
create type estado_pedido as enum (
  'recibido', 'confirmado', 'en_camino', 'listo_recojo', 'entregado', 'cancelado'
);
create type despacho_pedido as enum ('recojo', 'reparto');

-- ---------- Tablas ----------
create table distribuidores (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  -- ConfigTema: { nombre, logo_url, color_primario, color_secundario }
  config_tema jsonb not null default '{}'::jsonb,
  creado_en timestamptz not null default now()
);

-- Perfil ligado a auth.users. El rol vive aquí y en app_metadata (ver contrato).
create table usuarios (
  id uuid primary key references auth.users (id) on delete cascade,
  distribuidor_id uuid not null references distribuidores (id) on delete cascade,
  rol rol_usuario not null,
  nombre text not null,
  telefono text,
  creado_en timestamptz not null default now()
);

create table clientes_negocio (
  id uuid primary key default gen_random_uuid(),
  distribuidor_id uuid not null references distribuidores (id) on delete cascade,
  usuario_id uuid references usuarios (id) on delete set null,
  nombre_negocio text not null,
  direccion text,
  creado_en timestamptz not null default now()
);

create table categorias (
  id uuid primary key default gen_random_uuid(),
  distribuidor_id uuid not null references distribuidores (id) on delete cascade,
  nombre text not null,
  orden integer not null default 0
);

create table productos (
  id uuid primary key default gen_random_uuid(),
  distribuidor_id uuid not null references distribuidores (id) on delete cascade,
  categoria_id uuid not null references categorias (id) on delete restrict,
  nombre text not null,
  descripcion text,
  imagen_url text,
  activo boolean not null default true
);

-- distribuidor_id duplicado aquí a propósito: permite RLS simple y sin joins.
create table presentaciones (
  id uuid primary key default gen_random_uuid(),
  distribuidor_id uuid not null references distribuidores (id) on delete cascade,
  producto_id uuid not null references productos (id) on delete cascade,
  tipo tipo_presentacion not null,
  nombre text not null,
  precio_base_centimos integer not null check (precio_base_centimos >= 0),
  stock integer not null default 0 check (stock >= 0),
  unidades_por_presentacion integer not null default 1 check (unidades_por_presentacion > 0)
);

create table precios_volumen (
  id uuid primary key default gen_random_uuid(),
  distribuidor_id uuid not null references distribuidores (id) on delete cascade,
  presentacion_id uuid not null references presentaciones (id) on delete cascade,
  cantidad_minima integer not null check (cantidad_minima > 0),
  precio_centimos integer not null check (precio_centimos >= 0),
  unique (presentacion_id, cantidad_minima)
);

create table pedidos (
  id uuid primary key default gen_random_uuid(),
  distribuidor_id uuid not null references distribuidores (id) on delete cascade,
  cliente_id uuid not null references clientes_negocio (id) on delete restrict,
  repartidor_id uuid references usuarios (id) on delete set null,
  estado estado_pedido not null default 'recibido',
  despacho despacho_pedido not null default 'recojo',
  total_centimos integer not null default 0 check (total_centimos >= 0),
  creado_en timestamptz not null default now()
);

create table pedido_items (
  id uuid primary key default gen_random_uuid(),
  distribuidor_id uuid not null references distribuidores (id) on delete cascade,
  pedido_id uuid not null references pedidos (id) on delete cascade,
  presentacion_id uuid not null references presentaciones (id) on delete restrict,
  cantidad integer not null check (cantidad > 0),
  precio_unitario_centimos integer not null check (precio_unitario_centimos >= 0)
);

create index on usuarios (distribuidor_id);
create index on clientes_negocio (distribuidor_id);
create index on clientes_negocio (usuario_id);
create index on productos (distribuidor_id, categoria_id);
create index on presentaciones (distribuidor_id, producto_id);
create index on pedidos (distribuidor_id, estado);
create index on pedidos (cliente_id);
create index on pedidos (repartidor_id);
create index on pedido_items (pedido_id);

-- ---------- Helpers de RLS ----------
-- security definer: leen usuarios sin disparar RLS recursivo.
create function public.mi_distribuidor_id() returns uuid
language sql stable security definer set search_path = public
as $$ select distribuidor_id from usuarios where id = auth.uid() $$;

create function public.mi_rol() returns rol_usuario
language sql stable security definer set search_path = public
as $$ select rol from usuarios where id = auth.uid() $$;

create function public.mi_cliente_id() returns uuid
language sql stable security definer set search_path = public
as $$ select id from clientes_negocio where usuario_id = auth.uid() $$;

-- ---------- RLS ----------
alter table distribuidores enable row level security;
alter table usuarios enable row level security;
alter table clientes_negocio enable row level security;
alter table categorias enable row level security;
alter table productos enable row level security;
alter table presentaciones enable row level security;
alter table precios_volumen enable row level security;
alter table pedidos enable row level security;
alter table pedido_items enable row level security;

-- distribuidores: cada usuario ve solo el suyo; solo admin edita.
create policy distribuidores_select on distribuidores for select
  to authenticated using (id = public.mi_distribuidor_id());
create policy distribuidores_update_admin on distribuidores for update
  to authenticated
  using (id = public.mi_distribuidor_id() and public.mi_rol() = 'admin')
  with check (id = public.mi_distribuidor_id() and public.mi_rol() = 'admin');

-- usuarios: ve los de su distribuidor; cada uno ve su propio perfil; admin gestiona.
create policy usuarios_select on usuarios for select
  to authenticated using (distribuidor_id = public.mi_distribuidor_id());
create policy usuarios_admin_all on usuarios for all
  to authenticated
  using (distribuidor_id = public.mi_distribuidor_id() and public.mi_rol() = 'admin')
  with check (distribuidor_id = public.mi_distribuidor_id() and public.mi_rol() = 'admin');

-- clientes_negocio: admin ve y gestiona todos; el cliente ve solo su negocio.
create policy clientes_admin_all on clientes_negocio for all
  to authenticated
  using (distribuidor_id = public.mi_distribuidor_id() and public.mi_rol() = 'admin')
  with check (distribuidor_id = public.mi_distribuidor_id() and public.mi_rol() = 'admin');
create policy clientes_select_propio on clientes_negocio for select
  to authenticated using (usuario_id = auth.uid());

-- catálogo: cualquier usuario del distribuidor lee; solo admin escribe.
create policy categorias_select on categorias for select
  to authenticated using (distribuidor_id = public.mi_distribuidor_id());
create policy categorias_admin_write on categorias for all
  to authenticated
  using (distribuidor_id = public.mi_distribuidor_id() and public.mi_rol() = 'admin')
  with check (distribuidor_id = public.mi_distribuidor_id() and public.mi_rol() = 'admin');

create policy productos_select on productos for select
  to authenticated using (distribuidor_id = public.mi_distribuidor_id());
create policy productos_admin_write on productos for all
  to authenticated
  using (distribuidor_id = public.mi_distribuidor_id() and public.mi_rol() = 'admin')
  with check (distribuidor_id = public.mi_distribuidor_id() and public.mi_rol() = 'admin');

create policy presentaciones_select on presentaciones for select
  to authenticated using (distribuidor_id = public.mi_distribuidor_id());
create policy presentaciones_admin_write on presentaciones for all
  to authenticated
  using (distribuidor_id = public.mi_distribuidor_id() and public.mi_rol() = 'admin')
  with check (distribuidor_id = public.mi_distribuidor_id() and public.mi_rol() = 'admin');

create policy precios_select on precios_volumen for select
  to authenticated using (distribuidor_id = public.mi_distribuidor_id());
create policy precios_admin_write on precios_volumen for all
  to authenticated
  using (distribuidor_id = public.mi_distribuidor_id() and public.mi_rol() = 'admin')
  with check (distribuidor_id = public.mi_distribuidor_id() and public.mi_rol() = 'admin');

-- pedidos: admin ve todos del distribuidor; cliente ve los suyos; repartidor, los asignados.
-- No hay política de INSERT para clientes: los pedidos se crean solo con crear_pedido().
create policy pedidos_admin_all on pedidos for all
  to authenticated
  using (distribuidor_id = public.mi_distribuidor_id() and public.mi_rol() = 'admin')
  with check (distribuidor_id = public.mi_distribuidor_id() and public.mi_rol() = 'admin');
create policy pedidos_select_cliente on pedidos for select
  to authenticated using (cliente_id = public.mi_cliente_id());
create policy pedidos_select_repartidor on pedidos for select
  to authenticated using (repartidor_id = auth.uid() and public.mi_rol() = 'repartidor');

create policy pedido_items_select on pedido_items for select
  to authenticated using (
    exists (
      select 1 from pedidos p
      where p.id = pedido_items.pedido_id
        and (
          (p.distribuidor_id = public.mi_distribuidor_id() and public.mi_rol() = 'admin')
          or p.cliente_id = public.mi_cliente_id()
          or (p.repartidor_id = auth.uid() and public.mi_rol() = 'repartidor')
        )
    )
  );

-- ---------- Función transaccional: crear_pedido ----------
-- Valida stock con bloqueo de fila, descuenta, aplica precio por volumen y crea el pedido.
-- Todo ocurre en una sola transacción: si algo falla, se revierte completo.
-- p_items: [{ "presentacion_id": "<uuid>", "cantidad": <int> }, ...]
create function public.crear_pedido(p_items jsonb, p_despacho despacho_pedido default 'recojo')
returns uuid
language plpgsql security definer set search_path = public
as $$
declare
  v_cliente uuid := public.mi_cliente_id();
  v_dist uuid := public.mi_distribuidor_id();
  v_pedido uuid;
  v_total integer := 0;
  v_item jsonb;
  v_pres presentaciones%rowtype;
  v_cant integer;
  v_precio integer;
  v_ids uuid[];
begin
  if v_cliente is null then
    raise exception 'Solo un cliente puede crear pedidos' using errcode = '42501';
  end if;

  if jsonb_typeof(p_items) is distinct from 'array' or jsonb_array_length(p_items) = 0 then
    raise exception 'El pedido no tiene ítems' using errcode = '22023';
  end if;

  if exists (
    select 1 from jsonb_array_elements(p_items) i
    where coalesce((i ->> 'cantidad')::integer, 0) <= 0
  ) then
    raise exception 'Cada ítem debe tener una cantidad mayor a cero' using errcode = '22023';
  end if;

  -- Bloqueo de filas en orden fijo (evita deadlocks entre pedidos simultáneos).
  select array_agg(distinct (i ->> 'presentacion_id')::uuid order by (i ->> 'presentacion_id')::uuid)
    into v_ids
    from jsonb_array_elements(p_items) i;

  perform 1 from presentaciones p
    where p.id = any (v_ids) and p.distribuidor_id = v_dist
    order by p.id
    for update;

  if (select count(*) from presentaciones p where p.id = any (v_ids) and p.distribuidor_id = v_dist)
     <> cardinality(v_ids) then
    raise exception 'Algún producto no existe o no pertenece a este distribuidor' using errcode = 'P0002';
  end if;

  insert into pedidos (distribuidor_id, cliente_id, estado, despacho, total_centimos)
  values (v_dist, v_cliente, 'recibido', p_despacho, 0)
  returning id into v_pedido;

  for v_item in select value from jsonb_array_elements(p_items) loop
    v_cant := (v_item ->> 'cantidad')::integer;

    select * into v_pres from presentaciones
      where id = (v_item ->> 'presentacion_id')::uuid;

    if v_pres.stock < v_cant then
      raise exception 'Stock insuficiente para "%": pedidos %, disponibles %',
        v_pres.nombre, v_cant, v_pres.stock
        using errcode = 'P0001';
    end if;

    select pv.precio_centimos into v_precio
      from precios_volumen pv
      where pv.presentacion_id = v_pres.id and pv.cantidad_minima <= v_cant
      order by pv.cantidad_minima desc
      limit 1;
    v_precio := coalesce(v_precio, v_pres.precio_base_centimos);

    update presentaciones set stock = stock - v_cant where id = v_pres.id;

    insert into pedido_items (distribuidor_id, pedido_id, presentacion_id, cantidad, precio_unitario_centimos)
    values (v_dist, v_pedido, v_pres.id, v_cant, v_precio);

    v_total := v_total + v_precio * v_cant;
  end loop;

  update pedidos set total_centimos = v_total where id = v_pedido;
  return v_pedido;
end;
$$;

-- Solo usuarios autenticados pueden llamar la función; anon no.
revoke all on function public.crear_pedido(jsonb, despacho_pedido) from public;
grant execute on function public.crear_pedido(jsonb, despacho_pedido) to authenticated;

-- Supabase otorga EXECUTE a anon por defecto: se revoca explícitamente.
revoke execute on function public.crear_pedido(jsonb, despacho_pedido) from anon;
-- Helpers de RLS: solo los usa el rol authenticated.
revoke execute on function public.mi_distribuidor_id() from anon;
revoke execute on function public.mi_rol() from anon;
revoke execute on function public.mi_cliente_id() from anon;
