-- Ayudas de aserción para las pruebas SQL. SOLO para pruebas: nunca forma
-- parte de las migraciones. Todas se ejecutan con los privilegios del rol
-- actual (sin security definer), para ejercitar RLS y permisos.

create schema pruebas;
grant usage on schema pruebas to anon, authenticated, service_role;

-- Simula una sesión autenticada con ese uid.
create function pruebas.como(p_uid uuid) returns void
language plpgsql
as $$
begin
  perform set_config('request.jwt.claims', json_build_object('sub', p_uid)::text, false);
  set role authenticated;
end $$;

-- Simula una sesión anónima (sin claims).
create function pruebas.como_anon() returns void
language plpgsql
as $$
begin
  perform set_config('request.jwt.claims', '', false);
  set role anon;
end $$;

-- Vuelve al rol inicial de la sesión (funciona desde authenticated o anon).
create function pruebas.como_servicio() returns void
language plpgsql
as $$
begin
  perform set_config('request.jwt.claims', '', false);
  reset role;
end $$;

create function pruebas.afirma(p_condicion boolean, p_etiqueta text) returns void
language plpgsql
as $$
begin
  if p_condicion is not true then
    raise exception 'FALLO %', p_etiqueta;
  end if;
  raise notice 'OK %', p_etiqueta;
end $$;

-- Ejecuta p_sql y exige que falle con el SQLSTATE indicado.
create function pruebas.espera_error(p_sql text, p_sqlstate text, p_etiqueta text) returns void
language plpgsql
as $$
declare
  v_obtenido text;
begin
  begin
    execute p_sql;
  exception when others then
    v_obtenido := sqlstate;
  end;
  if v_obtenido is null then
    raise exception 'FALLO % (no hubo error, se esperaba %)', p_etiqueta, p_sqlstate;
  elsif v_obtenido <> p_sqlstate then
    raise exception 'FALLO % (SQLSTATE % en vez de %)', p_etiqueta, v_obtenido, p_sqlstate;
  end if;
  raise notice 'OK %', p_etiqueta;
end $$;

-- Cuántas filas devuelve un select para el rol actual.
create function pruebas.cuenta(p_sql text) returns bigint
language plpgsql
as $$
declare
  v_n bigint;
begin
  execute 'select count(*) from (' || p_sql || ') as t' into v_n;
  return v_n;
end $$;

grant execute on all functions in schema pruebas to anon, authenticated, service_role;
