-- Simula el mínimo de Supabase sobre Postgres plano. SOLO para pruebas:
-- nunca forma parte de las migraciones. Se aplica antes de las migraciones.

-- Roles (son del cluster: la creación es idempotente entre ejecuciones).
do $$
declare
  r text;
begin
  foreach r in array array['anon', 'authenticated', 'service_role'] loop
    if not exists (select 1 from pg_roles where rolname = r) then
      execute format('create role %I nologin', r);
    end if;
  end loop;
end $$;

-- auth
create schema auth;
grant usage on schema auth to anon, authenticated, service_role;

create table auth.users (
  id uuid primary key,
  email text,
  phone text,
  raw_app_meta_data jsonb,
  raw_user_meta_data jsonb
);

create function auth.jwt() returns jsonb
language sql stable
as $$
  select coalesce(nullif(current_setting('request.jwt.claims', true), ''), '{}')::jsonb
$$;

create function auth.uid() returns uuid
language sql stable
as $$
  select nullif(auth.jwt() ->> 'sub', '')::uuid
$$;

grant execute on function auth.jwt(), auth.uid() to anon, authenticated, service_role;

-- storage
create schema storage;
grant usage on schema storage to anon, authenticated, service_role;

create table storage.buckets (
  id text primary key,
  name text,
  public boolean,
  file_size_limit bigint,
  allowed_mime_types text[]
);

create table storage.objects (
  id uuid,
  bucket_id text,
  name text,
  owner uuid
);
alter table storage.objects enable row level security;

-- Como en Supabase real: los roles de la API tienen privilegios de tabla en
-- storage; el acceso efectivo lo deciden las políticas RLS.
grant select, insert, update, delete on storage.objects, storage.buckets
  to anon, authenticated, service_role;

create function storage.foldername(name text) returns text[]
language sql immutable
as $$
  select string_to_array(name, '/')
$$;

grant execute on function storage.foldername(text) to anon, authenticated, service_role;

-- Publicación de Realtime (vacía; las migraciones agregan tablas).
create publication supabase_realtime;

-- Privilegios por defecto de Supabase sobre public: así las pruebas detectan
-- cualquier tabla o función que quede expuesta sin revoke explícito.
grant usage on schema public to anon, authenticated, service_role;
alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to anon, authenticated, service_role;
