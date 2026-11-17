-- =============================================================================
-- SEED DE DESARROLLO (solo local / DEV). BORRADOR, pendiente de revisión.
-- Distribuidor de licores de prueba: 30 productos, presentaciones, precios por
-- volumen, 1 admin, 3 clientes y 1 repartidor.
-- Los usuarios se insertan en auth.users sin contraseña: sirven para probar
-- RLS y redirección por rol, no para iniciar sesión.
-- =============================================================================

-- ---------- Distribuidor ----------
insert into distribuidores (id, nombre, config_tema) values (
  '00000000-0000-0000-0000-000000000d01',
  'Licores del Norte (demo)',
  '{"nombre": "Licores del Norte", "logo_url": null, "color_primario": "#1F3A5F", "color_secundario": "#F2A900"}'
);

-- ---------- Cuentas de prueba ----------
insert into auth.users (id, email, raw_app_meta_data) values
  ('00000000-0000-0000-0000-0000000000a1', 'admin.demo@example.com',     '{"rol": "admin"}'),
  ('00000000-0000-0000-0000-0000000000c1', 'bodega.roble@example.com',   '{"rol": "cliente"}'),
  ('00000000-0000-0000-0000-0000000000c2', 'licoreria.sanmartin@example.com', '{"rol": "cliente"}'),
  ('00000000-0000-0000-0000-0000000000c3', 'licoreria.esquina@example.com',  '{"rol": "cliente"}'),
  ('00000000-0000-0000-0000-0000000000e1', 'repartidor.demo@example.com', '{"rol": "repartidor"}');

insert into usuarios (id, distribuidor_id, rol, nombre, telefono) values
  ('00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-000000000d01', 'admin',      'Administrador demo', '900000001'),
  ('00000000-0000-0000-0000-0000000000c1', '00000000-0000-0000-0000-000000000d01', 'cliente',    'Bodega El Roble',    '900000002'),
  ('00000000-0000-0000-0000-0000000000c2', '00000000-0000-0000-0000-000000000d01', 'cliente',    'Licorería San Martín', '900000003'),
  ('00000000-0000-0000-0000-0000000000c3', '00000000-0000-0000-0000-000000000d01', 'cliente',    'Licorería La Esquina', '900000004'),
  ('00000000-0000-0000-0000-0000000000e1', '00000000-0000-0000-0000-000000000d01', 'repartidor', 'Repartidor demo',    '900000005');

insert into clientes_negocio (id, distribuidor_id, usuario_id, nombre_negocio, direccion) values
  ('00000000-0000-0000-0000-0000000000b1', '00000000-0000-0000-0000-000000000d01', '00000000-0000-0000-0000-0000000000c1', 'Bodega El Roble', 'Av. Los Olivos 123'),
  ('00000000-0000-0000-0000-0000000000b2', '00000000-0000-0000-0000-000000000d01', '00000000-0000-0000-0000-0000000000c2', 'Licorería San Martín', 'Jr. San Martín 456'),
  ('00000000-0000-0000-0000-0000000000b3', '00000000-0000-0000-0000-000000000d01', '00000000-0000-0000-0000-0000000000c3', 'Licorería La Esquina', 'Calle Principal 789');

-- ---------- Catálogo ----------
insert into categorias (id, distribuidor_id, nombre, orden) values
  ('00000000-0000-0000-0000-0000000000f1', '00000000-0000-0000-0000-000000000d01', 'Ron', 1),
  ('00000000-0000-0000-0000-0000000000f2', '00000000-0000-0000-0000-000000000d01', 'Pisco', 2),
  ('00000000-0000-0000-0000-0000000000f3', '00000000-0000-0000-0000-000000000d01', 'Whisky', 3),
  ('00000000-0000-0000-0000-0000000000f4', '00000000-0000-0000-0000-000000000d01', 'Cerveza', 4),
  ('00000000-0000-0000-0000-0000000000f5', '00000000-0000-0000-0000-000000000d01', 'Vino', 5);

-- Nombre, categoría, precio botella (céntimos), stock de botellas.
create temporary table _seed_productos (
  nombre text, categoria_id uuid, precio_botella integer, stock integer
);

insert into _seed_productos (nombre, categoria_id, precio_botella, stock) values
  ('Ron Añejo 7 años',        '00000000-0000-0000-0000-0000000000f1', 4200, 120),
  ('Ron Blanco Superior',     '00000000-0000-0000-0000-0000000000f1', 2600, 150),
  ('Ron Dorado Reserva',      '00000000-0000-0000-0000-0000000000f1', 3400, 90),
  ('Ron Especiado',           '00000000-0000-0000-0000-0000000000f1', 2900, 80),
  ('Ron Coco',                '00000000-0000-0000-0000-0000000000f1', 2400, 70),
  ('Ron Carta Oro 5 años',    '00000000-0000-0000-0000-0000000000f1', 3100, 100),
  ('Pisco Puro Quebranta',    '00000000-0000-0000-0000-0000000000f2', 3300, 110),
  ('Pisco Acholado',          '00000000-0000-0000-0000-0000000000f2', 3600, 95),
  ('Pisco Italia',            '00000000-0000-0000-0000-0000000000f2', 3000, 130),
  ('Pisco Mosto Verde',       '00000000-0000-0000-0000-0000000000f2', 4100, 60),
  ('Pisco Torontel',          '00000000-0000-0000-0000-0000000000f2', 2800, 85),
  ('Pisco Mosto Verde Reserva','00000000-0000-0000-0000-0000000000f2', 5200, 40),
  ('Whisky Blended 8 años',   '00000000-0000-0000-0000-0000000000f3', 4500, 75),
  ('Whisky Blended 12 años',  '00000000-0000-0000-0000-0000000000f3', 6800, 50),
  ('Whisky Single Malt',      '00000000-0000-0000-0000-0000000000f3', 9500, 25),
  ('Whisky Bourbon',          '00000000-0000-0000-0000-0000000000f3', 5600, 45),
  ('Whisky Irlandés',         '00000000-0000-0000-0000-0000000000f3', 6200, 35),
  ('Whisky Escocés 18 años',  '00000000-0000-0000-0000-0000000000f3', 12500, 20),
  ('Cerveza Lager 650 ml',    '00000000-0000-0000-0000-0000000000f4', 450, 400),
  ('Cerveza Rubia Artesanal', '00000000-0000-0000-0000-0000000000f4', 1100, 180),
  ('Cerveza Negra',           '00000000-0000-0000-0000-0000000000f4', 1000, 160),
  ('Cerveza IPA',             '00000000-0000-0000-0000-0000000000f4', 1300, 140),
  ('Cerveza Trigo',           '00000000-0000-0000-0000-0000000000f4', 1050, 150),
  ('Cerveza Pilsen',          '00000000-0000-0000-0000-0000000000f4', 950, 220),
  ('Vino Tinto Malbec',       '00000000-0000-0000-0000-0000000000f5', 3200, 90),
  ('Vino Blanco Sauvignon',   '00000000-0000-0000-0000-0000000000f5', 3100, 80),
  ('Vino Rosado',             '00000000-0000-0000-0000-0000000000f5', 2700, 70),
  ('Vino Tinto Carménère',    '00000000-0000-0000-0000-0000000000f5', 3800, 65),
  ('Vino Espumante',          '00000000-0000-0000-0000-0000000000f5', 4800, 40),
  ('Vino Tinto Reserva',      '00000000-0000-0000-0000-0000000000f5', 5900, 55);

insert into productos (distribuidor_id, categoria_id, nombre, descripcion)
select '00000000-0000-0000-0000-000000000d01', categoria_id, nombre, 'Producto de prueba'
from _seed_productos;

-- Botella (1 unidad) y caja x12 para todos; six pack x6 para cervezas.
insert into presentaciones (distribuidor_id, producto_id, tipo, nombre, precio_base_centimos, stock, unidades_por_presentacion)
select '00000000-0000-0000-0000-000000000d01', p.id, 'botella', p.nombre || ' · botella', s.precio_botella, s.stock, 1
from productos p join _seed_productos s on s.nombre = p.nombre;

insert into presentaciones (distribuidor_id, producto_id, tipo, nombre, precio_base_centimos, stock, unidades_por_presentacion)
select '00000000-0000-0000-0000-000000000d01', p.id, 'caja', p.nombre || ' · caja x12', s.precio_botella * 12 * 95 / 100, greatest(s.stock / 12, 1), 12
from productos p join _seed_productos s on s.nombre = p.nombre;

insert into presentaciones (distribuidor_id, producto_id, tipo, nombre, precio_base_centimos, stock, unidades_por_presentacion)
select '00000000-0000-0000-0000-000000000d01', p.id, 'six_pack', p.nombre || ' · six pack', s.precio_botella * 6 * 97 / 100, greatest(s.stock / 6, 1), 6
from productos p join _seed_productos s on s.nombre = p.nombre
where p.categoria_id = '00000000-0000-0000-0000-0000000000f4';

-- Precio por volumen: a partir de 5 cajas o 12 botellas hay descuento.
insert into precios_volumen (distribuidor_id, presentacion_id, cantidad_minima, precio_centimos)
select '00000000-0000-0000-0000-000000000d01', pr.id, 5, pr.precio_base_centimos * 97 / 100
from presentaciones pr where pr.tipo = 'caja';

insert into precios_volumen (distribuidor_id, presentacion_id, cantidad_minima, precio_centimos)
select '00000000-0000-0000-0000-000000000d01', pr.id, 12, pr.precio_base_centimos * 93 / 100
from presentaciones pr where pr.tipo = 'botella';

-- Limpieza de la tabla auxiliar del seed.
drop table _seed_productos;
