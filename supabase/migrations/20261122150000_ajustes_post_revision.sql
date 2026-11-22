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
-- 3. crear_pedido rechaza con P0002 las presentaciones cuyo producto tiene
--    la categoría inactiva, como ya hacía con presentación o producto
--    inactivos.

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

-- ---------------------------------------------------------------------------
-- 3. crear_pedido rechaza también las presentaciones de una categoría inactiva
-- Reemplaza la función de 20261122120000_pedidos.sql (ya aplicada, no se
-- edita). El cuerpo es una copia íntegra del original; solo cambia la
-- validación de presentaciones (paso 4), que ahora exige además que la
-- categoría del producto esté activa. Mismo P0002 que para una presentación
-- o un producto inactivos. Misma firma, mismos permisos.
--
-- Errores: 42501 sin permiso o bodega ajena (también si se pierde mientras
-- espera el bloqueo); 22023 parámetro o ítems mal formados, o más de 200
-- presentaciones distintas; P0002 presentación inexistente, inactiva (o su
-- producto, o la categoría de este) o de otro distribuidor; P0001 stock
-- insuficiente; P0003 distribuidor fuera de prueba/activo o bodega
-- inactiva; P0004 crédito no habilitado, límite excedido o deuda vencida.
-- ---------------------------------------------------------------------------
create or replace function public.crear_pedido(
  p_distribuidor_id uuid,
  p_items jsonb,
  p_clave_idempotencia uuid,
  p_despacho public.despacho_pedido,
  p_condicion_pago public.condicion_pago,
  p_cliente_id uuid default null,
  p_metodo_pago public.metodo_pago default null,
  p_nota text default null
) returns uuid
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  c_max_integer constant bigint := 2147483647;
  c_max_lineas constant integer := 200;
  v_uid uuid := auth.uid();
  v_cliente uuid;
  v_es_cliente boolean;
  v_bodega public.clientes_negocio;
  v_distribuidor public.distribuidores;
  v_pedido uuid;
  v_presentaciones uuid[];
  v_cantidades bigint[];
  v_item record;
  v_producto_actual uuid;
  v_reservado bigint;
  v_unidades bigint;
  v_linea public.pedido_items;
  v_lineas public.pedido_items[] := '{}';
  v_total bigint := 0;
  v_deuda bigint;
  v_hoy date;
  v_numero integer;
begin
  if v_uid is null then
    raise exception 'Se requiere una sesión' using errcode = '42501';
  end if;

  -- 1. Bodega y permiso.
  v_cliente := privado.mi_cliente_en(p_distribuidor_id);
  v_es_cliente := v_cliente is not null;
  if v_es_cliente then
    if p_cliente_id is not null and p_cliente_id <> v_cliente then
      raise exception 'No puede pedir a nombre de otra bodega' using errcode = '42501';
    end if;
  elsif privado.tiene_rol(p_distribuidor_id, '{admin,vendedor}') then
    if p_cliente_id is null then
      raise exception 'Indique la bodega del pedido' using errcode = '22023';
    end if;
    if not exists (
      select 1 from public.clientes_negocio c
      where c.id = p_cliente_id and c.distribuidor_id = p_distribuidor_id
    ) then
      raise exception 'La bodega no pertenece a este distribuidor' using errcode = '42501';
    end if;
    v_cliente := p_cliente_id;
  else
    raise exception 'No puede crear pedidos en este distribuidor' using errcode = '42501';
  end if;

  if p_clave_idempotencia is null or p_despacho is null or p_condicion_pago is null then
    raise exception 'Faltan la clave de idempotencia, el despacho o la condición de pago'
      using errcode = '22023';
  end if;

  -- Primer bloqueo: la bodega. "no key update" basta para serializar sus
  -- pedidos y no frena las claves foráneas que apuntan a ella.
  select * into v_bodega
  from public.clientes_negocio c
  where c.id = v_cliente and c.distribuidor_id = p_distribuidor_id
  for no key update;

  -- Revalida con la fila ya bloqueada: quien llama pudo perder su membresía
  -- o su rol (o el cliente, su bodega) mientras esperaba el bloqueo.
  if (v_es_cliente and privado.mi_cliente_en(p_distribuidor_id) is distinct from v_cliente)
     or (not v_es_cliente and not privado.tiene_rol(p_distribuidor_id, '{admin,vendedor}')) then
    raise exception 'No puede crear pedidos en este distribuidor' using errcode = '42501';
  end if;

  if v_bodega.id is null or not v_bodega.activo then
    raise exception 'La bodega está inactiva' using errcode = 'P0003';
  end if;

  select * into v_distribuidor
  from public.distribuidores d where d.id = p_distribuidor_id;

  if v_distribuidor.estado not in ('prueba', 'activo') then
    raise exception 'El distribuidor no está recibiendo pedidos' using errcode = 'P0003';
  end if;

  -- 2. Idempotencia: la misma clave de la misma bodega devuelve el pedido
  -- existente, sin revisar los ítems.
  select p.id into v_pedido
  from public.pedidos p
  where p.cliente_id = v_cliente and p.clave_idempotencia = p_clave_idempotencia;

  if v_pedido is not null then
    return v_pedido;
  end if;

  -- 3. Forma de p_items, antes de convertir tipos: arreglo no vacío de
  -- objetos con presentacion_id (texto con forma de uuid) y cantidad (número
  -- entero entre 1 y el máximo de integer).
  if p_items is null or jsonb_typeof(p_items) <> 'array' then
    raise exception 'Los ítems deben ser un arreglo' using errcode = '22023';
  end if;
  if jsonb_array_length(p_items) = 0 then
    raise exception 'El pedido no tiene ítems' using errcode = '22023';
  end if;
  if exists (
    select 1
    from jsonb_array_elements(p_items) as e (item)
    where jsonb_typeof(e.item) <> 'object'
       or jsonb_typeof(e.item -> 'presentacion_id') is distinct from 'string'
       or privado.uuid_o_nulo(e.item ->> 'presentacion_id') is null
       or jsonb_typeof(e.item -> 'cantidad') is distinct from 'number'
       or case
            when (e.item ->> 'cantidad') ~ '^[1-9][0-9]{0,9}$'
            then (e.item ->> 'cantidad')::bigint > c_max_integer
            else true
          end
  ) then
    raise exception 'Ítem inválido: se espera {"presentacion_id": uuid, "cantidad": entero > 0}'
      using errcode = '22023';
  end if;

  -- Consolida los ítems de una misma presentación sumando cantidades.
  select array_agg(c.presentacion_id order by c.presentacion_id),
         array_agg(c.cantidad order by c.presentacion_id)
  into v_presentaciones, v_cantidades
  from (
    select (e.item ->> 'presentacion_id')::uuid as presentacion_id,
           sum((e.item ->> 'cantidad')::bigint)::bigint as cantidad
    from jsonb_array_elements(p_items) as e (item)
    group by 1
  ) c;

  if exists (select 1 from unnest(v_cantidades) as q (cantidad) where q.cantidad > c_max_integer) then
    raise exception 'Cantidad demasiado grande' using errcode = '22023';
  end if;

  -- Tope de líneas (presentaciones distintas) por pedido, antes de bloquear.
  if cardinality(v_presentaciones) > c_max_lineas then
    raise exception 'El pedido supera las % líneas', c_max_lineas using errcode = '22023';
  end if;

  -- 4. Segundo bloqueo: los productos involucrados, por id ascendente. Solo
  -- se bloquean productos de este distribuidor.
  perform 1
  from public.productos p
  where p.distribuidor_id = p_distribuidor_id
    and p.id in (
      select pr.producto_id
      from public.presentaciones pr
      where pr.id = any (v_presentaciones)
        and pr.distribuidor_id = p_distribuidor_id)
  order by p.id
  for update;

  -- Con los productos ya bloqueados: cada presentación existe, es de este
  -- distribuidor y está activa, igual que su producto y la categoría de este
  -- (un producto sin categoría vale, como en privado.producto_visible).
  if (select count(*)
      from public.presentaciones pr
      join public.productos p
        on p.id = pr.producto_id and p.distribuidor_id = pr.distribuidor_id
      left join public.categorias c
        on c.id = p.categoria_id and c.distribuidor_id = p.distribuidor_id
      where pr.id = any (v_presentaciones)
        and pr.distribuidor_id = p_distribuidor_id
        and pr.activo
        and p.activo
        and coalesce(c.activo, true)) <> cardinality(v_presentaciones) then
    raise exception 'Presentación inexistente, inactiva o de otro distribuidor'
      using errcode = 'P0002';
  end if;

  -- 5. Stock y precio por línea. Se recorre por producto para acumular lo
  -- reservado por varias presentaciones del mismo producto.
  for v_item in
    select pr.id as presentacion_id, pr.nombre as nombre_presentacion, pr.factor,
           p.id as producto_id, p.nombre as nombre_producto,
           p.stock_fisico - p.stock_comprometido as disponible,
           i.cantidad::integer as cantidad
    from unnest(v_presentaciones, v_cantidades) as i (presentacion_id, cantidad)
    join public.presentaciones pr on pr.id = i.presentacion_id
    join public.productos p
      on p.id = pr.producto_id and p.distribuidor_id = pr.distribuidor_id
    order by p.id, pr.id
  loop
    if v_item.producto_id is distinct from v_producto_actual then
      v_producto_actual := v_item.producto_id;
      v_reservado := 0;
    end if;

    v_unidades := v_item.cantidad::bigint * v_item.factor;
    if v_reservado + v_unidades > v_item.disponible then
      raise exception 'Stock insuficiente de %', v_item.nombre_producto
        using errcode = 'P0001';
    end if;
    v_reservado := v_reservado + v_unidades;

    v_linea.presentacion_id := v_item.presentacion_id;
    v_linea.producto_id := v_item.producto_id;
    v_linea.nombre_producto := v_item.nombre_producto;
    v_linea.nombre_presentacion := v_item.nombre_presentacion;
    v_linea.factor := v_item.factor;
    v_linea.cantidad := v_item.cantidad;
    v_linea.precio_unitario_centimos :=
      privado.precio_para(v_item.presentacion_id, v_cliente, v_item.cantidad);
    v_linea.subtotal_centimos := v_linea.precio_unitario_centimos * v_item.cantidad;
    v_lineas := v_lineas || v_linea;
    v_total := v_total + v_linea.subtotal_centimos;
  end loop;

  -- 6. Crédito, con la fila de la bodega ya bloqueada. "Hoy" es la fecha en
  -- la zona horaria del distribuidor.
  if p_condicion_pago = 'credito' then
    if not v_bodega.credito_habilitado then
      raise exception 'La bodega no tiene crédito habilitado' using errcode = 'P0004';
    end if;

    v_hoy := (now() at time zone v_distribuidor.zona_horaria)::date;

    if exists (
      select 1 from public.pedidos p
      where p.cliente_id = v_cliente
        and p.condicion_pago = 'credito'
        and p.estado <> 'cancelado'
        and p.saldo_pendiente_centimos > 0
        and p.vence_en < v_hoy
    ) then
      raise exception 'La bodega tiene deuda vencida' using errcode = 'P0004';
    end if;

    select coalesce(sum(p.saldo_pendiente_centimos), 0) into v_deuda
    from public.pedidos p
    where p.cliente_id = v_cliente
      and p.condicion_pago = 'credito'
      and p.estado <> 'cancelado';

    if v_deuda + v_total > v_bodega.limite_credito_centimos then
      raise exception 'El pedido excede el límite de crédito de la bodega'
        using errcode = 'P0004';
    end if;
  end if;

  -- 7. Tercer bloqueo: el contador (se crea si no existe). El update lo
  -- bloquea y asigna el número.
  insert into public.contadores_pedido (distribuidor_id)
  values (p_distribuidor_id)
  on conflict (distribuidor_id) do nothing;

  update public.contadores_pedido
  set ultimo_numero = ultimo_numero + 1
  where distribuidor_id = p_distribuidor_id
  returning ultimo_numero into v_numero;

  insert into public.pedidos
    (distribuidor_id, numero, cliente_id, creado_por, despacho, direccion_entrega,
     nota_cliente, total_centimos, condicion_pago, metodo_pago, estado_pago,
     saldo_pendiente_centimos, plazo_credito_dias, clave_idempotencia)
  values
    (p_distribuidor_id, v_numero, v_cliente, v_uid, p_despacho, v_bodega.direccion,
     p_nota, v_total, p_condicion_pago, p_metodo_pago,
     -- Saldo 0 desde el inicio: no hay nada que cobrar.
     case when v_total = 0 then 'pagado' else 'pendiente' end::public.estado_pago,
     v_total,
     case when p_condicion_pago = 'credito' then v_bodega.plazo_credito_dias end,
     p_clave_idempotencia)
  returning id into v_pedido;

  insert into public.pedido_items
    (distribuidor_id, pedido_id, presentacion_id, producto_id, nombre_producto,
     nombre_presentacion, factor, cantidad, precio_unitario_centimos, subtotal_centimos)
  select p_distribuidor_id, v_pedido, l.presentacion_id, l.producto_id, l.nombre_producto,
         l.nombre_presentacion, l.factor, l.cantidad, l.precio_unitario_centimos,
         l.subtotal_centimos
  from unnest(v_lineas) as l;

  -- Reserva: sube el comprometido y registra el movimiento, por línea.
  foreach v_linea in array v_lineas loop
    perform privado.aplicar_movimiento_stock(
      v_linea.producto_id, 'reserva', 0, v_linea.cantidad * v_linea.factor, v_pedido, null);
  end loop;

  insert into public.pedido_eventos (distribuidor_id, pedido_id, estado_anterior, estado_nuevo, hecho_por)
  values (p_distribuidor_id, v_pedido, null, 'recibido', v_uid);

  return v_pedido;
end $$;

revoke execute on function
  public.crear_pedido(uuid, jsonb, uuid, public.despacho_pedido, public.condicion_pago,
                      uuid, public.metodo_pago, text)
  from public, anon;

grant execute on function
  public.crear_pedido(uuid, jsonb, uuid, public.despacho_pedido, public.condicion_pago,
                      uuid, public.metodo_pago, text)
  to authenticated;
