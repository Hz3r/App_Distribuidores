-- Migración 6: ajustes posteriores a la revisión final.
-- Las cinco migraciones anteriores ya están aplicadas en DEV: no se editan;
-- lo que cambia se reemplaza aquí.
--
-- 1. Aviso del asesor de Supabase: public.rls_auto_enable() (de la
--    plataforma) no debe poder ejecutarla anon ni authenticated.
-- 2. Quien no es admin ni vendedor (cliente y repartidor) ve del catálogo
--    solo lo que se puede pedir: productos activos de categoría activa,
--    presentaciones activas de esos productos y los precios de esas
--    presentaciones. Spec: sección 7.

-- ---------------------------------------------------------------------------
-- 1. public.rls_auto_enable()
-- La crea la plataforma (security definer, la usa un event trigger) y no
-- existe en el Postgres local ni en CI. No se borra ni se modifica: solo se
-- le quita execute a public, anon y authenticated, si existe.
-- ---------------------------------------------------------------------------
do $$
begin
  if to_regprocedure('public.rls_auto_enable()') is not null then
    revoke execute on function public.rls_auto_enable() from public, anon, authenticated;
  end if;
end $$;

-- ---------------------------------------------------------------------------
-- 2. Visibilidad del catálogo para cliente y repartidor
-- ---------------------------------------------------------------------------

-- true si el producto se puede pedir: está activo y su categoría, si tiene,
-- también. Falso si no existe. Security definer para leer productos y
-- categorías sin pasar por sus políticas: la regla no depende de ellas y no
-- hay recursión entre políticas. No mira membresías: la política que la usa
-- ya exige es_miembro.
create function privado.producto_visible(p_producto uuid) returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    (select p.activo and coalesce(c.activo, true)
     from public.productos p
     left join public.categorias c
       on c.id = p.categoria_id and c.distribuidor_id = p.distribuidor_id
     where p.id = p_producto),
    false)
$$;

-- true si la presentación se puede pedir: está activa y su producto es
-- visible según producto_visible. Falso si no existe. Misma razón para ser
-- security definer.
create function privado.presentacion_visible(p_presentacion uuid) returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    (select pr.activo and privado.producto_visible(pr.producto_id)
     from public.presentaciones pr
     where pr.id = p_presentacion),
    false)
$$;

-- Execute revocado a public y anon; authenticated las necesita porque las
-- usan políticas RLS.
revoke execute on function
  privado.producto_visible(uuid),
  privado.presentacion_visible(uuid)
  from public, anon;

grant execute on function
  privado.producto_visible(uuid),
  privado.presentacion_visible(uuid)
  to authenticated;

-- Políticas de lectura. Admin y vendedor (y el Super Admin) siguen viendo
-- todo; el repartidor sigue sin ver listas.
drop policy productos_select on public.productos;
create policy productos_select on public.productos
  for select to authenticated
  using (
    (select privado.es_super_admin())
    or (select privado.tiene_rol(distribuidor_id, '{admin,vendedor}'))
    or ((select privado.es_miembro(distribuidor_id))
        and (select privado.producto_visible(id)))
  );

drop policy presentaciones_select on public.presentaciones;
create policy presentaciones_select on public.presentaciones
  for select to authenticated
  using (
    (select privado.es_super_admin())
    or (select privado.tiene_rol(distribuidor_id, '{admin,vendedor}'))
    or (activo
        and (select privado.es_miembro(distribuidor_id))
        and (select privado.producto_visible(producto_id)))
  );

drop policy precios_volumen_select on public.precios_volumen;
create policy precios_volumen_select on public.precios_volumen
  for select to authenticated
  using (
    (select privado.es_super_admin())
    or (select privado.tiene_rol(distribuidor_id, '{admin,vendedor}'))
    or ((select privado.es_miembro(distribuidor_id))
        and (select privado.presentacion_visible(presentacion_id)))
  );

-- El cliente ve solo los de su lista; el repartidor, ninguno.
drop policy precios_lista_select on public.precios_lista;
create policy precios_lista_select on public.precios_lista
  for select to authenticated
  using (
    (select privado.es_super_admin())
    or (select privado.tiene_rol(distribuidor_id, '{admin,vendedor}'))
    or (lista_precios_id = (select privado.mi_lista_en(distribuidor_id))
        and (select privado.presentacion_visible(presentacion_id)))
  );
