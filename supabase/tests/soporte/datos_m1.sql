-- Datos fijos del módulo 1 (identidad y acceso). Se insertan como rol de
-- servicio. Ids con la forma 00000000-0000-0000-0000-00000000XXXX.
--   D1 0d01 "Licores Demo"     D2 0d02 "Electro Demo"
--   Bodegas D1: 0b01, 0b02     Bodega D2: 0b03
--   A1 00a1 admin D1           V1 00b1 vendedor D1     R1 00e1 repartidor D1
--   C1 00c1 cliente D1 (0b01) y D2 (0b03)              C2 00c2 cliente D1 (0b02)
--   A2 00a2 admin D2           S1 00f1 Super Admin     N1 0091 sin membresías

select pruebas.como_servicio();

-- El trigger de auth.users crea cada perfil.
insert into auth.users (id, email, phone, raw_user_meta_data) values
  ('00000000-0000-0000-0000-0000000000a1', 'a1@demo.pe', '51900000001', '{"nombre": "Admin Uno"}'),
  ('00000000-0000-0000-0000-0000000000b1', 'v1@demo.pe', '51900000002', '{"nombre": "Vendedor Uno"}'),
  ('00000000-0000-0000-0000-0000000000e1', 'r1@demo.pe', '51900000003', '{"nombre": "Repartidor Uno"}'),
  ('00000000-0000-0000-0000-0000000000c1', 'c1@demo.pe', '51900000004', '{"nombre": "Cliente Uno"}'),
  ('00000000-0000-0000-0000-0000000000c2', 'c2@demo.pe', '51900000005', '{"nombre": "Cliente Dos"}'),
  ('00000000-0000-0000-0000-0000000000a2', 'a2@demo.pe', '51900000006', '{"nombre": "Admin Dos"}'),
  ('00000000-0000-0000-0000-0000000000f1', 's1@demo.pe', null, '{"nombre": "Super Admin"}'),
  ('00000000-0000-0000-0000-000000000091', 'n1@demo.pe', null, null);

update public.perfiles set es_super_admin = true
where id = '00000000-0000-0000-0000-0000000000f1';

insert into public.distribuidores (id, nombre, slug, rubro, estado) values
  ('00000000-0000-0000-0000-000000000d01', 'Licores Demo', 'licores-demo', 'licores', 'activo'),
  ('00000000-0000-0000-0000-000000000d02', 'Electro Demo', 'electro-demo', 'electronica', 'activo');

insert into public.clientes_negocio (id, distribuidor_id, nombre_negocio) values
  ('00000000-0000-0000-0000-000000000b01', '00000000-0000-0000-0000-000000000d01', 'Bodega Uno'),
  ('00000000-0000-0000-0000-000000000b02', '00000000-0000-0000-0000-000000000d01', 'Bodega Dos'),
  ('00000000-0000-0000-0000-000000000b03', '00000000-0000-0000-0000-000000000d02', 'Tienda Tres');

insert into public.membresias (perfil_id, distribuidor_id, rol, cliente_negocio_id) values
  ('00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-000000000d01', 'admin', null),
  ('00000000-0000-0000-0000-0000000000b1', '00000000-0000-0000-0000-000000000d01', 'vendedor', null),
  ('00000000-0000-0000-0000-0000000000e1', '00000000-0000-0000-0000-000000000d01', 'repartidor', null),
  ('00000000-0000-0000-0000-0000000000c1', '00000000-0000-0000-0000-000000000d01', 'cliente', '00000000-0000-0000-0000-000000000b01'),
  ('00000000-0000-0000-0000-0000000000c1', '00000000-0000-0000-0000-000000000d02', 'cliente', '00000000-0000-0000-0000-000000000b03'),
  ('00000000-0000-0000-0000-0000000000c2', '00000000-0000-0000-0000-000000000d01', 'cliente', '00000000-0000-0000-0000-000000000b02'),
  ('00000000-0000-0000-0000-0000000000a2', '00000000-0000-0000-0000-000000000d02', 'admin', null);
