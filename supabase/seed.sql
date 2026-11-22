-- =============================================================================
-- SEED DE DESARROLLO (solo local / DEV). Nunca en PROD.
--
-- Se carga como rol de servicio (superusuario), después de todas las
-- migraciones: con `supabase db reset` o con `bash supabase/tests/run.sh`.
-- Sin sesión, auth.uid() es nulo: el trigger de protección de
-- clientes_negocio no aplica y el stock inicial se inserta directamente.
--
-- Ids fijos con la forma 5eed0000-0000-0000-TTTT-NNNNNNNNNNNN (TTTT = tabla),
-- distintos de los de las pruebas (00000000-0000-0000-0000-00000000XXXX):
--   0001 planes             0002 distribuidores      0003 suscripciones
--   0004 cuentas/perfiles   0005 bodegas y tiendas   0006 membresías
--   0007 categorías         0008 productos           0009 presentaciones
--   000a precios_volumen    000b listas_precios      000c precios_lista
--   000d invitaciones       000e movimientos_stock
--
-- Contenido:
--   Planes: basico y pro (valores de ejemplo, pendientes de definir).
--   D1 ...0002-...0001 "Licores del Norte (demo)": 5 categorías, 30 productos
--      (botella; Botella x1, Caja x12, Six pack x6 en cervezas; precio por
--      volumen en cada botella desde 12), lista "Mayorista" con 10
--      presentaciones. Personal: admin, vendedor, repartidor. Bodegas: El
--      Roble (crédito 500000 céntimos, 15 días), San Martín (lista
--      Mayorista), La Esquina (contado).
--   D2 ...0002-...0002 "ElectroMayor (demo)": 2 categorías, 8 productos
--      (unidad; Unidad x1, Pack x10). Admin y 2 tiendas.
--   Rosa Quispe tiene membresía de cliente en D1 (El Roble) y en D2 (Tienda
--   Centro). Un Super Admin. Invitaciones de rol cliente DEMA2345 (D1, La
--   Esquina) y DEMA6789 (D2, Tienda Norte), vigentes 30 días.
--   Sin pedidos: se crean desde la app.
--
-- Las cuentas se insertan en auth.users sin contraseña: sirven para probar
-- RLS y permisos, no para iniciar sesión.
-- =============================================================================

begin;

-- ---------- Planes ----------
insert into public.planes (id, codigo, nombre, precio_mensual_centimos, limites) values
  ('5eed0000-0000-0000-0001-000000000001', 'basico', 'Básico', 9900,
   '{"max_clientes": 50, "max_productos": 200, "max_usuarios": 3}'),
  ('5eed0000-0000-0000-0001-000000000002', 'pro', 'Pro', 19900,
   '{"max_clientes": 500, "max_productos": 2000, "max_usuarios": 15}');

-- ---------- Distribuidores ----------
insert into public.distribuidores (id, nombre, slug, rubro, telefono, estado, config_tema) values
  ('5eed0000-0000-0000-0002-000000000001', 'Licores del Norte (demo)', 'licores-del-norte-demo',
   'licores', '51900100001', 'activo',
   '{"nombre": "Licores del Norte", "logo_url": null, "color_primario": "#1F3A5F", "color_secundario": "#F2A900"}'),
  ('5eed0000-0000-0000-0002-000000000002', 'ElectroMayor (demo)', 'electromayor-demo',
   'electronica', '51900100002', 'activo',
   '{"nombre": "ElectroMayor", "logo_url": null, "color_primario": "#0B5394", "color_secundario": "#38B26B"}');

-- Suscripción activa por el periodo en curso (30 días desde hoy).
insert into public.suscripciones (id, distribuidor_id, plan_id, estado, periodo_inicio, periodo_fin) values
  ('5eed0000-0000-0000-0003-000000000001', '5eed0000-0000-0000-0002-000000000001',
   '5eed0000-0000-0000-0001-000000000002', 'activa', current_date, current_date + 29),
  ('5eed0000-0000-0000-0003-000000000002', '5eed0000-0000-0000-0002-000000000002',
   '5eed0000-0000-0000-0001-000000000001', 'activa', current_date, current_date + 29);

-- ---------- Cuentas ----------
-- El trigger de auth.users crea cada perfil (con el teléfono); el nombre y el
-- Super Admin se fijan después.
insert into auth.users (id, email, phone) values
  ('5eed0000-0000-0000-0004-000000000001', 'admin.licores@example.com',    '51900200001'),
  ('5eed0000-0000-0000-0004-000000000002', 'vendedor.licores@example.com', '51900200002'),
  ('5eed0000-0000-0000-0004-000000000003', 'repartidor.licores@example.com', '51900200003'),
  ('5eed0000-0000-0000-0004-000000000011', 'bodega.roble@example.com',     '51900200011'),
  ('5eed0000-0000-0000-0004-000000000012', 'licoreria.sanmartin@example.com', '51900200012'),
  ('5eed0000-0000-0000-0004-000000000013', 'licoreria.esquina@example.com', '51900200013'),
  ('5eed0000-0000-0000-0004-000000000021', 'admin.electro@example.com',    '51900200021'),
  ('5eed0000-0000-0000-0004-000000000022', 'tienda.norte@example.com',     '51900200022'),
  ('5eed0000-0000-0000-0004-000000000099', 'superadmin@example.com',       null);

update public.perfiles p
set nombre = v.nombre
from (values
  ('5eed0000-0000-0000-0004-000000000001'::uuid, 'Admin Licores'),
  ('5eed0000-0000-0000-0004-000000000002'::uuid, 'Vendedor Licores'),
  ('5eed0000-0000-0000-0004-000000000003'::uuid, 'Repartidor Licores'),
  ('5eed0000-0000-0000-0004-000000000011'::uuid, 'Rosa Quispe'),
  ('5eed0000-0000-0000-0004-000000000012'::uuid, 'Martín Salas'),
  ('5eed0000-0000-0000-0004-000000000013'::uuid, 'Lucía Paredes'),
  ('5eed0000-0000-0000-0004-000000000021'::uuid, 'Admin Electro'),
  ('5eed0000-0000-0000-0004-000000000022'::uuid, 'Jorge Huamán'),
  ('5eed0000-0000-0000-0004-000000000099'::uuid, 'Super Admin')
) as v (id, nombre)
where p.id = v.id;

update public.perfiles set es_super_admin = true
where id = '5eed0000-0000-0000-0004-000000000099';

-- ---------- Bodegas y tiendas ----------
insert into public.clientes_negocio
  (id, distribuidor_id, nombre_negocio, documento, direccion, referencia, telefono,
   credito_habilitado, limite_credito_centimos, plazo_credito_dias)
values
  ('5eed0000-0000-0000-0005-000000000001', '5eed0000-0000-0000-0002-000000000001',
   'Bodega El Roble', '10456789012', 'Av. Los Olivos 123', 'Frente al parque', '51900300001',
   true, 500000, 15),
  ('5eed0000-0000-0000-0005-000000000002', '5eed0000-0000-0000-0002-000000000001',
   'Licorería San Martín', '10456789023', 'Jr. San Martín 456', null, '51900300002',
   false, null, null),
  ('5eed0000-0000-0000-0005-000000000003', '5eed0000-0000-0000-0002-000000000001',
   'Licorería La Esquina', null, 'Calle Principal 789', 'Esquina con Jr. Lima', '51900300003',
   false, null, null),
  ('5eed0000-0000-0000-0005-000000000011', '5eed0000-0000-0000-0002-000000000002',
   'Tienda Centro', '10456789034', 'Av. Grau 321', null, '51900300011',
   false, null, null),
  ('5eed0000-0000-0000-0005-000000000012', '5eed0000-0000-0000-0002-000000000002',
   'Tienda Norte', null, 'Av. Túpac Amaru 654', 'Galería Norte, puesto 12', '51900300012',
   false, null, null);

-- ---------- Membresías ----------
insert into public.membresias (id, perfil_id, distribuidor_id, rol, cliente_negocio_id) values
  -- Licores del Norte
  ('5eed0000-0000-0000-0006-000000000001', '5eed0000-0000-0000-0004-000000000001',
   '5eed0000-0000-0000-0002-000000000001', 'admin', null),
  ('5eed0000-0000-0000-0006-000000000002', '5eed0000-0000-0000-0004-000000000002',
   '5eed0000-0000-0000-0002-000000000001', 'vendedor', null),
  ('5eed0000-0000-0000-0006-000000000003', '5eed0000-0000-0000-0004-000000000003',
   '5eed0000-0000-0000-0002-000000000001', 'repartidor', null),
  ('5eed0000-0000-0000-0006-000000000011', '5eed0000-0000-0000-0004-000000000011',
   '5eed0000-0000-0000-0002-000000000001', 'cliente', '5eed0000-0000-0000-0005-000000000001'),
  ('5eed0000-0000-0000-0006-000000000012', '5eed0000-0000-0000-0004-000000000012',
   '5eed0000-0000-0000-0002-000000000001', 'cliente', '5eed0000-0000-0000-0005-000000000002'),
  ('5eed0000-0000-0000-0006-000000000013', '5eed0000-0000-0000-0004-000000000013',
   '5eed0000-0000-0000-0002-000000000001', 'cliente', '5eed0000-0000-0000-0005-000000000003'),
  -- ElectroMayor (Rosa Quispe es cliente en los dos distribuidores)
  ('5eed0000-0000-0000-0006-000000000021', '5eed0000-0000-0000-0004-000000000021',
   '5eed0000-0000-0000-0002-000000000002', 'admin', null),
  ('5eed0000-0000-0000-0006-000000000022', '5eed0000-0000-0000-0004-000000000011',
   '5eed0000-0000-0000-0002-000000000002', 'cliente', '5eed0000-0000-0000-0005-000000000011'),
  ('5eed0000-0000-0000-0006-000000000023', '5eed0000-0000-0000-0004-000000000022',
   '5eed0000-0000-0000-0002-000000000002', 'cliente', '5eed0000-0000-0000-0005-000000000012');

-- ---------- Catálogo: categorías ----------
insert into public.categorias (id, distribuidor_id, nombre, orden) values
  ('5eed0000-0000-0000-0007-000000000001', '5eed0000-0000-0000-0002-000000000001', 'Ron', 1),
  ('5eed0000-0000-0000-0007-000000000002', '5eed0000-0000-0000-0002-000000000001', 'Pisco', 2),
  ('5eed0000-0000-0000-0007-000000000003', '5eed0000-0000-0000-0002-000000000001', 'Whisky', 3),
  ('5eed0000-0000-0000-0007-000000000004', '5eed0000-0000-0000-0002-000000000001', 'Cerveza', 4),
  ('5eed0000-0000-0000-0007-000000000005', '5eed0000-0000-0000-0002-000000000001', 'Vino', 5),
  ('5eed0000-0000-0000-0007-000000000011', '5eed0000-0000-0000-0002-000000000002', 'Accesorios de cómputo', 1),
  ('5eed0000-0000-0000-0007-000000000012', '5eed0000-0000-0000-0002-000000000002', 'Audio', 2);

-- ---------- Catálogo: productos ----------
-- n: número del producto (forma su id y los de sus presentaciones).
-- precio: precio base de la unidad base en céntimos. stock: unidades base.
create temporary table _seed_productos (
  n integer primary key,
  distribuidor_id uuid not null,
  categoria integer not null,
  nombre text not null,
  unidad_base text not null,
  precio bigint not null,
  stock integer not null
) on commit drop;

insert into _seed_productos (n, distribuidor_id, categoria, nombre, unidad_base, precio, stock)
select v.n, '5eed0000-0000-0000-0002-000000000001', v.categoria, v.nombre, 'botella', v.precio, v.stock
from (values
  ( 1, 1, 'Ron Añejo 7 años',           4200, 120),
  ( 2, 1, 'Ron Blanco Superior',        2600, 150),
  ( 3, 1, 'Ron Dorado Reserva',         3400,  90),
  ( 4, 1, 'Ron Especiado',              2900,  80),
  ( 5, 1, 'Ron Coco',                   2400,  70),
  ( 6, 1, 'Ron Carta Oro 5 años',       3100, 100),
  ( 7, 2, 'Pisco Puro Quebranta',       3300, 110),
  ( 8, 2, 'Pisco Acholado',             3600,  95),
  ( 9, 2, 'Pisco Italia',               3000, 130),
  (10, 2, 'Pisco Mosto Verde',          4100,  60),
  (11, 2, 'Pisco Torontel',             2800,  85),
  (12, 2, 'Pisco Mosto Verde Reserva',  5200,  60),
  (13, 3, 'Whisky Blended 8 años',      4500,  75),
  (14, 3, 'Whisky Blended 12 años',     6800,  60),
  (15, 3, 'Whisky Single Malt',         9500,  60),
  (16, 3, 'Whisky Bourbon',             5600,  65),
  (17, 3, 'Whisky Irlandés',            6200,  60),
  (18, 3, 'Whisky Escocés 18 años',    12500,  60),
  (19, 4, 'Cerveza Lager 650 ml',        450, 600),
  (20, 4, 'Cerveza Rubia Artesanal',    1100, 180),
  (21, 4, 'Cerveza Negra',              1000, 160),
  (22, 4, 'Cerveza IPA',                1300, 140),
  (23, 4, 'Cerveza Trigo',              1050, 150),
  (24, 4, 'Cerveza Pilsen',              950, 360),
  (25, 5, 'Vino Tinto Malbec',          3200,  90),
  (26, 5, 'Vino Blanco Sauvignon',      3100,  80),
  (27, 5, 'Vino Rosado',                2700,  70),
  (28, 5, 'Vino Tinto Carménère',       3800,  65),
  (29, 5, 'Vino Espumante',             4800,  60),
  (30, 5, 'Vino Tinto Reserva',         5900,  60)
) as v (n, categoria, nombre, precio, stock);

insert into _seed_productos (n, distribuidor_id, categoria, nombre, unidad_base, precio, stock)
select v.n, '5eed0000-0000-0000-0002-000000000002', v.categoria, v.nombre, 'unidad', v.precio, v.stock
from (values
  (101, 11, 'Mouse inalámbrico',         2500, 300),
  (102, 11, 'Teclado USB',               3500, 200),
  (103, 11, 'Cable HDMI 2 m',            1500, 400),
  (104, 11, 'Cargador USB-C 20 W',       3900, 250),
  (105, 12, 'Audífonos in-ear',          2900, 300),
  (106, 12, 'Parlante Bluetooth',        8900, 120),
  (107, 12, 'Audífonos over-ear',       12900,  80),
  (108, 12, 'Micrófono de solapa',       4500, 150)
) as v (n, categoria, nombre, precio, stock);

insert into public.productos
  (id, distribuidor_id, categoria_id, nombre, unidad_base, stock_fisico)
select ('5eed0000-0000-0000-0008-' || lpad(s.n::text, 12, '0'))::uuid,
       s.distribuidor_id,
       ('5eed0000-0000-0000-0007-' || lpad(s.categoria::text, 12, '0'))::uuid,
       s.nombre, s.unidad_base, s.stock
from _seed_productos s;

-- El stock inicial queda también en el historial, como un ingreso.
insert into public.movimientos_stock
  (id, distribuidor_id, producto_id, tipo, delta_fisico, nota)
select ('5eed0000-0000-0000-000e-' || lpad(s.n::text, 12, '0'))::uuid,
       s.distribuidor_id,
       ('5eed0000-0000-0000-0008-' || lpad(s.n::text, 12, '0'))::uuid,
       'ingreso', s.stock, 'Stock inicial (seed)'
from _seed_productos s;

-- ---------- Catálogo: presentaciones ----------
-- Id de la presentación: n * 100 + k (k = 1 primera, 2 caja o pack, 3 six pack).
-- Licores: Botella x1 al precio base; Caja x12 con 8 % de descuento; Six pack
-- x6 (solo cervezas, categoría 4) con 5 %. Electrónica: Unidad x1; Pack x10
-- con 10 %.
insert into public.presentaciones
  (id, distribuidor_id, producto_id, nombre, factor, precio_base_centimos, orden)
select ('5eed0000-0000-0000-0009-' || lpad((s.n * 100 + p.k)::text, 12, '0'))::uuid,
       s.distribuidor_id,
       ('5eed0000-0000-0000-0008-' || lpad(s.n::text, 12, '0'))::uuid,
       p.nombre, p.factor, s.precio * p.factor * p.porcentaje / 100, p.k
from _seed_productos s
join (values
  ('botella', 1, 'Botella',  1, 100),
  ('botella', 2, 'Caja x12', 12, 92),
  ('botella', 3, 'Six pack',  6, 95),
  ('unidad',  1, 'Unidad',    1, 100),
  ('unidad',  2, 'Pack x10', 10, 90)
) as p (unidad_base, k, nombre, factor, porcentaje)
  on p.unidad_base = s.unidad_base
where p.k <> 3 or s.categoria = 4;

-- Precio por volumen en cada botella: desde 12 botellas, 5 % menos.
insert into public.precios_volumen
  (id, distribuidor_id, presentacion_id, cantidad_minima, precio_centimos)
select ('5eed0000-0000-0000-000a-' || lpad(s.n::text, 12, '0'))::uuid,
       s.distribuidor_id,
       ('5eed0000-0000-0000-0009-' || lpad((s.n * 100 + 1)::text, 12, '0'))::uuid,
       12, s.precio * 95 / 100
from _seed_productos s
where s.unidad_base = 'botella';

-- ---------- Lista de precios "Mayorista" (Licores) ----------
-- 10 presentaciones: botella y caja del primer producto de cada categoría,
-- con 10 % menos que el precio base. Asignada a Licorería San Martín.
insert into public.listas_precios (id, distribuidor_id, nombre) values
  ('5eed0000-0000-0000-000b-000000000001', '5eed0000-0000-0000-0002-000000000001', 'Mayorista');

insert into public.precios_lista
  (id, distribuidor_id, lista_precios_id, presentacion_id, precio_centimos)
select ('5eed0000-0000-0000-000c-' || lpad(pr_n::text, 12, '0'))::uuid,
       pr.distribuidor_id,
       '5eed0000-0000-0000-000b-000000000001',
       pr.id,
       pr.precio_base_centimos * 90 / 100
from (
  select pr.*, s.n * 100 + k.k as pr_n
  from _seed_productos s
  cross join (values (1), (2)) as k (k)
  join public.presentaciones pr
    on pr.id = ('5eed0000-0000-0000-0009-' || lpad((s.n * 100 + k.k)::text, 12, '0'))::uuid
  where s.n in (1, 7, 13, 19, 25)
) pr;

update public.clientes_negocio
set lista_precios_id = '5eed0000-0000-0000-000b-000000000001'
where id = '5eed0000-0000-0000-0005-000000000002';

-- ---------- Invitaciones ----------
-- Códigos fijos con el alfabeto de invitaciones (sin 0, O, 1, I, L).
insert into public.invitaciones
  (id, distribuidor_id, codigo, rol, cliente_negocio_id, creada_por, vence_en)
values
  ('5eed0000-0000-0000-000d-000000000001', '5eed0000-0000-0000-0002-000000000001',
   'DEMA2345', 'cliente', '5eed0000-0000-0000-0005-000000000003',
   '5eed0000-0000-0000-0004-000000000001', now() + interval '30 days'),
  ('5eed0000-0000-0000-000d-000000000002', '5eed0000-0000-0000-0002-000000000002',
   'DEMA6789', 'cliente', '5eed0000-0000-0000-0005-000000000012',
   '5eed0000-0000-0000-0004-000000000021', now() + interval '30 days');

commit;
