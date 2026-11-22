-- Pruebas del módulo 1: identidad y acceso.
-- Ids: D1 0d01, D2 0d02; bodegas 0b01, 0b02 (D1), 0b03 (D2);
-- A1 00a1, V1 00b1, R1 00e1, C1 00c1, C2 00c2, A2 00a2, S1 00f1, N1 0091.
begin;
\ir soporte/datos_m1.sql

-- 1.1 a 1.11: lectura y escritura directa de tablas.
select pruebas.como('00000000-0000-0000-0000-0000000000a1');
select pruebas.afirma(
  pruebas.cuenta('select 1 from public.distribuidores') = 1
  and pruebas.cuenta($q$select 1 from public.distribuidores where id = '00000000-0000-0000-0000-000000000d01'$q$) = 1,
  '1.1 el admin de D1 ve solo D1');

select pruebas.como('00000000-0000-0000-0000-0000000000c1');
select pruebas.afirma(pruebas.cuenta('select 1 from public.distribuidores') = 2,
  '1.2 el cliente con dos membresías ve los dos distribuidores');

select pruebas.como('00000000-0000-0000-0000-000000000091');
select pruebas.afirma(
  pruebas.cuenta('select 1 from public.distribuidores') = 0
  and pruebas.cuenta('select 1 from public.membresias') = 0
  and pruebas.cuenta('select 1 from public.clientes_negocio') = 0,
  '1.3 sin membresías no ve distribuidores, membresías ni bodegas');

select pruebas.como_anon();
select pruebas.espera_error('select * from public.distribuidores', '42501',
  '1.4 anon no puede leer distribuidores');

select pruebas.como('00000000-0000-0000-0000-0000000000a1');
select pruebas.afirma(
  pruebas.cuenta('select 1 from public.clientes_negocio') = 2
  and pruebas.cuenta($q$select 1 from public.clientes_negocio where distribuidor_id = '00000000-0000-0000-0000-000000000d02'$q$) = 0,
  '1.5 el admin de D1 ve las 2 bodegas de D1 y ninguna de D2');

select pruebas.como('00000000-0000-0000-0000-0000000000c2');
select pruebas.afirma(
  pruebas.cuenta('select 1 from public.clientes_negocio') = 1
  and pruebas.cuenta($q$select 1 from public.clientes_negocio where id = '00000000-0000-0000-0000-000000000b02'$q$) = 1,
  '1.6 el cliente ve solo su bodega');

select pruebas.como('00000000-0000-0000-0000-0000000000a1');
do $$
declare
  v_d2 integer;
  v_d1 integer;
begin
  update public.distribuidores set nombre = 'Otro'
  where id = '00000000-0000-0000-0000-000000000d02';
  get diagnostics v_d2 = row_count;
  update public.distribuidores set telefono = '014000000'
  where id = '00000000-0000-0000-0000-000000000d01';
  get diagnostics v_d1 = row_count;
  perform pruebas.afirma(v_d2 = 0 and v_d1 = 1,
    '1.7 el admin de D1 no edita D2 (0 filas) y sí edita D1');
end $$;

select pruebas.como('00000000-0000-0000-0000-0000000000c1');
select pruebas.espera_error(
  $q$update public.perfiles set es_super_admin = true where id = '00000000-0000-0000-0000-0000000000c1'$q$,
  '42501', '1.8 nadie se vuelve Super Admin desde la app');

do $$
declare
  v_n integer;
begin
  update public.perfiles set nombre = 'Nuevo'
  where id = '00000000-0000-0000-0000-0000000000c1';
  get diagnostics v_n = row_count;
  perform pruebas.afirma(v_n = 1, '1.9 el usuario edita su nombre');
end $$;

select pruebas.espera_error(
  $q$insert into public.membresias (perfil_id, distribuidor_id, rol)
     values ('00000000-0000-0000-0000-0000000000c1', '00000000-0000-0000-0000-000000000d02', 'admin')$q$,
  '42501', '1.10 nadie inserta membresías directamente');

select pruebas.como('00000000-0000-0000-0000-0000000000f1');
select pruebas.afirma(pruebas.cuenta('select 1 from public.distribuidores') = 2,
  '1.11 el Super Admin ve todos los distribuidores');

-- 1.12 a 1.19: invitaciones y canje.
select pruebas.como('00000000-0000-0000-0000-0000000000a1');
select codigo as cod_112, vence_en as vence_112
from public.crear_invitacion('00000000-0000-0000-0000-000000000d01', 'cliente',
                             '00000000-0000-0000-0000-000000000b02') \gset
select pruebas.afirma(
  length(:'cod_112') = 8
  and :'cod_112' ~ '^[ABCDEFGHJKMNPQRSTUVWXYZ23456789]{8}$'
  and :'vence_112'::timestamptz = now() + interval '7 days',
  '1.12 crear_invitacion da un código de 8 caracteres del alfabeto que vence a los 7 días');

select pruebas.como('00000000-0000-0000-0000-000000000091');
select public.canjear_invitacion('  ' || lower(:'cod_112') || ' ') is not null as ok_113 \gset
select pruebas.afirma(
  :'ok_113'::boolean
  and pruebas.cuenta($q$select 1 from public.distribuidores where id = '00000000-0000-0000-0000-000000000d01'$q$) = 1
  and pruebas.cuenta($q$select 1 from public.clientes_negocio where id = '00000000-0000-0000-0000-000000000b02'$q$) = 1,
  '1.13 el canje normaliza el código y N1 ve D1 y la bodega 0b02');

select pruebas.como('00000000-0000-0000-0000-0000000000c2');
select pruebas.afirma(public.canjear_invitacion(:'cod_112') is null,
  '1.14 un código ya usado devuelve null');

select pruebas.como('00000000-0000-0000-0000-0000000000a1');
select codigo as cod_115
from public.crear_invitacion('00000000-0000-0000-0000-000000000d01', 'cliente',
                             '00000000-0000-0000-0000-000000000b01') \gset
select pruebas.como('00000000-0000-0000-0000-000000000091');
select pruebas.afirma(public.canjear_invitacion(:'cod_115') is null,
  '1.15 quien ya es miembro del distribuidor recibe null');

-- Usuarios nuevos sin membresías para 1.16 a 1.19.
select pruebas.como_servicio();
insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-000000000092', 'n2@demo.pe'),
  ('00000000-0000-0000-0000-000000000093', 'n3@demo.pe'),
  ('00000000-0000-0000-0000-000000000094', 'n4@demo.pe'),
  ('00000000-0000-0000-0000-000000000095', 'n5@demo.pe');
insert into public.invitaciones (distribuidor_id, codigo, rol, cliente_negocio_id, vence_en)
values ('00000000-0000-0000-0000-000000000d01', 'VENC2345', 'cliente',
        '00000000-0000-0000-0000-000000000b01', now() - interval '1 minute');
insert into public.clientes_negocio (id, distribuidor_id, nombre_negocio, activo)
values ('00000000-0000-0000-0000-000000000b04', '00000000-0000-0000-0000-000000000d01',
        'Bodega Cerrada', false);

select pruebas.como('00000000-0000-0000-0000-000000000092');
select pruebas.afirma(public.canjear_invitacion('VENC2345') is null,
  '1.16 un código vencido devuelve null');

select pruebas.como('00000000-0000-0000-0000-0000000000a1');
select id as inv_117, codigo as cod_117
from public.crear_invitacion('00000000-0000-0000-0000-000000000d01', 'repartidor') \gset
select public.revocar_invitacion(:'inv_117');
select pruebas.como('00000000-0000-0000-0000-000000000093');
select pruebas.afirma(public.canjear_invitacion(:'cod_117') is null,
  '1.17 un código revocado devuelve null');

select pruebas.como('00000000-0000-0000-0000-0000000000a1');
select codigo as cod_118
from public.crear_invitacion('00000000-0000-0000-0000-000000000d01', 'cliente',
                             '00000000-0000-0000-0000-000000000b04') \gset
select pruebas.como('00000000-0000-0000-0000-000000000094');
select pruebas.afirma(public.canjear_invitacion(:'cod_118') is null,
  '1.18 un código de una bodega inactiva devuelve null');

select pruebas.como('00000000-0000-0000-0000-000000000095');
do $$
declare
  i integer;
  v_todos_null boolean := true;
begin
  for i in 1..5 loop
    v_todos_null := v_todos_null and public.canjear_invitacion('XXXXXXXX') is null;
  end loop;
  perform pruebas.afirma(v_todos_null, '1.19 cinco canjes fallidos devuelven null');
end $$;
select pruebas.espera_error($q$select public.canjear_invitacion('XXXXXXXX')$q$, 'P0005',
  '1.19 el sexto canje queda frenado');
select pruebas.como_servicio();
select pruebas.afirma(
  pruebas.cuenta($q$select 1 from public.intentos_canje where perfil_id = '00000000-0000-0000-0000-000000000095'$q$) = 5,
  '1.19 quedan 5 intentos registrados');

-- 1.20 a 1.22: permisos y parámetros de crear_invitacion.
select pruebas.como('00000000-0000-0000-0000-0000000000b1');
select pruebas.espera_error(
  $q$select public.crear_invitacion('00000000-0000-0000-0000-000000000d01', 'admin')$q$,
  '42501', '1.20 el vendedor no crea invitaciones de admin');

select pruebas.como('00000000-0000-0000-0000-0000000000a1');
select pruebas.espera_error(
  $q$select public.crear_invitacion('00000000-0000-0000-0000-000000000d02', 'cliente', '00000000-0000-0000-0000-000000000b03')$q$,
  '42501', '1.21 el admin de D1 no crea invitaciones de D2');

select pruebas.espera_error(
  $q$select public.crear_invitacion('00000000-0000-0000-0000-000000000d01', 'cliente')$q$,
  '22023', '1.22 una invitación de cliente exige bodega');

-- 1.23 a 1.26: gestión de membresías.
select public.cambiar_estado_membresia(
  (select id from public.membresias
   where perfil_id = '00000000-0000-0000-0000-0000000000c2'
     and distribuidor_id = '00000000-0000-0000-0000-000000000d01'),
  'suspendida');
select pruebas.como('00000000-0000-0000-0000-0000000000c2');
select pruebas.afirma(pruebas.cuenta('select 1 from public.distribuidores') = 0,
  '1.23 la membresía suspendida no ve el distribuidor');

select pruebas.como('00000000-0000-0000-0000-0000000000a1');
select pruebas.espera_error(
  $q$select public.cambiar_rol_membresia(
       (select id from public.membresias
        where perfil_id = '00000000-0000-0000-0000-0000000000a1'
          and distribuidor_id = '00000000-0000-0000-0000-000000000d01'),
       'vendedor')$q$,
  'P0006', '1.24 el único admin no puede dejar de serlo');

select pruebas.espera_error(
  $q$select public.cambiar_rol_membresia(
       (select id from public.membresias
        where perfil_id = '00000000-0000-0000-0000-0000000000b1'
          and distribuidor_id = '00000000-0000-0000-0000-000000000d01'),
       'cliente')$q$,
  '22023', '1.25 el personal no se convierte en cliente');

select public.cambiar_rol_membresia(
  (select id from public.membresias
   where perfil_id = '00000000-0000-0000-0000-0000000000b1'
     and distribuidor_id = '00000000-0000-0000-0000-000000000d01'),
  'repartidor');
select pruebas.afirma(
  (select rol from public.membresias
   where perfil_id = '00000000-0000-0000-0000-0000000000b1'
     and distribuidor_id = '00000000-0000-0000-0000-000000000d01') = 'repartidor',
  '1.26 el admin cambia el rol de vendedor a repartidor');

-- 1.27: dispositivos.
select pruebas.como('00000000-0000-0000-0000-0000000000c1');
select public.registrar_dispositivo('tok-1', 'android');
select pruebas.como('00000000-0000-0000-0000-0000000000c2');
select public.registrar_dispositivo('tok-1', 'android');
select pruebas.como_servicio();
select pruebas.afirma(
  pruebas.cuenta($q$select 1 from public.dispositivos_push where token = 'tok-1'$q$) = 1
  and (select perfil_id from public.dispositivos_push where token = 'tok-1')
      = '00000000-0000-0000-0000-0000000000c2',
  '1.27 el token se reasigna a la última cuenta que lo registra');

-- 1.28: la bodega de una membresía debe ser del mismo distribuidor.
select pruebas.espera_error(
  $q$insert into public.membresias (perfil_id, distribuidor_id, rol, cliente_negocio_id)
     values ('00000000-0000-0000-0000-0000000000a2', '00000000-0000-0000-0000-000000000d01',
             'cliente', '00000000-0000-0000-0000-000000000b03')$q$,
  '23503', '1.28 una membresía no apunta a una bodega de otro distribuidor');

-- 1.29: desactivar la bodega corta el acceso. Antes se reactiva a C2 (1.23).
select pruebas.como('00000000-0000-0000-0000-0000000000a1');
select public.cambiar_estado_membresia(
  (select id from public.membresias
   where perfil_id = '00000000-0000-0000-0000-0000000000c2'
     and distribuidor_id = '00000000-0000-0000-0000-000000000d01'),
  'activa');
select pruebas.como('00000000-0000-0000-0000-0000000000c2');
select pruebas.afirma(pruebas.cuenta('select 1 from public.distribuidores') = 1,
  '1.29 (previo) C2 reactivada vuelve a ver D1');
select pruebas.como_servicio();
update public.clientes_negocio set activo = false
where id = '00000000-0000-0000-0000-000000000b02';
select pruebas.como('00000000-0000-0000-0000-0000000000c2');
select pruebas.afirma(
  pruebas.cuenta('select 1 from public.distribuidores') = 0
  and pruebas.cuenta('select 1 from public.clientes_negocio') = 0,
  '1.29 con la bodega inactiva el cliente no ve el distribuidor ni la bodega');

-- 1.30 a 1.33: cambiar la bodega de una membresía de cliente. C2 sigue
-- vinculada a 0b02, que 1.29 dejó inactiva.
select pruebas.como('00000000-0000-0000-0000-0000000000a1');
select public.cambiar_bodega_membresia(
  (select id from public.membresias
   where perfil_id = '00000000-0000-0000-0000-0000000000c2'
     and distribuidor_id = '00000000-0000-0000-0000-000000000d01'),
  '00000000-0000-0000-0000-000000000b01');
select pruebas.como('00000000-0000-0000-0000-0000000000c2');
select pruebas.afirma(
  pruebas.cuenta('select 1 from public.clientes_negocio') = 1
  and pruebas.cuenta($q$select 1 from public.clientes_negocio where id = '00000000-0000-0000-0000-000000000b01'$q$) = 1
  and pruebas.cuenta('select 1 from public.distribuidores') = 1,
  '1.30 el admin mueve a C2 de 0b02 a 0b01 y C2 ve solo 0b01');

-- V1 volvió a ser vendedor tras 1.26 (repartidor).
select pruebas.como('00000000-0000-0000-0000-0000000000a1');
select public.cambiar_rol_membresia(
  (select id from public.membresias
   where perfil_id = '00000000-0000-0000-0000-0000000000b1'
     and distribuidor_id = '00000000-0000-0000-0000-000000000d01'),
  'vendedor');
select pruebas.como('00000000-0000-0000-0000-0000000000b1');
select pruebas.espera_error(
  $q$select public.cambiar_bodega_membresia(
       (select id from public.membresias
        where perfil_id = '00000000-0000-0000-0000-0000000000c2'
          and distribuidor_id = '00000000-0000-0000-0000-000000000d01'),
       '00000000-0000-0000-0000-000000000b02')$q$,
  '42501', '1.31 el vendedor no cambia la bodega de una membresía');
select pruebas.como('00000000-0000-0000-0000-0000000000a1');
select pruebas.espera_error(
  $q$select public.cambiar_bodega_membresia(gen_random_uuid(), '00000000-0000-0000-0000-000000000b01')$q$,
  '42501', '1.31 membresía inexistente');

select pruebas.espera_error(
  $q$select public.cambiar_bodega_membresia(
       (select id from public.membresias
        where perfil_id = '00000000-0000-0000-0000-0000000000c2'
          and distribuidor_id = '00000000-0000-0000-0000-000000000d01'),
       '00000000-0000-0000-0000-000000000b03')$q$,
  '22023', '1.32 la bodega destino es de otro distribuidor');
select pruebas.espera_error(
  $q$select public.cambiar_bodega_membresia(
       (select id from public.membresias
        where perfil_id = '00000000-0000-0000-0000-0000000000c2'
          and distribuidor_id = '00000000-0000-0000-0000-000000000d01'),
       '00000000-0000-0000-0000-000000000b02')$q$,
  '22023', '1.32 la bodega destino debe estar activa');

select pruebas.espera_error(
  $q$select public.cambiar_bodega_membresia(
       (select id from public.membresias
        where perfil_id = '00000000-0000-0000-0000-0000000000b1'
          and distribuidor_id = '00000000-0000-0000-0000-000000000d01'),
       '00000000-0000-0000-0000-000000000b01')$q$,
  '22023', '1.33 una membresía de personal no lleva bodega');

-- 1.34: el generador usa los 31 caracteres del alfabeto. Con 300 códigos
-- (2400 caracteres) la probabilidad de que falte alguno es menor a 1e-30.
select pruebas.como_servicio();
select pruebas.afirma(
  (select count(distinct ch) = 31
   from (select privado.generar_codigo_invitacion() as codigo
         from generate_series(1, 300)) as g,
        regexp_split_to_table(g.codigo, '') as ch),
  '1.34 los códigos generados usan los 31 caracteres del alfabeto (también el 9)');

-- 1.35: el teléfono del perfil sigue al de la cuenta.
update auth.users set phone = '51999999999'
where id = '00000000-0000-0000-0000-0000000000c1';
update auth.users set phone = null
where id = '00000000-0000-0000-0000-0000000000c2';
select pruebas.afirma(
  (select telefono = '51999999999' from public.perfiles
   where id = '00000000-0000-0000-0000-0000000000c1')
  and (select telefono is null from public.perfiles
       where id = '00000000-0000-0000-0000-0000000000c2'),
  '1.35 cambiar auth.users.phone actualiza perfiles.telefono');

rollback;
