# Base de datos completa: plan de implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reemplazar el esquema borrador por la base de datos completa del SaaS (identidad, catálogo e inventario, pedidos, cobros y plataforma), en cinco migraciones con pruebas SQL.

**Architecture:** Multi-tenant por `distribuidor_id` con RLS validado contra la tabla `membresias` mediante funciones auxiliares en el esquema `privado`. Toda escritura de stock, pedidos y pagos pasa por funciones `security definer` en `public`. Las pruebas corren sobre Postgres puro con un archivo que simula lo mínimo de Supabase (`auth`, `storage`, roles), sin Docker.

**Tech Stack:** PostgreSQL 17 (Supabase), SQL y PL/pgSQL, `psql`, bash, GitHub Actions.

**Spec:** `docs/superpowers/specs/2026-11-22-base-de-datos-design.md`. Leerla completa antes de empezar cualquier tarea. Este plan no repite sus reglas de negocio: las referencia por sección.

**Precondición:** el documento de diseño está aprobado por Hz3r. Antes de fusionar a `main` hace falta el acuerdo de Jair103 sobre la propiedad de `supabase/` (Tarea 1 cambia `CODEOWNERS`).

**Fuera de este plan:** actualizar los modelos Dart de `packages/core` y los routers de las apps. Va en un plan aparte: eliminar `Usuario` y `RolUsuario` rompe la compilación de `apps/panel_web` (área de Jair103) y requiere Flutter, que no está en este entorno. La Tarea 9 deja el contrato marcado para ese plan.

## Global Constraints

- Nunca aplicar nada al proyecto remoto de Supabase. Ni `apply_migration`, ni `execute_sql`, ni `db push`.
- Nombres en español y `snake_case`. Ids `uuid` con `gen_random_uuid()`. Fechas `timestamptz`.
- Todo monto es `bigint` en céntimos, con sufijo `_centimos`. Nunca `numeric` ni `double`.
- Toda tabla de negocio lleva `distribuidor_id` y RLS activo. Toda tabla lleva `creado_en timestamptz not null default now()`; las editables llevan `actualizado_en` mantenido por el trigger `privado.tg_actualizado_en()`.
- Las tablas hijas llevan `distribuidor_id` propio, y sus claves foráneas hacia el padre son compuestas `(x_id, distribuidor_id)` contra un `unique (id, distribuidor_id)` del padre. Así es imposible cruzar distribuidores.
- Permisos explícitos en cada migración, sin depender de los privilegios por defecto: `revoke all on <tabla> from anon, authenticated;` y luego `grant` solo de lo que la matriz de la sección 7 de la spec permite. Donde la spec restringe columnas, usar `grant update (col, ...)`.
- Políticas: siempre `to authenticated`; toda política de `UPDATE` con `using` y `with check`; llamadas a funciones auxiliares envueltas en `(select ...)`.
- Funciones `security definer`: `set search_path = ''` con nombres calificados; verifican `auth.uid()` y la membresía en el cuerpo; `revoke execute ... from public, anon;` y `grant execute ... to authenticated;`.
- El esquema `privado` no se expone: `grant usage on schema privado to authenticated` y nada a `anon`.
- Códigos de error: los de la sección 6.3 de la spec, más `P0005` (canje frenado) y `P0006` (operación no válida para el estado actual: transición de pedido inválida, pago sobre pedido cancelado, pago ya anulado, cancelar con pagos activos).
- Commits en Conventional Commits. Rama de trabajo: `claude/focused-bardeen-arnwyv`.
- Las migraciones deben aplicarse en orden y cada una debe pasar sus pruebas sin las siguientes: `supabase/tests/run.sh N` aplica solo las primeras N.

## Review Focus

Casos que la spec implica pero no enumera. Cada uno tiene su prueba en la tarea indicada.

1. **Dos pedidos simultáneos por las últimas unidades.** Exactamente uno se crea; el otro recibe `P0001`; el comprometido nunca supera el físico. (Tarea 5, prueba de concurrencia.)
2. **Ítems mal formados en `p_items`:** cantidad no numérica, nula, decimal, negativa o gigante (`1e12`), `presentacion_id` que no es uuid, o `p_items` que no es un arreglo. Siempre `22023`, nunca un error interno de conversión. (Tarea 5.)
3. **La misma presentación repetida en el pedido.** Se consolida en una sola línea sumando cantidades, y el precio por volumen se calcula sobre el total. (Tarea 5.)
4. **Acceso revocado con la sesión abierta:** membresía suspendida o bodega desactivada. La persona deja de leer datos de ese distribuidor y no puede crear pedidos, sin esperar a que el token se refresque. (Tareas 2 y 5.)
5. **Código de invitación escrito con minúsculas o espacios**, y código de una bodega que fue desactivada después de emitirlo. El primero se acepta normalizado; el segundo devuelve `null`. (Tarea 2.)

## Estructura de archivos

| Archivo | Responsabilidad |
|---|---|
| `supabase/migrations/20261122100000_identidad_y_acceso.sql` | Esquema `privado`, distribuidores, perfiles, membresías, bodegas, invitaciones |
| `supabase/migrations/20261122110000_catalogo_e_inventario.sql` | Catálogo, listas de precios, stock, movimientos, bucket de imágenes |
| `supabase/migrations/20261122120000_pedidos.sql` | Pedidos, crédito de bodegas, estados, repartidor, Realtime |
| `supabase/migrations/20261122130000_cobros.sql` | Pagos de pedidos |
| `supabase/migrations/20261122140000_plataforma.sql` | Planes, suscripciones, alta de distribuidores |
| `supabase/tests/soporte/supabase_shim.sql` | Simula `auth`, `storage`, roles y publicación de Supabase en Postgres puro |
| `supabase/tests/soporte/ayudas.sql` | Esquema `pruebas` con funciones de aserción |
| `supabase/tests/soporte/datos_m1.sql` … `datos_m3.sql` | Datos fijos de prueba, acumulativos por módulo |
| `supabase/tests/NN_<modulo>_test.sql` | Pruebas de cada módulo |
| `supabase/tests/03_concurrencia_test.sh` | Prueba de pedidos simultáneos |
| `supabase/tests/run.sh` | Crea la BD de prueba, aplica migraciones y corre las pruebas |
| `supabase/seed.sql` | Datos de demostración para local y DEV |
| `docs/contrato.md` | Contrato reescrito |

---

### Task 1: Infraestructura de pruebas y limpieza del borrador

**Files:**
- Delete: `supabase/migrations/20261117120000_esquema_inicial.sql`, `supabase/tests/crear_pedido_test.sql`
- Create: `supabase/tests/soporte/supabase_shim.sql`, `supabase/tests/soporte/ayudas.sql`, `supabase/tests/run.sh`, `supabase/tests/00_infra_test.sql`
- Modify: `supabase/seed.sql` (dejar solo un comentario de cabecera; se llena en la Tarea 9), `.github/CODEOWNERS` (`/supabase/` pasa a `@Hz3r`), `CLAUDE.md` (sección Contexto: Hz3r lleva `supabase/`; Jair103 lleva `apps/panel_web`), `pubspec.yaml` (script de Melos `db:test` que ejecuta `bash supabase/tests/run.sh`)

**Interfaces:**
- Produces:
  - `supabase/tests/run.sh [N]`: usa `PGHOST`, `PGPORT`, `PGUSER` del entorno (por defecto socket local y usuario `postgres`). Borra y crea la BD `distribuidores_test`; aplica el shim y `ayudas.sql`; aplica las primeras N migraciones en orden de nombre (todas si se omite N); ejecuta cada `supabase/tests/NN_*_test.sql` con `NN <= N` usando `psql -v ON_ERROR_STOP=1`, y cada `NN_*_test.sh`; si no se pasa N, carga además `supabase/seed.sql`. Sale con código distinto de cero al primer fallo e imprime `TODO OK` al final.
  - Shim: roles `anon`, `authenticated`, `service_role` (sin login); esquema `auth` con `auth.users (id uuid primary key, email text, phone text, raw_app_meta_data jsonb, raw_user_meta_data jsonb)`, `auth.uid() returns uuid` y `auth.jwt() returns jsonb`, ambas leyendo `current_setting('request.jwt.claims', true)`; esquema `storage` con `storage.buckets (id text primary key, name text, public boolean)`, `storage.objects (id uuid, bucket_id text, name text, owner uuid)` con RLS activo, y `storage.foldername(text) returns text[]`; publicación vacía `supabase_realtime`; los privilegios por defecto de Supabase sobre `public` (`grant usage` y `alter default privileges ... grant all` a los tres roles), para que las pruebas detecten cualquier tabla que quede expuesta.
  - `pruebas.como(p_uid uuid)`: fija `request.jwt.claims` con ese `sub` y cambia al rol `authenticated`.
  - `pruebas.como_anon()`: rol `anon` sin claims. `pruebas.como_servicio()`: vuelve al rol inicial.
  - `pruebas.afirma(p_condicion boolean, p_etiqueta text)`: lanza `FALLO <etiqueta>` si es falso o nulo; si no, `raise notice 'OK <etiqueta>'`.
  - `pruebas.espera_error(p_sql text, p_sqlstate text, p_etiqueta text)`: ejecuta `p_sql` en un bloque con `exception`; falla si no hay error o si el SQLSTATE difiere.
  - `pruebas.cuenta(p_sql text) returns bigint`: ejecuta un `select` y devuelve cuántas filas ve el rol actual.
  - Convención de cada archivo de prueba: `begin;` al inicio, `\ir soporte/datos_mK.sql` que necesite, y `rollback;` al final.

- [ ] **Step 1: Escribir `00_infra_test.sql`**

```sql
begin;
select pruebas.afirma(auth.uid() is null, '0.1 sin sesión no hay uid');
select pruebas.como('00000000-0000-0000-0000-0000000000a1');
select pruebas.afirma(auth.uid() = '00000000-0000-0000-0000-0000000000a1', '0.2 como() fija el uid');
select pruebas.afirma(current_user = 'authenticated', '0.3 como() cambia de rol');
select pruebas.espera_error('select 1/0', '22012', '0.4 espera_error captura el sqlstate');
select pruebas.como_servicio();
select pruebas.afirma(current_user <> 'authenticated', '0.5 como_servicio() restaura el rol');
rollback;
```

- [ ] **Step 2: Levantar Postgres local y verificar que falla**

Run: `pg_ctlcluster 16 main start && su postgres -c "bash supabase/tests/run.sh 0"`
Expected: FAIL, `run.sh` no existe.

- [ ] **Step 3: Escribir el shim, `ayudas.sql` y `run.sh`; borrar el borrador; vaciar el seed**

- [ ] **Step 4: Verificar**

Run: `su postgres -c "bash supabase/tests/run.sh 0"`
Expected: cinco líneas `OK 0.x` y `TODO OK`.

- [ ] **Step 5: Actualizar `CODEOWNERS`, `CLAUDE.md` y `pubspec.yaml`, y hacer commit**

```bash
git add -A supabase .github/CODEOWNERS CLAUDE.md pubspec.yaml
git commit -m "chore(supabase): infraestructura de pruebas SQL y retiro del esquema borrador"
```

---

### Task 2: Módulo 1, identidad y acceso

Spec: sección 6.1 y matriz de la sección 7.

**Files:**
- Create: `supabase/migrations/20261122100000_identidad_y_acceso.sql`, `supabase/tests/soporte/datos_m1.sql`, `supabase/tests/01_identidad_test.sql`

**Interfaces:**
- Produces (tablas; además de `id`, `creado_en` y `actualizado_en`):
  - `distribuidores (nombre text, slug text unique, rubro text, documento text, telefono text, estado estado_distribuidor default 'prueba', moneda text default 'PEN' check (length = 3), zona_horaria text default 'America/Lima', config_tema jsonb default '{}')`
  - `perfiles (id uuid pk → auth.users on delete cascade, nombre text not null default '', telefono text, es_super_admin boolean default false)`
  - `clientes_negocio (distribuidor_id, nombre_negocio text, documento text, direccion text, referencia text, telefono text, activo boolean default true, unique (id, distribuidor_id))`
  - `membresias (perfil_id, distribuidor_id, rol rol_membresia, estado estado_membresia default 'activa', cliente_negocio_id, unique (perfil_id, distribuidor_id), check ((rol = 'cliente') = (cliente_negocio_id is not null)))`
  - `invitaciones (distribuidor_id, codigo text unique, rol rol_membresia, cliente_negocio_id, creada_por → perfiles, vence_en timestamptz, usada_por → perfiles, usada_en, revocada_en)`, con el mismo `check` de rol y bodega que `membresias`
  - `intentos_canje (perfil_id, exitoso boolean, creado_en)`
  - `dispositivos_push (perfil_id, token text unique, plataforma text check in ('android','ios','web'))`
- Produces (enums): `estado_distribuidor`, `rol_membresia`, `estado_membresia` con los valores de la spec.
- Produces (funciones):
  - `privado.tg_actualizado_en() returns trigger`
  - `privado.es_super_admin() returns boolean`
  - `privado.es_miembro(p_distribuidor uuid) returns boolean`
  - `privado.tiene_rol(p_distribuidor uuid, p_roles public.rol_membresia[]) returns boolean`
  - Para ambas, una membresía cuenta solo si su `estado` es `activa` y, cuando es de rol `cliente`, su bodega tiene `activo = true`. Desactivar una bodega corta el acceso de sus personas a ese distribuidor.
  - `privado.mi_cliente_en(p_distribuidor uuid) returns uuid` (nulo si la membresía está suspendida o la bodega inactiva)
  - `privado.comparte_distribuidor_como_personal(p_perfil uuid) returns boolean`: quien llama es admin, vendedor o repartidor activo en algún distribuidor donde `p_perfil` tiene membresía
  - `privado.generar_codigo_invitacion() returns text`: 8 caracteres del alfabeto `ABCDEFGHJKMNPQRSTUVWXYZ23456789`, derivados de los bytes de `gen_random_uuid()`
  - `public.crear_invitacion(p_distribuidor_id uuid, p_rol rol_membresia, p_cliente_negocio_id uuid default null, p_dias_vigencia integer default 7) returns public.invitaciones`
  - `public.revocar_invitacion(p_invitacion_id uuid) returns void`
  - `public.canjear_invitacion(p_codigo text) returns uuid`: normaliza con `upper(trim(...))`
  - `public.cambiar_estado_membresia(p_membresia_id uuid, p_estado estado_membresia) returns void` (solo admin)
  - `public.cambiar_rol_membresia(p_membresia_id uuid, p_rol rol_membresia) returns void` (solo admin; solo entre `admin`, `vendedor`, `repartidor`)
  - `public.registrar_dispositivo(p_token text, p_plataforma text) returns void`: inserta o reasigna el token a `auth.uid()`
- Decisiones:
  - Trigger `after insert on auth.users` crea el perfil: `nombre` desde `raw_user_meta_data ->> 'nombre'` (o `''`), `telefono` desde `phone`.
  - `perfiles`: `grant select` y `grant update (nombre)`. Sin `insert` ni `delete`.
  - `distribuidores`: `grant select` y `grant update (nombre, telefono, config_tema)`; política de update solo para admin.
  - `membresias`, `invitaciones`: solo `grant select`. `intentos_canje`: sin ningún `grant`.
  - `clientes_negocio`: `select`, `insert`, `update` para admin y vendedor; sin `delete`.
  - Las dos funciones de membresía lanzan `P0006` si dejarían al distribuidor sin ningún admin activo.
  - El vendedor solo crea y revoca invitaciones de rol `cliente`; el Super Admin puede crear invitaciones de cualquier distribuidor.

**Datos fijos (`datos_m1.sql`)**, insertados como rol de servicio. Todos los ids tienen la forma `00000000-0000-0000-0000-00000000XXXX`; abajo solo se escribe `XXXX`.

| Qué | Id | Detalle |
|---|---|---|
| Distribuidor D1 | `0d01` | "Licores Demo", estado `activo` |
| Distribuidor D2 | `0d02` | "Electro Demo", estado `activo` |
| Bodegas de D1 | `0b01`, `0b02` | "Bodega Uno", "Bodega Dos" |
| Bodega de D2 | `0b03` | "Tienda Tres" |
| A1 | `00a1` | admin de D1 |
| V1 | `00b1` | vendedor de D1 |
| R1 | `00e1` | repartidor de D1 |
| C1 | `00c1` | cliente de D1 en `0b01` **y** cliente de D2 en `0b03` |
| C2 | `00c2` | cliente de D1 en `0b02` |
| A2 | `00a2` | admin de D2 |
| S1 | `00f1` | Super Admin, sin membresías |
| N1 | `0091` | sin membresías |

- [ ] **Step 1: Escribir `datos_m1.sql` y `01_identidad_test.sql`**

| Etiqueta | Actor | Acción | Resultado esperado |
|---|---|---|---|
| 1.1 | A1 | `select` de `distribuidores` | 1 fila (D1) |
| 1.2 | C1 | `select` de `distribuidores` | 2 filas |
| 1.3 | N1 | `select` de `distribuidores`, `membresias`, `clientes_negocio` | 0 filas en las tres |
| 1.4 | anon | `select` de `distribuidores` | error `42501` |
| 1.5 | A1 | `select` de `clientes_negocio` | 2 filas; ninguna de D2 |
| 1.6 | C2 | `select` de `clientes_negocio` | 1 fila (`0b02`) |
| 1.7 | A1 | `update` de `distribuidores` de D2 | 0 filas afectadas |
| 1.8 | C1 | `update perfiles set es_super_admin = true` sobre su fila | error `42501` |
| 1.9 | C1 | `update perfiles set nombre = 'Nuevo'` sobre su fila | 1 fila afectada |
| 1.10 | C1 | `insert` directo en `membresias` como admin de D2 | error `42501` |
| 1.11 | S1 | `select` de `distribuidores` | 2 filas |
| 1.12 | A1 | `crear_invitacion(D1, 'cliente', '0b02')` | devuelve fila con `codigo` de 8 caracteres, todos del alfabeto, y `vence_en` a 7 días |
| 1.13 | N1 | `canjear_invitacion` con ese código en minúsculas y con espacios alrededor | devuelve uuid; N1 ahora ve D1 y la bodega `0b02` |
| 1.14 | C2 | `canjear_invitacion` con el mismo código | `null` (ya usado) |
| 1.15 | N1 | canjear otro código válido de D1 | `null` (ya es miembro) |
| 1.16 | N1 nuevo | canjear código con `vence_en` en el pasado | `null` |
| 1.17 | N1 nuevo | canjear código revocado | `null` |
| 1.18 | N1 nuevo | canjear código de una bodega con `activo = false` | `null` |
| 1.19 | N1 nuevo | 5 canjes de `'XXXXXXXX'`, luego un sexto | los 5 devuelven `null`; el sexto lanza `P0005`; `intentos_canje` tiene 5 filas de esa cuenta |
| 1.20 | V1 | `crear_invitacion(D1, 'admin')` | error `42501` |
| 1.21 | A1 | `crear_invitacion(D2, 'cliente', '0b03')` | error `42501` |
| 1.22 | A1 | `crear_invitacion(D1, 'cliente')` sin bodega | error `22023` |
| 1.23 | A1 | `cambiar_estado_membresia` de C2 a `suspendida`; luego C2 hace `select` de `distribuidores` | C2 ve 0 filas |
| 1.24 | A1 | `cambiar_rol_membresia` de su propia membresía a `vendedor` | error `P0006` (único admin) |
| 1.25 | A1 | `cambiar_rol_membresia` de V1 a `cliente` | error `22023` |
| 1.26 | A1 | `cambiar_rol_membresia` de V1 a `repartidor` | la fila queda con rol `repartidor` |
| 1.27 | C1 | `registrar_dispositivo('tok-1', 'android')`; luego C2 registra el mismo token | queda 1 fila, de C2 |
| 1.28 | servicio | insertar en `membresias` rol `cliente` de D1 apuntando a la bodega `0b03` de D2 | error `23503` |
| 1.29 | servicio y C2 | poner la bodega `0b02` con `activo = false`; C2 hace `select` de `distribuidores` y de `clientes_negocio` | 0 filas en ambas |

"N1 nuevo" significa un usuario sin membresías creado en la prueba para ese caso.

- [ ] **Step 2: Verificar que falla**

Run: `su postgres -c "bash supabase/tests/run.sh 1"`
Expected: FAIL en `datos_m1.sql`, la tabla `distribuidores` no existe.

- [ ] **Step 3: Escribir la migración**

Orden dentro del archivo: esquema `privado`, enums, tablas, índices (toda clave foránea y `membresias (perfil_id, distribuidor_id)`), triggers, funciones auxiliares, permisos, políticas, funciones públicas.

- [ ] **Step 4: Verificar**

Run: `su postgres -c "bash supabase/tests/run.sh 1"`
Expected: `OK 1.1` a `OK 1.29` y `TODO OK`.

- [ ] **Step 5: Commit**

```bash
git add supabase
git commit -m "feat(supabase): identidad y acceso con membresías e invitaciones"
```

---

### Task 3: Módulo 2, catálogo e inventario

Spec: sección 6.2 y matriz de la sección 7.

**Files:**
- Create: `supabase/migrations/20261122110000_catalogo_e_inventario.sql`, `supabase/tests/soporte/datos_m2.sql`, `supabase/tests/02_catalogo_test.sql`

**Interfaces:**
- Consumes: `privado.tiene_rol`, `privado.es_miembro`, `privado.mi_cliente_en`, `privado.es_super_admin`, `privado.tg_actualizado_en`, tabla `clientes_negocio`.
- Produces (tablas):
  - `categorias (distribuidor_id, nombre, orden integer default 0, activo boolean default true)`
  - `productos (distribuidor_id, categoria_id, nombre, descripcion, marca, sku, imagen_url, unidad_base text default 'unidad', stock_fisico integer default 0, stock_comprometido integer default 0, activo, check (0 <= stock_comprometido and stock_comprometido <= stock_fisico))`; `sku` único por distribuidor cuando no es nulo
  - `presentaciones (distribuidor_id, producto_id, nombre, factor integer check (> 0), precio_base_centimos bigint check (>= 0), orden integer default 0, activo)`
  - `precios_volumen (distribuidor_id, presentacion_id, cantidad_minima integer check (> 0), precio_centimos bigint check (>= 0), unique (presentacion_id, cantidad_minima))`
  - `listas_precios (distribuidor_id, nombre, activo)`
  - `precios_lista (distribuidor_id, lista_precios_id, presentacion_id, precio_centimos bigint check (>= 0), unique (lista_precios_id, presentacion_id))`
  - `movimientos_stock (distribuidor_id, producto_id, tipo tipo_movimiento_stock, delta_fisico integer, delta_comprometido integer, pedido_id uuid, hecho_por → perfiles, nota text)`; `pedido_id` sin clave foránea todavía (se agrega en la Tarea 4)
  - `clientes_negocio.lista_precios_id` (nueva columna, nula por defecto)
- Produces (funciones):
  - `privado.mi_lista_en(p_distribuidor uuid) returns uuid`
  - `privado.uuid_o_nulo(p_texto text) returns uuid`: nulo si el texto no es un uuid
  - `privado.precio_para(p_presentacion uuid, p_cliente uuid, p_cantidad integer) returns bigint`: regla de precio de la spec 6.2 (el menor entre lista o base, y volumen). Ignora listas con `activo = false`.
  - `privado.aplicar_movimiento_stock(p_producto uuid, p_tipo public.tipo_movimiento_stock, p_delta_fisico integer, p_delta_comprometido integer, p_pedido uuid, p_nota text) returns void`: actualiza `productos` e inserta el movimiento. Quien la llama ya debe tener la fila bloqueada. Sin `grant` a `authenticated`.
  - `public.registrar_movimiento_stock(p_producto_id uuid, p_tipo tipo_movimiento_stock, p_cantidad integer, p_nota text default null) returns void`: solo admin. `ingreso` exige cantidad mayor a cero. `ajuste` toma la cantidad como diferencia con signo, distinta de cero. Otros tipos: `22023`. Si el físico quedaría por debajo del comprometido: `P0001`.
  - `privado.tg_clientes_negocio_protege_campos() returns trigger`: `before update` en `clientes_negocio`; lanza `42501` si alguien que no es admin cambia `lista_precios_id`. No aplica cuando no hay sesión (rol de servicio).
- Decisiones:
  - `productos`: `grant update` solo sobre `categoria_id, nombre, descripcion, marca, sku, imagen_url, unidad_base, activo`. Nunca sobre las columnas de stock.
  - Clientes y repartidores leen de `categorias`, `productos` y `presentaciones` solo filas con `activo = true`. Admin y vendedor leen todas.
  - El cliente lee de `precios_lista` solo las filas de su propia lista, y de `listas_precios` solo la suya. El repartidor no lee ninguna de las dos.
  - Bucket: `insert into storage.buckets (id, name, public) values ('catalogo', 'catalogo', true)`. Políticas de `insert`, `update` y `delete` sobre `storage.objects` para `authenticated` con `bucket_id = 'catalogo'` y `privado.tiene_rol(privado.uuid_o_nulo((storage.foldername(name))[1]), '{admin}')`.

**Datos fijos (`datos_m2.sql`)**, que incluye `datos_m1.sql`:

| Qué | Id | Detalle |
|---|---|---|
| Categoría de D1 | `0ca1` | "Ron" |
| Producto P1 (D1) | `0101` | "Ron Añejo", `unidad_base` `botella`, `stock_fisico` 120 |
| Producto P2 (D1) | `0102` | "Ron Descontinuado", `activo = false`, `stock_fisico` 10 |
| Presentación PR1 | `0201` | de P1, "Botella", factor 1, precio base 4200 |
| Presentación PR2 | `0202` | de P1, "Caja x12", factor 12, precio base 48000 |
| Presentación PR4 | `0204` | de P2, "Botella", factor 1, precio base 3000 |
| Precio por volumen | | PR1 desde 12 unidades: 3900 |
| Lista L1 (D1) | `0301` | "Mayorista", con PR1 a 4000; asignada a la bodega `0b02` |
| Categoría de D2 | `0ca2` | "Accesorios" |
| Producto P3 (D2) | `0103` | "Mouse", `unidad_base` `unidad`, `stock_fisico` 200 |
| Presentación PR3 | `0203` | de P3, "Unidad", factor 1, precio base 2500 |

- [ ] **Step 1: Escribir `datos_m2.sql` y `02_catalogo_test.sql`**

| Etiqueta | Actor | Acción | Resultado esperado |
|---|---|---|---|
| 2.1 | C2 | `select` de `productos` | 1 fila (P1); no ve P2 ni P3 |
| 2.2 | A1 | `select` de `productos` | 2 filas (P1 y P2) |
| 2.3 | C1 | `select` de `productos` | 2 filas (P1 de D1 y P3 de D2) |
| 2.4 | C2 | `update productos set nombre = 'x'` | 0 filas afectadas |
| 2.5 | C2 | `insert` en `productos` de D1 | error `42501` |
| 2.6 | A1 | `update productos set stock_fisico = 999` sobre P1 | error `42501` |
| 2.7 | A1 | `update productos set nombre = 'Ron Añejo 7'` sobre P1 | 1 fila afectada |
| 2.8 | A1 | `insert` en `productos` con `distribuidor_id` de D2 | error `42501` |
| 2.9 | A1 | `registrar_movimiento_stock(P1, 'ingreso', 24)` | `stock_fisico` = 144; un movimiento `ingreso` con `delta_fisico` 24 y `hecho_por` A1 |
| 2.10 | A1 | `registrar_movimiento_stock(P1, 'ajuste', -4)` | `stock_fisico` = 140 |
| 2.11 | A1 | `registrar_movimiento_stock(P1, 'ajuste', -500)` | error `P0001`; stock sin cambios |
| 2.12 | A1 | `registrar_movimiento_stock(P1, 'reserva', 5)` | error `22023` |
| 2.13 | A1 | `registrar_movimiento_stock(P1, 'ingreso', 0)` | error `22023` |
| 2.14 | V1 | `registrar_movimiento_stock(P1, 'ingreso', 1)` | error `42501` |
| 2.15 | A1 | `registrar_movimiento_stock(P3, 'ingreso', 1)` | error `42501` |
| 2.16 | A1 | `update` y `delete` sobre `movimientos_stock` | error `42501` en ambos |
| 2.17 | C2 | `select` de `movimientos_stock` | 0 filas |
| 2.18 | servicio | `privado.precio_para(PR1, '0b01', 1)` | 4200 |
| 2.19 | servicio | `privado.precio_para(PR1, '0b01', 12)` | 3900 |
| 2.20 | servicio | `privado.precio_para(PR1, '0b02', 1)` | 4000 |
| 2.21 | servicio | `privado.precio_para(PR1, '0b02', 12)` | 3900 |
| 2.22 | servicio | `privado.precio_para(PR2, '0b02', 1)` | 48000 (la lista no tiene PR2) |
| 2.23 | servicio | poner L1 con `activo = false`; `precio_para(PR1, '0b02', 1)` | 4200 |
| 2.24 | C2 | `select` de `precios_lista` | 1 fila |
| 2.25 | C1 | `select` de `precios_lista` | 0 filas |
| 2.26 | V1 | `update clientes_negocio set lista_precios_id = null` sobre `0b02` | error `42501` |
| 2.27 | V1 | `update clientes_negocio set direccion = 'Av. Uno 123'` sobre `0b02` | 1 fila afectada |
| 2.28 | A1 | `insert` en `storage.objects` con `name` `'<D1>/foto.png'` | se inserta |
| 2.29 | A1 | `insert` en `storage.objects` con `name` `'<D2>/foto.png'` y con `name` `'suelta.png'` | error `42501` en ambos |
| 2.30 | servicio | `update productos set stock_comprometido = 999` sobre P1 | error `23514` |

- [ ] **Step 2: Verificar que falla**

Run: `su postgres -c "bash supabase/tests/run.sh 2"`
Expected: las pruebas `1.x` pasan; FAIL en `datos_m2.sql`, la tabla `categorias` no existe.

- [ ] **Step 3: Escribir la migración**

- [ ] **Step 4: Verificar**

Run: `su postgres -c "bash supabase/tests/run.sh 2"`
Expected: `OK 2.1` a `OK 2.30` y `TODO OK`.

- [ ] **Step 5: Commit**

```bash
git add supabase
git commit -m "feat(supabase): catálogo, listas de precios e inventario con movimientos"
```

---

### Task 4: Módulo 3 (parte 1), tablas de pedidos y `crear_pedido`

Spec: sección 6.3 hasta los códigos de error, y matriz de la sección 7.

**Files:**
- Create: `supabase/migrations/20261122120000_pedidos.sql`, `supabase/tests/soporte/datos_m3.sql`, `supabase/tests/03_pedidos_test.sql`

**Interfaces:**
- Consumes: `privado.precio_para`, `privado.aplicar_movimiento_stock`, `privado.tiene_rol`, `privado.mi_cliente_en`, `privado.tg_clientes_negocio_protege_campos`.
- Produces (enums): `estado_pedido`, `despacho_pedido`, `condicion_pago`, `metodo_pago`, `estado_pago` con los valores de la spec.
- Produces (tablas):
  - `clientes_negocio`: columnas nuevas `credito_habilitado boolean default false`, `limite_credito_centimos bigint`, `plazo_credito_dias integer`, y `check (not credito_habilitado or (limite_credito_centimos > 0 and plazo_credito_dias > 0))`
  - `contadores_pedido (distribuidor_id pk, ultimo_numero integer default 0)`, sin `grant`
  - `pedidos (distribuidor_id, numero integer, cliente_id, creado_por → perfiles, repartidor_id → perfiles, estado default 'recibido', despacho, direccion_entrega text, nota_cliente text, total_centimos bigint, condicion_pago, metodo_pago, estado_pago default 'pendiente', saldo_pendiente_centimos bigint, vence_en date, motivo_cancelacion text, clave_idempotencia uuid not null, entregado_en timestamptz, unique (distribuidor_id, numero), unique (cliente_id, clave_idempotencia), check (0 <= saldo_pendiente_centimos and saldo_pendiente_centimos <= total_centimos))`
  - `pedido_items (distribuidor_id, pedido_id, presentacion_id, producto_id, nombre_producto text, nombre_presentacion text, factor integer, cantidad integer check (> 0), precio_unitario_centimos bigint, subtotal_centimos bigint)`
  - `pedido_eventos (distribuidor_id, pedido_id, estado_anterior estado_pedido, estado_nuevo estado_pedido, hecho_por → perfiles, nota text)`
  - clave foránea `movimientos_stock.pedido_id → pedidos`
- Produces (función):

```sql
public.crear_pedido(
  p_distribuidor_id uuid,
  p_items jsonb,
  p_clave_idempotencia uuid,
  p_cliente_id uuid default null,
  p_despacho despacho_pedido default 'recojo',
  p_condicion_pago condicion_pago default 'contado',
  p_metodo_pago metodo_pago default null,
  p_nota text default null
) returns uuid
```

  El orden de parámetros difiere del de la spec porque en Postgres los que tienen valor por defecto van al final. La app los pasa por nombre.
- Decisiones:
  - Orden de bloqueos, siempre el mismo: fila de `clientes_negocio`, luego filas de `productos` por `id` ascendente, luego la fila de `contadores_pedido`. `crear_pedido` crea la fila del contador si no existe (`insert ... on conflict do nothing` antes de bloquearla).
  - Los ítems con la misma `presentacion_id` se consolidan sumando cantidades antes de validar y de calcular el precio.
  - Toda validación de forma de `p_items` ocurre antes de convertir tipos y responde `22023`.
  - Si la clave de idempotencia ya existe para esa bodega, se devuelve el id existente sin revisar los ítems.
  - "Hoy" para deuda vencida es `(now() at time zone distribuidores.zona_horaria)::date`.
  - El trigger de protección de `clientes_negocio` se amplía a las tres columnas de crédito.
  - `pedidos`, `pedido_items`, `pedido_eventos`: solo `grant select`. Lectura según la matriz: admin y vendedor todo el distribuidor; repartidor donde `repartidor_id = auth.uid()` y sigue siendo repartidor activo; cliente donde `cliente_id = privado.mi_cliente_en(distribuidor_id)`.
  - Políticas adicionales de lectura: el repartidor lee `clientes_negocio` de sus pedidos asignados; el cliente lee el `perfiles` del repartidor de sus pedidos.

**Datos fijos (`datos_m3.sql`)**, que incluye `datos_m2.sql`: la bodega `0b02` queda con `credito_habilitado = true`, `limite_credito_centimos = 100000`, `plazo_credito_dias = 15`.

- [ ] **Step 1: Escribir `datos_m3.sql` y la primera parte de `03_pedidos_test.sql`**

Abreviaturas: `K1`, `K2`... son uuids distintos de idempotencia. Salvo que se indique, despacho `recojo` y condición `contado`.

| Etiqueta | Actor | Acción | Resultado esperado |
|---|---|---|---|
| 3.1 | C1 | `crear_pedido(D1, [PR2×2, PR1×6], K1)` | pedido `numero` 1, estado `recibido`, `total_centimos` 121200, `saldo_pendiente_centimos` 121200, `estado_pago` `pendiente`, `creado_por` C1, `cliente_id` `0b01`; P1 con `stock_comprometido` 30 y `stock_fisico` 120; 2 líneas con `nombre_producto` "Ron Añejo" y `factor` 12 y 1; movimientos `reserva` que suman `delta_comprometido` 30; 1 evento con `estado_nuevo` `recibido` |
| 3.2 | C1 | repetir la llamada con `K1` | mismo uuid; sigue habiendo 1 pedido; comprometido sigue en 30 |
| 3.3 | C1 | `crear_pedido(D1, [PR2×8], K2)` (96 > 90 disponibles) | error `P0001`; conteo de pedidos y comprometido sin cambios |
| 3.4 | C1 | `crear_pedido(D1, [PR1×6, PR1×6], K3)` | 1 línea con `cantidad` 12 y `precio_unitario_centimos` 3900; total 46800; `numero` 2 |
| 3.5 | C1 | `p_items` = `[]`, `{}`, `null`, `"x"` | error `22023` en los cuatro |
| 3.6 | C1 | cantidad `0`, `-1`, `1.5`, `"abc"`, `null`, `1000000000000` | error `22023` en los seis |
| 3.7 | C1 | `presentacion_id` = `"no-es-uuid"` y sin la clave | error `22023` en ambos |
| 3.8 | C1 | `crear_pedido(D1, [PR3×1], K4)` (presentación de D2) | error `P0002` |
| 3.9 | C1 | `crear_pedido(D1, [PR4×1], K5)` (producto inactivo) | error `P0002` |
| 3.10 | C1 | `crear_pedido(D2, [PR3×5], K6)` | pedido en D2 con `numero` 1 y `cliente_id` `0b03`; P3 comprometido 5 |
| 3.11 | C2 | `crear_pedido(D1, [PR1×1], K7, p_cliente_id => '0b01')` | error `42501` |
| 3.12 | V1 | `crear_pedido(D1, [PR1×1], K8, p_cliente_id => '0b02')` | pedido con `cliente_id` `0b02`, `creado_por` V1, total 4000 (precio de lista de la bodega) |
| 3.13 | V1 | `crear_pedido(D1, [PR1×1], K9)` sin bodega | error `22023` |
| 3.14 | V1 | `crear_pedido(D1, [PR1×1], K10, p_cliente_id => '0b03')` | error `42501` |
| 3.15 | R1 | `crear_pedido(D1, [PR1×1], K11, p_cliente_id => '0b01')` | error `42501` |
| 3.16 | N1 y anon | `crear_pedido(D1, [PR1×1], K12)` | error `42501` en ambos |
| 3.17 | C1 | `crear_pedido(D1, [PR1×1], K13, p_condicion_pago => 'credito')` | error `P0004` (sin crédito habilitado) |
| 3.18 | C2 | `crear_pedido(D1, [PR2×2], K14, p_condicion_pago => 'credito')` | pedido con total 96000 y `vence_en` nulo |
| 3.19 | C2 | `crear_pedido(D1, [PR1×1], K15, p_condicion_pago => 'credito')` | se crea: deuda a crédito previa 96000 + 4000 = 100000, igual al límite (el pedido de 3.12 no cuenta por ser de contado) |
| 3.20 | C2 | `crear_pedido(D1, [PR1×1], K16, p_condicion_pago => 'credito')` | error `P0004` (límite excedido) |
| 3.21 | servicio y C2 | poner `vence_en = current_date - 1` al pedido de 3.18 y subir el límite a 10000000; C2 pide a crédito | error `P0004` (deuda vencida) |
| 3.22 | C2 | mismo pedido que 3.21 pero de contado | se crea |
| 3.23 | servicio y C1 | poner D1 en `suspendido`; C1 pide | error `P0003`; C1 aún puede leer sus pedidos |
| 3.24 | servicio y C1 | D1 de vuelta a `activo`, bodega `0b01` con `activo = false`; C1 pide en D1 | error `42501`; C1 no ve productos de D1 pero sí los de D2 |
| 3.25 | C1, C2, A1, A2 | `select` de `pedidos` (antes de 3.23) | C1 ve solo los de `0b01` y `0b03`; C2 solo los de `0b02`; A1 todos los de D1 y ninguno de D2; A2 solo el de D2 |
| 3.26 | C1 | `insert`, `update` y `delete` directos sobre `pedidos` y `pedido_items` | error `42501` en todos |
| 3.27 | V1 | `update clientes_negocio set limite_credito_centimos = 1` sobre `0b02` | error `42501` |
| 3.28 | servicio | `update productos set nombre = 'Otro'` sobre P1; leer línea del pedido 3.1 | `nombre_producto` sigue siendo "Ron Añejo" |

- [ ] **Step 2: Verificar que falla**

Run: `su postgres -c "bash supabase/tests/run.sh 3"`
Expected: `1.x` y `2.x` pasan; FAIL en `datos_m3.sql`, la columna `credito_habilitado` no existe.

- [ ] **Step 3: Escribir la migración (enums, tablas, permisos, políticas y `crear_pedido`)**

- [ ] **Step 4: Verificar**

Run: `su postgres -c "bash supabase/tests/run.sh 3"`
Expected: `OK 3.1` a `OK 3.28` y `TODO OK`.

- [ ] **Step 5: Commit**

```bash
git add supabase
git commit -m "feat(supabase): pedidos con reserva de stock, crédito e idempotencia"
```

---

### Task 5: Módulo 3 (parte 2), estados, repartidor, Realtime y concurrencia

Spec: sección 6.3 desde `cambiar_estado_pedido`.

**Files:**
- Modify: `supabase/migrations/20261122120000_pedidos.sql` (agregar al final), `supabase/tests/03_pedidos_test.sql` (agregar casos)
- Create: `supabase/tests/03_concurrencia_test.sh`

**Interfaces:**
- Consumes: tablas y `crear_pedido` de la Tarea 4; `privado.aplicar_movimiento_stock`.
- Produces:
  - `public.cambiar_estado_pedido(p_pedido_id uuid, p_estado estado_pedido, p_nota text default null) returns void`
  - `public.asignar_repartidor(p_pedido_id uuid, p_repartidor_id uuid) returns void`: `p_repartidor_id` nulo desasigna
  - `privado.validar_cancelacion(p_pedido uuid) returns void`: en esta tarea no hace nada. `cambiar_estado_pedido` la llama antes de cancelar. La Tarea 6 la reemplaza. Así el módulo de cobros no tiene que redefinir toda la función de estados.
- Decisiones:
  - Bloquea la fila del pedido y luego los productos por `id` ascendente.
  - Pedido inexistente o de un distribuidor donde quien llama no tiene rol: `P0002`. Transición no permitida por la tabla de la spec: `P0006`. Rol sin permiso para esa transición: `42501`. Cancelar sin `p_nota` (nula o vacía): `22023`; la nota se guarda en `motivo_cancelacion`.
  - Al entregar: `entregado_en = now()`; si es a crédito, `vence_en = (now() at time zone zona_horaria)::date + plazo_credito_dias`.
  - `asignar_repartidor`: solo admin o vendedor; solo pedidos con despacho `reparto` (si no, `22023`) y en estado no final (si no, `P0006`); el repartidor debe tener membresía activa de rol `repartidor` en ese distribuidor (si no, `22023`).
  - `alter publication supabase_realtime add table public.pedidos, public.pedido_eventos;`

- [ ] **Step 1: Agregar casos a `03_pedidos_test.sql`**

Cada caso parte de pedidos nuevos creados dentro del caso. `Prep` = pedido de C1 por `PR1×10` con despacho `reparto`; `Prec` = igual con despacho `recojo`.

| Etiqueta | Actor | Acción | Resultado esperado |
|---|---|---|---|
| 3.40 | A1 | `Prep`: `recibido → confirmado` | estado `confirmado`; 2 eventos, el último con `estado_anterior` `recibido` y `hecho_por` A1 |
| 3.41 | A1 | `Prep` recibido: pasar directo a `entregado` y a `en_camino` | error `P0006` en ambos |
| 3.42 | A1 | `Prec` confirmado: pasar a `en_camino` | error `P0006` |
| 3.43 | A1 | `Prep` confirmado: pasar a `listo_recojo` | error `P0006` |
| 3.44 | A1 | `Prec`: confirmado → `listo_recojo` → `entregado` | P1 baja `stock_fisico` y `stock_comprometido` en 10 cada uno respecto a antes de entregar; movimiento `salida` con ambos deltas en -10; `entregado_en` no nulo |
| 3.45 | A1 | pedido entregado: pasar a `cancelado` | error `P0006` |
| 3.46 | A1 | `Prep` confirmado: `cancelado` sin nota | error `22023` |
| 3.47 | A1 | `Prep` confirmado: `cancelado` con nota "sin stock real" | `stock_comprometido` baja 10; `stock_fisico` igual; movimiento `liberacion`; `motivo_cancelacion` guardado |
| 3.48 | C1 | `Prep` recibido propio: `cancelado` con nota | se cancela |
| 3.49 | C1 | `Prep` confirmado propio: `cancelado` con nota | error `42501` |
| 3.50 | C2 | `Prep` recibido de C1: `cancelado` con nota | error `P0002` |
| 3.51 | C1 | `Prep` recibido propio: `confirmado` | error `42501` |
| 3.52 | A1 | `asignar_repartidor(Prep, R1)` | `repartidor_id` = R1; R1 ve ese pedido, sus líneas y la bodega `0b01` |
| 3.53 | R1 | pedido de D1 no asignado a él | no lo ve; `cambiar_estado_pedido` da `P0002` |
| 3.54 | R1 | `Prep` asignado y confirmado: `en_camino` y luego `entregado` | ambos pasan |
| 3.55 | R1 | `Prep` asignado y recibido: `confirmado`; y `cancelado` con nota | error `42501` en ambos |
| 3.56 | A1 | `asignar_repartidor(Prec, R1)` | error `22023` |
| 3.57 | A1 | `asignar_repartidor(Prep, V1)` y con C1 | error `22023` en ambos |
| 3.58 | A1 | `asignar_repartidor(Prep, null)` tras 3.52 | R1 deja de ver el pedido |
| 3.59 | A2 | `cambiar_estado_pedido` y `asignar_repartidor` sobre un pedido de D1 | error `P0002` en ambos |
| 3.60 | A1 | pedido a crédito de C2 (`PR1×1`, `recojo`), llevado a `entregado` | `vence_en` = hoy en `America/Lima` + 15 días |
| 3.61 | C1 | ve el `perfiles` de R1 solo mientras R1 es repartidor de un pedido suyo | 1 fila con asignación; 0 sin ella |
| 3.62 | servicio | consultar `pg_publication_tables` de `supabase_realtime` | contiene `pedidos` y `pedido_eventos` |

- [ ] **Step 2: Escribir `03_concurrencia_test.sh`**

El script usa la BD `distribuidores_test` ya migrada por `run.sh`. Pasos:
1. Como servicio (y con `commit`), cargar `datos_m3.sql` y dejar P1 con `stock_fisico` 10 y `stock_comprometido` 0.
2. Lanzar en paralelo dos `psql`, uno como C1 y otro como C2, cada uno con una transacción que ejecuta `crear_pedido(D1, [PR1×10], <clave propia>)`, luego `select pg_sleep(2)`, luego `commit`.
3. Esperar a ambos. Afirmar: exactamente un proceso terminó bien y el otro falló con `P0001`; hay 1 pedido; P1 tiene `stock_comprometido` 10.
4. Borrar los datos que insertó (o recrear la BD) para no afectar otras pruebas. `run.sh` lo ejecuta al final de las pruebas del módulo 3.

- [ ] **Step 3: Verificar que falla**

Run: `su postgres -c "bash supabase/tests/run.sh 3"`
Expected: FAIL en `3.40`, la función `cambiar_estado_pedido` no existe.

- [ ] **Step 4: Agregar las funciones y la publicación a la migración**

- [ ] **Step 5: Verificar**

Run: `su postgres -c "bash supabase/tests/run.sh 3"`
Expected: `OK 3.40` a `OK 3.62`, `OK concurrencia` y `TODO OK`.

- [ ] **Step 6: Commit**

```bash
git add supabase
git commit -m "feat(supabase): estados de pedido, repartidor y prueba de concurrencia"
```

---

### Task 6: Módulo 4, cobros

Spec: sección 6.4.

**Files:**
- Create: `supabase/migrations/20261122130000_cobros.sql`, `supabase/tests/04_cobros_test.sql`

**Interfaces:**
- Consumes: `pedidos` y sus columnas de pago; `privado.validar_cancelacion`; `privado.tiene_rol`.
- Produces:
  - `pagos (distribuidor_id, pedido_id, cliente_id, monto_centimos bigint check (> 0), metodo metodo_pago, referencia text, nota text, registrado_por → perfiles, anulado_en timestamptz, anulado_por → perfiles)`; solo `grant select`
  - `public.registrar_pago(p_pedido_id uuid, p_monto_centimos bigint, p_metodo metodo_pago, p_referencia text default null, p_nota text default null) returns uuid`
  - `public.anular_pago(p_pago_id uuid, p_nota text) returns void`
  - `privado.validar_cancelacion(p_pedido uuid)` reemplazada: lanza `P0006` si el pedido tiene pagos con `anulado_en` nulo
- Decisiones:
  - Ambas funciones bloquean la fila del pedido antes de leer el saldo.
  - `estado_pago`: saldo 0 → `pagado`; saldo igual al total → `pendiente`; cualquier otro → `parcial`.
  - Monto nulo, cero, negativo o mayor al saldo: `22023`. Pedido cancelado, o pago ya anulado: `P0006`. Pedido o pago inexistente o ajeno: `P0002`. `anular_pago` exige nota no vacía (`22023`) y la agrega a `pagos.nota`.
  - Lectura: admin y vendedor todos los del distribuidor; repartidor los de pedidos asignados a él; cliente los de su bodega.

- [ ] **Step 1: Escribir `04_cobros_test.sql`**

Usa `datos_m3.sql`. `Ped` = pedido de C1 por `PR1×10` (total 42000), despacho `reparto`, confirmado y asignado a R1.

| Etiqueta | Actor | Acción | Resultado esperado |
|---|---|---|---|
| 4.1 | V1 | `registrar_pago(Ped, 20000, 'efectivo')` | saldo 22000; `estado_pago` `parcial`; pago con `registrado_por` V1 y `cliente_id` `0b01` |
| 4.2 | R1 | `registrar_pago(Ped, 22000, 'billetera_digital', 'YAPE-123')` | saldo 0; `estado_pago` `pagado` |
| 4.3 | A1 | `registrar_pago(Ped, 1, 'efectivo')` con saldo 0 | error `22023` |
| 4.4 | A1 | montos `0`, `-5`, `null`, y uno mayor al saldo sobre un pedido nuevo | error `22023` en los cuatro |
| 4.5 | C1 | `registrar_pago` sobre su propio pedido | error `42501` |
| 4.6 | R1 | `registrar_pago` sobre un pedido de D1 no asignado a él | error `P0002` |
| 4.7 | A2 | `registrar_pago(Ped, 100, 'efectivo')` | error `P0002` |
| 4.8 | V1 | `anular_pago` del pago de 4.1 | error `42501` |
| 4.9 | A1 | `anular_pago` del pago de 4.2 con nota "monto errado" | saldo 22000; `estado_pago` `parcial`; `anulado_en` y `anulado_por` llenos; la fila sigue existiendo |
| 4.10 | A1 | `anular_pago` del mismo pago otra vez | error `P0006` |
| 4.11 | A1 | `anular_pago` sin nota | error `22023` |
| 4.12 | A1 | `cambiar_estado_pedido(Ped, 'cancelado', 'x')` con el pago de 4.1 activo | error `P0006`; stock sin cambios |
| 4.13 | A1 | anular el pago de 4.1 y cancelar | se cancela; saldo igual al total |
| 4.14 | A1 | `registrar_pago` sobre el pedido cancelado | error `P0006` |
| 4.15 | C1 y C2 | `select` de `pagos` | C1 ve los de `Ped`; C2 ve 0 |
| 4.16 | A1 | `update` y `delete` directos sobre `pagos` | error `42501` en ambos |
| 4.17 | A1 y C2 | pagar por completo un pedido a crédito de C2 de 96000; luego C2 pide a crédito otros 96000 | el segundo pedido se crea (la deuda bajó a 0) |
| 4.18 | A1 | pedido de contado entregado y sin pagos | queda `entregado` con `estado_pago` `pendiente` y admite `registrar_pago` |

- [ ] **Step 2: Verificar que falla**

Run: `su postgres -c "bash supabase/tests/run.sh 4"`
Expected: módulos 1 a 3 pasan; FAIL en `4.1`, la función `registrar_pago` no existe.

- [ ] **Step 3: Escribir la migración**

- [ ] **Step 4: Verificar**

Run: `su postgres -c "bash supabase/tests/run.sh 4"`
Expected: `OK 4.1` a `OK 4.18` y `TODO OK`.

- [ ] **Step 5: Commit**

```bash
git add supabase
git commit -m "feat(supabase): pagos de pedidos con parciales y anulación"
```

---

### Task 7: Módulo 5, plataforma

Spec: sección 6.5.

**Files:**
- Create: `supabase/migrations/20261122140000_plataforma.sql`, `supabase/tests/05_plataforma_test.sql`

**Interfaces:**
- Consumes: `privado.es_super_admin`, `privado.tiene_rol`, `privado.generar_codigo_invitacion`, tablas `distribuidores` e `invitaciones`.
- Produces:
  - Enum `estado_suscripcion`: `prueba`, `activa`, `vencida`, `cancelada`
  - `planes (codigo text unique, nombre, precio_mensual_centimos bigint check (>= 0), moneda text default 'PEN', limites jsonb default '{}', activo boolean default true)`
  - `suscripciones (distribuidor_id, plan_id, estado estado_suscripcion, periodo_inicio date, periodo_fin date, proveedor_pago text, referencia_externa text)`, con índice único parcial sobre `distribuidor_id` donde `estado in ('prueba', 'activa')`
  - `pagos_suscripcion (distribuidor_id, suscripcion_id, monto_centimos bigint check (> 0), metodo text, periodo_inicio date, periodo_fin date, registrado_por → perfiles, referencia_externa text, nota text)`
  - `public.crear_distribuidor(p_nombre text, p_slug text, p_rubro text, p_plan_codigo text, p_documento text default null, p_telefono text default null) returns jsonb`: devuelve `{"distribuidor_id": "<uuid>", "invitacion_codigo": "<8 caracteres>"}`
  - `public.cambiar_estado_distribuidor(p_distribuidor_id uuid, p_estado estado_distribuidor) returns void`
  - `public.registrar_pago_suscripcion(p_suscripcion_id uuid, p_monto_centimos bigint, p_metodo text, p_periodo_inicio date, p_periodo_fin date, p_referencia text default null, p_nota text default null) returns uuid`: deja la suscripción en `activa` con ese periodo
- Decisiones:
  - Las tres funciones: solo Super Admin; cualquier otro recibe `42501`.
  - `crear_distribuidor`: distribuidor en estado `prueba`; suscripción en `prueba` con `periodo_inicio` hoy y `periodo_fin` hoy + 30 días (la spec no fija la duración de la prueba; 30 días es decisión de este plan); invitación de rol `admin` vigente 7 días con `creada_por` el Super Admin. Plan inexistente o inactivo: `22023`. Slug repetido: `23505`.
  - `planes`: lectura para todo `authenticated`; `insert` y `update` solo Super Admin por política. `suscripciones` y `pagos_suscripcion`: lectura para el Super Admin y para el admin de ese distribuidor; escritura solo por las funciones.

- [ ] **Step 1: Escribir `05_plataforma_test.sql`**

Usa `datos_m3.sql` más un plan `basico` (precio 9900) insertado como servicio.

| Etiqueta | Actor | Acción | Resultado esperado |
|---|---|---|---|
| 5.1 | S1 | `crear_distribuidor('Abarrotes Sur', 'abarrotes-sur', 'abarrotes', 'basico')` | JSON con `distribuidor_id` e `invitacion_codigo` de 8 caracteres; distribuidor en `prueba`; 1 suscripción en `prueba` con `periodo_fin` = `periodo_inicio` + 30 |
| 5.2 | N1 | `canjear_invitacion` con ese código | N1 queda como admin del distribuidor nuevo y lo ve |
| 5.3 | N1 | crear una categoría en su distribuidor nuevo | se inserta |
| 5.4 | A1 | `crear_distribuidor(...)` | error `42501` |
| 5.5 | S1 | `crear_distribuidor` con plan `'no-existe'` | error `22023` |
| 5.6 | S1 | `crear_distribuidor` con el slug `'abarrotes-sur'` otra vez | error `23505` |
| 5.7 | S1 y C1 | `cambiar_estado_distribuidor(D1, 'suspendido')`; C1 intenta `crear_pedido` en D1 | error `P0003` |
| 5.8 | A1 | `cambiar_estado_distribuidor(D1, 'activo')` | error `42501` |
| 5.9 | S1 | `registrar_pago_suscripcion` de la suscripción de 5.1, 9900, `'transferencia'`, del 2026-12-01 al 2026-12-31 | suscripción `activa` con ese periodo; 1 fila en `pagos_suscripcion` con `registrado_por` S1 |
| 5.10 | N1, A1 | `select` de `suscripciones` | N1 ve 1 (la suya); A1 ve 0 |
| 5.11 | C1 | `select` de `suscripciones` y `pagos_suscripcion` | 0 filas en ambas |
| 5.12 | A1 | `insert` en `planes`; `update` de `suscripciones` | error `42501` en ambos |
| 5.13 | S1 | `insert` en `planes` con código `'pro'` | se inserta |
| 5.14 | servicio | insertar una segunda suscripción `activa` para el mismo distribuidor | error `23505` |
| 5.15 | C1 | `select` de `planes` | ve los planes |

- [ ] **Step 2: Verificar que falla**

Run: `su postgres -c "bash supabase/tests/run.sh 5"`
Expected: módulos 1 a 4 pasan; FAIL al insertar el plan, la tabla `planes` no existe.

- [ ] **Step 3: Escribir la migración**

- [ ] **Step 4: Verificar**

Run: `su postgres -c "bash supabase/tests/run.sh 5"`
Expected: `OK 5.1` a `OK 5.15` y `TODO OK`.

- [ ] **Step 5: Commit**

```bash
git add supabase
git commit -m "feat(supabase): planes, suscripciones y alta de distribuidores"
```

---

### Task 8: Barrido de seguridad sobre el esquema completo

Una prueba que recorre el catálogo de Postgres, para atrapar cualquier tabla o función que una tarea anterior haya dejado expuesta.

**Files:**
- Create: `supabase/tests/06_seguridad_test.sql`
- Modify: las migraciones que la prueba señale

**Interfaces:**
- Consumes: todo el esquema.

- [ ] **Step 1: Escribir `06_seguridad_test.sql`**

| Etiqueta | Consulta al catálogo | Resultado esperado |
|---|---|---|
| 6.1 | tablas de `public` con `relrowsecurity = false` | 0 |
| 6.2 | privilegios de `anon` sobre tablas de `public` (`information_schema.role_table_grants`) | 0 |
| 6.3 | funciones de `public` y `privado` que `anon` puede ejecutar (`has_function_privilege`) | 0 |
| 6.4 | funciones `security definer` de `public` y `privado` sin `search_path` en `proconfig` | 0 |
| 6.5 | políticas de `public` cuyo rol no sea exactamente `authenticated` | 0 |
| 6.6 | políticas de `UPDATE` o `ALL` sin `with check` | 0 |
| 6.7 | tablas de `public` con columna `distribuidor_id` y sin índice que empiece por ella | 0 |
| 6.8 | privilegios de `authenticated` para `insert`, `update` o `delete` sobre `pedidos`, `pedido_items`, `pedido_eventos`, `pagos`, `movimientos_stock`, `membresias`, `invitaciones`, `intentos_canje`, `contadores_pedido`, `suscripciones`, `pagos_suscripcion` | 0 |
| 6.9 | `has_column_privilege('authenticated', 'public.productos', col, 'UPDATE')` para `stock_fisico` y `stock_comprometido`; y `public.perfiles.es_super_admin` | falso en las tres |
| 6.10 | `has_schema_privilege('anon', 'privado', 'USAGE')` | falso |
| 6.11 | columnas de `public` cuyo nombre termina en `_centimos` y cuyo tipo no es `bigint` | 0 |

- [ ] **Step 2: Ejecutar**

Run: `su postgres -c "bash supabase/tests/run.sh"`
Expected: puede fallar en alguna de las `6.x`.

- [ ] **Step 3: Corregir en la migración correspondiente lo que la prueba señale**

Estas migraciones no están aplicadas en ningún entorno, así que se editan en su archivo.

- [ ] **Step 4: Verificar**

Run: `su postgres -c "bash supabase/tests/run.sh"`
Expected: todas las pruebas de los módulos 1 a 5, `OK 6.1` a `OK 6.11` y `TODO OK`.

- [ ] **Step 5: Commit**

```bash
git add supabase
git commit -m "test(supabase): barrido de seguridad sobre el esquema completo"
```

---

### Task 9: Seed, contrato, README y CI

**Files:**
- Modify: `supabase/seed.sql`, `docs/contrato.md`, `README.md` (sección Supabase), `.github/workflows/ci.yml`

**Interfaces:**
- Consumes: todo el esquema y `supabase/tests/run.sh`.

- [ ] **Step 1: Reescribir `supabase/seed.sql`**

Contenido, insertado como rol de servicio y con ids fijos distintos de los de las pruebas:
- 2 planes: `basico` y `pro`.
- Distribuidor "Licores del Norte (demo)" con el `config_tema` actual, y "ElectroMayor (demo)", ambos en `activo` con suscripción `activa`.
- Licores: 5 categorías, 30 productos con `unidad_base` `botella` y stock entre 60 y 600, presentaciones "Botella" (factor 1) y "Caja x12" (factor 12), "Six pack" (factor 6) para cervezas, y precio por volumen en cada botella desde 12 unidades.
- Electrónica: 2 categorías, 8 productos con presentaciones "Unidad" (factor 1) y "Pack x10" (factor 10).
- Una lista "Mayorista" en licores con 10 presentaciones.
- Licores: 1 admin, 1 vendedor, 1 repartidor y 3 bodegas, una con crédito (límite 500000, plazo 15 días) y otra con la lista "Mayorista". Electrónica: 1 admin y 2 tiendas.
- Una persona con membresía de cliente en ambos distribuidores.
- 1 Super Admin.
- 2 invitaciones vigentes de rol `cliente`, con códigos `DEMO2345` y `DEMO6789`.
- Sin pedidos: se crean desde la app.

Los usuarios van en `auth.users` con `id`, `email` y `phone`, sin contraseña, igual que el seed anterior.

- [ ] **Step 2: Verificar que el seed carga sobre el esquema completo**

Run: `su postgres -c "bash supabase/tests/run.sh"`
Expected: `TODO OK`, incluida la línea de carga del seed.

- [ ] **Step 3: Reescribir `docs/contrato.md`**

Mantener su estructura actual de secciones y su estado BORRADOR. Debe contener: convenciones; enums y tablas por módulo con sus columnas; funciones auxiliares; matriz de permisos; cada función pública con firma exacta, quién puede llamarla, qué hace y sus códigos de error (incluidos `P0003` a `P0006`); transiciones de estado; regla de precio; reglas de crédito; el JSON de `config_tema` sin cambios; descripción del seed; y cómo correr las pruebas. Reemplazar la sección 7 ("Rol del usuario en la app") por: el rol ya no está en `app_metadata`; la app lee `membresias` tras iniciar sesión. Marcar la sección de modelos Dart como **desactualizada, pendiente del plan de `packages/core`**, con la lista de modelos a crear, cambiar y eliminar. Vaciar la lista de pendientes ya resueltos y dejar: proveedor de SMS, valores reales de los planes, validación sobre Supabase real.

- [ ] **Step 4: Actualizar `README.md`**

En la sección Supabase: reemplazar el comando de `crear_pedido_test.sql` por `bash supabase/tests/run.sh` y `dart run melos run db:test`, e indicar que solo requiere Postgres y `psql`.

- [ ] **Step 5: Agregar el job de pruebas SQL a `.github/workflows/ci.yml`**

Job nuevo `sql`, en paralelo al existente: `runs-on: ubuntu-latest`, servicio `postgres:17` con `POSTGRES_PASSWORD: postgres` y chequeo de salud con `pg_isready`, variables `PGHOST: localhost`, `PGPORT: 5432`, `PGUSER: postgres`, `PGPASSWORD: postgres`, y un paso `bash supabase/tests/run.sh`.

- [ ] **Step 6: Verificación final**

Run: `su postgres -c "bash supabase/tests/run.sh"` y luego `git status --short`
Expected: `TODO OK`; ningún archivo sin seguimiento fuera de los previstos; no existe `supabase/migrations/20261117120000_esquema_inicial.sql`.

- [ ] **Step 7: Commit**

```bash
git add supabase docs/contrato.md README.md .github/workflows/ci.yml
git commit -m "docs: contrato, seed y CI para el esquema completo"
```

---

## Después de este plan

1. **Validar sobre Supabase real.** El shim simula `auth` y `storage`; hay que confirmar contra una rama de Supabase o `supabase start` que el trigger sobre `auth.users`, las políticas de `storage.objects` y la publicación de Realtime se comportan igual, y pasar los asesores de seguridad y rendimiento. Requiere aprobación de ambos socios porque toca el remoto.
2. **Plan de `packages/core`:** modelos Dart del contrato nuevo y cambio de la redirección en los routers.
