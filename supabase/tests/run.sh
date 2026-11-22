#!/usr/bin/env bash
# Ejecuta las pruebas SQL contra un Postgres local.
# Uso: bash supabase/tests/run.sh [N]
#   N: aplica solo las primeras N migraciones (orden de nombre) y las pruebas
#      con prefijo NN <= N. Sin N: todas, más supabase/seed.sql.
# Usa PGHOST, PGPORT, PGUSER y PGPASSWORD del entorno.
set -euo pipefail

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUPABASE="$(dirname "$AQUI")"
BD=distribuidores_test
PSQL=(psql -X -q -v ON_ERROR_STOP=1)
export PGUSER="${PGUSER:-postgres}"

if [ $# -ge 1 ]; then
  N="$1"
  case "$N" in ''|*[!0-9]*) echo "N debe ser un entero" >&2; exit 2;; esac
  N=$((10#$N))
  CON_SEED=0
else
  N=""
  CON_SEED=1
fi

"${PSQL[@]}" -d postgres -c "drop database if exists $BD with (force)" >/dev/null 2>&1
"${PSQL[@]}" -d postgres -c "create database $BD" >/dev/null
export PGDATABASE=$BD

PGOPTIONS="-c client_min_messages=error" "${PSQL[@]}" -f "$AQUI/soporte/supabase_shim.sql" >/dev/null
"${PSQL[@]}" -f "$AQUI/soporte/ayudas.sql" >/dev/null

shopt -s nullglob extglob
i=0
for m in "$SUPABASE"/migrations/*.sql; do
  i=$((i + 1))
  if [ -n "$N" ] && [ "$i" -gt "$N" ]; then break; fi
  echo "== migración $(basename "$m")"
  "${PSQL[@]}" -f "$m" >/dev/null
done

if [ "$CON_SEED" = 1 ]; then
  echo "== seed"
  "${PSQL[@]}" -f "$SUPABASE/seed.sql" >/dev/null
fi

# Un solo glob: .sql y .sh se ejecutan intercalados por orden de nombre (NN).
for t in "$AQUI"/[0-9][0-9]_*_test.@(sql|sh); do
  nombre="$(basename "$t")"
  nn=$((10#${nombre:0:2}))
  if [ -n "$N" ] && [ "$nn" -gt "$N" ]; then continue; fi
  echo "== prueba $nombre"
  case "$t" in
    *.sql) "${PSQL[@]}" -f "$t" >/dev/null ;;
    *.sh) bash "$t" ;;
  esac
done

echo "TODO OK"
