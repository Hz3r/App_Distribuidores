-- Migración 7: registro por invitación.
-- Las seis migraciones anteriores ya están aplicadas en DEV: no se editan.
-- Spec: docs/superpowers/specs/2026-11-25-ingreso-y-registro-por-invitacion-design.md
--
-- 1. intentos_consulta: registro de consultas de códigos para frenar, por
--    dirección de red, a quien prueba códigos sin sesión.
-- 2. consultar_invitacion(): la app muestra a quién se une la bodega antes
--    de que tenga cuenta. Es la ÚNICA función del esquema que puede ejecutar
--    anon.
-- 3. completar_datos_negocio(): la bodega, ya con sesión, completa los datos
--    de contacto de su bodega. Nunca el nombre, la lista ni el crédito.

-- ---------------------------------------------------------------------------
-- 1. Tabla intentos_consulta
-- Sin distribuidor_id: el intento no pertenece a ningún distribuidor (el
-- código puede no existir). Sin ningún grant: solo la escriben y leen las
-- funciones security definer.
-- ---------------------------------------------------------------------------
create table public.intentos_consulta (
  id uuid primary key default gen_random_uuid(),
  direccion_red text not null,
  exitoso boolean not null,
  creado_en timestamptz not null default now()
);

alter table public.intentos_consulta enable row level security;

create index intentos_consulta_direccion_idx
  on public.intentos_consulta (direccion_red, creado_en);

revoke all on public.intentos_consulta from anon, authenticated;

-- ---------------------------------------------------------------------------
-- 2. consultar_invitacion
-- Se puede llamar sin sesión. Si el código es canjeable devuelve el nombre
-- visible del distribuidor, el rol y, si es de cliente, los datos de la
-- bodega. Si no (inexistente, usado, revocado, vencido o de bodega inactiva)
-- devuelve null: los cinco casos son indistinguibles para quien llama.
--
-- No lanza error cuando el código no sirve: así el intento fallido queda
-- registrado (un error revertiría su insert) y el freno funciona. Solo lanza
-- P0005 con 5 o más consultas fallidas desde la misma dirección en los
-- últimos 15 minutos.
--
-- Dirección de red, de las cabeceras que pone PostgREST en request.headers,
-- en este orden:
--   a. cf-connecting-ip, si no está vacía tras trim: el borde de Cloudflare,
--      delante de Supabase, la fija y sobreescribe la que mande el cliente;
--   b. si no, el ÚLTIMO elemento de x-forwarded-for, con trim: el que agregó
--      el proxy de confianza. El primero lo elige el cliente (el borde agrega
--      la dirección real al final en vez de reemplazar la cabecera), así que
--      usarlo permitiría saltarse el freno o frenar a otro;
--   c. si no, 'desconocida' (fuera de PostgREST el ajuste puede ser nulo o
--      vacío, o no ser JSON).
-- El valor es texto no confiable: nunca se interpola en SQL y se guarda
-- cortado a 64 caracteres (una IPv6 completa ocupa 45).
--
-- Cada consulta borra los intentos de su dirección con más de 1 día, para
-- que la tabla, que escribe un anónimo, no crezca sin límite.
-- ---------------------------------------------------------------------------
create function public.consultar_invitacion(p_codigo text) returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_cabeceras_texto text := current_setting('request.headers', true);
  v_cabeceras jsonb;
  v_direccion text;
  v_inv public.invitaciones;
  v_resultado jsonb;
begin
  begin
    v_cabeceras := nullif(v_cabeceras_texto, '')::jsonb;
  exception when invalid_text_representation then
    -- request.headers que no es JSON válido: se trata como sin cabeceras.
    v_cabeceras := null;
  end;
  -- split_part con -1 da el último elemento (también si hay uno solo).
  v_direccion := left(coalesce(
    nullif(trim(v_cabeceras ->> 'cf-connecting-ip'), ''),
    nullif(trim(split_part(v_cabeceras ->> 'x-forwarded-for', ',', -1)), ''),
    'desconocida'), 64);

  -- Serializa las consultas de una misma dirección: sin esto, varias
  -- llamadas en paralelo leerían el conteo antes de que ninguna registre su
  -- intento y todas pasarían el freno. Clave (2, hash de la dirección): el 2
  -- separa este freno del de canjear_invitacion (1).
  perform pg_advisory_xact_lock(2, hashtext(v_direccion));

  -- Limpieza: los intentos de esta dirección con más de 1 día ya no cuentan
  -- para el freno (ventana de 15 minutos).
  delete from public.intentos_consulta i
  where i.direccion_red = v_direccion
    and i.creado_en < now() - interval '1 day';

  if (select count(*) from public.intentos_consulta i
      where i.direccion_red = v_direccion
        and not i.exitoso
        and i.creado_en > now() - interval '15 minutes') >= 5 then
    raise exception 'Demasiadas consultas de códigos; espere unos minutos'
      using errcode = 'P0005';
  end if;

  select * into v_inv
  from public.invitaciones
  where codigo = upper(trim(p_codigo));

  -- Mismas condiciones de canjeable que canjear_invitacion.
  if found
     and v_inv.usada_en is null
     and v_inv.revocada_en is null
     and v_inv.vence_en > now()
     and (v_inv.rol <> 'cliente' or exists (
       select 1 from public.clientes_negocio c
       where c.id = v_inv.cliente_negocio_id
         and c.distribuidor_id = v_inv.distribuidor_id
         and c.activo))
  then
    select jsonb_build_object(
      'distribuidor_id', d.id,
      'distribuidor_nombre', coalesce(nullif(trim(d.config_tema ->> 'nombre'), ''), d.nombre),
      'rol', v_inv.rol,
      'negocio', (
        select jsonb_build_object(
          'nombre_negocio', c.nombre_negocio,
          'documento', c.documento,
          'direccion', c.direccion,
          'referencia', c.referencia,
          'telefono', c.telefono)
        from public.clientes_negocio c
        where v_inv.rol = 'cliente'
          and c.id = v_inv.cliente_negocio_id
          and c.distribuidor_id = v_inv.distribuidor_id))
    into v_resultado
    from public.distribuidores d
    where d.id = v_inv.distribuidor_id;
  end if;

  insert into public.intentos_consulta (direccion_red, exitoso)
  values (v_direccion, v_resultado is not null);

  return v_resultado;
end $$;

-- ---------------------------------------------------------------------------
-- 3. completar_datos_negocio
-- La bodega de quien llama en ese distribuidor completa sus datos de
-- contacto. Cada parámetro se limpia con trim; uno nulo o vacío no cambia su
-- columna. El documento solo se escribe si estaba nulo o vacío (si ya tiene
-- valor se ignora, sin error). Nunca toca nombre_negocio, lista_precios_id,
-- el crédito ni activo.
--
-- Errores: 42501 sin sesión o si quien llama no es cliente activo de ese
-- distribuidor (también si lo deja de ser mientras espera el bloqueo de la
-- bodega); 22023 documento o teléfono de más de 20 caracteres, o dirección
-- o referencia de más de 200, ya limpios.
-- ---------------------------------------------------------------------------
create function public.completar_datos_negocio(
  p_distribuidor_id uuid,
  p_documento text default null,
  p_direccion text default null,
  p_referencia text default null,
  p_telefono text default null
) returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_cliente uuid;
  v_documento text := nullif(trim(p_documento), '');
  v_direccion text := nullif(trim(p_direccion), '');
  v_referencia text := nullif(trim(p_referencia), '');
  v_telefono text := nullif(trim(p_telefono), '');
begin
  if v_uid is null then
    raise exception 'Se requiere una sesión' using errcode = '42501';
  end if;

  v_cliente := privado.mi_cliente_en(p_distribuidor_id);
  if v_cliente is null then
    raise exception 'No es cliente activo de este distribuidor' using errcode = '42501';
  end if;

  if length(v_documento) > 20 or length(v_telefono) > 20
     or length(v_direccion) > 200 or length(v_referencia) > 200 then
    raise exception 'Documento o teléfono de más de 20 caracteres, o dirección o referencia de más de 200'
      using errcode = '22023';
  end if;

  perform 1 from public.clientes_negocio c
  where c.id = v_cliente and c.distribuidor_id = p_distribuidor_id
  for update;

  -- Revalida con la fila ya bloqueada: la bodega o la membresía pudieron
  -- desactivarse mientras esperaba el bloqueo.
  if privado.mi_cliente_en(p_distribuidor_id) is distinct from v_cliente then
    raise exception 'No es cliente activo de este distribuidor' using errcode = '42501';
  end if;

  update public.clientes_negocio c
  set documento = case when coalesce(trim(c.documento), '') = ''
                       then coalesce(v_documento, c.documento)
                       else c.documento end,
      direccion = coalesce(v_direccion, c.direccion),
      referencia = coalesce(v_referencia, c.referencia),
      telefono = coalesce(v_telefono, c.telefono)
  where c.id = v_cliente and c.distribuidor_id = p_distribuidor_id;
end $$;

-- ---------------------------------------------------------------------------
-- Permisos de funciones. consultar_invitacion es la única excepción del
-- esquema: la ejecuta también anon (la bodega aún no tiene cuenta).
-- ---------------------------------------------------------------------------
revoke execute on function
  public.consultar_invitacion(text),
  public.completar_datos_negocio(uuid, text, text, text, text)
  from public, anon;

grant execute on function public.consultar_invitacion(text) to anon, authenticated;
grant execute on function public.completar_datos_negocio(uuid, text, text, text, text)
  to authenticated;
