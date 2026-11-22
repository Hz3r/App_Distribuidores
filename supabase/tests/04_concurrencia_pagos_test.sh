#!/usr/bin/env bash
# Prueba de concurrencia de cobros (módulo 4). La ejecuta run.sh.
#
# Como 03_concurrencia_test.sh, necesita sesiones paralelas que hacen
# commit: copia distribuidores_test (ya migrada por run.sh) a una BD aparte y
# la borra al terminar, pase lo que pase.
#
# Cada caso es una carrera determinista entre dos sesiones sobre el mismo
# pedido, sin depender de tiempos:
#   - la primera hace su operación dentro de una transacción y no confirma
#     hasta ver a la segunda esperando un bloqueo;
#   - la segunda arranca su operación cuando ve en pg_locks que la primera
#     ya bloqueó una fila de pedidos.
#
# Casos (pedidos de C1 por PR1 x10, total 42000, recibidos y al contado):
#   1. A1 y V1 registran a la vez un pago por el saldo completo: el primero
#      lo logra y el segundo falla con 22023; saldo 0 y un solo pago activo.
#   2. registrar_pago y cambiar_estado_pedido(..., 'cancelado', ...) a la
#      vez, en los dos órdenes:
#      a. gana el pago: la cancelación falla con P0006 y el pedido queda
#         pagado;
#      b. gana la cancelación: el pago falla con P0006 y el pedido queda
#         cancelado y sin pagos.
#      Al final, ningún pedido cancelado tiene pagos activos.
#
# Usa PGHOST, PGPORT, PGUSER y PGPASSWORD del entorno.
set -euo pipefail

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORIGEN="${PGDATABASE:-distribuidores_test}"
BD="${ORIGEN}_concurrencia_pagos"
PSQL=(psql -X -q -v ON_ERROR_STOP=1)
export PGUSER="${PGUSER:-postgres}"
TMP="$(mktemp -d)"

limpiar() {
  "${PSQL[@]}" -d postgres -c "drop database if exists $BD with (force)" >/dev/null 2>&1 || true
  rm -rf "$TMP"
}
trap limpiar EXIT

falla() {
  echo "FALLO concurrencia pagos: $*" >&2
  exit 1
}

"${PSQL[@]}" -d postgres -c "drop database if exists $BD with (force)" >/dev/null 2>&1
"${PSQL[@]}" -d postgres -c "create database $BD template $ORIGEN" >/dev/null
export PGDATABASE=$BD

D1=00000000-0000-0000-0000-000000000d01
A1=00000000-0000-0000-0000-0000000000a1
V1=00000000-0000-0000-0000-0000000000b1
C1=00000000-0000-0000-0000-0000000000c1
ITEMS='[{"presentacion_id": "00000000-0000-0000-0000-000000000201", "cantidad": 10}]'

# Valor de una consulta como servicio.
valor() {
  "${PSQL[@]}" -At -c "$1"
}

# Datos fijos con commit.
"${PSQL[@]}" -f "$AQUI/soporte/datos_m3.sql" >/dev/null

# Esperas deterministas (solo en esta BD copia, que se borra al terminar).
# Corren como servicio: ven las sesiones y bloqueos de todos. Cada vuelta
# limpia la instantánea de estadísticas, que si no queda fija durante la
# transacción. Tras 20 s sin ver la condición, fallan.
"${PSQL[@]}" >/dev/null <<'SQL'
-- Espera a que la sesión p_app tenga bloqueada alguna fila de pedidos.
create function pruebas.espera_bloqueo_de_pedido(p_app text) returns void
language plpgsql
as $$
begin
  for i in 1..400 loop
    perform pg_stat_clear_snapshot();
    if exists (
      select 1
      from pg_locks l
      join pg_stat_activity a on a.pid = l.pid
      where a.application_name = p_app
        and l.locktype = 'relation'
        and l.relation = 'public.pedidos'::regclass
        and l.mode = 'RowShareLock'
        and l.granted
    ) then
      return;
    end if;
    perform pg_sleep(0.05);
  end loop;
  raise exception 'La sesión % no llegó a bloquear el pedido', p_app;
end $$;

-- Espera a que la sesión p_app quede esperando un bloqueo.
create function pruebas.espera_que_espere(p_app text) returns void
language plpgsql
as $$
begin
  for i in 1..400 loop
    perform pg_stat_clear_snapshot();
    if exists (
      select 1
      from pg_locks l
      join pg_stat_activity a on a.pid = l.pid
      where a.application_name = p_app and not l.granted
    ) then
      return;
    end if;
    perform pg_sleep(0.05);
  end loop;
  raise exception 'La sesión % no llegó a esperar un bloqueo', p_app;
end $$;
SQL

# Un pedido nuevo de C1 (total 42000, recibido, al contado); imprime su id.
nuevo_pedido() {
  "${PSQL[@]}" -At <<SQL | tail -n 1
select pruebas.como('$C1') \gset
select public.crear_pedido('$D1', '$ITEMS', gen_random_uuid(),
                           p_despacho => 'recojo', p_condicion_pago => 'contado');
SQL
}

# Carrera entre dos sesiones. Uso: carrera CASO UID1 SQL1 UID2 SQL2.
# SQL1 corre como UID1 y bloquea el pedido; SQL2 corre como UID2 y lo espera.
# Deja las salidas en $TMP/CASO.{1,2}.{out,err} y los códigos en R1 y R2.
carrera() {
  local caso="$1" uid1="$2" sql1="$3" uid2="$4" sql2="$5"
  local app1="pagos_${caso}_1" app2="pagos_${caso}_2" pid1 pid2

  PGAPPNAME="$app1" "${PSQL[@]}" -At >"$TMP/$caso.1.out" 2>"$TMP/$caso.1.err" <<SQL &
\set VERBOSITY verbose
begin;
select pruebas.como('$uid1') \gset
$sql1
select pruebas.como_servicio() \gset
select pruebas.espera_que_espere('$app2') \gset
commit;
SQL
  pid1=$!

  PGAPPNAME="$app2" "${PSQL[@]}" -At >"$TMP/$caso.2.out" 2>"$TMP/$caso.2.err" <<SQL &
\set VERBOSITY verbose
select pruebas.espera_bloqueo_de_pedido('$app1') \gset
select pruebas.como('$uid2') \gset
$sql2
SQL
  pid2=$!

  R1=0; wait "$pid1" || R1=$?
  R2=0; wait "$pid2" || R2=$?
}

pago_completo() {
  echo "select public.registrar_pago('$1', 42000, 'efectivo') as pago \gset"
}

cancelacion() {
  echo "select public.cambiar_estado_pedido('$1', 'cancelado', 'cancelación de prueba') \gset"
}

# --- Caso 1: dos pagos por el saldo completo ------------------------------
PED1=$(nuevo_pedido)
carrera c1 "$A1" "$(pago_completo "$PED1")" "$V1" "$(pago_completo "$PED1")"
[ "$R1" = 0 ] || falla "caso 1: el primer pago falló: $(cat "$TMP/c1.1.err")"
[ "$R2" != 0 ] || falla "caso 1: el segundo pago también se registró"
grep -q 'ERROR:  22023' "$TMP/c1.2.err" \
  || falla "caso 1: el segundo pago no falló con 22023: $(cat "$TMP/c1.2.err")"
r=$(valor "select saldo_pendiente_centimos || ' ' || estado_pago from public.pedidos where id = '$PED1'")
[ "$r" = "0 pagado" ] || falla "caso 1: se esperaba saldo 0 y pagado, y hay '$r'"
n=$(valor "select count(*) from public.pagos where pedido_id = '$PED1' and anulado_en is null")
[ "$n" = 1 ] || falla "caso 1: se esperaba 1 pago activo y hay $n"

# --- Caso 2a: gana el pago; la cancelación falla --------------------------
PED2=$(nuevo_pedido)
carrera c2a "$V1" "$(pago_completo "$PED2")" "$A1" "$(cancelacion "$PED2")"
[ "$R1" = 0 ] || falla "caso 2a: el pago falló: $(cat "$TMP/c2a.1.err")"
[ "$R2" != 0 ] || falla "caso 2a: se canceló un pedido con un pago activo"
grep -q 'ERROR:  P0006' "$TMP/c2a.2.err" \
  || falla "caso 2a: la cancelación no falló con P0006: $(cat "$TMP/c2a.2.err")"
r=$(valor "select estado || ' ' || estado_pago || ' ' || saldo_pendiente_centimos from public.pedidos where id = '$PED2'")
[ "$r" = "recibido pagado 0" ] || falla "caso 2a: se esperaba 'recibido pagado 0' y hay '$r'"
n=$(valor "select count(*) from public.pagos where pedido_id = '$PED2' and anulado_en is null")
[ "$n" = 1 ] || falla "caso 2a: se esperaba 1 pago activo y hay $n"

# --- Caso 2b: gana la cancelación; el pago falla --------------------------
PED3=$(nuevo_pedido)
carrera c2b "$A1" "$(cancelacion "$PED3")" "$V1" "$(pago_completo "$PED3")"
[ "$R1" = 0 ] || falla "caso 2b: la cancelación falló: $(cat "$TMP/c2b.1.err")"
[ "$R2" != 0 ] || falla "caso 2b: se registró un pago sobre un pedido cancelado"
grep -q 'ERROR:  P0006' "$TMP/c2b.2.err" \
  || falla "caso 2b: el pago no falló con P0006: $(cat "$TMP/c2b.2.err")"
r=$(valor "select estado::text from public.pedidos where id = '$PED3'")
[ "$r" = cancelado ] || falla "caso 2b: se esperaba el pedido cancelado y está '$r'"
n=$(valor "select count(*) from public.pagos where pedido_id = '$PED3'")
[ "$n" = 0 ] || falla "caso 2b: se esperaba ningún pago y hay $n"

# Invariante: nunca un pedido cancelado con un pago activo.
n=$(valor "select count(*) from public.pedidos p
           where p.estado = 'cancelado'
             and exists (select 1 from public.pagos g
                         where g.pedido_id = p.id and g.anulado_en is null)")
[ "$n" = 0 ] || falla "hay $n pedidos cancelados con pagos activos"

echo "OK concurrencia pagos"
