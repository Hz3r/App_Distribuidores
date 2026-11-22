-- Datos fijos del módulo 2 (catálogo e inventario). Incluye los del módulo 1.
-- Se insertan como rol de servicio. Ids con la forma
-- 00000000-0000-0000-0000-00000000XXXX.
--   D1: categoría 0ca1 "Ron"
--       P1 0101 "Ron Añejo" (botella, físico 120)
--       P2 0102 "Ron Descontinuado" (inactivo, físico 10)
--       PR1 0201 P1 "Botella" x1 a 4200, desde 12: 3900
--       PR2 0202 P1 "Caja x12" x12 a 48000
--       PR4 0204 P2 "Botella" x1 a 3000
--       L1 0301 "Mayorista": PR1 a 4000; asignada a la bodega 0b02
--   D2: categoría 0ca2 "Accesorios"
--       P3 0103 "Mouse" (unidad, físico 200)
--       PR3 0203 P3 "Unidad" x1 a 2500

\ir datos_m1.sql

select pruebas.como_servicio();

insert into public.categorias (id, distribuidor_id, nombre) values
  ('00000000-0000-0000-0000-000000000ca1', '00000000-0000-0000-0000-000000000d01', 'Ron'),
  ('00000000-0000-0000-0000-000000000ca2', '00000000-0000-0000-0000-000000000d02', 'Accesorios');

insert into public.productos
  (id, distribuidor_id, categoria_id, nombre, unidad_base, stock_fisico, activo)
values
  ('00000000-0000-0000-0000-000000000101', '00000000-0000-0000-0000-000000000d01',
   '00000000-0000-0000-0000-000000000ca1', 'Ron Añejo', 'botella', 120, true),
  ('00000000-0000-0000-0000-000000000102', '00000000-0000-0000-0000-000000000d01',
   '00000000-0000-0000-0000-000000000ca1', 'Ron Descontinuado', 'botella', 10, false),
  ('00000000-0000-0000-0000-000000000103', '00000000-0000-0000-0000-000000000d02',
   '00000000-0000-0000-0000-000000000ca2', 'Mouse', 'unidad', 200, true);

insert into public.presentaciones
  (id, distribuidor_id, producto_id, nombre, factor, precio_base_centimos)
values
  ('00000000-0000-0000-0000-000000000201', '00000000-0000-0000-0000-000000000d01',
   '00000000-0000-0000-0000-000000000101', 'Botella', 1, 4200),
  ('00000000-0000-0000-0000-000000000202', '00000000-0000-0000-0000-000000000d01',
   '00000000-0000-0000-0000-000000000101', 'Caja x12', 12, 48000),
  ('00000000-0000-0000-0000-000000000204', '00000000-0000-0000-0000-000000000d01',
   '00000000-0000-0000-0000-000000000102', 'Botella', 1, 3000),
  ('00000000-0000-0000-0000-000000000203', '00000000-0000-0000-0000-000000000d02',
   '00000000-0000-0000-0000-000000000103', 'Unidad', 1, 2500);

insert into public.precios_volumen
  (distribuidor_id, presentacion_id, cantidad_minima, precio_centimos)
values
  ('00000000-0000-0000-0000-000000000d01', '00000000-0000-0000-0000-000000000201', 12, 3900);

insert into public.listas_precios (id, distribuidor_id, nombre) values
  ('00000000-0000-0000-0000-000000000301', '00000000-0000-0000-0000-000000000d01', 'Mayorista');

insert into public.precios_lista
  (distribuidor_id, lista_precios_id, presentacion_id, precio_centimos)
values
  ('00000000-0000-0000-0000-000000000d01', '00000000-0000-0000-0000-000000000301',
   '00000000-0000-0000-0000-000000000201', 4000);

update public.clientes_negocio
set lista_precios_id = '00000000-0000-0000-0000-000000000301'
where id = '00000000-0000-0000-0000-000000000b02';
