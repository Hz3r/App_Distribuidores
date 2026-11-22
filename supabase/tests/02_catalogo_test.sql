-- Pruebas del módulo 2: catálogo e inventario.
-- Ids del módulo 1: D1 0d01, D2 0d02; bodegas 0b01, 0b02 (D1), 0b03 (D2);
-- A1 00a1, V1 00b1, R1 00e1, C1 00c1, C2 00c2, A2 00a2, S1 00f1, N1 0091.
-- Ids del módulo 2: categorías 0ca1 (D1), 0ca2 (D2); productos P1 0101,
-- P2 0102 (inactivo), P3 0103 (D2); presentaciones PR1 0201, PR2 0202,
-- PR4 0204, PR3 0203 (D2); lista L1 0301 asignada a 0b02.
begin;
\ir soporte/datos_m2.sql

-- 2.1 a 2.8: lectura y escritura directa del catálogo.
select pruebas.como('00000000-0000-0000-0000-0000000000c2');
select pruebas.afirma(
  pruebas.cuenta('select 1 from public.productos') = 1
  and pruebas.cuenta($q$select 1 from public.productos where id = '00000000-0000-0000-0000-000000000101'$q$) = 1,
  '2.1 el cliente ve solo los productos activos de su distribuidor');

select pruebas.como('00000000-0000-0000-0000-0000000000a1');
select pruebas.afirma(
  pruebas.cuenta('select 1 from public.productos') = 2
  and pruebas.cuenta($q$select 1 from public.productos where id in ('00000000-0000-0000-0000-000000000101', '00000000-0000-0000-0000-000000000102')$q$) = 2,
  '2.2 el admin ve también los productos inactivos de su distribuidor');

select pruebas.como('00000000-0000-0000-0000-0000000000c1');
select pruebas.afirma(
  pruebas.cuenta('select 1 from public.productos') = 2
  and pruebas.cuenta($q$select 1 from public.productos where id in ('00000000-0000-0000-0000-000000000101', '00000000-0000-0000-0000-000000000103')$q$) = 2,
  '2.3 el cliente de dos distribuidores ve los productos activos de ambos');

select pruebas.como('00000000-0000-0000-0000-0000000000c2');
do $$
declare
  v_n integer;
begin
  update public.productos set nombre = 'x';
  get diagnostics v_n = row_count;
  perform pruebas.afirma(v_n = 0, '2.4 el cliente no edita productos (0 filas)');
end $$;

select pruebas.espera_error(
  $q$insert into public.productos (distribuidor_id, nombre)
     values ('00000000-0000-0000-0000-000000000d01', 'Pirata')$q$,
  '42501', '2.5 el cliente no crea productos');

select pruebas.como('00000000-0000-0000-0000-0000000000a1');
select pruebas.espera_error(
  $q$update public.productos set stock_fisico = 999
     where id = '00000000-0000-0000-0000-000000000101'$q$,
  '42501', '2.6 ni el admin escribe el stock con un update directo');

do $$
declare
  v_n integer;
begin
  update public.productos set nombre = 'Ron Añejo 7'
  where id = '00000000-0000-0000-0000-000000000101';
  get diagnostics v_n = row_count;
  perform pruebas.afirma(v_n = 1, '2.7 el admin edita el nombre de un producto');
end $$;

select pruebas.espera_error(
  $q$insert into public.productos (distribuidor_id, nombre)
     values ('00000000-0000-0000-0000-000000000d02', 'Intruso')$q$,
  '42501', '2.8 el admin de D1 no crea productos en D2');

-- 2.9 a 2.17: movimientos de stock.
select public.registrar_movimiento_stock('00000000-0000-0000-0000-000000000101', 'ingreso', 24);
select pruebas.afirma(
  (select stock_fisico from public.productos where id = '00000000-0000-0000-0000-000000000101') = 144
  and pruebas.cuenta($q$select 1 from public.movimientos_stock
                        where producto_id = '00000000-0000-0000-0000-000000000101'
                          and tipo = 'ingreso' and delta_fisico = 24 and delta_comprometido = 0
                          and distribuidor_id = '00000000-0000-0000-0000-000000000d01'
                          and hecho_por = '00000000-0000-0000-0000-0000000000a1'$q$) = 1,
  '2.9 un ingreso suma al físico y queda registrado a nombre del admin');

select public.registrar_movimiento_stock('00000000-0000-0000-0000-000000000101', 'ajuste', -4,
                                         'merma');
select pruebas.afirma(
  (select stock_fisico from public.productos where id = '00000000-0000-0000-0000-000000000101') = 140,
  '2.10 un ajuste negativo resta del físico');

select pruebas.espera_error(
  $q$select public.registrar_movimiento_stock('00000000-0000-0000-0000-000000000101', 'ajuste', -500)$q$,
  'P0001', '2.11 un ajuste no deja el físico por debajo del comprometido');
select pruebas.afirma(
  (select stock_fisico from public.productos where id = '00000000-0000-0000-0000-000000000101') = 140
  and pruebas.cuenta('select 1 from public.movimientos_stock') = 2,
  '2.11 el stock y el historial quedan sin cambios');

select pruebas.espera_error(
  $q$select public.registrar_movimiento_stock('00000000-0000-0000-0000-000000000101', 'reserva', 5)$q$,
  '22023', '2.12 la reserva no se registra a mano');

select pruebas.espera_error(
  $q$select public.registrar_movimiento_stock('00000000-0000-0000-0000-000000000101', 'ingreso', 0)$q$,
  '22023', '2.13 un ingreso exige cantidad mayor a cero');

select pruebas.como('00000000-0000-0000-0000-0000000000b1');
select pruebas.espera_error(
  $q$select public.registrar_movimiento_stock('00000000-0000-0000-0000-000000000101', 'ingreso', 1)$q$,
  '42501', '2.14 el vendedor no registra movimientos');

select pruebas.como('00000000-0000-0000-0000-0000000000a1');
select pruebas.espera_error(
  $q$select public.registrar_movimiento_stock('00000000-0000-0000-0000-000000000103', 'ingreso', 1)$q$,
  '42501', '2.15 el admin de D1 no mueve stock de D2');

select pruebas.espera_error(
  $q$update public.movimientos_stock set nota = 'x'$q$,
  '42501', '2.16 nadie edita movimientos');
select pruebas.espera_error(
  $q$delete from public.movimientos_stock$q$,
  '42501', '2.16 nadie borra movimientos');

select pruebas.como('00000000-0000-0000-0000-0000000000c2');
select pruebas.afirma(pruebas.cuenta('select 1 from public.movimientos_stock') = 0,
  '2.17 el cliente no ve movimientos');

-- 2.18 a 2.23: regla de precio.
select pruebas.como_servicio();
select pruebas.afirma(
  privado.precio_para('00000000-0000-0000-0000-000000000201', '00000000-0000-0000-0000-000000000b01', 1) = 4200,
  '2.18 sin lista ni volumen se cobra el precio base');
select pruebas.afirma(
  privado.precio_para('00000000-0000-0000-0000-000000000201', '00000000-0000-0000-0000-000000000b01', 12) = 3900,
  '2.19 desde 12 unidades aplica el precio por volumen');
select pruebas.afirma(
  privado.precio_para('00000000-0000-0000-0000-000000000201', '00000000-0000-0000-0000-000000000b02', 1) = 4000,
  '2.20 la bodega con lista paga el precio de su lista');
select pruebas.afirma(
  privado.precio_para('00000000-0000-0000-0000-000000000201', '00000000-0000-0000-0000-000000000b02', 12) = 3900,
  '2.21 se cobra el menor entre lista y volumen');
select pruebas.afirma(
  privado.precio_para('00000000-0000-0000-0000-000000000202', '00000000-0000-0000-0000-000000000b02', 1) = 48000,
  '2.22 sin precio en la lista se cobra el base');

update public.listas_precios set activo = false
where id = '00000000-0000-0000-0000-000000000301';
select pruebas.afirma(
  privado.precio_para('00000000-0000-0000-0000-000000000201', '00000000-0000-0000-0000-000000000b02', 1) = 4200,
  '2.23 una lista inactiva no se aplica');
-- Se reactiva L1 para las pruebas siguientes.
update public.listas_precios set activo = true
where id = '00000000-0000-0000-0000-000000000301';

-- 2.24 a 2.27: listas de precios y su asignación.
select pruebas.como('00000000-0000-0000-0000-0000000000c2');
select pruebas.afirma(
  pruebas.cuenta('select 1 from public.precios_lista') = 1
  and pruebas.cuenta('select 1 from public.listas_precios') = 1,
  '2.24 el cliente ve su lista y sus precios');

select pruebas.como('00000000-0000-0000-0000-0000000000c1');
select pruebas.afirma(
  pruebas.cuenta('select 1 from public.precios_lista') = 0
  and pruebas.cuenta('select 1 from public.listas_precios') = 0,
  '2.25 el cliente sin lista no ve listas ni precios de lista');

select pruebas.como('00000000-0000-0000-0000-0000000000b1');
select pruebas.espera_error(
  $q$update public.clientes_negocio set lista_precios_id = null
     where id = '00000000-0000-0000-0000-000000000b02'$q$,
  '42501', '2.26 el vendedor no cambia la lista de una bodega');
select pruebas.espera_error(
  $q$insert into public.clientes_negocio (distribuidor_id, nombre_negocio, lista_precios_id)
     values ('00000000-0000-0000-0000-000000000d01', 'Bodega Nueva',
             '00000000-0000-0000-0000-000000000301')$q$,
  '42501', '2.26 el vendedor no crea una bodega con lista');

do $$
declare
  v_n integer;
begin
  update public.clientes_negocio set direccion = 'Av. Uno 123'
  where id = '00000000-0000-0000-0000-000000000b02';
  get diagnostics v_n = row_count;
  perform pruebas.afirma(v_n = 1, '2.27 el vendedor edita los demás datos de la bodega');
end $$;

-- 2.28 y 2.29: imágenes en Storage.
select pruebas.como('00000000-0000-0000-0000-0000000000a1');
do $$
declare
  v_ins integer;
  v_upd integer;
  v_del integer;
begin
  insert into storage.objects (bucket_id, name)
  values ('catalogo', '00000000-0000-0000-0000-000000000d01/foto.png');
  get diagnostics v_ins = row_count;
  update storage.objects set owner = '00000000-0000-0000-0000-0000000000a1'
  where bucket_id = 'catalogo' and name = '00000000-0000-0000-0000-000000000d01/foto.png';
  get diagnostics v_upd = row_count;
  delete from storage.objects
  where bucket_id = 'catalogo' and name = '00000000-0000-0000-0000-000000000d01/foto.png';
  get diagnostics v_del = row_count;
  perform pruebas.afirma(v_ins = 1 and v_upd = 1 and v_del = 1,
    '2.28 el admin sube, reemplaza y borra en la carpeta de su distribuidor');
end $$;

select pruebas.espera_error(
  $q$insert into storage.objects (bucket_id, name)
     values ('catalogo', '00000000-0000-0000-0000-000000000d02/foto.png')$q$,
  '42501', '2.29 el admin de D1 no sube a la carpeta de D2');
select pruebas.espera_error(
  $q$insert into storage.objects (bucket_id, name) values ('catalogo', 'suelta.png')$q$,
  '42501', '2.29 nadie sube fuera de una carpeta de distribuidor');

-- 2.30: la restricción de stock vale incluso para el rol de servicio.
select pruebas.como_servicio();
select pruebas.espera_error(
  $q$update public.productos set stock_comprometido = 999
     where id = '00000000-0000-0000-0000-000000000101'$q$,
  '23514', '2.30 el comprometido no supera al físico');

-- 2.31: id y distribuidor de una bodega no cambian, ni siquiera para el admin.
select pruebas.como('00000000-0000-0000-0000-0000000000a1');
select pruebas.espera_error(
  $q$update public.clientes_negocio set distribuidor_id = '00000000-0000-0000-0000-000000000d02'
     where id = '00000000-0000-0000-0000-000000000b02'$q$,
  '42501', '2.31 el admin no mueve una bodega a otro distribuidor');
-- Sin el trigger, este cambio fallaría con 23503 (la membresía de C1 apunta a 0b01).
select pruebas.espera_error(
  $q$update public.clientes_negocio set id = gen_random_uuid()
     where id = '00000000-0000-0000-0000-000000000b01'$q$,
  '42501', '2.31 el admin no cambia el id de una bodega');

rollback;
