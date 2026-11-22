-- Pruebas del módulo 4: cobros.
-- Ids del módulo 1: D1 0d01, D2 0d02; bodegas 0b01 (C1), 0b02 (C2) en D1;
-- A1 00a1, V1 00b1, R1 00e1, C1 00c1, C2 00c2, A2 00a2.
-- Ids del módulo 2: P1 0101 (físico 120); PR1 0201 (P1 x1, 4200; desde 12:
-- 3900), PR2 0202 (P1 x12, 48000); lista L1 (solo PR1) asignada a 0b02.
-- Módulo 3: 0b02 con crédito (límite 100000, plazo 15 días).
-- Esta prueba crea todos sus pedidos con las funciones del módulo 3. Los
-- casos corren en orden dentro de una transacción: cada uno parte del estado
-- que dejan los anteriores.
--
-- Ped = pedido de C1 por PR1 x10 (total 42000), despacho reparto, confirmado
-- y asignado a R1. Otro = pedido de C1 por PR1 x10, reparto, sin repartidor.
begin;
\ir soporte/datos_m3.sql

\set d1 00000000-0000-0000-0000-000000000d01
\set p1 00000000-0000-0000-0000-000000000101
\set a1 00000000-0000-0000-0000-0000000000a1
\set v1 00000000-0000-0000-0000-0000000000b1
\set r1 00000000-0000-0000-0000-0000000000e1
\set c1 00000000-0000-0000-0000-0000000000c1
\set c2 00000000-0000-0000-0000-0000000000c2
\set a2 00000000-0000-0000-0000-0000000000a2
\set pr1x10 '[{"presentacion_id": "00000000-0000-0000-0000-000000000201", "cantidad": 10}]'
\set pr2x2 '[{"presentacion_id": "00000000-0000-0000-0000-000000000202", "cantidad": 2}]'

-- Más stock de P1 para los pedidos de esta prueba.
select pruebas.como_servicio();
select privado.aplicar_movimiento_stock(:'p1', 'ingreso', 300, 0, null, 'stock para pruebas');

-- Ped.
select pruebas.como(:'c1');
select public.crear_pedido(:'d1', :'pr1x10', gen_random_uuid(), p_despacho => 'reparto') as ped \gset
select pruebas.como(:'a1');
select public.cambiar_estado_pedido(:'ped', 'confirmado');
select public.asignar_repartidor(:'ped', :'r1');

-- 4.1: el vendedor registra un pago parcial.
select pruebas.como(:'v1');
select public.registrar_pago(:'ped', 20000, 'efectivo') as pago41 \gset
select pruebas.afirma(
  (select total_centimos = 42000 and saldo_pendiente_centimos = 22000 and estado_pago = 'parcial'
   from public.pedidos where id = :'ped'),
  '4.1 saldo 22000 y estado_pago parcial');
select pruebas.afirma(
  (select pedido_id = :'ped' and monto_centimos = 20000 and metodo = 'efectivo'
          and registrado_por = '00000000-0000-0000-0000-0000000000b1'
          and cliente_id = '00000000-0000-0000-0000-000000000b01'
          and distribuidor_id = '00000000-0000-0000-0000-000000000d01'
          and referencia is null and nota is null
          and anulado_en is null and anulado_por is null
   from public.pagos where id = :'pago41'),
  '4.1 el pago queda registrado por V1 para la bodega 0b01');

-- 4.2: el repartidor asignado cobra el resto.
select pruebas.como(:'r1');
select public.registrar_pago(:'ped', 22000, 'billetera_digital', 'YAPE-123') as pago42 \gset
select pruebas.afirma(
  (select saldo_pendiente_centimos = 0 and estado_pago = 'pagado'
   from public.pedidos where id = :'ped')
  and (select referencia = 'YAPE-123' and metodo = 'billetera_digital'
              and registrado_por = '00000000-0000-0000-0000-0000000000e1'
       from public.pagos where id = :'pago42'),
  '4.2 saldo 0 y estado_pago pagado');

-- 4.3: con saldo 0 no se acepta ni un céntimo.
select pruebas.como(:'a1');
select pruebas.espera_error(
  format($q$select public.registrar_pago(%L, 1, 'efectivo')$q$, :'ped'),
  '22023', '4.3 no se paga más que el saldo (saldo 0)');

-- 4.4: montos inválidos sobre un pedido nuevo (Otro, total 42000).
select pruebas.como(:'c1');
select public.crear_pedido(:'d1', :'pr1x10', gen_random_uuid(), p_despacho => 'reparto') as otro \gset
select pruebas.como(:'a1');
select pruebas.espera_error(
         format($q$select public.registrar_pago(%L, %s, 'efectivo')$q$, :'otro', m.monto),
         '22023', '4.4 monto ' || m.monto)
from unnest(array['0', '-5', 'null', '42001']) with ordinality as m (monto, n)
order by m.n;
select pruebas.espera_error(
  format($q$select public.registrar_pago(%L, 100, null)$q$, :'otro'),
  '22023', '4.4 método nulo');
select pruebas.afirma(
  (select saldo_pendiente_centimos = 42000 and estado_pago = 'pendiente'
   from public.pedidos where id = :'otro')
  and pruebas.cuenta(format($q$select 1 from public.pagos where pedido_id = %L$q$, :'otro')) = 0,
  '4.4 el pedido queda sin pagos y con el saldo intacto');

-- 4.5: la bodega no registra pagos, ni en su propio pedido.
select pruebas.como(:'c1');
select pruebas.espera_error(
  format($q$select public.registrar_pago(%L, 100, 'efectivo')$q$, :'otro'),
  '42501', '4.5 C1 no registra pagos en su pedido');

-- 4.6: el repartidor no cobra pedidos que no le asignaron (no los ve).
select pruebas.como(:'r1');
select pruebas.espera_error(
  format($q$select public.registrar_pago(%L, 100, 'efectivo')$q$, :'otro'),
  'P0002', '4.6 R1 no cobra un pedido no asignado a él');
-- El admin sí: deja un pago que R1 no debe ver (4.15).
select pruebas.como(:'a1');
select public.registrar_pago(:'otro', 1000, 'transferencia') as pago46 \gset
select pruebas.afirma(
  (select saldo_pendiente_centimos = 41000 and estado_pago = 'parcial'
   from public.pedidos where id = :'otro'),
  '4.6 el admin sí cobra ese pedido');

-- 4.7: el admin de otro distribuidor no ve el pedido.
select pruebas.como(:'a2');
select pruebas.espera_error(
  format($q$select public.registrar_pago(%L, 100, 'efectivo')$q$, :'ped'),
  'P0002', '4.7 A2 no cobra un pedido de D1');
select pruebas.espera_error(
  format($q$select public.anular_pago(%L, 'x')$q$, :'pago41'),
  'P0002', '4.7 A2 no anula un pago de D1');
select pruebas.espera_error(
  $q$select public.anular_pago(gen_random_uuid(), 'x')$q$,
  'P0002', '4.7 pago inexistente');

-- 4.8: solo el admin anula.
select pruebas.como(:'v1');
select pruebas.espera_error(
  format($q$select public.anular_pago(%L, 'error')$q$, :'pago41'),
  '42501', '4.8 V1 no anula pagos');
select pruebas.como(:'r1');
select pruebas.espera_error(
  format($q$select public.anular_pago(%L, 'error')$q$, :'pago42'),
  '42501', '4.8 R1 no anula pagos');

-- 4.9: el admin anula el pago de 4.2: el monto vuelve al saldo.
select pruebas.como(:'a1');
select public.anular_pago(:'pago42', 'monto errado');
select pruebas.afirma(
  (select saldo_pendiente_centimos = 22000 and estado_pago = 'parcial'
   from public.pedidos where id = :'ped'),
  '4.9 saldo 22000 y estado_pago parcial');
select pruebas.afirma(
  (select anulado_en is not null
          and anulado_por = '00000000-0000-0000-0000-0000000000a1'
          and monto_centimos = 22000 and referencia = 'YAPE-123'
          and nota like '%monto errado%'
   from public.pagos where id = :'pago42')
  and (select anulado_en is null from public.pagos where id = :'pago41'),
  '4.9 el pago sigue existiendo, anulado por A1 y con la nota');

-- 4.10: un pago anulado no se anula otra vez.
select pruebas.espera_error(
  format($q$select public.anular_pago(%L, 'otra vez')$q$, :'pago42'),
  'P0006', '4.10 el pago ya está anulado');

-- 4.11: anular exige nota.
select pruebas.espera_error(
  format($q$select public.anular_pago(%L, null)$q$, :'pago41'),
  '22023', '4.11 anular sin nota');
select pruebas.espera_error(
  format($q$select public.anular_pago(%L, '   ')$q$, :'pago41'),
  '22023', '4.11 anular con nota en blanco');

-- 4.12: no se cancela un pedido con pagos activos.
select stock_fisico as fisico_412, stock_comprometido as comprometido_412
from public.productos where id = :'p1' \gset
select pruebas.espera_error(
  format($q$select public.cambiar_estado_pedido(%L, 'cancelado', 'x')$q$, :'ped'),
  'P0006', '4.12 cancelar con el pago de 4.1 activo');
select pruebas.afirma(
  (select estado = 'confirmado' from public.pedidos where id = :'ped')
  and (select stock_fisico = :fisico_412 and stock_comprometido = :comprometido_412
       from public.productos where id = :'p1'),
  '4.12 el pedido sigue confirmado y el stock sin cambios');

-- 4.13: anulado el último pago activo, se cancela.
select public.anular_pago(:'pago41', 'el cliente devolvió el pedido');
select public.cambiar_estado_pedido(:'ped', 'cancelado', 'x');
select pruebas.afirma(
  (select estado = 'cancelado' and saldo_pendiente_centimos = total_centimos
          and estado_pago = 'pendiente'
   from public.pedidos where id = :'ped')
  and (select stock_comprometido = :comprometido_412 - 10
       from public.productos where id = :'p1'),
  '4.13 se cancela con el saldo igual al total');

-- 4.14: no se cobra un pedido cancelado.
select pruebas.espera_error(
  format($q$select public.registrar_pago(%L, 100, 'efectivo')$q$, :'ped'),
  'P0006', '4.14 pago sobre un pedido cancelado');

-- 4.15: lectura de pagos.
select pruebas.como(:'c1');
select pruebas.afirma(
  pruebas.cuenta(format($q$select 1 from public.pagos where pedido_id = %L$q$, :'ped')) = 2
  and pruebas.cuenta(format($q$select 1 from public.pagos where pedido_id = %L$q$, :'otro')) = 1,
  '4.15 C1 ve los pagos de sus pedidos, también los anulados');
select pruebas.como(:'c2');
select pruebas.afirma(pruebas.cuenta('select 1 from public.pagos') = 0,
  '4.15 C2 no ve pagos de otra bodega');
select pruebas.como(:'r1');
select pruebas.afirma(
  pruebas.cuenta('select 1 from public.pagos') = 2
  and pruebas.cuenta(format($q$select 1 from public.pagos where pedido_id = %L$q$, :'ped')) = 2,
  '4.15 R1 ve solo los pagos de su pedido asignado');
select pruebas.como(:'v1');
select pruebas.afirma(pruebas.cuenta('select 1 from public.pagos') = 3,
  '4.15 V1 ve todos los pagos del distribuidor');
select pruebas.como(:'a2');
select pruebas.afirma(pruebas.cuenta('select 1 from public.pagos') = 0,
  '4.15 A2 no ve pagos de D1');

-- 4.16: nadie escribe pagos directamente; anon no llama las funciones.
select pruebas.como(:'a1');
select pruebas.espera_error(
  format($q$update public.pagos set monto_centimos = 1 where id = %L$q$, :'pago46'),
  '42501', '4.16 el admin no edita un pago');
select pruebas.espera_error(
  format($q$delete from public.pagos where id = %L$q$, :'pago46'),
  '42501', '4.16 el admin no borra un pago');
select pruebas.espera_error(
  format($q$insert into public.pagos (distribuidor_id, pedido_id, cliente_id, monto_centimos, metodo)
            values (%L, %L, '00000000-0000-0000-0000-000000000b01', 1, 'efectivo')$q$,
         :'d1', :'otro'),
  '42501', '4.16 el admin no inserta un pago');
select pruebas.como_anon();
select pruebas.espera_error(
  format($q$select public.registrar_pago(%L, 100, 'efectivo')$q$, :'otro'),
  '42501', '4.16 anon no registra pagos');
select pruebas.espera_error(
  format($q$select public.anular_pago(%L, 'x')$q$, :'pago46'),
  '42501', '4.16 anon no anula pagos');
select pruebas.espera_error('select 1 from public.pagos', '42501', '4.16 anon no lee pagos');

-- 4.17: pagar un pedido a crédito libera el límite (100000).
select pruebas.como(:'c2');
select public.crear_pedido(:'d1', :'pr2x2', gen_random_uuid(),
                           p_condicion_pago => 'credito') as cred1 \gset
select pruebas.espera_error(
  format($q$select public.crear_pedido(%L, %L, gen_random_uuid(),
                                        p_condicion_pago => 'credito')$q$, :'d1', :'pr2x2'),
  'P0004', '4.17 con 96000 de deuda no cabe otro pedido de 96000');
select pruebas.como(:'a1');
select public.registrar_pago(:'cred1', 96000, 'transferencia');
select pruebas.afirma(
  (select total_centimos = 96000 and saldo_pendiente_centimos = 0 and estado_pago = 'pagado'
   from public.pedidos where id = :'cred1'),
  '4.17 el pedido a crédito queda pagado');
select pruebas.como(:'c2');
select public.crear_pedido(:'d1', :'pr2x2', gen_random_uuid(),
                           p_condicion_pago => 'credito') as cred2 \gset
select pruebas.afirma(
  (select total_centimos = 96000 and condicion_pago = 'credito'
   from public.pedidos where id = :'cred2'),
  '4.17 con la deuda en 0 se crea el segundo pedido a crédito');

-- 4.18: un pedido de contado se entrega sin pagar y se cobra después.
select pruebas.como(:'c1');
select public.crear_pedido(:'d1', :'pr1x10', gen_random_uuid()) as cont \gset
select pruebas.como(:'a1');
select public.cambiar_estado_pedido(:'cont', 'confirmado');
select public.cambiar_estado_pedido(:'cont', 'listo_recojo');
select public.cambiar_estado_pedido(:'cont', 'entregado');
select pruebas.afirma(
  (select estado = 'entregado' and estado_pago = 'pendiente'
          and saldo_pendiente_centimos = total_centimos
   from public.pedidos where id = :'cont'),
  '4.18 entregado con estado_pago pendiente');
select public.registrar_pago(:'cont', 42000, 'efectivo');
select pruebas.afirma(
  (select estado = 'entregado' and estado_pago = 'pagado' and saldo_pendiente_centimos = 0
   from public.pedidos where id = :'cont'),
  '4.18 se cobra después de entregado');
select pruebas.como_servicio();

rollback;
