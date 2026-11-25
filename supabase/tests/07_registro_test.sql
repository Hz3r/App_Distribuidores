-- Pruebas de la migración 7: registro por invitación.
-- consultar_invitacion (sin sesión, con freno por dirección de red) y
-- completar_datos_negocio (la bodega completa sus datos).
-- Ids del módulo 1: D1 0d01 "Licores Demo", D2 0d02; bodegas 0b01 (C1),
-- 0b02 (C2) en D1, 0b03 (C1) en D2; A1 00a1, V1 00b1, R1 00e1, C1 00c1,
-- C2 00c2, A2 00a2, N1 0091 (sin membresías).
-- La dirección de red se simula con request.headers, como la pone PostgREST.
-- Los casos corren en orden dentro de una transacción.
begin;
\ir soporte/datos_m3.sql

\set d1 00000000-0000-0000-0000-000000000d01
\set d2 00000000-0000-0000-0000-000000000d02
\set a1 00000000-0000-0000-0000-0000000000a1
\set a2 00000000-0000-0000-0000-0000000000a2
\set v1 00000000-0000-0000-0000-0000000000b1
\set r1 00000000-0000-0000-0000-0000000000e1
\set c1 00000000-0000-0000-0000-0000000000c1
\set c2 00000000-0000-0000-0000-0000000000c2
\set n1 00000000-0000-0000-0000-000000000091
\set b01 00000000-0000-0000-0000-000000000b01
\set b02 00000000-0000-0000-0000-000000000b02
\set b03 00000000-0000-0000-0000-000000000b03
\set b09 00000000-0000-0000-0000-000000000b09

-- Invitaciones de las pruebas.
-- Bodega 0b09 de D1, solo para la invitación de bodega inactiva.
select pruebas.como_servicio();
insert into public.clientes_negocio (id, distribuidor_id, nombre_negocio)
values (:'b09', :'d1', 'Bodega Inactiva');

select pruebas.como(:'a1');
select codigo as cod_b02
from public.crear_invitacion(:'d1', 'cliente', :'b02') \gset
select codigo as cod_usada
from public.crear_invitacion(:'d1', 'cliente', :'b01') \gset
select id as inv_revocada, codigo as cod_revocada
from public.crear_invitacion(:'d1', 'cliente', :'b01') \gset
select public.revocar_invitacion(:'inv_revocada');
select id as inv_vencida, codigo as cod_vencida
from public.crear_invitacion(:'d1', 'cliente', :'b01', 1) \gset
select codigo as cod_inactiva
from public.crear_invitacion(:'d1', 'cliente', :'b09') \gset
select codigo as cod_vendedor
from public.crear_invitacion(:'d1', 'vendedor') \gset

select pruebas.como(:'a2');
select codigo as cod_d2
from public.crear_invitacion(:'d2', 'cliente', :'b03') \gset

-- N1 canjea cod_usada; luego se vence una y se desactiva la bodega 0b09.
select pruebas.como(:'n1');
select pruebas.afirma(public.canjear_invitacion(:'cod_usada') is not null,
  'preparación: N1 canjea la invitación que queda usada');

select pruebas.como_servicio();
update public.invitaciones set vence_en = now() - interval '1 second'
where id = :'inv_vencida';
update public.clientes_negocio set activo = false where id = :'b09';

-- 8.1: consulta anónima de un código válido, en minúsculas y con espacios.
select pruebas.como_anon();
select set_config('request.headers', '{"x-forwarded-for":"10.0.0.1, 10.9.9.9"}', true);
select public.consultar_invitacion('  ' || lower(:'cod_b02') || ' ') as r81 \gset
select pruebas.afirma(
  (:'r81'::jsonb) ->> 'distribuidor_id' = :'d1'
  and (:'r81'::jsonb) ->> 'distribuidor_nombre' = 'Licores Demo'
  and (:'r81'::jsonb) ->> 'rol' = 'cliente'
  and (:'r81'::jsonb) -> 'negocio' ->> 'nombre_negocio' = 'Bodega Dos'
  and (select array_agg(k order by k) from jsonb_object_keys((:'r81'::jsonb) -> 'negocio') k)
      = array['direccion', 'documento', 'nombre_negocio', 'referencia', 'telefono']
  and (select array_agg(k order by k) from jsonb_object_keys(:'r81'::jsonb) k)
      = array['distribuidor_id', 'distribuidor_nombre', 'negocio', 'rol'],
  '8.1 anon ve el distribuidor, el rol y la bodega del código normalizado');

select pruebas.como_servicio();
select pruebas.afirma(
  (select count(*) from public.intentos_consulta) = 1
  and (select count(*) from public.intentos_consulta
       where direccion_red = '10.0.0.1' and exitoso) = 1,
  '8.1 queda un intento exitoso con direccion_red 10.0.0.1');

-- 8.2: código inexistente.
select pruebas.como_anon();
select pruebas.afirma(public.consultar_invitacion('XXXXXXXX') is null,
  '8.2 un código inexistente devuelve null');

select pruebas.como_servicio();
select pruebas.afirma(
  (select count(*) from public.intentos_consulta
   where direccion_red = '10.0.0.1' and not exitoso) = 1,
  '8.2 queda un intento fallido');

-- 8.3: usado, revocado, vencido y de bodega inactiva: todos null, como uno
-- inexistente. Desde 10.0.0.4 para no sumar fallos a 10.0.0.1.
select pruebas.como_anon();
select set_config('request.headers', '{"x-forwarded-for":"10.0.0.4"}', true);
select pruebas.afirma(
  public.consultar_invitacion(:'cod_usada') is null
  and public.consultar_invitacion(:'cod_revocada') is null
  and public.consultar_invitacion(:'cod_vencida') is null
  and public.consultar_invitacion(:'cod_inactiva') is null,
  '8.3 usado, revocado, vencido y bodega inactiva devuelven null');

select pruebas.como_servicio();
select pruebas.afirma(
  (select count(*) from public.intentos_consulta
   where direccion_red = '10.0.0.4' and not exitoso) = 4,
  '8.3 los cuatro cuentan como intentos fallidos');

-- 8.4: con 5 fallos en 15 minutos, la dirección queda frenada.
select pruebas.como_anon();
select set_config('request.headers', '{"x-forwarded-for":"10.0.0.2"}', true);
do $$
declare
  v_todos_null boolean := true;
  i integer;
begin
  for i in 1..5 loop
    v_todos_null := v_todos_null and public.consultar_invitacion('XXXXXXXX') is null;
  end loop;
  perform pruebas.afirma(v_todos_null, '8.4 las 5 consultas fallidas devuelven null');
end $$;
select pruebas.espera_error(
  format('select public.consultar_invitacion(%L)', :'cod_b02'), 'P0005',
  '8.4 la sexta consulta, aunque el código sea válido, lanza P0005');

-- 8.5: el freno es por dirección.
select set_config('request.headers', '{"x-forwarded-for":"10.0.0.3"}', true);
select pruebas.afirma(
  public.consultar_invitacion(:'cod_b02') ->> 'distribuidor_id' = :'d1',
  '8.5 desde 10.0.0.3 el código válido devuelve datos');

-- 8.6: sin cabecera, la dirección es 'desconocida'.
select set_config('request.headers', '', true);
select pruebas.afirma(
  public.consultar_invitacion(:'cod_b02') ->> 'distribuidor_id' = :'d1',
  '8.6 sin cabecera el código válido devuelve datos');
select set_config('request.headers', '{"accept":"application/json"}', true);
select pruebas.afirma(
  public.consultar_invitacion(:'cod_b02') ->> 'distribuidor_id' = :'d1',
  '8.6 con cabeceras pero sin x-forwarded-for devuelve datos');

select set_config('request.headers', 'no es json', true);
select pruebas.afirma(
  public.consultar_invitacion(:'cod_b02') ->> 'distribuidor_id' = :'d1',
  '8.6 con request.headers que no es JSON devuelve datos');

select pruebas.como_servicio();
select pruebas.afirma(
  (select count(*) from public.intentos_consulta
   where direccion_red = 'desconocida' and exitoso) = 3,
  '8.6 los intentos quedan con direccion_red desconocida');

-- La cabecera es texto del cliente: se guarda tal cual (sin interpretarla)
-- y cortada a 64 caracteres.
select pruebas.como_anon();
select set_config('request.headers',
  json_build_object('x-forwarded-for', repeat('9', 100) || ''');--, 10.0.0.1')::text, true);
select pruebas.afirma(
  public.consultar_invitacion(:'cod_b02') ->> 'distribuidor_id' = :'d1',
  '8.6 con una cabecera larga y con comillas devuelve datos');

select pruebas.como_servicio();
select pruebas.afirma(
  (select count(*) from public.intentos_consulta
   where direccion_red = repeat('9', 64) and exitoso) = 1,
  '8.6 la dirección guardada se corta a 64 caracteres');

-- 8.7: invitación de personal: rol vendedor y sin bodega.
select pruebas.como_anon();
select set_config('request.headers', '{"x-forwarded-for":"10.0.0.7"}', true);
select public.consultar_invitacion(:'cod_vendedor') as r87 \gset
select pruebas.afirma(
  (:'r87'::jsonb) ->> 'rol' = 'vendedor'
  and jsonb_typeof((:'r87'::jsonb) -> 'negocio') = 'null'
  and (:'r87'::jsonb) ->> 'distribuidor_nombre' = 'Licores Demo',
  '8.7 una invitación de vendedor da rol vendedor y negocio null');

-- 8.8: el nombre visible sale de config_tema.nombre si no está vacío.
select pruebas.como_servicio();
update public.distribuidores set config_tema = '{"nombre":"Marca X"}' where id = :'d2';

select pruebas.como_anon();
select pruebas.afirma(
  public.consultar_invitacion(:'cod_d2') ->> 'distribuidor_nombre' = 'Marca X',
  '8.8 distribuidor_nombre es config_tema.nombre');

select pruebas.como_servicio();
update public.distribuidores set config_tema = '{"nombre":"   "}' where id = :'d2';

select pruebas.como_anon();
select pruebas.afirma(
  public.consultar_invitacion(:'cod_d2') ->> 'distribuidor_nombre' = 'Electro Demo',
  '8.8 con config_tema.nombre en blanco se usa distribuidores.nombre');

-- 8.9: anon no lee las tablas directamente.
select pruebas.espera_error('select * from public.intentos_consulta', '42501',
  '8.9 anon no lee intentos_consulta');
select pruebas.espera_error('select * from public.invitaciones', '42501',
  '8.9 anon no lee invitaciones');
select pruebas.espera_error('select * from public.clientes_negocio', '42501',
  '8.9 anon no lee clientes_negocio');
select set_config('request.headers', '', true);

-- 8.10 a 8.17: completar_datos_negocio.
select pruebas.como(:'c2');
select public.completar_datos_negocio(:'d1',
  p_documento => ' 20601234567 ',
  p_direccion => 'Av. Los Olivos 123',
  p_telefono => '987654321');

select pruebas.como_servicio();
select pruebas.afirma(
  (select documento = '20601234567' and direccion = 'Av. Los Olivos 123'
          and telefono = '987654321' and referencia is null
          and nombre_negocio = 'Bodega Dos'
   from public.clientes_negocio where id = :'b02'),
  '8.10 C2 completa documento, dirección y teléfono (limpios); el nombre no cambia');

select pruebas.como(:'c2');
select public.completar_datos_negocio(:'d1', p_documento => '10111111111');

select pruebas.como_servicio();
select pruebas.afirma(
  (select documento from public.clientes_negocio where id = :'b02') = '20601234567',
  '8.11 el documento ya completo no cambia, sin error');

update public.clientes_negocio set referencia = 'Frente al parque' where id = :'b02';

select pruebas.como(:'c2');
select public.completar_datos_negocio(:'d1',
  p_direccion => '', p_referencia => null, p_telefono => '   ');

select pruebas.como_servicio();
select pruebas.afirma(
  (select direccion = 'Av. Los Olivos 123' and referencia = 'Frente al parque'
          and telefono = '987654321'
   from public.clientes_negocio where id = :'b02'),
  '8.12 un parámetro vacío o nulo no cambia su columna');

select pruebas.como(:'c2');
select pruebas.espera_error(
  format('select public.completar_datos_negocio(%L, p_direccion => %L)',
         :'d1', repeat('a', 201)),
  '22023', '8.13 una dirección de 201 caracteres da 22023');

select pruebas.como_servicio();
select pruebas.afirma(
  (select direccion from public.clientes_negocio where id = :'b02') = 'Av. Los Olivos 123',
  '8.13 la dirección no cambió');

select pruebas.como(:'c2');
select pruebas.espera_error(
  format('select public.completar_datos_negocio(%L, p_direccion => %L)', :'d2', 'x'),
  '42501', '8.14 C2 no completa datos en D2, donde no es cliente');

select pruebas.como(:'v1');
select pruebas.espera_error(
  format('select public.completar_datos_negocio(%L, p_direccion => %L)', :'d1', 'x'),
  '42501', '8.15 el vendedor recibe 42501');
select pruebas.como(:'r1');
select pruebas.espera_error(
  format('select public.completar_datos_negocio(%L, p_direccion => %L)', :'d1', 'x'),
  '42501', '8.15 el repartidor recibe 42501');
select pruebas.como_anon();
select pruebas.espera_error(
  format('select public.completar_datos_negocio(%L, p_direccion => %L)', :'d1', 'x'),
  '42501', '8.15 anon recibe 42501');

select pruebas.como(:'c1');
select public.completar_datos_negocio(:'d1', p_direccion => 'Calle Uno 1');

select pruebas.como_servicio();
select pruebas.afirma(
  (select direccion from public.clientes_negocio where id = :'b01') = 'Calle Uno 1'
  and (select direccion from public.clientes_negocio where id = :'b02') = 'Av. Los Olivos 123'
  and (select direccion from public.clientes_negocio where id = :'b03') is null,
  '8.16 C1 cambia solo la bodega 0b01; 0b02 y 0b03 intactas');

update public.clientes_negocio set activo = false where id = :'b02';

select pruebas.como(:'c2');
select pruebas.espera_error(
  format('select public.completar_datos_negocio(%L, p_direccion => %L)', :'d1', 'x'),
  '42501', '8.17 con la bodega inactiva, C2 recibe 42501');

rollback;
