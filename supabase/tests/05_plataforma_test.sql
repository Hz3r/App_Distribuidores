-- Pruebas del módulo 5: plataforma.
-- Ids del módulo 1: D1 0d01; A1 00a1 (admin de D1), C1 00c1 (cliente de D1),
-- S1 00f1 (Super Admin), N1 0091 (sin membresías).
-- Módulo 2: PR1 0201 (presentación de D1).
-- Los casos corren en orden dentro de una transacción: cada uno parte del
-- estado que dejan los anteriores.
--
-- Nuevo = distribuidor 'abarrotes-sur' creado por S1 en 5.1.
begin;
\ir soporte/datos_m3.sql

\set d1 00000000-0000-0000-0000-000000000d01
\set a1 00000000-0000-0000-0000-0000000000a1
\set c1 00000000-0000-0000-0000-0000000000c1
\set s1 00000000-0000-0000-0000-0000000000f1
\set n1 00000000-0000-0000-0000-000000000091
\set pr1x1 '[{"presentacion_id": "00000000-0000-0000-0000-000000000201", "cantidad": 1}]'

-- Planes de partida: basico (activo) y viejo (inactivo).
select pruebas.como_servicio();
insert into public.planes (codigo, nombre, precio_mensual_centimos)
values ('basico', 'Básico', 9900);
insert into public.planes (codigo, nombre, precio_mensual_centimos, activo)
values ('viejo', 'Plan retirado', 5000, false);

-- 5.1: el Super Admin crea un distribuidor.
select pruebas.como(:'s1');
select public.crear_distribuidor('Abarrotes Sur', 'abarrotes-sur', 'abarrotes', 'basico')
  as alta \gset
select pruebas.afirma(
  (:'alta'::jsonb ? 'distribuidor_id')
  and length(:'alta'::jsonb ->> 'invitacion_codigo') = 8,
  '5.1 devuelve distribuidor_id e invitacion_codigo de 8 caracteres');
select :'alta'::jsonb ->> 'distribuidor_id' as nuevo,
       :'alta'::jsonb ->> 'invitacion_codigo' as codigo \gset

select pruebas.como_servicio();
select pruebas.afirma(
  (select nombre = 'Abarrotes Sur' and slug = 'abarrotes-sur' and rubro = 'abarrotes'
          and estado = 'prueba'
   from public.distribuidores where id = :'nuevo'),
  '5.1 distribuidor en prueba');
select pruebas.afirma(
  (select count(*) = 1 from public.suscripciones where distribuidor_id = :'nuevo'),
  '5.1 una sola suscripción');
select pruebas.afirma(
  (select s.estado = 'prueba'
          and s.plan_id = (select id from public.planes where codigo = 'basico')
          and s.periodo_inicio = (now() at time zone 'America/Lima')::date
          and s.periodo_fin = s.periodo_inicio + 30
          and s.proveedor_pago is null and s.referencia_externa is null
   from public.suscripciones s where s.distribuidor_id = :'nuevo'),
  '5.1 suscripción en prueba por 30 días desde hoy');
select pruebas.afirma(
  (select rol = 'admin' and creada_por = :'s1' and cliente_negocio_id is null
          and usada_en is null and revocada_en is null
          and vence_en > now() + interval '6 days 23 hours'
          and vence_en <= now() + interval '7 days'
   from public.invitaciones where codigo = :'codigo' and distribuidor_id = :'nuevo'),
  '5.1 invitación de admin vigente 7 días, creada por S1');
select id as suscripcion from public.suscripciones where distribuidor_id = :'nuevo' \gset

-- 5.2: N1 canjea el código y queda como admin del distribuidor nuevo.
select pruebas.como(:'n1');
select pruebas.afirma(public.canjear_invitacion(:'codigo') is not null,
  '5.2 el canje devuelve la membresía');
select pruebas.afirma(
  (select rol = 'admin' and estado = 'activa'
   from public.membresias where perfil_id = :'n1' and distribuidor_id = :'nuevo'),
  '5.2 N1 es admin activo del distribuidor nuevo');
select pruebas.afirma(
  pruebas.cuenta(format('select 1 from public.distribuidores where id = %L', :'nuevo')) = 1,
  '5.2 N1 ve su distribuidor');

-- 5.3: N1 crea una categoría en su distribuidor.
insert into public.categorias (distribuidor_id, nombre) values (:'nuevo', 'Arroces');
select pruebas.afirma(
  pruebas.cuenta(format(
    'select 1 from public.categorias where distribuidor_id = %L and nombre = ''Arroces''',
    :'nuevo')) = 1,
  '5.3 la categoría se inserta');

-- 5.4: solo el Super Admin crea distribuidores.
select pruebas.como(:'a1');
select pruebas.espera_error(
  $$select public.crear_distribuidor('Otro', 'otro', 'abarrotes', 'basico')$$,
  '42501', '5.4 el admin no crea distribuidores');
select pruebas.como(:'n1');
select pruebas.espera_error(
  $$select public.crear_distribuidor('Otro', 'otro', 'abarrotes', 'basico')$$,
  '42501', '5.4 el admin de otro distribuidor tampoco');
select pruebas.como_anon();
select pruebas.espera_error(
  $$select public.crear_distribuidor('Otro', 'otro', 'abarrotes', 'basico')$$,
  '42501', '5.4 anon no ejecuta la función');

-- 5.5: plan inexistente o inactivo.
select pruebas.como(:'s1');
select pruebas.espera_error(
  $$select public.crear_distribuidor('Otro', 'otro', 'abarrotes', 'no-existe')$$,
  '22023', '5.5 plan inexistente');
select pruebas.espera_error(
  $$select public.crear_distribuidor('Otro', 'otro', 'abarrotes', 'viejo')$$,
  '22023', '5.5 plan inactivo');
select pruebas.espera_error(
  $$select public.crear_distribuidor('  ', 'otro', 'abarrotes', 'basico')$$,
  '22023', '5.5 nombre vacío');

-- 5.6: slug repetido.
select pruebas.espera_error(
  $$select public.crear_distribuidor('Abarrotes Sur 2', 'abarrotes-sur', 'abarrotes', 'basico')$$,
  '23505', '5.6 slug repetido');
select pruebas.como_servicio();
select pruebas.afirma(
  (select count(*) = 2 from public.distribuidores where slug <> 'abarrotes-sur')
  and (select count(*) = 1 from public.suscripciones),
  '5.6 los rechazos no dejan distribuidores ni suscripciones a medias');

-- 5.7: el Super Admin suspende D1 y la bodega ya no puede pedir.
select pruebas.como(:'s1');
select public.cambiar_estado_distribuidor(:'d1', 'suspendido');
select pruebas.afirma(
  (select estado = 'suspendido' from public.distribuidores where id = :'d1'),
  '5.7 D1 queda suspendido');
select pruebas.como(:'c1');
select pruebas.espera_error(
  format($q$select public.crear_pedido(%L, %L, gen_random_uuid(), p_despacho => 'recojo',
                                        p_condicion_pago => 'contado')$q$, :'d1', :'pr1x1'),
  'P0003', '5.7 crear_pedido rechaza pedidos en D1 suspendido');
select pruebas.afirma(
  pruebas.cuenta(format('select 1 from public.productos where distribuidor_id = %L', :'d1')) > 0,
  '5.7 el catálogo de D1 sigue legible');

-- 5.8: solo el Super Admin cambia el estado de un distribuidor.
select pruebas.como(:'a1');
select pruebas.espera_error(
  format($$select public.cambiar_estado_distribuidor(%L, 'activo')$$, :'d1'),
  '42501', '5.8 el admin no reactiva su distribuidor');
select pruebas.espera_error(
  format($$update public.distribuidores set estado = 'activo' where id = %L$$, :'d1'),
  '42501', '5.8 ni con un update directo');
select pruebas.como(:'s1');
select pruebas.espera_error(
  $$select public.cambiar_estado_distribuidor(gen_random_uuid(), 'activo')$$,
  'P0002', '5.8 distribuidor inexistente');
select pruebas.espera_error(
  format('select public.cambiar_estado_distribuidor(%L, null)', :'d1'),
  '22023', '5.8 estado nulo');

-- 5.9: el Super Admin registra el pago de la suscripción.
select public.registrar_pago_suscripcion(
  :'suscripcion', 9900, 'transferencia', '2026-12-01', '2026-12-31') as pago59 \gset
select pruebas.afirma(
  (select estado = 'activa' and periodo_inicio = '2026-12-01' and periodo_fin = '2026-12-31'
   from public.suscripciones where id = :'suscripcion'),
  '5.9 suscripción activa con el periodo pagado');
select pruebas.afirma(
  (select count(*) = 1 from public.pagos_suscripcion where suscripcion_id = :'suscripcion'),
  '5.9 una fila en pagos_suscripcion');
select pruebas.afirma(
  (select id = :'pago59' and distribuidor_id = :'nuevo' and monto_centimos = 9900
          and metodo = 'transferencia' and registrado_por = :'s1'
          and periodo_inicio = '2026-12-01' and periodo_fin = '2026-12-31'
          and referencia_externa is null and nota is null
   from public.pagos_suscripcion where suscripcion_id = :'suscripcion'),
  '5.9 el pago queda registrado por S1');
select pruebas.espera_error(
  format($$select public.registrar_pago_suscripcion(%L, 0, 'transferencia',
           '2027-01-01', '2027-01-31')$$, :'suscripcion'),
  '22023', '5.9 monto cero');
select pruebas.espera_error(
  format($$select public.registrar_pago_suscripcion(%L, 9900, 'transferencia',
           '2027-01-31', '2027-01-01')$$, :'suscripcion'),
  '22023', '5.9 periodo invertido');
select pruebas.espera_error(
  $$select public.registrar_pago_suscripcion(gen_random_uuid(), 9900, 'transferencia',
    '2027-01-01', '2027-01-31')$$,
  'P0002', '5.9 suscripción inexistente');
select pruebas.como(:'n1');
select pruebas.espera_error(
  format($$select public.registrar_pago_suscripcion(%L, 9900, 'transferencia',
           '2027-01-01', '2027-01-31')$$, :'suscripcion'),
  '42501', '5.9 el admin del distribuidor no registra pagos de su suscripción');

-- 5.10: el admin lee solo la suscripción de su distribuidor.
select pruebas.afirma(pruebas.cuenta('select 1 from public.suscripciones') = 1,
  '5.10 N1 ve su suscripción');
select pruebas.afirma(pruebas.cuenta('select 1 from public.pagos_suscripcion') = 1,
  '5.10 N1 ve su pago');
select pruebas.como(:'a1');
select pruebas.afirma(pruebas.cuenta('select 1 from public.suscripciones') = 0,
  '5.10 A1 no ve suscripciones ajenas');
select pruebas.afirma(pruebas.cuenta('select 1 from public.pagos_suscripcion') = 0,
  '5.10 A1 no ve pagos ajenos');
select pruebas.como(:'s1');
select pruebas.afirma(pruebas.cuenta('select 1 from public.suscripciones') = 1
  and pruebas.cuenta('select 1 from public.pagos_suscripcion') = 1,
  '5.10 el Super Admin lee todo');

-- 5.11: la bodega no ve suscripciones ni pagos de suscripción.
select pruebas.como(:'c1');
select pruebas.afirma(pruebas.cuenta('select 1 from public.suscripciones') = 0,
  '5.11 C1 no ve suscripciones');
select pruebas.afirma(pruebas.cuenta('select 1 from public.pagos_suscripcion') = 0,
  '5.11 C1 no ve pagos de suscripción');

-- 5.12: nadie fuera del Super Admin escribe el módulo directamente.
select pruebas.como(:'a1');
select pruebas.espera_error(
  $$insert into public.planes (codigo, nombre, precio_mensual_centimos)
    values ('gratis', 'Gratis', 0)$$,
  '42501', '5.12 el admin no inserta planes');
select pruebas.espera_error(
  $$update public.suscripciones set estado = 'cancelada'$$,
  '42501', '5.12 el admin no edita suscripciones');
-- Un update que la política filtra no falla: no toca ninguna fila.
select pruebas.como(:'n1');
update public.planes set precio_mensual_centimos = 0 where codigo = 'basico';
select pruebas.como_servicio();
select pruebas.afirma(
  (select precio_mensual_centimos = 9900 from public.planes where codigo = 'basico'),
  '5.12 el update de planes del admin no cambia nada');
select pruebas.como(:'n1');
select pruebas.espera_error(
  format($$insert into public.pagos_suscripcion
           (distribuidor_id, suscripcion_id, monto_centimos, metodo, periodo_inicio, periodo_fin)
           values (%L, %L, 100, 'efectivo', '2027-01-01', '2027-01-31')$$,
         :'nuevo', :'suscripcion'),
  '42501', '5.12 el admin no inserta pagos de suscripción');
select pruebas.como(:'s1');
select pruebas.espera_error(
  $$update public.suscripciones set estado = 'cancelada'$$,
  '42501', '5.12 tampoco el Super Admin edita suscripciones fuera de las funciones');

-- 5.13: el Super Admin crea y edita planes.
insert into public.planes (codigo, nombre, precio_mensual_centimos, limites)
values ('pro', 'Pro', 19900, '{"max_clientes": 200}');
update public.planes set nombre = 'Básico 2027' where codigo = 'basico';
select pruebas.como_servicio();
select pruebas.afirma(
  (select nombre = 'Pro' and precio_mensual_centimos = 19900 and moneda = 'PEN'
          and limites = '{"max_clientes": 200}' and activo
   from public.planes where codigo = 'pro'),
  '5.13 el plan pro se inserta');
select pruebas.afirma(
  (select nombre = 'Básico 2027' from public.planes where codigo = 'basico'),
  '5.13 el Super Admin edita un plan');

-- 5.14: a lo sumo una suscripción vigente por distribuidor.
select pruebas.espera_error(
  format($$insert into public.suscripciones
           (distribuidor_id, plan_id, estado, periodo_inicio, periodo_fin)
           select %L, id, 'activa', '2027-01-01', '2027-01-31'
           from public.planes where codigo = 'pro'$$, :'nuevo'),
  '23505', '5.14 segunda suscripción vigente');
insert into public.suscripciones (distribuidor_id, plan_id, estado, periodo_inicio, periodo_fin)
select :'nuevo', id, 'vencida', '2026-01-01', '2026-01-31'
from public.planes where codigo = 'basico';
select pruebas.afirma(
  (select count(*) = 2 from public.suscripciones where distribuidor_id = :'nuevo'),
  '5.14 una suscripción no vigente sí convive con la vigente');

-- 5.15: toda persona autenticada lee los planes.
select pruebas.como(:'c1');
select pruebas.afirma(pruebas.cuenta('select 1 from public.planes') = 3,
  '5.15 C1 ve los planes');
select pruebas.como_anon();
select pruebas.espera_error('select 1 from public.planes', '42501', '5.15 anon no lee planes');
select pruebas.como_servicio();

-- 5.16: el slug se guarda en minúsculas y debe tener forma de slug.
select pruebas.como(:'s1');
select public.crear_distribuidor('Abarrotes Norte', '  ABARROTES-Norte ', 'abarrotes', 'pro')
  ->> 'distribuidor_id' as norte \gset
select pruebas.afirma(
  (select slug = 'abarrotes-norte' from public.distribuidores where id = :'norte'),
  '5.16 el slug se guarda en minúsculas y sin espacios');
select pruebas.espera_error(
  $$select public.crear_distribuidor('Otro', 'mal slug', 'abarrotes', 'pro')$$,
  '22023', '5.16 slug con espacio');
select pruebas.espera_error(
  $$select public.crear_distribuidor('Otro', '-otro', 'abarrotes', 'pro')$$,
  '22023', '5.16 slug que empieza con guion');
select pruebas.espera_error(
  $$select public.crear_distribuidor('Otro', 'otro--dos', 'abarrotes', 'pro')$$,
  '22023', '5.16 slug con guiones seguidos');
select pruebas.espera_error(
  $$select public.crear_distribuidor('Otro', 'ñandú', 'abarrotes', 'pro')$$,
  '22023', '5.16 slug con letras fuera de a-z');
select pruebas.espera_error(
  $$select public.crear_distribuidor('Abarrotes Sur 3', 'ABARROTES-SUR', 'abarrotes', 'pro')$$,
  '23505', '5.16 el slug repetido se detecta sin importar mayúsculas');

-- 5.17: no se registra el pago de una suscripción cancelada.
select pruebas.como_servicio();
insert into public.suscripciones (distribuidor_id, plan_id, estado, periodo_inicio, periodo_fin)
select :'d1', id, 'cancelada', '2026-01-01', '2026-01-31'
from public.planes where codigo = 'basico'
returning id as cancelada \gset
select pruebas.como(:'s1');
select pruebas.espera_error(
  format($$select public.registrar_pago_suscripcion(%L, 9900, 'transferencia',
           '2027-01-01', '2027-01-31')$$, :'cancelada'),
  'P0006', '5.17 pago sobre una suscripción cancelada');

-- 5.18: el distribuidor nuevo ya tiene una vigente (5.9): pagar su
-- suscripción vencida (5.14) da P0006 y no deja nada registrado.
select id as vencida from public.suscripciones
where distribuidor_id = :'nuevo' and estado = 'vencida' \gset
select pruebas.espera_error(
  format($$select public.registrar_pago_suscripcion(%L, 9900, 'transferencia',
           '2027-01-01', '2027-01-31')$$, :'vencida'),
  'P0006', '5.18 pago que dejaría dos suscripciones vigentes');
select pruebas.afirma(
  (select estado = 'vencida' from public.suscripciones where id = :'vencida')
  and (select count(*) = 0 from public.pagos_suscripcion
       where suscripcion_id in (:'vencida', :'cancelada')),
  '5.18 los rechazos no dejan pagos ni cambian las suscripciones');
select pruebas.como_servicio();

rollback;
