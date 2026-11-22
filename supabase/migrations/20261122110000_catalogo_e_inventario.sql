-- Módulo 2: catálogo e inventario.
-- Categorías, productos, presentaciones, precios por volumen, listas de
-- precios, historial de stock y bucket de imágenes. Agrega a
-- clientes_negocio la lista de precios. Spec: secciones 6.2 y 7.
--
-- Orden: enums, tablas, índices, triggers, funciones auxiliares, permisos,
-- políticas, Storage, funciones públicas.

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------
create type public.tipo_movimiento_stock as enum
  ('ingreso', 'ajuste', 'reserva', 'liberacion', 'salida');

-- ---------------------------------------------------------------------------
-- Tablas
-- Las hijas apuntan al padre con clave foránea compuesta (x_id,
-- distribuidor_id): imposible cruzar distribuidores.
-- ---------------------------------------------------------------------------
create table public.categorias (
  id uuid primary key default gen_random_uuid(),
  distribuidor_id uuid not null references public.distribuidores (id),
  nombre text not null,
  orden integer not null default 0,
  activo boolean not null default true,
  creado_en timestamptz not null default now(),
  actualizado_en timestamptz not null default now(),
  unique (id, distribuidor_id)
);

-- Lo que se inventaría. El stock va en unidades base y solo cambia mediante
-- funciones (ver permisos). Disponible = stock_fisico - stock_comprometido.
create table public.productos (
  id uuid primary key default gen_random_uuid(),
  distribuidor_id uuid not null references public.distribuidores (id),
  categoria_id uuid,
  nombre text not null,
  descripcion text,
  marca text,
  sku text check (sku <> ''),
  imagen_url text,
  unidad_base text not null default 'unidad',
  stock_fisico integer not null default 0,
  stock_comprometido integer not null default 0,
  activo boolean not null default true,
  creado_en timestamptz not null default now(),
  actualizado_en timestamptz not null default now(),
  unique (id, distribuidor_id),
  -- Varios productos sin sku conviven: los nulos no chocan en un unique (por
  -- eso el sku vacío se rechaza: sin código va nulo).
  unique (distribuidor_id, sku),
  foreign key (categoria_id, distribuidor_id)
    references public.categorias (id, distribuidor_id),
  constraint productos_stock_check
    check (0 <= stock_comprometido and stock_comprometido <= stock_fisico)
);

-- Lo que se vende: un producto en cierta cantidad de unidades base (factor).
create table public.presentaciones (
  id uuid primary key default gen_random_uuid(),
  distribuidor_id uuid not null references public.distribuidores (id),
  producto_id uuid not null,
  nombre text not null,
  factor integer not null check (factor > 0),
  precio_base_centimos bigint not null check (precio_base_centimos >= 0),
  orden integer not null default 0,
  activo boolean not null default true,
  creado_en timestamptz not null default now(),
  actualizado_en timestamptz not null default now(),
  unique (id, distribuidor_id),
  foreign key (producto_id, distribuidor_id)
    references public.productos (id, distribuidor_id)
);

-- Precio desde cierta cantidad de la presentación.
create table public.precios_volumen (
  id uuid primary key default gen_random_uuid(),
  distribuidor_id uuid not null references public.distribuidores (id),
  presentacion_id uuid not null,
  cantidad_minima integer not null check (cantidad_minima > 0),
  precio_centimos bigint not null check (precio_centimos >= 0),
  creado_en timestamptz not null default now(),
  actualizado_en timestamptz not null default now(),
  unique (presentacion_id, cantidad_minima),
  foreign key (presentacion_id, distribuidor_id)
    references public.presentaciones (id, distribuidor_id) on delete cascade
);

-- Lista opcional por tipo de cliente. Se desactiva, no se borra.
create table public.listas_precios (
  id uuid primary key default gen_random_uuid(),
  distribuidor_id uuid not null references public.distribuidores (id),
  nombre text not null,
  activo boolean not null default true,
  creado_en timestamptz not null default now(),
  actualizado_en timestamptz not null default now(),
  unique (id, distribuidor_id)
);

create table public.precios_lista (
  id uuid primary key default gen_random_uuid(),
  distribuidor_id uuid not null references public.distribuidores (id),
  lista_precios_id uuid not null,
  presentacion_id uuid not null,
  precio_centimos bigint not null check (precio_centimos >= 0),
  creado_en timestamptz not null default now(),
  actualizado_en timestamptz not null default now(),
  unique (lista_precios_id, presentacion_id),
  foreign key (lista_precios_id, distribuidor_id)
    references public.listas_precios (id, distribuidor_id) on delete cascade,
  foreign key (presentacion_id, distribuidor_id)
    references public.presentaciones (id, distribuidor_id) on delete cascade
);

-- Historial de inventario, solo de inserción. pedido_id recibe su clave
-- foránea en el módulo de pedidos.
create table public.movimientos_stock (
  id uuid primary key default gen_random_uuid(),
  distribuidor_id uuid not null references public.distribuidores (id),
  producto_id uuid not null,
  tipo public.tipo_movimiento_stock not null,
  delta_fisico integer not null default 0,
  delta_comprometido integer not null default 0,
  pedido_id uuid,
  hecho_por uuid references public.perfiles (id) on delete set null,
  nota text,
  creado_en timestamptz not null default now(),
  foreign key (producto_id, distribuidor_id)
    references public.productos (id, distribuidor_id)
);

-- Lista de precios de la bodega (nula = sin lista).
alter table public.clientes_negocio
  add column lista_precios_id uuid,
  add foreign key (lista_precios_id, distribuidor_id)
    references public.listas_precios (id, distribuidor_id);

alter table public.categorias enable row level security;
alter table public.productos enable row level security;
alter table public.presentaciones enable row level security;
alter table public.precios_volumen enable row level security;
alter table public.listas_precios enable row level security;
alter table public.precios_lista enable row level security;
alter table public.movimientos_stock enable row level security;

-- ---------------------------------------------------------------------------
-- Índices: toda clave foránea y las columnas usadas en RLS.
-- productos (distribuidor_id, ...) lo cubre su unique con sku;
-- precios_volumen (presentacion_id) y precios_lista (lista_precios_id), sus
-- unique.
-- ---------------------------------------------------------------------------
create index categorias_distribuidor_idx on public.categorias (distribuidor_id);
create index productos_categoria_idx on public.productos (categoria_id, distribuidor_id);
create index presentaciones_distribuidor_idx on public.presentaciones (distribuidor_id);
create index presentaciones_producto_idx on public.presentaciones (producto_id, distribuidor_id);
create index precios_volumen_distribuidor_idx on public.precios_volumen (distribuidor_id);
create index listas_precios_distribuidor_idx on public.listas_precios (distribuidor_id);
create index precios_lista_distribuidor_idx on public.precios_lista (distribuidor_id);
create index precios_lista_presentacion_idx on public.precios_lista (presentacion_id, distribuidor_id);
create index movimientos_stock_distribuidor_idx on public.movimientos_stock (distribuidor_id, creado_en);
create index movimientos_stock_producto_idx on public.movimientos_stock (producto_id, distribuidor_id);
create index movimientos_stock_pedido_idx on public.movimientos_stock (pedido_id);
create index movimientos_stock_hecho_por_idx on public.movimientos_stock (hecho_por);
create index clientes_negocio_lista_precios_idx on public.clientes_negocio (lista_precios_id, distribuidor_id);

-- ---------------------------------------------------------------------------
-- Triggers
-- ---------------------------------------------------------------------------
create trigger categorias_actualizado_en before update on public.categorias
  for each row execute function privado.tg_actualizado_en();
create trigger productos_actualizado_en before update on public.productos
  for each row execute function privado.tg_actualizado_en();
create trigger presentaciones_actualizado_en before update on public.presentaciones
  for each row execute function privado.tg_actualizado_en();
create trigger precios_volumen_actualizado_en before update on public.precios_volumen
  for each row execute function privado.tg_actualizado_en();
create trigger listas_precios_actualizado_en before update on public.listas_precios
  for each row execute function privado.tg_actualizado_en();
create trigger precios_lista_actualizado_en before update on public.precios_lista
  for each row execute function privado.tg_actualizado_en();

-- Protege campos de clientes_negocio que la política de UPDATE no distingue
-- (el personal tiene UPDATE sobre toda la tabla). Con sesión:
-- - id y distribuidor_id no cambian para nadie, ni siquiera el admin;
-- - solo el admin asigna o cambia lista_precios_id (también al crear).
-- Sin sesión (rol de servicio, migraciones, seed) no aplica.
create function privado.tg_clientes_negocio_protege_campos() returns trigger
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
  elsif new.lista_precios_id is not null
        and not privado.tiene_rol(new.distribuidor_id, '{admin}') then
    raise exception 'Solo el admin asigna la lista de precios de una bodega'
      using errcode = '42501';
  end if;

  return new;
end $$;

create trigger clientes_negocio_protege_campos before insert or update on public.clientes_negocio
  for each row execute function privado.tg_clientes_negocio_protege_campos();

-- ---------------------------------------------------------------------------
-- Funciones auxiliares
-- ---------------------------------------------------------------------------

-- Lista de precios activa de la bodega de quien llama en ese distribuidor;
-- nulo si no es cliente activo, su bodega no tiene lista o la lista está
-- inactiva (una lista inactiva no se cobra, así que tampoco se muestra).
create function privado.mi_lista_en(p_distribuidor uuid) returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select c.lista_precios_id
  from public.clientes_negocio c
  join public.listas_precios l
    on l.id = c.lista_precios_id and l.distribuidor_id = c.distribuidor_id
  where c.id = privado.mi_cliente_en(p_distribuidor)
    and c.distribuidor_id = p_distribuidor
    and l.activo
$$;

-- Convierte texto a uuid; nulo si no tiene la forma canónica de un uuid.
create function privado.uuid_o_nulo(p_texto text) returns uuid
language sql
immutable
set search_path = ''
as $$
  select case
    when p_texto ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
    then p_texto::uuid
  end
$$;

-- Precio unitario en céntimos de una presentación para una bodega y una
-- cantidad (spec 6.2):
-- 1. partida: precio de la lista activa de la bodega si la presentación lo
--    tiene; si no, el precio base;
-- 2. volumen: el de mayor cantidad_minima que no supere la cantidad;
-- 3. se cobra el menor de los dos.
-- Nulo si la presentación no existe. Uso interno de las funciones de pedidos.
create function privado.precio_para(p_presentacion uuid, p_cliente uuid, p_cantidad integer)
returns bigint
language sql
stable
set search_path = ''
as $$
  select least(
    coalesce(
      (select pl.precio_centimos
       from public.clientes_negocio c
       join public.listas_precios l
         on l.id = c.lista_precios_id and l.distribuidor_id = c.distribuidor_id
       join public.precios_lista pl
         on pl.lista_precios_id = l.id and pl.distribuidor_id = l.distribuidor_id
       where c.id = p_cliente
         and l.activo
         and pl.presentacion_id = pr.id),
      pr.precio_base_centimos),
    (select pv.precio_centimos
     from public.precios_volumen pv
     where pv.presentacion_id = pr.id
       and pv.cantidad_minima <= p_cantidad
     order by pv.cantidad_minima desc
     limit 1))
  from public.presentaciones pr
  where pr.id = p_presentacion
$$;

-- Aplica los deltas al stock del producto y registra el movimiento a nombre
-- de quien llama (nulo sin sesión). No valida reglas de negocio: quien la
-- llama ya bloqueó la fila del producto y validó; la restricción
-- productos_stock_check es el último resguardo. Uso interno.
create function privado.aplicar_movimiento_stock(
  p_producto uuid,
  p_tipo public.tipo_movimiento_stock,
  p_delta_fisico integer,
  p_delta_comprometido integer,
  p_pedido uuid,
  p_nota text
) returns void
language plpgsql
volatile
set search_path = ''
as $$
declare
  v_distribuidor uuid;
begin
  update public.productos
  set stock_fisico = stock_fisico + p_delta_fisico,
      stock_comprometido = stock_comprometido + p_delta_comprometido
  where id = p_producto
  returning distribuidor_id into v_distribuidor;

  if v_distribuidor is null then
    raise exception 'Producto inexistente' using errcode = 'P0002';
  end if;

  insert into public.movimientos_stock
    (distribuidor_id, producto_id, tipo, delta_fisico, delta_comprometido,
     pedido_id, hecho_por, nota)
  values
    (v_distribuidor, p_producto, p_tipo, p_delta_fisico, p_delta_comprometido,
     p_pedido, auth.uid(), p_nota);
end $$;

-- ---------------------------------------------------------------------------
-- Permisos de tablas (explícitos, sin depender de los privilegios por defecto)
-- Nadie modifica id, distribuidor_id ni las marcas de tiempo; las filas
-- hijas no cambian de padre. El stock no se escribe ni al crear el producto
-- ni con un UPDATE: solo mediante funciones.
-- ---------------------------------------------------------------------------
revoke all on public.categorias, public.productos, public.presentaciones,
  public.precios_volumen, public.listas_precios, public.precios_lista,
  public.movimientos_stock
  from anon, authenticated;

grant select on public.categorias to authenticated;
grant insert (id, distribuidor_id, nombre, orden, activo) on public.categorias to authenticated;
grant update (nombre, orden, activo) on public.categorias to authenticated;

grant select on public.productos to authenticated;
grant insert (id, distribuidor_id, categoria_id, nombre, descripcion, marca, sku,
              imagen_url, unidad_base, activo)
  on public.productos to authenticated;
grant update (categoria_id, nombre, descripcion, marca, sku, imagen_url, unidad_base, activo)
  on public.productos to authenticated;

grant select on public.presentaciones to authenticated;
grant insert (id, distribuidor_id, producto_id, nombre, factor, precio_base_centimos,
              orden, activo)
  on public.presentaciones to authenticated;
grant update (nombre, factor, precio_base_centimos, orden, activo)
  on public.presentaciones to authenticated;

grant select, delete on public.precios_volumen to authenticated;
grant insert (id, distribuidor_id, presentacion_id, cantidad_minima, precio_centimos)
  on public.precios_volumen to authenticated;
grant update (cantidad_minima, precio_centimos) on public.precios_volumen to authenticated;

grant select on public.listas_precios to authenticated;
grant insert (id, distribuidor_id, nombre, activo) on public.listas_precios to authenticated;
grant update (nombre, activo) on public.listas_precios to authenticated;

grant select, delete on public.precios_lista to authenticated;
grant insert (id, distribuidor_id, lista_precios_id, presentacion_id, precio_centimos)
  on public.precios_lista to authenticated;
grant update (precio_centimos) on public.precios_lista to authenticated;

-- movimientos_stock: solo lectura; se escribe mediante funciones.
grant select on public.movimientos_stock to authenticated;

-- ---------------------------------------------------------------------------
-- Permisos de funciones: execute revocado a public y anon en todas.
-- ---------------------------------------------------------------------------
revoke execute on function
  privado.tg_clientes_negocio_protege_campos(),
  privado.mi_lista_en(uuid),
  privado.uuid_o_nulo(text),
  privado.precio_para(uuid, uuid, integer),
  privado.aplicar_movimiento_stock(uuid, public.tipo_movimiento_stock, integer, integer, uuid, text)
  from public, anon;

-- Auxiliares usadas en políticas RLS (de tablas y de Storage).
grant execute on function
  privado.mi_lista_en(uuid),
  privado.uuid_o_nulo(text)
  to authenticated;

-- ---------------------------------------------------------------------------
-- Políticas
-- Clientes y repartidores leen solo filas activas del catálogo; admin y
-- vendedor, todas. Solo el admin escribe.
-- ---------------------------------------------------------------------------
create policy categorias_select on public.categorias
  for select to authenticated
  using (
    (select privado.es_super_admin())
    or (select privado.tiene_rol(distribuidor_id, '{admin,vendedor}'))
    or (activo and (select privado.es_miembro(distribuidor_id)))
  );

create policy categorias_insert on public.categorias
  for insert to authenticated
  with check ((select privado.tiene_rol(distribuidor_id, '{admin}')));

create policy categorias_update on public.categorias
  for update to authenticated
  using ((select privado.tiene_rol(distribuidor_id, '{admin}')))
  with check ((select privado.tiene_rol(distribuidor_id, '{admin}')));

create policy productos_select on public.productos
  for select to authenticated
  using (
    (select privado.es_super_admin())
    or (select privado.tiene_rol(distribuidor_id, '{admin,vendedor}'))
    or (activo and (select privado.es_miembro(distribuidor_id)))
  );

create policy productos_insert on public.productos
  for insert to authenticated
  with check ((select privado.tiene_rol(distribuidor_id, '{admin}')));

create policy productos_update on public.productos
  for update to authenticated
  using ((select privado.tiene_rol(distribuidor_id, '{admin}')))
  with check ((select privado.tiene_rol(distribuidor_id, '{admin}')));

create policy presentaciones_select on public.presentaciones
  for select to authenticated
  using (
    (select privado.es_super_admin())
    or (select privado.tiene_rol(distribuidor_id, '{admin,vendedor}'))
    or (activo and (select privado.es_miembro(distribuidor_id)))
  );

create policy presentaciones_insert on public.presentaciones
  for insert to authenticated
  with check ((select privado.tiene_rol(distribuidor_id, '{admin}')));

create policy presentaciones_update on public.presentaciones
  for update to authenticated
  using ((select privado.tiene_rol(distribuidor_id, '{admin}')))
  with check ((select privado.tiene_rol(distribuidor_id, '{admin}')));

create policy precios_volumen_select on public.precios_volumen
  for select to authenticated
  using (
    (select privado.es_super_admin())
    or (select privado.es_miembro(distribuidor_id))
  );

create policy precios_volumen_insert on public.precios_volumen
  for insert to authenticated
  with check ((select privado.tiene_rol(distribuidor_id, '{admin}')));

create policy precios_volumen_update on public.precios_volumen
  for update to authenticated
  using ((select privado.tiene_rol(distribuidor_id, '{admin}')))
  with check ((select privado.tiene_rol(distribuidor_id, '{admin}')));

create policy precios_volumen_delete on public.precios_volumen
  for delete to authenticated
  using ((select privado.tiene_rol(distribuidor_id, '{admin}')));

-- El cliente ve solo su lista; el repartidor, ninguna.
create policy listas_precios_select on public.listas_precios
  for select to authenticated
  using (
    (select privado.es_super_admin())
    or (select privado.tiene_rol(distribuidor_id, '{admin,vendedor}'))
    or id = (select privado.mi_lista_en(distribuidor_id))
  );

create policy listas_precios_insert on public.listas_precios
  for insert to authenticated
  with check ((select privado.tiene_rol(distribuidor_id, '{admin}')));

create policy listas_precios_update on public.listas_precios
  for update to authenticated
  using ((select privado.tiene_rol(distribuidor_id, '{admin}')))
  with check ((select privado.tiene_rol(distribuidor_id, '{admin}')));

create policy precios_lista_select on public.precios_lista
  for select to authenticated
  using (
    (select privado.es_super_admin())
    or (select privado.tiene_rol(distribuidor_id, '{admin,vendedor}'))
    or lista_precios_id = (select privado.mi_lista_en(distribuidor_id))
  );

create policy precios_lista_insert on public.precios_lista
  for insert to authenticated
  with check ((select privado.tiene_rol(distribuidor_id, '{admin}')));

create policy precios_lista_update on public.precios_lista
  for update to authenticated
  using ((select privado.tiene_rol(distribuidor_id, '{admin}')))
  with check ((select privado.tiene_rol(distribuidor_id, '{admin}')));

create policy precios_lista_delete on public.precios_lista
  for delete to authenticated
  using ((select privado.tiene_rol(distribuidor_id, '{admin}')));

create policy movimientos_stock_select on public.movimientos_stock
  for select to authenticated
  using (
    (select privado.es_super_admin())
    or (select privado.tiene_rol(distribuidor_id, '{admin,vendedor}'))
  );

-- ---------------------------------------------------------------------------
-- Storage: bucket catalogo, de lectura pública, con rutas
-- <distribuidor_id>/... Solo el admin de ese distribuidor escribe en su
-- carpeta. La política de select (también de su carpeta) hace falta para que
-- el update y el delete encuentren la fila; la lectura pública va por la URL
-- del bucket, no por esta tabla. Solo imágenes jpeg, png o webp de hasta
-- 5 MB.
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('catalogo', 'catalogo', true, 5242880, '{image/jpeg,image/png,image/webp}');

create policy catalogo_select on storage.objects
  for select to authenticated
  using (
    bucket_id = 'catalogo'
    and (select privado.tiene_rol(privado.uuid_o_nulo((storage.foldername(name))[1]), '{admin}'))
  );

create policy catalogo_insert on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'catalogo'
    and (select privado.tiene_rol(privado.uuid_o_nulo((storage.foldername(name))[1]), '{admin}'))
  );

create policy catalogo_update on storage.objects
  for update to authenticated
  using (
    bucket_id = 'catalogo'
    and (select privado.tiene_rol(privado.uuid_o_nulo((storage.foldername(name))[1]), '{admin}'))
  )
  with check (
    bucket_id = 'catalogo'
    and (select privado.tiene_rol(privado.uuid_o_nulo((storage.foldername(name))[1]), '{admin}'))
  );

create policy catalogo_delete on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'catalogo'
    and (select privado.tiene_rol(privado.uuid_o_nulo((storage.foldername(name))[1]), '{admin}'))
  );

-- ---------------------------------------------------------------------------
-- Funciones públicas
-- ---------------------------------------------------------------------------

-- Registra un movimiento manual de stock. Solo admin del distribuidor del
-- producto y solo tipos ingreso (cantidad > 0, suma al físico) y ajuste
-- (diferencia con signo, distinta de cero). Reserva, liberación y salida las
-- generan únicamente las funciones de pedidos.
--
-- Errores: 42501 sin sesión, producto inexistente o sin permiso; 22023 tipo
-- o cantidad inválidos, o un físico resultante mayor al máximo de integer;
-- P0001 el físico quedaría por debajo del comprometido.
create function public.registrar_movimiento_stock(
  p_producto_id uuid,
  p_tipo public.tipo_movimiento_stock,
  p_cantidad integer,
  p_nota text default null
) returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_distribuidor uuid;
  v_p public.productos;
begin
  if v_uid is null then
    raise exception 'Se requiere una sesión' using errcode = '42501';
  end if;

  select p.distribuidor_id into v_distribuidor
  from public.productos p where p.id = p_producto_id;

  if v_distribuidor is null or not privado.tiene_rol(v_distribuidor, '{admin}') then
    raise exception 'No puede mover el stock de este producto' using errcode = '42501';
  end if;

  if p_tipo is null or p_tipo not in ('ingreso', 'ajuste') or p_cantidad is null
     or (p_tipo = 'ingreso' and p_cantidad <= 0)
     or (p_tipo = 'ajuste' and p_cantidad = 0) then
    raise exception 'Tipo o cantidad inválidos: ingreso exige cantidad > 0 y ajuste, distinta de 0'
      using errcode = '22023';
  end if;

  select * into v_p from public.productos p where p.id = p_producto_id for update;

  -- Revalida con la fila ya bloqueada: quien llama pudo perder el rol de
  -- admin mientras esperaba el bloqueo.
  if not privado.tiene_rol(v_distribuidor, '{admin}') then
    raise exception 'No puede mover el stock de este producto' using errcode = '42501';
  end if;

  -- En bigint: con integer, una cantidad enorme desbordaría (22003).
  if v_p.stock_fisico::bigint + p_cantidad > 2147483647 then
    raise exception 'La cantidad haría desbordar el stock físico' using errcode = '22023';
  end if;

  if v_p.stock_fisico::bigint + p_cantidad < v_p.stock_comprometido then
    raise exception 'El stock físico quedaría por debajo del comprometido'
      using errcode = 'P0001';
  end if;

  perform privado.aplicar_movimiento_stock(
    p_producto_id, p_tipo, p_cantidad, 0, null, p_nota);
end $$;

revoke execute on function
  public.registrar_movimiento_stock(uuid, public.tipo_movimiento_stock, integer, text)
  from public, anon;

grant execute on function
  public.registrar_movimiento_stock(uuid, public.tipo_movimiento_stock, integer, text)
  to authenticated;
