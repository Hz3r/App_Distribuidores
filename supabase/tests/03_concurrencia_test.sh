#!/usr/bin/env bash
# Prueba de concurrencia de crear_pedido (módulo 3). La ejecuta run.sh.
#
# Necesita sesiones paralelas que hacen commit, así que no corre en la BD
# compartida: copia distribuidores_test (ya migrada por run.sh) a una BD
# aparte y la borra al terminar, pase lo que pase. La BD compartida no recibe
# ningún dato.
#
# Casos:
#   1. C1 y C2 piden a la vez las 10 botellas que quedan de P1: uno lo logra
#      y el otro falla con P0001; queda 1 pedido y el comprometido en 10.
#   2. C1 reintenta a la vez con la misma clave de idempotencia: las dos
#      sesiones devuelven el mismo id y hay un solo pedido con esa clave.
#
# Usa PGHOST, PGPORT, PGUSER y PGPASSWORD del entorno.
set -euo pipefail

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORIGEN="${PGDATABASE:-distribuidores_test}"
BD="${ORIGEN}_concurrencia"
PSQL=(psql -X -q -v ON_ERROR_STOP=1)
export PGUSER="${PGUSER:-postgres}"
TMP="$(mktemp -d)"

limpiar() {
  "${PSQL[@]}" -d postgres -c "drop database if exists $BD with (force)" >/dev/null 2>&1 || true
  rm -rf "$TMP"
}
trap limpiar EXIT

falla() {
  echo "FALLO concurrencia: $*" >&2
  exit 1
}

"${PSQL[@]}" -d postgres -c "drop database if exists $BD with (force)" >/dev/null 2>&1
"${PSQL[@]}" -d postgres -c "create database $BD template $ORIGEN" >/dev/null
export PGDATABASE=$BD

D1=00000000-0000-0000-0000-000000000d01
P1=00000000-0000-0000-0000-000000000101
C1=00000000-0000-0000-0000-0000000000c1
C2=00000000-0000-0000-0000-0000000000c2
ITEMS='[{"presentacion_id": "00000000-0000-0000-0000-000000000201", "cantidad": 10}]'

# Valor de una consulta como servicio.
valor() {
  "${PSQL[@]}" -At -c "$1"
}

# Una sesión que crea un pedido como p_uid con la clave p_clave y retiene sus
# bloqueos 2 segundos antes del commit. Escribe "ID <uuid>" en la salida y,
# si falla, el SQLSTATE en el error (VERBOSITY verbose).
sesion() {
  local uid="$1" clave="$2" salida="$3"
  "${PSQL[@]}" -At >"$salida.out" 2>"$salida.err" <<SQL
\set VERBOSITY verbose
begin;
select pruebas.como('$uid') \gset
select public.crear_pedido('$D1', '$ITEMS', '$clave') as pedido \gset
select pg_sleep(2) \gset
commit;
\echo ID :pedido
SQL
}

# Datos fijos con commit; P1 queda con 10 botellas y nada comprometido.
"${PSQL[@]}" -f "$AQUI/soporte/datos_m3.sql" >/dev/null
valor "update public.productos set stock_fisico = 10, stock_comprometido = 0 where id = '$P1'" >/dev/null

# --- Caso 1: dos bodegas compiten por el mismo stock -----------------------
sesion "$C1" 00000000-0000-0000-0000-00000000cc01 "$TMP/c1" & pid1=$!
sesion "$C2" 00000000-0000-0000-0000-00000000cc02 "$TMP/c2" & pid2=$!
r1=0; wait "$pid1" || r1=$?
r2=0; wait "$pid2" || r2=$?

if [ "$r1" = 0 ] && [ "$r2" != 0 ]; then
  perdedor="$TMP/c2"
elif [ "$r2" = 0 ] && [ "$r1" != 0 ]; then
  perdedor="$TMP/c1"
else
  falla "se esperaba un éxito y un fallo (salidas $r1 y $r2): $(cat "$TMP"/c*.err)"
fi
grep -q 'ERROR:  P0001' "$perdedor.err" \
  || falla "el perdedor no falló con P0001: $(cat "$perdedor.err")"

n=$(valor "select count(*) from public.pedidos where distribuidor_id = '$D1'")
[ "$n" = 1 ] || falla "se esperaba 1 pedido en D1 y hay $n"
c=$(valor "select stock_comprometido from public.productos where id = '$P1'")
[ "$c" = 10 ] || falla "se esperaba comprometido 10 en P1 y hay $c"

# --- Caso 2: reintento simultáneo con la misma clave -----------------------
valor "update public.productos set stock_fisico = 20 where id = '$P1'" >/dev/null
CLAVE=00000000-0000-0000-0000-00000000cc03
sesion "$C1" "$CLAVE" "$TMP/i1" & pid1=$!
sesion "$C1" "$CLAVE" "$TMP/i2" & pid2=$!
r1=0; wait "$pid1" || r1=$?
r2=0; wait "$pid2" || r2=$?
[ "$r1" = 0 ] && [ "$r2" = 0 ] \
  || falla "los dos reintentos debían terminar bien (salidas $r1 y $r2): $(cat "$TMP"/i*.err)"

id1=$(sed -n 's/^ID //p' "$TMP/i1.out")
id2=$(sed -n 's/^ID //p' "$TMP/i2.out")
[ -n "$id1" ] && [ "$id1" = "$id2" ] \
  || falla "los reintentos devolvieron ids distintos: '$id1' y '$id2'"
n=$(valor "select count(*) from public.pedidos where clave_idempotencia = '$CLAVE'")
[ "$n" = 1 ] || falla "se esperaba 1 pedido con la clave repetida y hay $n"
c=$(valor "select stock_comprometido from public.productos where id = '$P1'")
[ "$c" = 20 ] || falla "se esperaba comprometido 20 en P1 (una sola reserva) y hay $c"

echo "OK concurrencia"
