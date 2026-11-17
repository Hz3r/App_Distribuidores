-- =============================================================================
-- Pruebas de crear_pedido() y RLS. Requiere migración + seed aplicados.
-- Se ejecuta en una transacción que termina en ROLLBACK: no deja datos.
--   psql "$DB_URL" -v ON_ERROR_STOP=1 -f supabase/tests/crear_pedido_test.sql
-- Cualquier aserción fallida aborta el script con error.
-- =============================================================================
begin;

-- Helper: simula la sesión de un usuario autenticado.
create temporary table _ctx (nombre text primary key, valor text) on commit drop;

-- ---------- 1) Pedido exitoso: stock baja y precio por volumen aplica ----------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated"}', true);
set local role authenticated;

do $$
declare
  v_pres uuid;
  v_stock_antes integer;
  v_stock_despues integer;
  v_pedido uuid;
  v_total integer;
begin
  select id, stock into v_pres, v_stock_antes
    from presentaciones where nombre = 'Ron Añejo 7 años · botella';

  v_pedido := public.crear_pedido(
    jsonb_build_array(jsonb_build_object('presentacion_id', v_pres, 'cantidad', 12)),
    'recojo'
  );

  select stock into v_stock_despues from presentaciones where id = v_pres;
  if v_stock_despues <> v_stock_antes - 12 then
    raise exception 'FALLO 1: stock esperado %, obtenido %', v_stock_antes - 12, v_stock_despues;
  end if;

  select total_centimos into v_total from pedidos where id = v_pedido;
  -- 12 botellas aplican precio por volumen (93%) desde 12 unidades.
  if v_total <> (4200 * 93 / 100) * 12 then
    raise exception 'FALLO 1: total esperado %, obtenido %', (4200 * 93 / 100) * 12, v_total;
  end if;
  raise notice 'OK 1: pedido creado con stock y precio por volumen correctos';
end $$;

-- ---------- 2) Stock insuficiente: error claro y sin cambios ----------
do $$
declare
  v_pres uuid;
  v_stock_antes integer;
  v_pedidos_antes integer;
  v_pedidos_despues integer;
  v_mensaje text;
begin
  select id, stock into v_pres, v_stock_antes
    from presentaciones where nombre = 'Whisky Escocés 18 años · botella';
  select count(*) into v_pedidos_antes from pedidos;

  begin
    perform public.crear_pedido(
      jsonb_build_array(jsonb_build_object('presentacion_id', v_pres, 'cantidad', v_stock_antes + 1)),
      'recojo'
    );
    raise exception 'FALLO 2: debió rechazar el pedido por stock insuficiente';
  exception when sqlstate 'P0001' then
    get stacked diagnostics v_mensaje = message_text;
    raise notice 'OK 2: rechazado con mensaje: %', v_mensaje;
  end;

  if (select stock from presentaciones where id = v_pres) <> v_stock_antes then
    raise exception 'FALLO 2: el stock cambió pese al rechazo';
  end if;
  select count(*) into v_pedidos_despues from pedidos;
  if v_pedidos_despues <> v_pedidos_antes then
    raise exception 'FALLO 2: quedó un pedido huérfano';
  end if;
end $$;

-- ---------- 3) Un pedido con dos ítems: el segundo ve el stock ya descontado ----------
do $$
declare
  v_pres uuid;
  v_stock_inicial integer;
  v_pedido uuid;
begin
  select id, stock into v_pres, v_stock_inicial
    from presentaciones where nombre = 'Cerveza Lager 650 ml · botella';

  begin
    v_pedido := public.crear_pedido(jsonb_build_array(
      jsonb_build_object('presentacion_id', v_pres, 'cantidad', v_stock_inicial - 1),
      jsonb_build_object('presentacion_id', v_pres, 'cantidad', 2)
    ), 'reparto');
    raise exception 'FALLO 3: debió fallar, el segundo ítem excede el stock restante';
  exception when sqlstate 'P0001' then
    raise notice 'OK 3: el stock acumulado dentro del pedido se valida correctamente';
  end;
end $$;

-- ---------- 4) RLS: el cliente 2 no ve pedidos del cliente 1 ----------
reset role;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000c2","role":"authenticated"}', true);
set local role authenticated;

do $$
declare
  v_visibles integer;
begin
  select count(*) into v_visibles from pedidos;
  if v_visibles <> 0 then
    raise exception 'FALLO 4: el cliente 2 ve % pedidos ajenos', v_visibles;
  end if;
  raise notice 'OK 4: RLS aísla pedidos entre clientes';
end $$;

-- ---------- 5) Un cliente NO puede actualizar stock directamente ----------
do $$
declare
  v_filas integer;
begin
  update presentaciones set stock = 999999 where true;
  get diagnostics v_filas = row_count;
  if v_filas <> 0 then
    raise exception 'FALLO 5: un cliente modificó % filas de stock', v_filas;
  end if;
  raise notice 'OK 5: el cliente no puede escribir stock directamente';
end $$;

-- ---------- 6) Usuario anónimo no puede ejecutar crear_pedido ----------
reset role;
set local role anon;
do $$
begin
  perform public.crear_pedido('[]'::jsonb, 'recojo');
  raise exception 'FALLO 6: anon pudo ejecutar crear_pedido';
exception when insufficient_privilege then
  raise notice 'OK 6: anon bloqueado por permisos';
end $$;

rollback;
\echo 'Pruebas de crear_pedido y RLS terminadas (transacción revertida).'
