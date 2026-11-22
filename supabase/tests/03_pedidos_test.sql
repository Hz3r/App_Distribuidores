-- Pruebas del módulo 3: pedidos.
-- Ids del módulo 1: D1 0d01, D2 0d02; bodegas 0b01, 0b02 (D1), 0b03 (D2);
-- A1 00a1, V1 00b1, R1 00e1, C1 00c1, C2 00c2, A2 00a2, S1 00f1, N1 0091.
-- Ids del módulo 2: productos P1 0101 (físico 120), P2 0102 (inactivo),
-- P3 0103 (D2, físico 200); presentaciones PR1 0201 (P1 x1, 4200; desde 12:
-- 3900), PR2 0202 (P1 x12, 48000), PR4 0204 (P2), PR3 0203 (D2, 2500);
-- lista L1 0301 (PR1 a 4000) asignada a 0b02.
-- Módulo 3: 0b02 con crédito (límite 100000, plazo 15 días).
-- Los casos corren en orden dentro de una transacción: cada uno parte del
-- estado que dejan los anteriores.
begin;
\ir soporte/datos_m3.sql

-- 3.1 y 3.2: pedido de la propia bodega e idempotencia.
select pruebas.como('00000000-0000-0000-0000-0000000000c1');
select public.crear_pedido(
  '00000000-0000-0000-0000-000000000d01',
  '[{"presentacion_id": "00000000-0000-0000-0000-000000000202", "cantidad": 2},
    {"presentacion_id": "00000000-0000-0000-0000-000000000201", "cantidad": 6}]',
  '00000000-0000-0000-0000-00000000aa01') as pedido_31 \gset

select pruebas.afirma(
  (select numero = 1 and estado = 'recibido' and total_centimos = 121200
          and saldo_pendiente_centimos = 121200 and estado_pago = 'pendiente'
          and condicion_pago = 'contado' and despacho = 'recojo' and vence_en is null
          and creado_por = '00000000-0000-0000-0000-0000000000c1'
          and cliente_id = '00000000-0000-0000-0000-000000000b01'
          and distribuidor_id = '00000000-0000-0000-0000-000000000d01'
   from public.pedidos where id = :'pedido_31'),
  '3.1 el pedido nace en recibido con número 1, total y saldo de 121200');
select pruebas.afirma(
  (select stock_comprometido = 30 and stock_fisico = 120
   from public.productos where id = '00000000-0000-0000-0000-000000000101'),
  '3.1 se comprometen 30 botellas de P1 sin tocar el físico');
select pruebas.afirma(
  pruebas.cuenta(format($q$select 1 from public.pedido_items where pedido_id = %L$q$, :'pedido_31')) = 2
  and pruebas.cuenta(format($q$select 1 from public.pedido_items
                               where pedido_id = %L and nombre_producto = 'Ron Añejo'
                                 and ((factor = 12 and cantidad = 2 and precio_unitario_centimos = 48000
                                       and subtotal_centimos = 96000)
                                   or (factor = 1 and cantidad = 6 and precio_unitario_centimos = 4200
                                       and subtotal_centimos = 25200))$q$, :'pedido_31')) = 2,
  '3.1 dos líneas con copia de nombre, factor y precio');
select pruebas.afirma(
  pruebas.cuenta(format($q$select 1 from public.pedido_eventos
                           where pedido_id = %L and estado_anterior is null
                             and estado_nuevo = 'recibido'
                             and hecho_por = '00000000-0000-0000-0000-0000000000c1'$q$, :'pedido_31')) = 1
  and pruebas.cuenta(format($q$select 1 from public.pedido_eventos where pedido_id = %L$q$, :'pedido_31')) = 1,
  '3.1 un evento inicial en recibido');
select pruebas.como_servicio();
select pruebas.afirma(
  (select sum(delta_comprometido) = 30 and sum(delta_fisico) = 0 and bool_and(tipo = 'reserva')
          and bool_and(hecho_por = '00000000-0000-0000-0000-0000000000c1')
   from public.movimientos_stock where pedido_id = :'pedido_31'),
  '3.1 movimientos de reserva que suman 30 al comprometido');

select pruebas.como('00000000-0000-0000-0000-0000000000c1');
select pruebas.afirma(
  public.crear_pedido(
    '00000000-0000-0000-0000-000000000d01',
    '[{"presentacion_id": "00000000-0000-0000-0000-000000000202", "cantidad": 2},
      {"presentacion_id": "00000000-0000-0000-0000-000000000201", "cantidad": 6}]',
    '00000000-0000-0000-0000-00000000aa01') = :'pedido_31'
  and pruebas.cuenta('select 1 from public.pedidos') = 1
  and (select stock_comprometido from public.productos
       where id = '00000000-0000-0000-0000-000000000101') = 30,
  '3.2 repetir la clave devuelve el mismo pedido sin reservar de nuevo');

-- 3.3: stock insuficiente (96 botellas pedidas, 90 disponibles).
select pruebas.espera_error(
  $q$select public.crear_pedido(
       '00000000-0000-0000-0000-000000000d01',
       '[{"presentacion_id": "00000000-0000-0000-0000-000000000202", "cantidad": 8}]',
       '00000000-0000-0000-0000-00000000aa02')$q$,
  'P0001', '3.3 sin stock suficiente no se crea el pedido');
select pruebas.afirma(
  pruebas.cuenta('select 1 from public.pedidos') = 1
  and (select stock_comprometido from public.productos
       where id = '00000000-0000-0000-0000-000000000101') = 30,
  '3.3 pedidos y comprometido sin cambios');

-- 3.4: ítems repetidos se consolidan antes de calcular el precio.
select public.crear_pedido(
  '00000000-0000-0000-0000-000000000d01',
  '[{"presentacion_id": "00000000-0000-0000-0000-000000000201", "cantidad": 6},
    {"presentacion_id": "00000000-0000-0000-0000-000000000201", "cantidad": 6}]',
  '00000000-0000-0000-0000-00000000aa03') as pedido_34 \gset
select pruebas.afirma(
  (select numero = 2 and total_centimos = 46800 from public.pedidos where id = :'pedido_34')
  and pruebas.cuenta(format($q$select 1 from public.pedido_items where pedido_id = %L$q$, :'pedido_34')) = 1
  and pruebas.cuenta(format($q$select 1 from public.pedido_items
                               where pedido_id = %L and cantidad = 12
                                 and precio_unitario_centimos = 3900$q$, :'pedido_34')) = 1,
  '3.4 una sola línea de 12 al precio por volumen, total 46800, número 2');

-- 3.5 a 3.7: forma de p_items.
select pruebas.espera_error(
  $q$select public.crear_pedido('00000000-0000-0000-0000-000000000d01', '[]', gen_random_uuid())$q$,
  '22023', '3.5 lista de ítems vacía');
select pruebas.espera_error(
  $q$select public.crear_pedido('00000000-0000-0000-0000-000000000d01', '{}', gen_random_uuid())$q$,
  '22023', '3.5 ítems como objeto');
select pruebas.espera_error(
  $q$select public.crear_pedido('00000000-0000-0000-0000-000000000d01', null, gen_random_uuid())$q$,
  '22023', '3.5 ítems nulos');
select pruebas.espera_error(
  $q$select public.crear_pedido('00000000-0000-0000-0000-000000000d01', 'null', gen_random_uuid())$q$,
  '22023', '3.5 ítems null de JSON');
select pruebas.espera_error(
  $q$select public.crear_pedido('00000000-0000-0000-0000-000000000d01', '"x"', gen_random_uuid())$q$,
  '22023', '3.5 ítems como texto');

do $$
declare
  v_cantidad text;
begin
  foreach v_cantidad in array array['0', '-1', '1.5', '"abc"', 'null', '1000000000000'] loop
    perform pruebas.espera_error(
      format($q$select public.crear_pedido('00000000-0000-0000-0000-000000000d01',
                  '[{"presentacion_id": "00000000-0000-0000-0000-000000000201", "cantidad": %s}]',
                  gen_random_uuid())$q$, v_cantidad),
      '22023', '3.6 cantidad ' || v_cantidad);
  end loop;
end $$;

select pruebas.espera_error(
  $q$select public.crear_pedido('00000000-0000-0000-0000-000000000d01',
       '[{"presentacion_id": "no-es-uuid", "cantidad": 1}]', gen_random_uuid())$q$,
  '22023', '3.7 presentacion_id que no es uuid');
select pruebas.espera_error(
  $q$select public.crear_pedido('00000000-0000-0000-0000-000000000d01',
       '[{"cantidad": 1}]', gen_random_uuid())$q$,
  '22023', '3.7 ítem sin presentacion_id');

-- 3.8 y 3.9: presentaciones que no se pueden pedir.
select pruebas.espera_error(
  $q$select public.crear_pedido('00000000-0000-0000-0000-000000000d01',
       '[{"presentacion_id": "00000000-0000-0000-0000-000000000203", "cantidad": 1}]',
       '00000000-0000-0000-0000-00000000aa04')$q$,
  'P0002', '3.8 presentación de otro distribuidor');
select pruebas.espera_error(
  $q$select public.crear_pedido('00000000-0000-0000-0000-000000000d01',
       '[{"presentacion_id": "00000000-0000-0000-0000-000000000204", "cantidad": 1}]',
       '00000000-0000-0000-0000-00000000aa05')$q$,
  'P0002', '3.9 presentación activa de un producto inactivo');

-- 3.10: el mismo cliente pide en D2; el correlativo es por distribuidor.
select public.crear_pedido(
  '00000000-0000-0000-0000-000000000d02',
  '[{"presentacion_id": "00000000-0000-0000-0000-000000000203", "cantidad": 5}]',
  '00000000-0000-0000-0000-00000000aa06') as pedido_310 \gset
select pruebas.afirma(
  (select numero = 1 and cliente_id = '00000000-0000-0000-0000-000000000b03'
          and distribuidor_id = '00000000-0000-0000-0000-000000000d02'
   from public.pedidos where id = :'pedido_310')
  and (select stock_comprometido from public.productos
       where id = '00000000-0000-0000-0000-000000000103') = 5,
  '3.10 pedido en D2 con número 1 para la bodega 0b03');

-- 3.11 a 3.16: quién pide y para qué bodega.
select pruebas.como('00000000-0000-0000-0000-0000000000c2');
select pruebas.espera_error(
  $q$select public.crear_pedido('00000000-0000-0000-0000-000000000d01',
       '[{"presentacion_id": "00000000-0000-0000-0000-000000000201", "cantidad": 1}]',
       '00000000-0000-0000-0000-00000000aa07',
       p_cliente_id => '00000000-0000-0000-0000-000000000b01')$q$,
  '42501', '3.11 un cliente no pide a nombre de otra bodega');

select pruebas.como('00000000-0000-0000-0000-0000000000b1');
select public.crear_pedido(
  '00000000-0000-0000-0000-000000000d01',
  '[{"presentacion_id": "00000000-0000-0000-0000-000000000201", "cantidad": 1}]',
  '00000000-0000-0000-0000-00000000aa08',
  p_cliente_id => '00000000-0000-0000-0000-000000000b02') as pedido_312 \gset
select pruebas.afirma(
  (select cliente_id = '00000000-0000-0000-0000-000000000b02'
          and creado_por = '00000000-0000-0000-0000-0000000000b1'
          and total_centimos = 4000
   from public.pedidos where id = :'pedido_312'),
  '3.12 el vendedor pide a nombre de la bodega con el precio de su lista');

select pruebas.espera_error(
  $q$select public.crear_pedido('00000000-0000-0000-0000-000000000d01',
       '[{"presentacion_id": "00000000-0000-0000-0000-000000000201", "cantidad": 1}]',
       '00000000-0000-0000-0000-00000000aa09')$q$,
  '22023', '3.13 el vendedor debe indicar la bodega');
select pruebas.espera_error(
  $q$select public.crear_pedido('00000000-0000-0000-0000-000000000d01',
       '[{"presentacion_id": "00000000-0000-0000-0000-000000000201", "cantidad": 1}]',
       '00000000-0000-0000-0000-00000000aa10',
       p_cliente_id => '00000000-0000-0000-0000-000000000b03')$q$,
  '42501', '3.14 el vendedor no pide para una bodega de otro distribuidor');

select pruebas.como('00000000-0000-0000-0000-0000000000e1');
select pruebas.espera_error(
  $q$select public.crear_pedido('00000000-0000-0000-0000-000000000d01',
       '[{"presentacion_id": "00000000-0000-0000-0000-000000000201", "cantidad": 1}]',
       '00000000-0000-0000-0000-00000000aa11',
       p_cliente_id => '00000000-0000-0000-0000-000000000b01')$q$,
  '42501', '3.15 el repartidor no crea pedidos');

select pruebas.como('00000000-0000-0000-0000-000000000091');
select pruebas.espera_error(
  $q$select public.crear_pedido('00000000-0000-0000-0000-000000000d01',
       '[{"presentacion_id": "00000000-0000-0000-0000-000000000201", "cantidad": 1}]',
       '00000000-0000-0000-0000-00000000aa12')$q$,
  '42501', '3.16 sin membresía no se pide');
select pruebas.como_anon();
select pruebas.espera_error(
  $q$select public.crear_pedido('00000000-0000-0000-0000-000000000d01',
       '[{"presentacion_id": "00000000-0000-0000-0000-000000000201", "cantidad": 1}]',
       '00000000-0000-0000-0000-00000000aa12')$q$,
  '42501', '3.16 anon no pide');

-- 3.17 a 3.22: reglas de crédito.
select pruebas.como('00000000-0000-0000-0000-0000000000c1');
select pruebas.espera_error(
  $q$select public.crear_pedido('00000000-0000-0000-0000-000000000d01',
       '[{"presentacion_id": "00000000-0000-0000-0000-000000000201", "cantidad": 1}]',
       '00000000-0000-0000-0000-00000000aa13', p_condicion_pago => 'credito')$q$,
  'P0004', '3.17 sin crédito habilitado no se pide a crédito');

select pruebas.como('00000000-0000-0000-0000-0000000000c2');
select public.crear_pedido(
  '00000000-0000-0000-0000-000000000d01',
  '[{"presentacion_id": "00000000-0000-0000-0000-000000000202", "cantidad": 2}]',
  '00000000-0000-0000-0000-00000000aa14', p_condicion_pago => 'credito') as pedido_318 \gset
select pruebas.afirma(
  (select total_centimos = 96000 and saldo_pendiente_centimos = 96000
          and condicion_pago = 'credito' and vence_en is null
   from public.pedidos where id = :'pedido_318'),
  '3.18 pedido a crédito de 96000 sin vencimiento hasta la entrega');

select public.crear_pedido(
  '00000000-0000-0000-0000-000000000d01',
  '[{"presentacion_id": "00000000-0000-0000-0000-000000000201", "cantidad": 1}]',
  '00000000-0000-0000-0000-00000000aa15', p_condicion_pago => 'credito') as pedido_319 \gset
select pruebas.afirma(
  (select total_centimos = 4000 and condicion_pago = 'credito'
   from public.pedidos where id = :'pedido_319'),
  '3.19 la deuda a crédito llega justo al límite (el pedido de contado no cuenta)');

select pruebas.espera_error(
  $q$select public.crear_pedido('00000000-0000-0000-0000-000000000d01',
       '[{"presentacion_id": "00000000-0000-0000-0000-000000000201", "cantidad": 1}]',
       '00000000-0000-0000-0000-00000000aa16', p_condicion_pago => 'credito')$q$,
  'P0004', '3.20 un pedido que excede el límite se rechaza');

-- "Hoy" se mide en la zona del distribuidor (America/Lima): se usa esa fecha
-- y no current_date para que la prueba no dependa de la zona del servidor.
select pruebas.como_servicio();
update public.pedidos set vence_en = (now() at time zone 'America/Lima')::date - 1
where id = :'pedido_318';
update public.clientes_negocio set limite_credito_centimos = 10000000
where id = '00000000-0000-0000-0000-000000000b02';
select pruebas.como('00000000-0000-0000-0000-0000000000c2');
select pruebas.espera_error(
  $q$select public.crear_pedido('00000000-0000-0000-0000-000000000d01',
       '[{"presentacion_id": "00000000-0000-0000-0000-000000000201", "cantidad": 1}]',
       '00000000-0000-0000-0000-00000000aa17', p_condicion_pago => 'credito')$q$,
  'P0004', '3.21 con deuda vencida no se pide a crédito');

select pruebas.afirma(
  public.crear_pedido(
    '00000000-0000-0000-0000-000000000d01',
    '[{"presentacion_id": "00000000-0000-0000-0000-000000000201", "cantidad": 1}]',
    '00000000-0000-0000-0000-00000000aa17') is not null,
  '3.22 con deuda vencida sí se pide de contado');

-- Se quita el vencimiento para que los casos siguientes no arrastren deuda
-- vencida (el límite queda en 10000000).
select pruebas.como_servicio();
update public.pedidos set vence_en = null where id = :'pedido_318';

-- 3.25 (antes de 3.23): cada quien ve sus pedidos.
-- D1: 3.1 y 3.4 (0b01); 3.12, 3.18, 3.19 y 3.22 (0b02). D2: 3.10 (0b03).
select pruebas.como('00000000-0000-0000-0000-0000000000c1');
select pruebas.afirma(
  pruebas.cuenta('select 1 from public.pedidos') = 3
  and pruebas.cuenta($q$select 1 from public.pedidos
                        where cliente_id in ('00000000-0000-0000-0000-000000000b01',
                                             '00000000-0000-0000-0000-000000000b03')$q$) = 3,
  '3.25 C1 ve solo los pedidos de 0b01 y 0b03');
select pruebas.como('00000000-0000-0000-0000-0000000000c2');
select pruebas.afirma(
  pruebas.cuenta('select 1 from public.pedidos') = 4
  and pruebas.cuenta($q$select 1 from public.pedidos
                        where cliente_id = '00000000-0000-0000-0000-000000000b02'$q$) = 4,
  '3.25 C2 ve solo los pedidos de 0b02');
select pruebas.como('00000000-0000-0000-0000-0000000000a1');
select pruebas.afirma(
  pruebas.cuenta('select 1 from public.pedidos') = 6
  and pruebas.cuenta($q$select 1 from public.pedidos
                        where distribuidor_id = '00000000-0000-0000-0000-000000000d01'$q$) = 6,
  '3.25 A1 ve todos los de D1 y ninguno de D2');
select pruebas.como('00000000-0000-0000-0000-0000000000a2');
select pruebas.afirma(
  pruebas.cuenta('select 1 from public.pedidos') = 1
  and pruebas.cuenta(format($q$select 1 from public.pedidos where id = %L$q$, :'pedido_310')) = 1,
  '3.25 A2 ve solo el pedido de D2');

-- 3.23: distribuidor suspendido.
select pruebas.como_servicio();
update public.distribuidores set estado = 'suspendido'
where id = '00000000-0000-0000-0000-000000000d01';
select pruebas.como('00000000-0000-0000-0000-0000000000c1');
select pruebas.espera_error(
  $q$select public.crear_pedido('00000000-0000-0000-0000-000000000d01',
       '[{"presentacion_id": "00000000-0000-0000-0000-000000000201", "cantidad": 1}]',
       '00000000-0000-0000-0000-00000000aa18')$q$,
  'P0003', '3.23 un distribuidor suspendido no recibe pedidos');
select pruebas.afirma(
  pruebas.cuenta($q$select 1 from public.pedidos
                    where distribuidor_id = '00000000-0000-0000-0000-000000000d01'$q$) = 2,
  '3.23 el cliente sigue leyendo sus pedidos');

-- 3.24: bodega inactiva.
select pruebas.como_servicio();
update public.distribuidores set estado = 'activo'
where id = '00000000-0000-0000-0000-000000000d01';
update public.clientes_negocio set activo = false
where id = '00000000-0000-0000-0000-000000000b01';
select pruebas.como('00000000-0000-0000-0000-0000000000c1');
select pruebas.espera_error(
  $q$select public.crear_pedido('00000000-0000-0000-0000-000000000d01',
       '[{"presentacion_id": "00000000-0000-0000-0000-000000000201", "cantidad": 1}]',
       '00000000-0000-0000-0000-00000000aa19')$q$,
  '42501', '3.24 la bodega inactiva no pide');
select pruebas.afirma(
  pruebas.cuenta('select 1 from public.productos') = 1
  and pruebas.cuenta($q$select 1 from public.productos
                        where id = '00000000-0000-0000-0000-000000000103'$q$) = 1,
  '3.24 C1 no ve productos de D1 pero sí los de D2');
-- Se reactiva 0b01 para los casos siguientes.
select pruebas.como_servicio();
update public.clientes_negocio set activo = true
where id = '00000000-0000-0000-0000-000000000b01';

-- 3.26: nadie escribe pedidos ni líneas directamente.
select pruebas.como('00000000-0000-0000-0000-0000000000c1');
select pruebas.espera_error(
  $q$insert into public.pedidos (distribuidor_id, numero, cliente_id, despacho, total_centimos,
                                condicion_pago, saldo_pendiente_centimos, clave_idempotencia)
     values ('00000000-0000-0000-0000-000000000d01', 99, '00000000-0000-0000-0000-000000000b01',
             'recojo', 0, 'contado', 0, gen_random_uuid())$q$,
  '42501', '3.26 insert directo en pedidos');
select pruebas.espera_error(
  $q$update public.pedidos set total_centimos = 1$q$,
  '42501', '3.26 update directo en pedidos');
select pruebas.espera_error(
  $q$delete from public.pedidos$q$,
  '42501', '3.26 delete directo en pedidos');
select pruebas.espera_error(
  format($q$insert into public.pedido_items
              (distribuidor_id, pedido_id, presentacion_id, producto_id, nombre_producto,
               nombre_presentacion, factor, cantidad, precio_unitario_centimos, subtotal_centimos)
            values ('00000000-0000-0000-0000-000000000d01', %L,
                    '00000000-0000-0000-0000-000000000201', '00000000-0000-0000-0000-000000000101',
                    'x', 'x', 1, 1, 0, 0)$q$, :'pedido_31'),
  '42501', '3.26 insert directo en pedido_items');
select pruebas.espera_error(
  $q$update public.pedido_items set precio_unitario_centimos = 1$q$,
  '42501', '3.26 update directo en pedido_items');
select pruebas.espera_error(
  $q$delete from public.pedido_items$q$,
  '42501', '3.26 delete directo en pedido_items');

-- 3.27: solo el admin cambia el crédito de una bodega.
select pruebas.como('00000000-0000-0000-0000-0000000000b1');
select pruebas.espera_error(
  $q$update public.clientes_negocio set limite_credito_centimos = 1
     where id = '00000000-0000-0000-0000-000000000b02'$q$,
  '42501', '3.27 el vendedor no cambia el límite de crédito');

-- 3.28: las líneas conservan el nombre del momento de la compra.
select pruebas.como_servicio();
update public.productos set nombre = 'Otro'
where id = '00000000-0000-0000-0000-000000000101';
select pruebas.afirma(
  pruebas.cuenta(format($q$select 1 from public.pedido_items
                           where pedido_id = %L and nombre_producto = 'Ron Añejo'$q$, :'pedido_31')) = 2,
  '3.28 editar el producto no altera las líneas del pedido');

-- 3.29 a 3.32: lecturas y escrituras complementarias de la matriz.
-- El repartidor ve la bodega de un pedido solo mientras lo tiene asignado
-- (la asignación se hace aquí como servicio; la función llega después).
select pruebas.como('00000000-0000-0000-0000-0000000000e1');
select pruebas.afirma(
  pruebas.cuenta('select 1 from public.clientes_negocio') = 0
  and pruebas.cuenta('select 1 from public.pedidos') = 0,
  '3.29 el repartidor sin pedidos asignados no ve bodegas ni pedidos');
select pruebas.como_servicio();
update public.pedidos set repartidor_id = '00000000-0000-0000-0000-0000000000e1'
where id = :'pedido_31';
select pruebas.como('00000000-0000-0000-0000-0000000000e1');
select pruebas.afirma(
  pruebas.cuenta('select 1 from public.clientes_negocio') = 1
  and pruebas.cuenta($q$select 1 from public.clientes_negocio
                        where id = '00000000-0000-0000-0000-000000000b01'$q$) = 1
  and pruebas.cuenta(format($q$select 1 from public.pedidos where id = %L$q$, :'pedido_31')) = 1
  and pruebas.cuenta('select 1 from public.pedidos') = 1
  and pruebas.cuenta('select 1 from public.pedido_items') = 2
  and pruebas.cuenta('select 1 from public.pedido_eventos') = 1,
  '3.29 el repartidor ve el pedido asignado, sus líneas, sus eventos y su bodega');
select pruebas.como_servicio();
update public.pedidos set repartidor_id = null where id = :'pedido_31';

select pruebas.como('00000000-0000-0000-0000-0000000000c2');
select pruebas.afirma(
  pruebas.cuenta('select 1 from public.pedido_items') = 4
  and pruebas.cuenta('select 1 from public.pedido_eventos') = 4
  and pruebas.cuenta(format($q$select 1 from public.pedido_items where pedido_id = %L$q$, :'pedido_31')) = 0,
  '3.30 el cliente ve solo las líneas y eventos de sus pedidos');

-- contadores_pedido no tiene grant: leerlo o escribirlo es error de privilegio.
select pruebas.espera_error(
  $q$select 1 from public.contadores_pedido$q$,
  '42501', '3.31 el cliente no lee el contador');
select pruebas.como('00000000-0000-0000-0000-0000000000a1');
select pruebas.espera_error(
  $q$select 1 from public.contadores_pedido$q$,
  '42501', '3.31 ni el admin lee el contador');
select pruebas.espera_error(
  $q$update public.contadores_pedido set ultimo_numero = 0$q$,
  '42501', '3.31 ni el admin escribe el contador');

do $$
declare
  v_n integer;
begin
  update public.clientes_negocio
  set credito_habilitado = true, limite_credito_centimos = 50000, plazo_credito_dias = 7
  where id = '00000000-0000-0000-0000-000000000b01';
  get diagnostics v_n = row_count;
  perform pruebas.afirma(v_n = 1, '3.32 el admin habilita el crédito de una bodega');
end $$;
select pruebas.espera_error(
  $q$update public.clientes_negocio set credito_habilitado = true, limite_credito_centimos = null
     where id = '00000000-0000-0000-0000-000000000b01'$q$,
  '23514', '3.32 no hay crédito habilitado sin límite');
select pruebas.como('00000000-0000-0000-0000-0000000000b1');
select pruebas.espera_error(
  $q$insert into public.clientes_negocio (distribuidor_id, nombre_negocio, credito_habilitado,
                                         limite_credito_centimos, plazo_credito_dias)
     values ('00000000-0000-0000-0000-000000000d01', 'Bodega Fiada', true, 1000, 7)$q$,
  '42501', '3.32 el vendedor no crea una bodega con crédito');
-- Se deja 0b01 sin crédito, como en los datos fijos.
select pruebas.como_servicio();
update public.clientes_negocio
set credito_habilitado = false, limite_credito_centimos = null, plazo_credito_dias = null
where id = '00000000-0000-0000-0000-000000000b01';

-- Estado al terminar estos casos (para los que sigan): D1 activo, 0b01 y
-- 0b02 activas; 0b02 con límite 10000000, deuda a crédito 100000 y sin deuda
-- vencida; 0b01 sin crédito; P1 se llama "Otro", con físico 120 y
-- comprometido 69 (disponible 51); P3 con comprometido 5. Pedidos: 6 en D1
-- (números 1 a 6) y 1 en D2.

-- ---------------------------------------------------------------------------
-- 3.40 a 3.63: estados del pedido, repartidor y Realtime.
-- Cada caso crea sus propios pedidos. Prep = pedido de C1 por PR1 x10 con
-- despacho reparto; Prec = igual con despacho recojo. Los valores de stock se
-- comparan contra lo leído justo antes de cada acción.
-- ---------------------------------------------------------------------------
\set d1 00000000-0000-0000-0000-000000000d01
\set p1 00000000-0000-0000-0000-000000000101
\set a1 00000000-0000-0000-0000-0000000000a1
\set v1 00000000-0000-0000-0000-0000000000b1
\set r1 00000000-0000-0000-0000-0000000000e1
\set c1 00000000-0000-0000-0000-0000000000c1
\set c2 00000000-0000-0000-0000-0000000000c2
\set a2 00000000-0000-0000-0000-0000000000a2
\set pr1x10 '[{"presentacion_id": "00000000-0000-0000-0000-000000000201", "cantidad": 10}]'
\set pr1x1 '[{"presentacion_id": "00000000-0000-0000-0000-000000000201", "cantidad": 1}]'

-- Más stock de P1 para los pedidos de este bloque.
select pruebas.como_servicio();
select privado.aplicar_movimiento_stock(:'p1', 'ingreso', 300, 0, null, 'stock para pruebas');

-- 3.40: recibido → confirmado.
select pruebas.como(:'c1');
select public.crear_pedido(:'d1', :'pr1x10', gen_random_uuid(), p_despacho => 'reparto') as p40 \gset
select pruebas.como(:'a1');
select public.cambiar_estado_pedido(:'p40', 'confirmado');
select pruebas.afirma(
  (select estado = 'confirmado' from public.pedidos where id = :'p40')
  and pruebas.cuenta(format($q$select 1 from public.pedido_eventos where pedido_id = %L$q$, :'p40')) = 2
  and pruebas.cuenta(format($q$select 1 from public.pedido_eventos
                               where pedido_id = %L and estado_anterior = 'recibido'
                                 and estado_nuevo = 'confirmado'
                                 and hecho_por = '00000000-0000-0000-0000-0000000000a1'$q$,
                            :'p40')) = 1,
  '3.40 el admin confirma: estado confirmado y evento desde recibido hecho por A1');

-- 3.41: desde recibido no se salta a entregado ni a en_camino.
select pruebas.como(:'c1');
select public.crear_pedido(:'d1', :'pr1x10', gen_random_uuid(), p_despacho => 'reparto') as p41 \gset
select pruebas.como(:'a1');
select pruebas.espera_error(
  format($q$select public.cambiar_estado_pedido(%L, 'entregado')$q$, :'p41'),
  'P0006', '3.41 recibido no pasa directo a entregado');
select pruebas.espera_error(
  format($q$select public.cambiar_estado_pedido(%L, 'en_camino')$q$, :'p41'),
  'P0006', '3.41 recibido no pasa directo a en_camino');

-- 3.42: un pedido de recojo no sale en camino.
select pruebas.como(:'c1');
select public.crear_pedido(:'d1', :'pr1x10', gen_random_uuid()) as p42 \gset
select pruebas.como(:'a1');
select public.cambiar_estado_pedido(:'p42', 'confirmado');
select pruebas.espera_error(
  format($q$select public.cambiar_estado_pedido(%L, 'en_camino')$q$, :'p42'),
  'P0006', '3.42 un pedido de recojo no pasa a en_camino');

-- 3.43: un pedido de reparto no queda listo para recojo.
select pruebas.como(:'c1');
select public.crear_pedido(:'d1', :'pr1x10', gen_random_uuid(), p_despacho => 'reparto') as p43 \gset
select pruebas.como(:'a1');
select public.cambiar_estado_pedido(:'p43', 'confirmado');
select pruebas.espera_error(
  format($q$select public.cambiar_estado_pedido(%L, 'listo_recojo')$q$, :'p43'),
  'P0006', '3.43 un pedido de reparto no pasa a listo_recojo');

-- 3.44: entregar baja el físico y el comprometido.
select pruebas.como(:'c1');
select public.crear_pedido(:'d1', :'pr1x10', gen_random_uuid()) as p44 \gset
select pruebas.como(:'a1');
select public.cambiar_estado_pedido(:'p44', 'confirmado');
select public.cambiar_estado_pedido(:'p44', 'listo_recojo');
select pruebas.como_servicio();
select stock_fisico as fis_44, stock_comprometido as com_44
from public.productos where id = :'p1' \gset
select pruebas.como(:'a1');
select public.cambiar_estado_pedido(:'p44', 'entregado');
select pruebas.como_servicio();
select pruebas.afirma(
  (select stock_fisico = :fis_44 - 10 and stock_comprometido = :com_44 - 10
   from public.productos where id = :'p1'),
  '3.44 entregar baja 10 el físico y 10 el comprometido de P1');
select pruebas.afirma(
  pruebas.cuenta(format($q$select 1 from public.movimientos_stock
                           where pedido_id = %L and tipo = 'salida'
                             and delta_fisico = -10 and delta_comprometido = -10
                             and hecho_por = '00000000-0000-0000-0000-0000000000a1'$q$,
                        :'p44')) = 1,
  '3.44 un movimiento salida con ambos deltas en -10');
select pruebas.afirma(
  (select estado = 'entregado' and entregado_en is not null and vence_en is null
   from public.pedidos where id = :'p44')
  and pruebas.cuenta(format($q$select 1 from public.pedido_eventos where pedido_id = %L$q$, :'p44')) = 4,
  '3.44 el pedido queda entregado, con entregado_en y un evento por cambio');

-- 3.45: entregado es final.
select pruebas.como(:'c1');
select public.crear_pedido(:'d1', :'pr1x10', gen_random_uuid()) as p45 \gset
select pruebas.como(:'a1');
select public.cambiar_estado_pedido(:'p45', 'confirmado');
select public.cambiar_estado_pedido(:'p45', 'listo_recojo');
select public.cambiar_estado_pedido(:'p45', 'entregado');
select pruebas.espera_error(
  format($q$select public.cambiar_estado_pedido(%L, 'cancelado', 'tarde')$q$, :'p45'),
  'P0006', '3.45 un pedido entregado no se cancela');
select pruebas.espera_error(
  format($q$select public.cambiar_estado_pedido(%L, 'entregado')$q$, :'p45'),
  'P0006', '3.45 un pedido entregado no se entrega de nuevo');

-- 3.46: cancelar exige nota.
select pruebas.como(:'c1');
select public.crear_pedido(:'d1', :'pr1x10', gen_random_uuid(), p_despacho => 'reparto') as p46 \gset
select pruebas.como(:'a1');
select public.cambiar_estado_pedido(:'p46', 'confirmado');
select pruebas.espera_error(
  format($q$select public.cambiar_estado_pedido(%L, 'cancelado')$q$, :'p46'),
  '22023', '3.46 cancelar sin nota');
select pruebas.espera_error(
  format($q$select public.cambiar_estado_pedido(%L, 'cancelado', '   ')$q$, :'p46'),
  '22023', '3.46 cancelar con nota vacía');

-- 3.47: cancelar libera el comprometido.
select pruebas.como(:'c1');
select public.crear_pedido(:'d1', :'pr1x10', gen_random_uuid(), p_despacho => 'reparto') as p47 \gset
select pruebas.como(:'a1');
select public.cambiar_estado_pedido(:'p47', 'confirmado');
select pruebas.como_servicio();
select stock_fisico as fis_47, stock_comprometido as com_47
from public.productos where id = :'p1' \gset
select pruebas.como(:'a1');
select public.cambiar_estado_pedido(:'p47', 'cancelado', 'sin stock real');
select pruebas.como_servicio();
select pruebas.afirma(
  (select stock_fisico = :fis_47 and stock_comprometido = :com_47 - 10
   from public.productos where id = :'p1'),
  '3.47 cancelar baja 10 el comprometido sin tocar el físico');
select pruebas.afirma(
  pruebas.cuenta(format($q$select 1 from public.movimientos_stock
                           where pedido_id = %L and tipo = 'liberacion'
                             and delta_fisico = 0 and delta_comprometido = -10$q$,
                        :'p47')) = 1,
  '3.47 un movimiento liberacion de -10 al comprometido');
select pruebas.afirma(
  (select estado = 'cancelado' and motivo_cancelacion = 'sin stock real'
   from public.pedidos where id = :'p47')
  and pruebas.cuenta(format($q$select 1 from public.pedido_eventos
                               where pedido_id = %L and estado_anterior = 'confirmado'
                                 and estado_nuevo = 'cancelado' and nota = 'sin stock real'$q$,
                            :'p47')) = 1,
  '3.47 se guarda el motivo de cancelación y el evento lleva la nota');

-- 3.48: el cliente cancela su pedido recibido.
select pruebas.como(:'c1');
select public.crear_pedido(:'d1', :'pr1x10', gen_random_uuid(), p_despacho => 'reparto') as p48 \gset
select public.cambiar_estado_pedido(:'p48', 'cancelado', 'me equivoqué');
select pruebas.afirma(
  (select estado = 'cancelado' and motivo_cancelacion = 'me equivoqué'
   from public.pedidos where id = :'p48'),
  '3.48 el cliente cancela su pedido recibido');

-- 3.49: el cliente no cancela un pedido ya confirmado.
select public.crear_pedido(:'d1', :'pr1x10', gen_random_uuid(), p_despacho => 'reparto') as p49 \gset
select pruebas.como(:'a1');
select public.cambiar_estado_pedido(:'p49', 'confirmado');
select pruebas.como(:'c1');
select pruebas.espera_error(
  format($q$select public.cambiar_estado_pedido(%L, 'cancelado', 'ya no')$q$, :'p49'),
  '42501', '3.49 el cliente no cancela un pedido confirmado');

-- 3.50: otra bodega no toca el pedido.
select public.crear_pedido(:'d1', :'pr1x10', gen_random_uuid(), p_despacho => 'reparto') as p50 \gset
select pruebas.como(:'c2');
select pruebas.espera_error(
  format($q$select public.cambiar_estado_pedido(%L, 'cancelado', 'ajeno')$q$, :'p50'),
  'P0002', '3.50 C2 no cancela el pedido de C1');

-- 3.51: el cliente no confirma su propio pedido.
select pruebas.como(:'c1');
select public.crear_pedido(:'d1', :'pr1x10', gen_random_uuid(), p_despacho => 'reparto') as p51 \gset
select pruebas.espera_error(
  format($q$select public.cambiar_estado_pedido(%L, 'confirmado')$q$, :'p51'),
  '42501', '3.51 el cliente no confirma su pedido');

-- 3.52: asignar repartidor.
select public.crear_pedido(:'d1', :'pr1x10', gen_random_uuid(), p_despacho => 'reparto') as p52 \gset
select pruebas.como(:'a1');
select public.asignar_repartidor(:'p52', :'r1');
select pruebas.afirma(
  (select repartidor_id = '00000000-0000-0000-0000-0000000000e1'
   from public.pedidos where id = :'p52'),
  '3.52 el admin asigna R1 al pedido');
select pruebas.como(:'r1');
select pruebas.afirma(
  pruebas.cuenta(format($q$select 1 from public.pedidos where id = %L$q$, :'p52')) = 1
  and pruebas.cuenta(format($q$select 1 from public.pedido_items where pedido_id = %L$q$, :'p52')) = 1
  and pruebas.cuenta($q$select 1 from public.clientes_negocio
                        where id = '00000000-0000-0000-0000-000000000b01'$q$) = 1,
  '3.52 R1 ve el pedido asignado, sus líneas y la bodega 0b01');

-- 3.53: el repartidor no ve ni mueve pedidos que no tiene asignados.
select pruebas.como(:'c1');
select public.crear_pedido(:'d1', :'pr1x10', gen_random_uuid(), p_despacho => 'reparto') as p53 \gset
select pruebas.como(:'a1');
select public.cambiar_estado_pedido(:'p53', 'confirmado');
select pruebas.como(:'r1');
select pruebas.afirma(
  pruebas.cuenta(format($q$select 1 from public.pedidos where id = %L$q$, :'p53')) = 0,
  '3.53 R1 no ve un pedido que no tiene asignado');
select pruebas.espera_error(
  format($q$select public.cambiar_estado_pedido(%L, 'en_camino')$q$, :'p53'),
  'P0002', '3.53 R1 no cambia el estado de un pedido no asignado');

-- 3.56 a 3.61 van antes que 3.54 y 3.55: esos dejan pedidos de C1
-- asignados a R1 para siempre (un pedido entregado ya no se desasigna), y
-- 3.61 necesita que C1 no tenga ninguno.

-- 3.56: solo se asigna repartidor a pedidos de reparto.
select pruebas.como(:'c1');
select public.crear_pedido(:'d1', :'pr1x10', gen_random_uuid()) as p56 \gset
select pruebas.como(:'a1');
select pruebas.espera_error(
  format($q$select public.asignar_repartidor(%L, '00000000-0000-0000-0000-0000000000e1')$q$, :'p56'),
  '22023', '3.56 no se asigna repartidor a un pedido de recojo');

-- 3.57: el asignado debe ser repartidor activo del distribuidor.
select pruebas.como(:'c1');
select public.crear_pedido(:'d1', :'pr1x10', gen_random_uuid(), p_despacho => 'reparto') as p57 \gset
select pruebas.como(:'a1');
select pruebas.espera_error(
  format($q$select public.asignar_repartidor(%L, '00000000-0000-0000-0000-0000000000b1')$q$, :'p57'),
  '22023', '3.57 un vendedor no se asigna como repartidor');
select pruebas.espera_error(
  format($q$select public.asignar_repartidor(%L, '00000000-0000-0000-0000-0000000000c1')$q$, :'p57'),
  '22023', '3.57 un cliente no se asigna como repartidor');

-- 3.58: desasignar.
select public.asignar_repartidor(:'p52', null);
select pruebas.afirma(
  (select repartidor_id is null from public.pedidos where id = :'p52'),
  '3.58 el admin desasigna el repartidor');
select pruebas.como(:'r1');
select pruebas.afirma(
  pruebas.cuenta(format($q$select 1 from public.pedidos where id = %L$q$, :'p52')) = 0,
  '3.58 tras desasignar, R1 deja de ver el pedido');

-- 3.59: el admin de otro distribuidor no toca pedidos de D1.
select pruebas.como(:'a2');
select pruebas.espera_error(
  format($q$select public.cambiar_estado_pedido(%L, 'confirmado')$q$, :'p52'),
  'P0002', '3.59 A2 no cambia el estado de un pedido de D1');
select pruebas.espera_error(
  format($q$select public.asignar_repartidor(%L, '00000000-0000-0000-0000-0000000000e1')$q$, :'p52'),
  'P0002', '3.59 A2 no asigna repartidor a un pedido de D1');

-- 3.60: entregar un pedido a crédito fija el vencimiento.
select pruebas.como(:'c2');
select public.crear_pedido(:'d1', :'pr1x1', gen_random_uuid(),
                           p_condicion_pago => 'credito') as p60 \gset
select pruebas.como(:'a1');
select public.cambiar_estado_pedido(:'p60', 'confirmado');
select public.cambiar_estado_pedido(:'p60', 'listo_recojo');
select public.cambiar_estado_pedido(:'p60', 'entregado');
select pruebas.afirma(
  (select vence_en = (now() at time zone 'America/Lima')::date + 15
   from public.pedidos where id = :'p60'),
  '3.60 vence_en es hoy en America/Lima más 15 días');

-- 3.61: C1 ve el perfil de R1 solo mientras R1 reparte un pedido suyo.
select pruebas.como(:'c1');
select public.crear_pedido(:'d1', :'pr1x10', gen_random_uuid(), p_despacho => 'reparto') as p61 \gset
select pruebas.afirma(
  pruebas.cuenta($q$select 1 from public.perfiles
                    where id = '00000000-0000-0000-0000-0000000000e1'$q$) = 0,
  '3.61 sin asignación C1 no ve el perfil de R1');
select pruebas.como(:'a1');
select public.asignar_repartidor(:'p61', :'r1');
select pruebas.como(:'c1');
select pruebas.afirma(
  pruebas.cuenta($q$select 1 from public.perfiles
                    where id = '00000000-0000-0000-0000-0000000000e1'$q$) = 1,
  '3.61 con R1 asignado C1 ve su perfil');
select pruebas.como(:'a1');
select public.asignar_repartidor(:'p61', null);
select pruebas.como(:'c1');
select pruebas.afirma(
  pruebas.cuenta($q$select 1 from public.perfiles
                    where id = '00000000-0000-0000-0000-0000000000e1'$q$) = 0,
  '3.61 al desasignar C1 deja de ver el perfil de R1');

-- 3.54: el repartidor asignado sale en camino y entrega.
select public.crear_pedido(:'d1', :'pr1x10', gen_random_uuid(), p_despacho => 'reparto') as p54 \gset
select pruebas.como(:'a1');
select public.cambiar_estado_pedido(:'p54', 'confirmado');
select public.asignar_repartidor(:'p54', :'r1');
select pruebas.como(:'r1');
select public.cambiar_estado_pedido(:'p54', 'en_camino');
select pruebas.afirma(
  (select estado = 'en_camino' from public.pedidos where id = :'p54'),
  '3.54 R1 pasa su pedido a en_camino');
select public.cambiar_estado_pedido(:'p54', 'entregado');
select pruebas.afirma(
  (select estado = 'entregado' from public.pedidos where id = :'p54')
  and pruebas.cuenta(format($q$select 1 from public.pedido_eventos
                               where pedido_id = %L
                                 and hecho_por = '00000000-0000-0000-0000-0000000000e1'$q$,
                            :'p54')) = 2,
  '3.54 R1 entrega su pedido; los dos eventos los hizo R1');

-- 3.55: el repartidor no confirma ni cancela.
select pruebas.como(:'c1');
select public.crear_pedido(:'d1', :'pr1x10', gen_random_uuid(), p_despacho => 'reparto') as p55 \gset
select pruebas.como(:'a1');
select public.asignar_repartidor(:'p55', :'r1');
select pruebas.como(:'r1');
select pruebas.espera_error(
  format($q$select public.cambiar_estado_pedido(%L, 'confirmado')$q$, :'p55'),
  '42501', '3.55 R1 no confirma');
select pruebas.espera_error(
  format($q$select public.cambiar_estado_pedido(%L, 'cancelado', 'no llego')$q$, :'p55'),
  '42501', '3.55 R1 no cancela');

-- 3.62: Realtime publica pedidos y sus eventos.
select pruebas.como_servicio();
select pruebas.afirma(
  (select count(*) = 2 from pg_publication_tables
   where pubname = 'supabase_realtime' and schemaname = 'public'
     and tablename in ('pedidos', 'pedido_eventos')),
  '3.62 supabase_realtime publica pedidos y pedido_eventos');

-- 3.63: el vendedor también confirma y asigna; anon no llama las funciones.
select pruebas.como(:'c1');
select public.crear_pedido(:'d1', :'pr1x10', gen_random_uuid(), p_despacho => 'reparto') as p63 \gset
select pruebas.como(:'v1');
select public.cambiar_estado_pedido(:'p63', 'confirmado');
select public.asignar_repartidor(:'p63', :'r1');
select pruebas.afirma(
  (select estado = 'confirmado' and repartidor_id = '00000000-0000-0000-0000-0000000000e1'
   from public.pedidos where id = :'p63'),
  '3.63 el vendedor confirma y asigna repartidor');
select pruebas.como_anon();
select pruebas.espera_error(
  format($q$select public.cambiar_estado_pedido(%L, 'cancelado', 'x')$q$, :'p63'),
  '42501', '3.63 anon no cambia estados');
select pruebas.espera_error(
  format($q$select public.asignar_repartidor(%L, null)$q$, :'p63'),
  '42501', '3.63 anon no asigna repartidor');
select pruebas.como_servicio();

rollback;
