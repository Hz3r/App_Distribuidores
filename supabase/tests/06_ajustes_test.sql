-- Pruebas de la migración 6: ajustes posteriores a la revisión.
-- Ids del módulo 1: D1 0d01, D2 0d02; bodegas 0b01 (C1), 0b02 (C2) en D1,
-- 0b03 (C1) en D2; A1 00a1, V1 00b1, R1 00e1, C1 00c1, C2 00c2.
-- Ids del módulo 2: categorías 0ca1 (D1), 0ca2 (D2); productos P1 0101,
-- P2 0102 (inactivo), P3 0103 (D2); presentaciones PR1 0201, PR2 0202 (de
-- P1), PR4 0204 (de P2, activa), PR3 0203 (D2); precio por volumen de PR1;
-- lista L1 0301 (PR1) asignada a 0b02.
-- Los casos corren en orden dentro de una transacción.
begin;
\ir soporte/datos_m3.sql

\set d1 00000000-0000-0000-0000-000000000d01
\set a1 00000000-0000-0000-0000-0000000000a1
\set v1 00000000-0000-0000-0000-0000000000b1
\set r1 00000000-0000-0000-0000-0000000000e1
\set c1 00000000-0000-0000-0000-0000000000c1
\set c2 00000000-0000-0000-0000-0000000000c2

-- 7.1: la bodega no ve la presentación activa de un producto inactivo.
select pruebas.como(:'c2');
select pruebas.afirma(
  pruebas.cuenta($q$select 1 from public.presentaciones
                    where id = '00000000-0000-0000-0000-000000000204'$q$) = 0
  and pruebas.cuenta($q$select 1 from public.presentaciones
                        where id in ('00000000-0000-0000-0000-000000000201',
                                     '00000000-0000-0000-0000-000000000202')$q$) = 2,
  '7.1 C2 ve PR1 y PR2 pero no PR4 (su producto P2 está inactivo)');

-- 7.2: admin y vendedor siguen viendo todo.
select pruebas.como(:'a1');
select pruebas.afirma(
  pruebas.cuenta($q$select 1 from public.presentaciones
                    where id = '00000000-0000-0000-0000-000000000204'$q$) = 1,
  '7.2 A1 ve PR4');
select pruebas.como(:'v1');
select pruebas.afirma(
  pruebas.cuenta($q$select 1 from public.presentaciones
                    where id = '00000000-0000-0000-0000-000000000204'$q$) = 1,
  '7.2 V1 ve PR4');

-- 7.3: el precio por volumen de PR4 no se le muestra a la bodega.
select pruebas.como_servicio();
insert into public.precios_volumen
  (distribuidor_id, presentacion_id, cantidad_minima, precio_centimos)
values
  (:'d1', '00000000-0000-0000-0000-000000000204', 6, 2800);

select pruebas.como(:'c2');
select pruebas.afirma(
  pruebas.cuenta($q$select 1 from public.precios_volumen
                    where presentacion_id = '00000000-0000-0000-0000-000000000204'$q$) = 0
  and pruebas.cuenta($q$select 1 from public.precios_volumen
                        where presentacion_id = '00000000-0000-0000-0000-000000000201'$q$) = 1,
  '7.3 C2 no ve el precio por volumen de PR4 (sí el de PR1)');
select pruebas.como(:'a1');
select pruebas.afirma(
  pruebas.cuenta($q$select 1 from public.precios_volumen
                    where presentacion_id = '00000000-0000-0000-0000-000000000204'$q$) = 1,
  '7.3 A1 ve el precio por volumen de PR4');

-- 7.4: con la categoría 0ca1 inactiva, la bodega no ve nada de D1.
select pruebas.como(:'c2');
select pruebas.afirma(
  pruebas.cuenta('select 1 from public.precios_lista') = 1,
  '7.4 (antes) C2 ve el precio de su lista para PR1');

select pruebas.como_servicio();
update public.categorias set activo = false
where id = '00000000-0000-0000-0000-000000000ca1';

select pruebas.como(:'c2');
select pruebas.afirma(
  pruebas.cuenta(format('select 1 from public.productos where distribuidor_id = %L', :'d1')) = 0
  and pruebas.cuenta(format('select 1 from public.presentaciones where distribuidor_id = %L', :'d1')) = 0
  and pruebas.cuenta(format('select 1 from public.precios_volumen where distribuidor_id = %L', :'d1')) = 0
  and pruebas.cuenta(format('select 1 from public.precios_lista where distribuidor_id = %L', :'d1')) = 0,
  '7.4 C2 no ve productos, presentaciones ni precios de D1 con la categoría inactiva');

select pruebas.como(:'c1');
select pruebas.afirma(
  pruebas.cuenta($q$select 1 from public.productos
                    where id = '00000000-0000-0000-0000-000000000103'$q$) = 1
  and pruebas.cuenta($q$select 1 from public.presentaciones
                        where id = '00000000-0000-0000-0000-000000000203'$q$) = 1,
  '7.4 C1 sigue viendo P3 y PR3 de D2');

-- 7.5: el admin sigue viendo todo con la categoría inactiva.
select pruebas.como(:'a1');
select pruebas.afirma(
  pruebas.cuenta(format('select 1 from public.productos where distribuidor_id = %L', :'d1')) = 2
  and pruebas.cuenta(format('select 1 from public.presentaciones where distribuidor_id = %L', :'d1')) = 3,
  '7.5 A1 ve los 2 productos y las 3 presentaciones de D1 con la categoría inactiva');

-- 7.6: con todo activo, el repartidor ve PR1 y PR2, no PR4.
select pruebas.como_servicio();
update public.categorias set activo = true
where id = '00000000-0000-0000-0000-000000000ca1';

select pruebas.como(:'r1');
select pruebas.afirma(
  pruebas.cuenta($q$select 1 from public.presentaciones
                    where id = '00000000-0000-0000-0000-000000000204'$q$) = 0
  and pruebas.cuenta($q$select 1 from public.presentaciones
                        where id in ('00000000-0000-0000-0000-000000000201',
                                     '00000000-0000-0000-0000-000000000202')$q$) = 2,
  '7.6 R1 ve PR1 y PR2 pero no PR4');

-- 7.7: public.rls_auto_enable() solo existe en Supabase real (la crea la
-- plataforma). Si existe, ni anon ni authenticated la ejecutan.
select pruebas.como_servicio();
select pruebas.afirma(
  case
    when to_regprocedure('public.rls_auto_enable()') is null then true
    else not has_function_privilege('anon', 'public.rls_auto_enable()', 'EXECUTE')
         and not has_function_privilege('authenticated', 'public.rls_auto_enable()', 'EXECUTE')
  end,
  '7.7 anon y authenticated no ejecutan public.rls_auto_enable() (si existe)');

rollback;
