-- Pruebas del módulo 6: barrido de seguridad sobre el catálogo completo.
-- No usa datos: recorre pg_catalog / information_schema y falla nombrando
-- los objetos expuestos. Solo mira public y privado (no pruebas, auth ni
-- storage, que son del shim o de Supabase).
begin;

-- Lista de objetos ofensores (o '-' si no hay), para el mensaje de fallo.
create function pg_temp.lista(p_sql text) returns text
language plpgsql
as $$
declare
  v text;
begin
  execute 'select coalesce(string_agg(x, '', '' order by x), ''-'') from (' || p_sql || ') t(x)' into v;
  return v;
end $$;

-- Afirma que la consulta (que devuelve un texto por ofensor) no da filas.
create function pg_temp.sin_ofensores(p_sql text, p_etiqueta text) returns void
language plpgsql
as $$
declare
  v text := pg_temp.lista(p_sql);
begin
  perform pruebas.afirma(v = '-', p_etiqueta || ' (ofensores: ' || v || ')');
end $$;

select pg_temp.sin_ofensores($q$
  select c.relname::text
  from pg_class c join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'public' and c.relkind in ('r', 'p') and not c.relrowsecurity
$q$, '6.1 toda tabla de public tiene RLS activo');

-- has_table_privilege y has_any_column_privilege cuentan también los grants
-- a PUBLIC y los grants por columna.
select pg_temp.sin_ofensores($q$
  select c.relname || ':' || priv
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  cross join unnest(array['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'TRUNCATE',
                          'REFERENCES', 'TRIGGER']) as priv
  where n.nspname = 'public' and c.relkind in ('r', 'p', 'v', 'm', 'f')
    and (has_table_privilege('anon', c.oid, priv)
         or (priv in ('SELECT', 'INSERT', 'UPDATE', 'REFERENCES')
             and has_any_column_privilege('anon', c.oid, priv)))
$q$, '6.2 anon sin privilegios (de tabla ni de columna, ni vía PUBLIC) sobre tablas de public');

-- 6.3: el conjunto de funciones de public y privado que anon puede ejecutar
-- es exactamente {public.consultar_invitacion(text)} (la consulta del código
-- antes de tener cuenta, migración 7). Sin la migración 7 (run.sh 6) el
-- conjunto esperado es vacío. Cualquier otra función, o que falte esa, falla.
select pg_temp.lista($q$
  select n.nspname || '.' || p.proname || '(' || pg_get_function_identity_arguments(p.oid) || ')'
  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
  where n.nspname in ('public', 'privado') and p.prokind in ('f', 'p')
    and has_function_privilege('anon', p.oid, 'EXECUTE')
$q$) as anon_ejecuta \gset
select case when to_regprocedure('public.consultar_invitacion(text)') is null then '-'
            else 'public.consultar_invitacion(p_codigo text)' end as anon_esperado \gset
select pruebas.afirma(:'anon_ejecuta' = :'anon_esperado',
  '6.3 anon solo puede ejecutar public.consultar_invitacion(text) (obtenido: '
  || :'anon_ejecuta' || '; esperado: ' || :'anon_esperado' || ')');

select pg_temp.sin_ofensores($q$
  select n.nspname || '.' || p.proname || '(' || pg_get_function_identity_arguments(p.oid) || ')'
  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
  where n.nspname in ('public', 'privado') and p.prosecdef
    and not exists (
      select 1 from unnest(coalesce(p.proconfig, '{}')) as cfg
      where cfg like 'search_path=%')
$q$, '6.4 toda función security definer fija search_path');

select pg_temp.sin_ofensores($q$
  select tablename || '.' || policyname
  from pg_policies
  where schemaname = 'public' and roles <> array['authenticated']::name[]
$q$, '6.5 toda política de public es solo para authenticated');

select pg_temp.sin_ofensores($q$
  select tablename || '.' || policyname
  from pg_policies
  where schemaname = 'public' and cmd in ('UPDATE', 'ALL') and with_check is null
$q$, '6.6 toda política UPDATE/ALL tiene with check');

select pg_temp.sin_ofensores($q$
  select c.relname::text
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  join pg_attribute a on a.attrelid = c.oid and a.attname = 'distribuidor_id' and not a.attisdropped
  where n.nspname = 'public' and c.relkind in ('r', 'p')
    and not exists (
      select 1 from pg_index i
      where i.indrelid = c.oid and i.indkey[0] = a.attnum)
$q$, '6.7 toda tabla con distribuidor_id tiene un índice que empieza por ella');

select pg_temp.sin_ofensores($q$
  select t || ':' || priv
  from unnest(array['pedidos', 'pedido_items', 'pedido_eventos', 'pagos',
         'movimientos_stock', 'membresias', 'invitaciones', 'intentos_canje',
         'contadores_pedido', 'suscripciones', 'pagos_suscripcion']) as t,
       unnest(array['INSERT', 'UPDATE', 'DELETE']) as priv
  where has_table_privilege('authenticated', format('public.%I', t), priv)
     or (priv <> 'DELETE'  -- DELETE no existe a nivel de columna
         and has_any_column_privilege('authenticated', format('public.%I', t), priv))
$q$, '6.8 authenticated sin escritura directa (tabla ni columna) en tablas solo-RPC');

select pg_temp.sin_ofensores($q$
  select c from (values
    ('productos.stock_fisico', has_column_privilege('authenticated', 'public.productos', 'stock_fisico', 'UPDATE')),
    ('productos.stock_comprometido', has_column_privilege('authenticated', 'public.productos', 'stock_comprometido', 'UPDATE')),
    ('perfiles.es_super_admin', has_column_privilege('authenticated', 'public.perfiles', 'es_super_admin', 'UPDATE'))
  ) v(c, tiene) where tiene
$q$, '6.9 authenticated no puede actualizar stock ni es_super_admin');

select pruebas.afirma(
  not has_schema_privilege('anon', 'privado', 'USAGE'),
  '6.10 anon sin USAGE sobre privado');

select pg_temp.sin_ofensores($q$
  select c.relname || '.' || a.attname || ' (' || format_type(a.atttypid, a.atttypmod) || ')'
  from pg_attribute a
  join pg_class c on c.oid = a.attrelid
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'public' and c.relkind in ('r', 'p', 'v', 'm')
    and a.attnum > 0 and not a.attisdropped
    and a.attname like '%\_centimos' and a.atttypid <> 'bigint'::regtype
$q$, '6.11 toda columna *_centimos es bigint');

rollback;
