# Contrato: esquema, modelos, estados y tema

> **Estado: VIGENTE.** Aplicado a Supabase DEV el 2026-11-22. PROD aún no.
> Las pruebas corren en PostgreSQL 16 local, con un esquema `auth` y `storage` simulado
> (`supabase/tests/soporte/supabase_shim.sql`); en CI corren sobre PostgreSQL 17.

Este documento es la fuente de verdad del contrato entre la app móvil, el panel web y Supabase.
Si cambias un campo, un estado o una regla aquí, avisa al otro socio antes de tocar código.
Describe el esquema tal como está en `supabase/migrations/`; si hay diferencia, manda la migración
y este documento se corrige.

---

## 1. Convenciones

| Tema | Regla |
|---|---|
| Multi-tenant | Toda tabla de negocio tiene `distribuidor_id`. RLS activo en todas las tablas de `public`. |
| Aislamiento | Las tablas hijas llevan su propio `distribuidor_id` y apuntan al padre con clave foránea compuesta `(x_id, distribuidor_id)`: es imposible cruzar distribuidores. |
| Montos | `bigint` en **céntimos**, con sufijo `_centimos`. Nunca `double` ni `numeric`. |
| Nombres en BD | `snake_case`, en español. |
| Nombres en Dart | `camelCase`. El mapeo a `snake_case` es automático (`build.yaml` de `core`). |
| Fechas | `timestamptz` en UTC. Las fechas de calendario (`vence_en`, periodos) son `date`, calculadas en la zona horaria del distribuidor. |
| IDs | `uuid`, generados con `gen_random_uuid()`. |
| Marcas de tiempo | Toda tabla tiene `creado_en`. Las editables tienen `actualizado_en`, mantenido por el trigger `privado.tg_actualizado_en()`. |
| Esquemas | `public`: tablas y funciones que la app llama (Data API). `privado`: funciones auxiliares, **no** expuesto; `authenticated` solo tiene `usage`, `anon` nada. |
| Escritura | Lo que mueve stock, pedidos, pagos, membresías, invitaciones y la plataforma se escribe **solo con funciones** (`supabase.rpc(...)`). La app no hace `insert`/`update` sobre esas tablas. |
| Permisos | Cada migración revoca todo a `anon` y `authenticated` y otorga solo lo de la matriz (sección 2). `anon` no tiene acceso a ninguna tabla ni función. |
| Distribuidor activo | La app guarda cuál distribuidor está seleccionado y lo manda como filtro o parámetro (`distribuidor_id`). La BD nunca confía en ese valor: siempre verifica la membresía. |
| Cambios de esquema | Solo con una migración nueva en `supabase/migrations/`. Nunca se edita una migración ya aplicada. |

---

## 2. Esquema de base de datos

Migraciones, en orden (cada una pasa sus pruebas sin las siguientes):

| # | Archivo | Módulo |
|---|---|---|
| 1 | `supabase/migrations/20261122100000_identidad_y_acceso.sql` | Distribuidores, perfiles, bodegas, membresías, invitaciones, dispositivos |
| 2 | `supabase/migrations/20261122110000_catalogo_e_inventario.sql` | Catálogo, listas de precios, stock, bucket `catalogo` |
| 3 | `supabase/migrations/20261122120000_pedidos.sql` | Pedidos, líneas, eventos, crédito de la bodega, Realtime |
| 4 | `supabase/migrations/20261122130000_cobros.sql` | Pagos de pedidos |
| 5 | `supabase/migrations/20261122140000_plataforma.sql` | Planes, suscripciones, alta de distribuidores |
| 6 | `supabase/migrations/20261122150000_ajustes_post_revision.sql` | Ajustes tras la revisión: catálogo visible para cliente y repartidor, `crear_pedido` rechaza categorías inactivas, `execute` de `public.rls_auto_enable()` |

### Tipos (enums)

| Enum | Valores | Módulo |
|---|---|---|
| `estado_distribuidor` | `prueba`, `activo`, `suspendido`, `cancelado` | 1 |
| `rol_membresia` | `admin`, `vendedor`, `repartidor`, `cliente` | 1 |
| `estado_membresia` | `activa`, `suspendida` | 1 |
| `tipo_movimiento_stock` | `ingreso`, `ajuste`, `reserva`, `liberacion`, `salida` | 2 |
| `estado_pedido` | `recibido`, `confirmado`, `en_camino`, `listo_recojo`, `entregado`, `cancelado` | 3 |
| `despacho_pedido` | `recojo`, `reparto` | 3 |
| `condicion_pago` | `contado`, `credito` | 3 |
| `metodo_pago` | `efectivo`, `billetera_digital` (Yape, Plin), `transferencia` | 3 |
| `estado_pago` | `pendiente`, `parcial`, `pagado` | 3 |
| `estado_suscripcion` | `prueba`, `activa`, `vencida`, `cancelada` | 5 |

Los enums `rol_usuario` y `tipo_presentacion` del borrador ya no existen.

### Tablas

Todas tienen `creado_en` y, salvo `contadores_pedido` (su pk es `distribuidor_id`), un `id uuid`
(pk) con default `gen_random_uuid()`; en `perfiles` el `id` no tiene default (es el de
`auth.users`). Las marcadas con ✎ tienen `actualizado_en`.
`?` = admite nulo.

#### Módulo 1: identidad y acceso

| Tabla | Propósito | Columnas |
|---|---|---|
| `distribuidores` ✎ | Tenant | `nombre`, `slug` (único), `rubro?`, `documento?` (RUC), `telefono?`, `estado` (`estado_distribuidor`, def. `prueba`), `moneda` (3 letras, def. `PEN`), `zona_horaria` (def. `America/Lima`), `config_tema` (jsonb, def. `{}`; ver sección 6) |
| `perfiles` ✎ | Persona, `id` = `auth.users.id` (borrado en cascada) | `nombre` (def. `''`), `telefono?`, `es_super_admin` (def. `false`) |
| `clientes_negocio` ✎ | Bodega o tienda cliente | `distribuidor_id`, `nombre_negocio`, `documento?`, `direccion?`, `referencia?`, `telefono?`, `activo` (def. `true`); del módulo 2: `lista_precios_id?`; del módulo 3: `credito_habilitado` (def. `false`), `limite_credito_centimos?`, `plazo_credito_dias?` |
| `membresias` ✎ | Vínculo persona–distribuidor | `perfil_id`, `distribuidor_id`, `rol`, `estado` (def. `activa`), `cliente_negocio_id?` |
| `invitaciones` ✎ | Código de un solo uso | `distribuidor_id`, `codigo` (único en la plataforma), `rol`, `cliente_negocio_id?`, `creada_por?`, `vence_en`, `usada_por?`, `usada_en?`, `revocada_en?` |
| `intentos_canje` | Freno a quien adivina códigos | `perfil_id`, `exitoso` |
| `dispositivos_push` ✎ | Token de notificaciones | `perfil_id`, `token` (único), `plataforma` (`android`, `ios` o `web`) |

Reglas:
- `membresias` es única por (`perfil_id`, `distribuidor_id`): un solo rol por distribuidor.
- `membresias.cliente_negocio_id` e `invitaciones.cliente_negocio_id` son obligatorios si el rol es
  `cliente` y nulos en los demás (`check`). Varias personas pueden pertenecer a la misma bodega.
- `perfiles` lo crea el trigger `crear_perfil` al insertarse la fila en `auth.users`: copia
  `auth.users.phone` a `telefono` y `raw_user_meta_data ->> 'nombre'` a `nombre`. La migración 1
  también crea el perfil de las cuentas que ya existían antes de aplicarse (mismo criterio).
- El trigger `sincronizar_telefono` (`after update of phone` en `auth.users`) mantiene
  `perfiles.telefono` igual a `auth.users.phone` cuando la cuenta cambia de teléfono.
- Una invitación cuenta como usada cuando `usada_en` no es nulo (`usada_por` queda nulo si se
  borra la cuenta que la canjeó).
- **Una membresía cuenta solo si está `activa` y, si es de cliente, su bodega está activa.**
  Desactivar una bodega corta el acceso de todas sus personas.
- Clientes del distribuidor: `clientes_negocio` no se borra (no hay `delete`); se desactiva.
- Trigger de protección de `clientes_negocio` (en `insert` y `update`, solo con sesión; no aplica
  al rol de servicio): nadie cambia `id` ni `distribuidor_id`, ni siquiera el admin; solo el admin
  asigna o cambia `lista_precios_id` y las columnas de crédito, también al crear la bodega. El
  vendedor que lo intenta recibe `42501`.

#### Módulo 2: catálogo e inventario

| Tabla | Propósito | Columnas |
|---|---|---|
| `categorias` ✎ | Agrupa productos | `distribuidor_id`, `nombre`, `orden` (def. 0), `activo` |
| `productos` ✎ | Lo que se inventaría | `distribuidor_id`, `categoria_id?`, `nombre`, `descripcion?`, `marca?`, `sku?` (único por distribuidor; nulo o no vacío), `imagen_url?`, `unidad_base` (texto libre, def. `unidad`), `stock_fisico` (def. 0), `stock_comprometido` (def. 0), `activo` |
| `presentaciones` ✎ | Lo que se vende | `distribuidor_id`, `producto_id`, `nombre`, `factor` (> 0), `precio_base_centimos` (≥ 0), `orden`, `activo` |
| `precios_volumen` ✎ | Precio desde cierta cantidad | `distribuidor_id`, `presentacion_id`, `cantidad_minima` (> 0), `precio_centimos` (≥ 0); único por (`presentacion_id`, `cantidad_minima`) |
| `listas_precios` ✎ | Lista opcional por tipo de cliente | `distribuidor_id`, `nombre`, `activo` |
| `precios_lista` ✎ | Precio de una presentación en una lista | `distribuidor_id`, `lista_precios_id`, `presentacion_id`, `precio_centimos` (≥ 0); único por (`lista_precios_id`, `presentacion_id`) |
| `movimientos_stock` | Historial de inventario, solo inserción | `distribuidor_id`, `producto_id`, `tipo`, `delta_fisico`, `delta_comprometido`, `pedido_id?`, `hecho_por?`, `nota?` |

Reglas de stock:
- El stock es **por producto, en unidades base**. Cada presentación descuenta `cantidad × factor`
  (una caja x12 descuenta 12 botellas).
- `check (0 <= stock_comprometido <= stock_fisico)` (`productos_stock_check`).
- **Disponible = `stock_fisico` − `stock_comprometido`.** El disponible de una presentación es
  `disponible / factor` redondeado hacia abajo. Lo calcula la app; no se guarda.
- Nadie escribe `stock_fisico` ni `stock_comprometido` directamente: los grants por columna
  excluyen esas columnas del `insert` y del `update`, incluso para el admin. Un producto nuevo nace
  con stock 0; el stock inicial solo entra con `registrar_movimiento_stock` (tipo `ingreso`) o con
  el rol de servicio (seed).
- `reserva`, `liberacion` y `salida` los generan únicamente las funciones de pedidos.
- Catálogo y listas se desactivan (`activo = false`), no se borran: los pedidos los referencian.
  Solo `precios_volumen` y `precios_lista` admiten `delete` (del admin).
- Una lista de precios inactiva no es visible para el cliente ni se usa al calcular el precio.
- **Visibilidad para cliente y repartidor** (migración 6): solo ven lo que se puede pedir.
  - `categorias`: las activas.
  - `productos`: activos y con su categoría activa (un producto sin categoría basta con que esté
    activo).
  - `presentaciones`: activas y de un producto visible según la regla anterior.
  - `precios_volumen` y `precios_lista`: solo los de presentaciones visibles; de `precios_lista`,
    además, solo los de la lista activa de su bodega (el repartidor no ve ninguno).
  - Admin, vendedor y Super Admin ven todo, activo o no. Desactivar un producto o una categoría
    oculta sus presentaciones y precios a las bodegas, y `crear_pedido` los rechaza con `P0002`
    (también al admin y al vendedor; la regla de la categoría, desde la migración 6).

**Imágenes (Storage):** bucket `catalogo`, de lectura pública por URL, con rutas
`<distribuidor_id>/...`. Solo el admin de ese distribuidor sube, reemplaza, borra (y lista) dentro
de su carpeta. Aquí van las fotos de productos y el logo. El bucket acepta solo `image/jpeg`,
`image/png` e `image/webp`, de hasta 5 MB (`file_size_limit` 5242880).

#### Módulo 3: pedidos

| Tabla | Propósito | Columnas |
|---|---|---|
| `pedidos` ✎ | Pedido de una bodega | `distribuidor_id`, `numero` (correlativo, único por distribuidor), `cliente_id` (bodega), `creado_por?`, `repartidor_id?`, `estado` (def. `recibido`), `despacho`, `direccion_entrega?`, `nota_cliente?`, `total_centimos` (≥ 0), `condicion_pago`, `metodo_pago?`, `estado_pago` (def. `pendiente`), `saldo_pendiente_centimos` (entre 0 y el total), `plazo_credito_dias?`, `vence_en?` (`date`), `motivo_cancelacion?`, `clave_idempotencia` (única por bodega), `entregado_en?` |
| `pedido_items` | Líneas del pedido | `distribuidor_id`, `pedido_id`, `presentacion_id`, `producto_id`, `nombre_producto`, `nombre_presentacion`, `factor`, `cantidad` (> 0), `precio_unitario_centimos`, `subtotal_centimos` (= precio × cantidad); una línea por presentación |
| `pedido_eventos` | Línea de tiempo | `distribuidor_id`, `pedido_id`, `estado_anterior?` (nulo en el evento de creación), `estado_nuevo`, `hecho_por?`, `nota?` |
| `contadores_pedido` ✎ | Correlativo por distribuidor | `distribuidor_id` (pk), `ultimo_numero`. Lo crea `crear_pedido` la primera vez. Sin acceso para nadie. |

Columnas de crédito que este módulo agrega a `clientes_negocio`: si `credito_habilitado` es `true`,
`limite_credito_centimos` y `plazo_credito_dias` son obligatorios y mayores a cero (`check`). No
existe el crédito sin límite.

Reglas:
- `pedido_items` guarda una copia del nombre, el factor y el precio del momento de la compra.
  Editar el catálogo después no altera pedidos anteriores.
- `direccion_entrega` es una copia de `clientes_negocio.direccion` al crear el pedido;
  `nota_cliente` es `p_nota` de `crear_pedido`.
- `plazo_credito_dias` es una copia del plazo de la bodega al crear un pedido a crédito (nulo en
  contado, `check`). `vence_en` se calcula con **ese** valor al entregar: si después cambia o se
  quita el crédito de la bodega, el vencimiento del pedido no cambia.
- `metodo_pago` del pedido es solo informativo (cómo piensa pagar); los pagos reales van en `pagos`.
- Las claves foráneas hacia catálogo y bodegas no tienen acción en cascada: se desactivan, no se
  borran.
- **Realtime:** `pedidos` y `pedido_eventos` están en la publicación `supabase_realtime`. RLS
  aplica igual a las suscripciones.

#### Módulo 4: cobros

| Tabla | Propósito | Columnas |
|---|---|---|
| `pagos` ✎ | Pago total o parcial de un pedido | `distribuidor_id`, `pedido_id`, `cliente_id`, `monto_centimos` (> 0), `metodo` (`metodo_pago`), `referencia?`, `nota?`, `registrado_por?`, `anulado_en?`, `anulado_por?` |

Reglas:
- Un pago nunca se borra ni se edita: anularlo llena `anulado_en` y `anulado_por` y agrega
  `Anulado: <motivo>` a `nota` (en una línea nueva).
- `pagos.cliente_id` es la bodega del pedido. Lo fija `registrar_pago`; no hay una restricción
  que lo compare con `pedidos.cliente_id`.
- El saldo y el estado de pago viven en `pedidos`; solo los mueven `registrar_pago` y `anular_pago`.
  `estado_pago`: saldo 0 → `pagado`; saldo igual al total → `pendiente`; otro → `parcial`.

#### Módulo 5: plataforma

| Tabla | Propósito | Columnas |
|---|---|---|
| `planes` ✎ | Oferta comercial (sin `distribuidor_id`) | `codigo` (único, no vacío), `nombre`, `precio_mensual_centimos` (≥ 0), `moneda` (def. `PEN`), `limites` (jsonb objeto, def. `{}`), `activo` |
| `suscripciones` ✎ | Plan de un distribuidor en un periodo | `distribuidor_id`, `plan_id`, `estado`, `periodo_inicio`, `periodo_fin` (`date`, fin ≥ inicio), `proveedor_pago?`, `referencia_externa?` |
| `pagos_suscripcion` | Pago de un periodo; nunca se edita ni se borra | `distribuidor_id`, `suscripcion_id`, `monto_centimos` (> 0), `metodo` (texto no vacío), `periodo_inicio`, `periodo_fin`, `registrado_por?`, `referencia_externa?`, `nota?` |

Reglas:
- A lo sumo una suscripción vigente (`prueba` o `activa`) por distribuidor: índice único parcial
  `suscripciones_vigente_unica`.
- `limites` guarda topes, por ejemplo `{"max_clientes": 50, "max_productos": 200, "max_usuarios": 3}`.
  Solo se guardan; no se hacen cumplir.
- `proveedor_pago` y `referencia_externa` quedan nulos por ahora (para una pasarela futura).
- El estado de la suscripción y el del distribuidor son independientes: pagar no reactiva un
  distribuidor suspendido, y no hay suspensión automática por vencimiento.

### Funciones auxiliares (esquema `privado`)

| Función | Devuelve | Notas |
|---|---|---|
| `es_super_admin()` | `true` si el perfil actual es Super Admin | definer; en políticas |
| `es_miembro(p_distribuidor uuid)` | `true` si tiene membresía activa (y bodega activa si es cliente) | definer; en políticas |
| `tiene_rol(p_distribuidor uuid, p_roles rol_membresia[])` | `true` si su membresía activa tiene un rol de la lista | definer; en políticas |
| `mi_cliente_en(p_distribuidor uuid)` | id de su bodega activa en ese distribuidor, o nulo | definer; en políticas |
| `comparte_distribuidor_como_personal(p_perfil uuid)` | `true` si quien llama es personal activo de un distribuidor donde `p_perfil` tiene membresía | definer; en políticas de `perfiles` |
| `mi_lista_en(p_distribuidor uuid)` | lista de precios **activa** de su bodega, o nulo | definer; en políticas |
| `producto_visible(p_producto uuid)` | `true` si el producto está activo y su categoría (si tiene) también | definer; en políticas (migración 6) |
| `presentacion_visible(p_presentacion uuid)` | `true` si la presentación está activa y su producto es visible | definer; en políticas (migración 6) |
| `uuid_o_nulo(p_texto text)` | el texto como `uuid`, o nulo si no tiene forma de uuid | en políticas de Storage y en `crear_pedido` |
| `otros_admin_activos(p_distribuidor uuid, p_excluir uuid)` | cuántos admin activos quedan sin contar una membresía | interna (regla del último admin) |
| `generar_codigo_invitacion()` | código de 8 caracteres | interna; ver `crear_invitacion` |
| `precio_para(p_presentacion uuid, p_cliente uuid, p_cantidad integer)` | precio unitario en céntimos (regla de precio, sección 3) | interna |
| `aplicar_movimiento_stock(...)` | aplica deltas de stock y registra el movimiento | interna |
| `ve_pedido(p_distribuidor uuid, p_cliente uuid, p_repartidor uuid)` | `true` si quien llama puede ver ese pedido (misma regla que la política de `pedidos`, sin el Super Admin) | interna |
| `validar_cancelacion(p_pedido uuid)` | nada; lanza `P0006` si el pedido tiene pagos sin anular | interna (el módulo 4 la redefine) |
| `estado_pago_segun(p_saldo bigint, p_total bigint)` | `estado_pago` según el saldo | interna |

Triggers: `tg_actualizado_en()`, `tg_crear_perfil()` y `tg_sincronizar_telefono()` (definer,
sobre `auth.users`) y `tg_clientes_negocio_protege_campos()`.

Todas tienen `search_path = ''` y `execute` revocado a `public` y `anon`. `authenticated` solo puede
ejecutar las marcadas "en políticas"; las internas solo las llaman funciones `security definer`.
La seguridad se valida contra `membresias`, no contra el token: una bodega que canjea un código ve el
catálogo al instante, sin cerrar sesión.

`public.rls_auto_enable()` no es nuestra: la crea Supabase (security definer, la usa un event
trigger) y no existe en el Postgres local ni en CI. La migración 6, si existe, le revoca `execute`
a `public`, `anon` y `authenticated` (aviso del asesor de seguridad); no la borra ni la modifica.

### Matriz de permisos (RLS y grants)

Las columnas Admin, Vendedor, Repartidor y Cliente aplican solo dentro del distribuidor donde la
persona tiene membresía activa (ver la regla de bodega activa arriba). "Funciones" = solo mediante
las funciones de la sección 3.

| Tabla | Admin | Vendedor | Repartidor | Cliente | Super Admin |
|---|---|---|---|---|---|
| `distribuidores` | lee; edita `nombre`, `telefono`, `config_tema` | lee | lee | lee | lee todos; `estado` por funciones |
| `perfiles` | lee el suyo y los de las personas con membresía en su distribuidor | igual que admin | igual que admin | lee el suyo y el del repartidor asignado a sus pedidos | lee todos |
| (todos) `perfiles` | cada persona edita solo su `nombre` | | | | |
| `membresias` | lee todas; estado, rol y bodega por funciones | lee todas | lee la suya | lee la suya | lee todas |
| `clientes_negocio` | lee, crea y edita (con lista y crédito); sin `delete` | lee, crea y edita, sin lista ni crédito | lee las de sus pedidos asignados | lee la suya | lee todas |
| `invitaciones` | lee todas; crea y revoca por funciones | lee, crea y revoca las de rol `cliente` | no | no | lee todas; crea y revoca en cualquiera |
| `categorias`, `productos`, `presentaciones` | lee todo; crea y edita por columnas (sin stock, sin `delete`) | lee todo | lee solo lo visible (sección 2, catálogo) | lee solo lo visible (sección 2, catálogo) | lee todo |
| `precios_volumen` | lee; crea, edita y borra | lee | lee los de presentaciones visibles | lee los de presentaciones visibles | lee |
| `listas_precios` | lee; crea y edita | lee | no | lee su lista si está activa | lee |
| `precios_lista` | lee; crea, edita y borra | lee | no | lee los de su lista si está activa, de presentaciones visibles | lee |
| `movimientos_stock` | lee; escribe por funciones | lee | no | no | lee |
| `pedidos`, `pedido_items`, `pedido_eventos` | lee todos; escribe por funciones | lee todos; escribe por funciones | lee los asignados a él mientras sea repartidor activo | lee los de su bodega | lee todos |
| `pagos` | lee todos; registra y anula por funciones | lee todos; registra por funciones | lee y registra los de sus pedidos asignados | lee los de su bodega | lee todos |
| `suscripciones`, `pagos_suscripcion` | lee las suyas | no | no | no | lee todas; escribe por funciones |
| `planes` | lee | lee | lee | lee | lee, crea y edita |
| `dispositivos_push` | cada persona lee y borra solo los suyos; registra con `registrar_dispositivo` | | | | |
| `intentos_canje`, `contadores_pedido` | sin acceso para nadie | | | | |
| Storage `catalogo` | sube, reemplaza y borra en `<su distribuidor_id>/` | lectura pública por URL | | | |

Grants por columna (lo que la API acepta en `insert` / `update`; lo demás falla con `42501`):

| Tabla | `insert` | `update` |
|---|---|---|
| `distribuidores` | — | `nombre`, `telefono`, `config_tema` |
| `perfiles` | — | `nombre` |
| `clientes_negocio` | todas | todas (el trigger protege `id`, `distribuidor_id`, lista y crédito) |
| `categorias` | `id`, `distribuidor_id`, `nombre`, `orden`, `activo` | `nombre`, `orden`, `activo` |
| `productos` | `id`, `distribuidor_id`, `categoria_id`, `nombre`, `descripcion`, `marca`, `sku`, `imagen_url`, `unidad_base`, `activo` | las mismas salvo `id` y `distribuidor_id` |
| `presentaciones` | `id`, `distribuidor_id`, `producto_id`, `nombre`, `factor`, `precio_base_centimos`, `orden`, `activo` | `nombre`, `factor`, `precio_base_centimos`, `orden`, `activo` |
| `precios_volumen` | `id`, `distribuidor_id`, `presentacion_id`, `cantidad_minima`, `precio_centimos` | `cantidad_minima`, `precio_centimos` |
| `listas_precios` | `id`, `distribuidor_id`, `nombre`, `activo` | `nombre`, `activo` |
| `precios_lista` | `id`, `distribuidor_id`, `lista_precios_id`, `presentacion_id`, `precio_centimos` | `precio_centimos` |
| `planes` | `id`, `codigo`, `nombre`, `precio_mensual_centimos`, `moneda`, `limites`, `activo` | las mismas salvo `id` |

El resto de las tablas es de solo lectura para `authenticated`. Un `update` que la política no
permite no da error: no cambia ninguna fila.

---

## 3. Funciones públicas

Todas son `security definer`, verifican `auth.uid()` y la membresía en su cuerpo, y solo las
ejecuta `authenticated` (`anon` recibe `permission denied`). Sin sesión, todas lanzan `42501`.
Los parámetros con valor por defecto van al final: **la app los pasa por nombre**
(`supabase.rpc('crear_pedido', params: {...})`).

### Códigos de error

| SQLSTATE | Significado |
|---|---|
| `42501` | Sin sesión, sin permiso, o recurso de otro distribuidor (bodega ajena) |
| `22023` | Parámetro inválido o mal formado |
| `23505` | Valor repetido (slug de distribuidor). También puede salir, en vez de `P0006`, si dos pagos de suscripción del mismo distribuidor se registran en el mismo instante |
| `P0001` | Stock insuficiente (o un ajuste que deja el físico por debajo del comprometido) |
| `P0002` | No existe, o quien llama no puede verlo (pedido, pago, presentación, suscripción, distribuidor) |
| `P0003` | Distribuidor que no está en `prueba` ni `activo`, o bodega inactiva en un pedido que admin o vendedor crean a su nombre (un cliente con la bodega inactiva recibe `42501`: su membresía ya no cuenta) |
| `P0004` | Crédito no habilitado, límite excedido o deuda vencida |
| `P0005` | Demasiados intentos de canje (solo `canjear_invitacion`) |
| `P0006` | Operación no válida para el estado actual: transición de pedido inválida, pago sobre pedido cancelado, pago ya anulado, cancelar con pagos activos, revocar una invitación usada, dejar a un distribuidor sin admin activo, pagar una suscripción cancelada o que dejaría dos vigentes |

> **Ojo con `P0004`:** coincide con el SQLSTATE de `assert_failure` de PL/pgSQL. Un bloque
> `exception when others` **no** lo captura; hay que nombrarlo (`when others or assert_failure`).
> Desde la app llega como cualquier otro error de Postgres, con `code = 'P0004'`.

Los mensajes están en español y pueden cambiar; la app decide por el código, no por el texto.

### Módulo 1: identidad y acceso

**`crear_invitacion(p_distribuidor_id uuid, p_rol rol_membresia, p_cliente_negocio_id uuid default null, p_dias_vigencia integer default 7) returns invitaciones`**
- Quién: admin (cualquier rol), vendedor (solo rol `cliente`), Super Admin (cualquier distribuidor).
- Genera el código (8 caracteres del alfabeto `ABCDEFGHJKMNPQRSTUVWXYZ23456789`, sin `0`, `O`, `1`,
  `I`, `L`), con `vence_en = now() + p_dias_vigencia días`. Devuelve la fila creada.
- Errores: `42501` sin permiso o bodega de otro distribuidor; `22023` rol nulo, vigencia nula o < 1,
  bodega ausente con rol `cliente` o presente con otro rol; `23503` (solo Super Admin, rol distinto
  de `cliente`) `p_distribuidor_id` inexistente.

**`revocar_invitacion(p_invitacion_id uuid) returns void`**
- Quién: los mismos que pueden crearla. Revocar dos veces no hace nada.
- Errores: `42501` inexistente o sin permiso; `P0006` ya usada.

**`canjear_invitacion(p_codigo text) returns uuid`**
- Quién: cualquier persona con sesión. Normaliza el código (`upper(trim(...))`).
- Si sirve, crea la membresía, marca la invitación usada y devuelve el id de la membresía.
- **Si no sirve devuelve `null`, sin error**: código inexistente, usado, revocado, vencido, bodega
  inactiva, o la persona ya tiene membresía (activa o suspendida) en ese distribuidor. Así el
  intento queda registrado y el freno funciona.
- Freno: con 5 intentos fallidos en 15 minutos, la cuenta queda frenada hasta que salga de la
  ventana. Los canjes de una misma cuenta se serializan.
- Errores: solo `42501` (sin sesión) y `P0005` (frenada).

**`cambiar_estado_membresia(p_membresia_id uuid, p_estado estado_membresia) returns void`**
- Quién: admin del distribuidor de la membresía (cualquier rol, también clientes).
- Errores: `42501` inexistente o sin permiso; `22023` estado nulo; `P0006` dejaría al distribuidor
  sin admin activo.

**`cambiar_rol_membresia(p_membresia_id uuid, p_rol rol_membresia) returns void`**
- Quién: admin del distribuidor. Solo entre `admin`, `vendedor` y `repartidor`: personal no pasa a
  cliente ni al revés.
- Errores: `42501` inexistente o sin permiso; `22023` rol nulo o fuera de personal; `P0006` dejaría
  al distribuidor sin admin activo.

**`cambiar_bodega_membresia(p_membresia_id uuid, p_cliente_negocio_id uuid) returns void`**
- Quién: admin del distribuidor. Mueve una membresía de rol `cliente` a otra bodega (por ejemplo,
  para corregir una invitación hecha con la bodega equivocada). La bodega destino debe ser del
  mismo distribuidor y estar activa.
- Errores: `42501` inexistente o sin permiso; `22023` bodega nula, membresía que no es de cliente,
  o bodega de otro distribuidor o inactiva.

**`registrar_dispositivo(p_token text, p_plataforma text) returns void`**
- Quién: cualquier persona con sesión. Guarda el token a su nombre; si el token ya existía (otra
  cuenta en el mismo dispositivo), lo reasigna.
- Errores: `22023` token vacío o plataforma distinta de `android`, `ios`, `web`.

### Módulo 2: catálogo e inventario

**`registrar_movimiento_stock(p_producto_id uuid, p_tipo tipo_movimiento_stock, p_cantidad integer, p_nota text default null) returns void`**
- Quién: admin del distribuidor del producto.
- `ingreso`: `p_cantidad > 0`, suma al físico. `ajuste`: diferencia con signo, distinta de 0.
  Registra el movimiento con `hecho_por` = quien llama.
- Errores: `42501` producto inexistente o sin permiso; `22023` otro tipo o cantidad inválida, o un
  físico resultante mayor al máximo de `integer`; `P0001` el físico quedaría por debajo del
  comprometido.

### Módulo 3: pedidos

**`crear_pedido(p_distribuidor_id uuid, p_items jsonb, p_clave_idempotencia uuid, p_despacho despacho_pedido, p_condicion_pago condicion_pago, p_cliente_id uuid default null, p_metodo_pago metodo_pago default null, p_nota text default null) returns uuid`**

- `p_despacho` y `p_condicion_pago` son **obligatorios** (sin valor por defecto): una llamada que
  omite alguno no encuentra la función (`42883`; por la Data API, error de función inexistente).
  Pasarlos explícitamente en `null` da `22023`.
- Máximo **200 presentaciones distintas** por pedido (después de sumar las repetidas).

- `p_items = [{"presentacion_id": "<uuid>", "cantidad": <entero>}, ...]`. Varias entradas de la
  misma presentación se suman en una línea.
- Quién:
  - **Cliente:** la bodega es la de su membresía; `p_cliente_id` nulo o igual a la suya.
  - **Admin o vendedor:** `p_cliente_id` obligatorio y de ese distribuidor (pedido a nombre de la
    bodega). Precios, lista y crédito se aplican según la bodega, no según quién llama.
  - Nadie más (el repartidor no crea pedidos).
- En una transacción:
  1. Verifica permiso y bodega. Un cliente cuya bodega está inactiva recibe `42501`: su membresía
     ya no cuenta, así que no es cliente de ese distribuidor. Bloquea la fila de la bodega
     (serializa sus pedidos) y, con el bloqueo obtenido, vuelve a verificar el permiso: si quien
     llama perdió su membresía o su rol mientras esperaba, recibe `42501`.
  2. Rechaza con `P0003` si el distribuidor no está en `prueba` ni `activo`, o si la bodega está
     inactiva (esto último solo llega en pedidos que admin o vendedor crean a su nombre).
  3. **Idempotencia:** si la bodega ya tiene un pedido con esa clave, devuelve su id sin revisar los
     ítems ni crear otro. La app genera la clave una vez por intento de compra y la reutiliza en los
     reintentos.
  4. Valida la forma de `p_items` y bloquea los productos involucrados por id ascendente.
  5. Valida que cada presentación exista, sea de ese distribuidor y esté activa, igual que su
     producto.
  6. Por línea: unidades base = `cantidad × factor`, contra el disponible (acumulando lo reservado
     por otras presentaciones del mismo producto); precio según la regla de abajo.
  7. Si es a crédito, aplica las reglas de crédito.
  8. Asigna el `numero`, crea el pedido en `recibido` con `saldo_pendiente_centimos = total` y
     `estado_pago = pendiente` (`pagado` si el total es 0), sus líneas, un movimiento `reserva`
     por línea (sube el comprometido) y el primer evento.
- Devuelve el id del pedido. Si algo falla, se revierte todo.
- Errores: `42501` sin permiso o bodega ajena (también un cliente cuya bodega está inactiva, o
  quien pierde el permiso mientras espera el bloqueo); `22023` clave, despacho o condición en
  `null`, admin o vendedor sin `p_cliente_id`, ítems que no son un arreglo no vacío de
  `{presentacion_id, cantidad}`, cantidad no entera, ≤ 0 o mayor al máximo de `integer`, más de
  200 presentaciones distintas;
  `P0002` presentación inexistente, inactiva (o su producto, o la categoría de su producto;
  un producto sin categoría vale) o de otro distribuidor; `P0001` stock
  insuficiente (el mensaje nombra el producto); `P0003` distribuidor fuera de `prueba`/`activo` o
  bodega inactiva en un pedido a su nombre (admin o vendedor); `P0004` crédito no habilitado, límite excedido o deuda vencida.
- Notas:
  - Lee el estado del distribuidor **sin bloquear su fila**: una suspensión confirmada en el mismo
    instante puede dejar pasar un pedido.
  - El estado del distribuidor y de la bodega se revisan antes de la idempotencia: un reintento con
    el distribuidor ya suspendido recibe `P0003` aunque el pedido exista.
  - Un pedido de total 0 (presentaciones a precio 0) nace con `estado_pago = pagado` y saldo 0:
    no hay nada que cobrar (`registrar_pago` rechaza todo monto por superar el saldo).

**Regla de precio** (por línea, `privado.precio_para`):
1. Precio de partida: el de `precios_lista` si la bodega tiene una lista **activa** y la
   presentación tiene precio en ella; si no, `precio_base_centimos`.
2. Precio por volumen: el de mayor `cantidad_minima` que no supere la cantidad de la línea, si existe.
3. Se cobra **el menor** de los dos. Un descuento por volumen nunca perjudica a un cliente con lista.

**Reglas de crédito** (solo con `p_condicion_pago = 'credito'`, con la bodega bloqueada):
- La bodega debe tener `credito_habilitado`.
- Si tiene un pedido a crédito no cancelado con saldo > 0 y `vence_en` anterior a hoy (fecha en la
  zona horaria del distribuidor), se rechaza.
- Deuda actual = suma de `saldo_pendiente_centimos` de sus pedidos a crédito no cancelados
  (entregados o no). Deuda actual + total del pedido nuevo no puede superar
  `limite_credito_centimos`.
- El pedido guarda `plazo_credito_dias` de la bodega; al entregarlo, `vence_en` = fecha de entrega +
  ese plazo.
- Solo el admin cambia las condiciones de crédito de una bodega. Anular un pago (que sube la deuda)
  bloquea la bodega, así que no hay carrera con un pedido nuevo.

**`cambiar_estado_pedido(p_pedido_id uuid, p_estado estado_pedido, p_nota text default null) returns void`**
- Quién y qué transiciones: sección 4. Cada cambio inserta un evento con la nota.
- `entregado`: movimiento `salida` por línea (baja físico y comprometido), `entregado_en = now()` y,
  si es a crédito, `vence_en`. `cancelado`: exige nota (se guarda en `motivo_cancelacion`),
  rechaza si hay pagos sin anular, y registra un movimiento `liberacion` por línea (baja el
  comprometido).
- Entregar no exige que el pedido esté pagado: queda `entregado` con su `estado_pago`.
- Errores: `P0002` pedido inexistente o que quien llama no puede ver; `22023` estado nulo o
  cancelación sin nota; `P0006` transición no válida o cancelar con pagos activos; `42501` rol sin
  permiso para esa transición.

**`asignar_repartidor(p_pedido_id uuid, p_repartidor_id uuid) returns void`**
- Quién: admin o vendedor. `p_repartidor_id` nulo desasigna. Solo pedidos de `reparto` no
  finales; el repartidor debe tener membresía activa de rol `repartidor` en ese distribuidor.
- Errores: `P0002` pedido inexistente o que no puede ver; `42501` sin rol de admin o vendedor;
  `22023` pedido de recojo o persona que no es repartidor activo; `P0006` pedido entregado o
  cancelado.

### Módulo 4: cobros

**`registrar_pago(p_pedido_id uuid, p_monto_centimos bigint, p_metodo metodo_pago, p_referencia text default null, p_nota text default null) returns uuid`**
- Quién: admin, vendedor o el repartidor asignado (si sigue siendo repartidor activo). La bodega no.
- Acepta pagos en cualquier estado salvo `cancelado` (también antes de entregar). Baja el saldo y
  recalcula `estado_pago`. Devuelve el id del pago.
- Errores: `42501` rol sin permiso para cobrar; `P0002` pedido inexistente o que no puede ver;
  `P0006` pedido cancelado; `22023` método nulo, o monto nulo, ≤ 0 o mayor al saldo.

**`anular_pago(p_pago_id uuid, p_nota text) returns void`**
- Quién: solo admin. Marca el pago anulado (ver módulo 4), devuelve el monto al saldo y recalcula
  `estado_pago`.
- Errores: `P0002` pago inexistente o de un pedido que no puede ver; `42501` no es admin; `22023`
  nota nula o vacía; `P0006` ya anulado.

### Módulo 5: plataforma (solo Super Admin)

**`crear_distribuidor(p_nombre text, p_slug text, p_rubro text, p_plan_codigo text, p_documento text default null, p_telefono text default null) returns jsonb`**
- Crea el distribuidor en `prueba`, su suscripción en `prueba` por 30 días desde hoy y una invitación
  de rol `admin` vigente 7 días a nombre del Super Admin. Quien la canjea es el primer admin.
- El slug se guarda sin espacios y en minúsculas, y debe cumplir `^[a-z0-9]+(-[a-z0-9]+)*$`
  (por ejemplo `licores-del-norte`).
- Devuelve `{"distribuidor_id": "<uuid>", "invitacion_codigo": "<código>"}`.
- Errores: `42501` no es Super Admin; `22023` nombre vacío, slug vacío o sin esa forma, o plan
  inexistente o inactivo; `23505` slug repetido (sin importar mayúsculas).

**`cambiar_estado_distribuidor(p_distribuidor_id uuid, p_estado estado_distribuidor) returns void`**
- Única vía para cambiar `distribuidores.estado` (suspender, reactivar, cancelar). Suspendido o
  cancelado: `crear_pedido` rechaza pedidos nuevos (`P0003`); lo demás sigue igual (los pedidos en
  curso se terminan y se cobran).
- Errores: `42501` no es Super Admin; `22023` estado nulo; `P0002` distribuidor inexistente.

**`registrar_pago_suscripcion(p_suscripcion_id uuid, p_monto_centimos bigint, p_metodo text, p_periodo_inicio date, p_periodo_fin date, p_referencia text default null, p_nota text default null) returns uuid`**
- Registra el pago (`p_referencia` va a `referencia_externa`) y deja la suscripción en `activa` con
  ese periodo, también si estaba `vencida`. Una suscripción `cancelada` no se reactiva con un pago.
  No cambia el estado del distribuidor: eso es manual con `cambiar_estado_distribuidor`. Devuelve
  el id del pago.
- Errores: `42501` no es Super Admin; `P0002` suscripción inexistente; `22023` monto nulo o ≤ 0,
  método vacío, periodo nulo o invertido; `P0006` suscripción cancelada, o el distribuidor ya tiene
  otra suscripción vigente (en los dos casos no queda nada registrado).

`planes` se crea y edita con `insert`/`update` directos del Super Admin (no hay función).

---

## 4. Estados del pedido

Enum `EstadoPedido` en Dart (`packages/core/lib/src/models/enums.dart`):

| Estado (BD) | Dart | Significado |
|---|---|---|
| `recibido` | `recibido` | Creado por la bodega o a su nombre |
| `confirmado` | `confirmado` | El distribuidor lo acepta |
| `en_camino` | `enCamino` | Va hacia la bodega (solo despacho `reparto`) |
| `listo_recojo` | `listoRecojo` | Listo para recoger (solo despacho `recojo`) |
| `entregado` | `entregado` | Final. Baja el stock físico |
| `cancelado` | `cancelado` | Final. Libera el stock comprometido |

Transiciones válidas (cualquier otra lanza `P0006`), impuestas por `cambiar_estado_pedido`:

```
recibido     → confirmado | cancelado
confirmado   → en_camino (solo reparto) | listo_recojo (solo recojo) | cancelado
en_camino    → entregado | cancelado
listo_recojo → entregado | cancelado
entregado, cancelado → (finales)
```

| Quién | Qué puede hacer |
|---|---|
| Admin, vendedor | Todas las transiciones |
| Repartidor | `confirmado → en_camino` y `en_camino → entregado`, solo en pedidos asignados a él |
| Cliente | `recibido → cancelado`, solo en pedidos de su bodega |

Cancelar exige nota y que no haya pagos sin anular. Un pedido de `reparto` necesita repartidor
asignado solo para que el repartidor lo mueva; admin y vendedor pueden moverlo sin él.

Otros estados:
- `estado_pago`: `pendiente` (saldo = total), `parcial`, `pagado` (saldo 0). Un pedido de total 0
  nace `pagado`. Después solo lo mueven `registrar_pago` y `anular_pago`.
- `estado_membresia`: `activa` ↔ `suspendida`, con `cambiar_estado_membresia`. La bodega de una
  membresía de cliente se cambia con `cambiar_bodega_membresia`.
- `estado_distribuidor`: libre entre sus valores, con `cambiar_estado_distribuidor`.
- `estado_suscripcion`: nace `prueba` (`crear_distribuidor`); `registrar_pago_suscripcion` la deja
  `activa`. `vencida` y `cancelada` no las pone ninguna función todavía.

---

## 5. Modelos (Dart, `packages/core`)

Todos son `freezed` + `json_serializable`, con campos en camelCase en Dart y JSON en `snake_case`
(`packages/core/build.yaml`). Cada modelo lleva todas las columnas de su tabla de la sección 2. El
dinero es `int` en céntimos. `toJson()` no es un payload de escritura: las escrituras pasan por las
funciones de la sección 3 o mandan solo las columnas que cambian.

| Modelo | Tabla |
|---|---|
| `Perfil` | `perfiles` |
| `Distribuidor` | `distribuidores` (`nombreVisible`: el nombre del tema si está, si no el legal) |
| `ConfigTema` | JSON `config_tema` de `distribuidores` (sección 6) |
| `Membresia` | `membresias` |
| `Invitacion` | `invitaciones` |
| `ClienteNegocio` | `clientes_negocio` |
| `ListaPrecios` | `listas_precios` |
| `PrecioLista` | `precios_lista` |
| `Categoria` | `categorias` |
| `Producto` | `productos` |
| `Presentacion` | `presentaciones` |
| `PrecioVolumen` | `precios_volumen` |
| `MovimientoStock` | `movimientos_stock` |
| `Pedido` | `pedidos` |
| `PedidoItem` | `pedido_items` |
| `PedidoEvento` | `pedido_eventos` |
| `Pago` | `pagos` |
| `Plan` | `planes` |
| `Suscripcion` | `suscripciones` |
| `PagoSuscripcion` | `pagos_suscripcion` |

Enums (`enums.dart`, con `@JsonValue` del valor de la BD): `EstadoPedido`, `RolMembresia`,
`EstadoMembresia`, `EstadoDistribuidor`, `TipoMovimientoStock`, `DespachoPedido`,
`CondicionPago`, `MetodoPago`, `EstadoPago`, `EstadoSuscripcion`.

Se eliminaron `Usuario`, `TipoPresentacion` y `RolUsuario` (el panel ya usa `RolMembresia`,
sección 7).

### Relaciones embebidas

Las relaciones son campos opcionales: solo vienen llenas si la consulta las embebe con el alias
del nombre del campo en `snake_case`.

| Modelo | Campos | `select` |
|---|---|---|
| `Membresia` | `distribuidor`, `clienteNegocio` | `'*, distribuidor:distribuidores(*), cliente_negocio:clientes_negocio(*)'` |
| `Pedido` | `items`, `eventos` | `'*, items:pedido_items(*), eventos:pedido_eventos(*)'` |
| `Producto` | `presentaciones` (con sus `preciosVolumen`) | `'*, presentaciones(*, precios_volumen(*))'` |
| `Presentacion` | `preciosVolumen` | `'*, precios_volumen(*)'` |

---

## 6. JSON de tema (`config_tema`)

Se guarda en `distribuidores.config_tema` (jsonb):

```json
{
  "nombre": "Licores del Norte",
  "logo_url": "https://.../logo.png",
  "color_primario": "#1F3A5F",
  "color_secundario": "#F2A900"
}
```

- Colores en `#RRGGBB`. `ThemeBuilder.desde()` rechaza otros formatos con `FormatException`.
- `logo_url` puede ser `null`.

---

## 7. Rol del usuario en la app

**El rol ya no está en `app_metadata`.** Una persona puede tener una membresía con un rol distinto
en cada distribuidor, y la BD valida contra la tabla `membresias`, no contra el token.

Tras iniciar sesión, la app:
1. Lee `membresias` con su distribuidor **filtrando por `perfil_id = auth.uid()`**, y se queda
   con las de `estado = 'activa'`. El filtro es obligatorio: la política `membresias_select`
   también devuelve todas las membresías de los distribuidores donde la persona es `admin` o
   `vendedor` (y todas a un super admin). Sin el filtro, el panel podría tomar como propia la
   membresía de otra persona.
2. Si hay varias, la persona elige el distribuidor; la app lo guarda como distribuidor activo.
3. Redirige según el rol de esa membresía (`cliente`, `repartidor`, o `admin`/`vendedor` en el
   panel). Sin membresías útiles, la app móvil muestra una pantalla sin acceso (con reintentar y
   cerrar sesión), **sin opción de canje**: el canje de un código (`canjear_invitacion`) está
   pendiente de construir en la app.

Una membresía de cliente cuya bodega está inactiva sigue en `estado = 'activa'` en `membresias`,
pero **no cuenta**: el distribuidor, el catálogo y los pedidos dejan de ser visibles y
`crear_pedido` lanza `42501`. La app debe tratar un `42501` (o una lectura vacía del distribuidor)
en catálogo o pedidos como "sin acceso a este distribuidor", no como un error genérico.

Estado de cada app:

- **`app_movil`: ya lo implementa.** Lee las membresías de la persona con
  `select('*, distribuidor:distribuidores(*), cliente_negocio:clientes_negocio(*)')` filtrando por
  `perfil_id`, y se queda con las **membresías útiles**: `estado = 'activa'`, rol `cliente` o
  `repartidor` (`admin` y `vendedor` usan el panel) y distribuidor visible. Ninguna → pantalla
  "Sin acceso en la app" (reintentar y cerrar sesión); una → entra directo; varias → elige en
  `seleccion-distribuidor`. La preferencia se guarda en **`user_metadata.distribuidor_activo`**
  (`auth.updateUser`) y se usa si sigue entre las útiles. Es solo una preferencia: la BD valida la
  membresía en cada consulta. Mientras lee muestra una pantalla de espera; si falla, una de error
  con reintentar y cerrar sesión. Cliente → catálogo; repartidor → su zona.
- **`user_metadata.distribuidor_activo` es la preferencia de la app móvil.** El panel debe usar
  su propia clave (por ejemplo `distribuidor_activo_panel`): una persona puede ser `admin` en un
  distribuidor y `cliente` en otro, y cada app elige entre membresías distintas.
- **`panel_web`: ya lo implementa** (`features/sesion`, mismo diseño que la app móvil). Entra con
  correo y contraseña. Lee las membresías de la persona con
  `select('*, distribuidor:distribuidores(*)')` filtrando por `perfil_id`, y se queda con las
  **útiles para el panel**: `estado = 'activa'`, rol `admin` o `vendedor` y distribuidor visible.
  Ninguna → pantalla "Sin acceso al panel"; una → entra directo; varias → elige en
  `seleccion-distribuidor`. La preferencia se guarda en
  **`user_metadata.distribuidor_activo_panel`**. La sección Configuración es solo del `admin`.
  Si el distribuidor está `suspendido` o `cancelado`, el panel sigue abierto y muestra un aviso
  fijo (la BD ya rechaza los pedidos nuevos con `P0003`).

---

## 8. Seed de desarrollo

`supabase/seed.sql` (solo local y DEV). Se carga como rol de servicio con `supabase db reset` y al
final de `bash supabase/tests/run.sh`. Ids fijos con prefijo `5eed0000-0000-0000-`. Las cuentas se
insertan en `auth.users` **sin contraseña**: sirven para RLS y permisos, no para iniciar sesión.

- Planes `basico` (9900) y `pro` (19900), con valores de ejemplo.
- **Licores del Norte (demo)**, `activo`, suscripción `activa` (plan `pro`), con el tema de la
  sección 6:
  - 5 categorías (ron, pisco, whisky, cerveza, vino), 30 productos con `unidad_base` `botella` y
    stock entre 60 y 600 (registrado también como movimiento `ingreso`).
  - Presentaciones "Botella" (factor 1), "Caja x12" (factor 12) y "Six pack" (factor 6, solo
    cervezas): 66 en total. Precio por volumen en cada botella desde 12 unidades.
  - Lista "Mayorista" con 10 presentaciones (botella y caja del primer producto de cada categoría).
  - Personal: `admin.licores@`, `vendedor.licores@`, `repartidor.licores@` (`example.com`).
  - Bodegas: El Roble (crédito, límite 500000, plazo 15 días; Rosa Quispe), San Martín (lista
    Mayorista; Martín Salas), La Esquina (contado; Lucía Paredes).
- **ElectroMayor (demo)**, `activo`, suscripción `activa` (plan `basico`):
  - 2 categorías, 8 productos con `unidad_base` `unidad`, presentaciones "Unidad" (factor 1) y
    "Pack x10" (factor 10).
  - `admin.electro@`; tiendas Tienda Centro (Rosa Quispe) y Tienda Norte (Jorge Huamán).
- **Rosa Quispe** (`bodega.roble@example.com`) es cliente en los dos distribuidores.
- Super Admin: `superadmin@example.com`.
- Invitaciones vigentes 30 días, rol `cliente`: `DEMA2345` (Licores, La Esquina) y `DEMA6789`
  (ElectroMayor, Tienda Norte).
- Sin pedidos: se crean desde la app.

### Cómo correr las pruebas

Solo requiere PostgreSQL (16 o 17) y `psql`; no hace falta Docker ni Supabase CLI. Un shim simula
lo mínimo de Supabase (`auth.users`, `auth.uid()`, `storage`, roles y la publicación de Realtime).

```bash
bash supabase/tests/run.sh       # todas las migraciones, todas las pruebas y el seed
bash supabase/tests/run.sh 3     # solo las primeras 3 migraciones y sus pruebas
dart run melos run db:test       # lo mismo que la primera línea
```

Usa `PGHOST`, `PGPORT`, `PGUSER` (def. `postgres`) y `PGPASSWORD` del entorno. Crea y borra la
base `distribuidores_test` (y `distribuidores_test_concurrencia` y
`distribuidores_test_concurrencia_pagos` para las pruebas de concurrencia).
Termina con `TODO OK`. En CI corre en el job `sql` de `.github/workflows/ci.yml`.

| Archivo | Cubre |
|---|---|
| `00_infra_test.sql` | El shim y las ayudas de prueba |
| `01_identidad_test.sql` | Aislamiento, invitaciones, canje y freno, membresías |
| `02_catalogo_test.sql` | Catálogo, stock, listas, Storage, protección de bodegas |
| `03_pedidos_test.sql` | `crear_pedido`, precio, crédito, idempotencia, estados, repartidor |
| `03_concurrencia_test.sh` | Dos pedidos simultáneos por el mismo stock; reintento simultáneo; permiso perdido mientras se espera el bloqueo de la bodega |
| `04_cobros_test.sql` | Pagos, anulación, cancelación con pagos |
| `04_concurrencia_pagos_test.sh` | Dos pagos simultáneos por el saldo completo; pago y cancelación simultáneos, en los dos órdenes |
| `05_plataforma_test.sql` | Planes, suscripciones, alta y estado de distribuidores |
| `06_ajustes_test.sql` | Catálogo visible para cliente y repartidor; `crear_pedido` con la categoría inactiva; `execute` de `public.rls_auto_enable()` si existe |
| `06_seguridad_test.sql` | Barrido: RLS, grants, `search_path`, políticas, montos `bigint` |

---

## 9. Pendientes

- [ ] Proveedor de SMS para el login por celular (decisión de Hz3r y Jair103; tiene costo por
      mensaje). No cambia el esquema.
- [ ] Valores reales de los planes (nombres, precios, topes).
- [x] Validación sobre Supabase real: el trigger sobre `auth.users`, las políticas de
      `storage.objects`, el bucket `catalogo` y la publicación de Realtime, verificados en DEV el
      2026-11-22.
- [ ] Validación sobre Supabase real (rama de Supabase o `supabase start`): la carga del seed con
      `supabase db reset` y los asesores de seguridad y rendimiento.
