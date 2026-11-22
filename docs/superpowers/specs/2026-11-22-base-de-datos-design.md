# Diseño de la base de datos completa

> **Estado: aprobado por Hz3r el 2026-11-22; pendiente de aprobación de Jair103** (incluye el
> traspaso de `supabase/`).
> Nada de esto está aplicado a DEV ni PROD.

Fecha: 2026-11-22

## 1. Intención

La plataforma es un SaaS de pedidos B2B: una sola infraestructura y una sola app móvil sirven a
muchos distribuidores. Cada distribuidor tiene su catálogo, sus precios, sus clientes (bodegas o
tiendas) y sus pedidos, aislados de los demás. El piloto es un distribuidor de licores, pero el
esquema debe servir igual para electrónica, abarrotes u otro rubro.

El esquema borrador actual (`supabase/migrations/20261117120000_esquema_inicial.sql`) solo cubre
catálogo y pedidos para un distribuidor por usuario. Este diseño lo reemplaza por uno completo,
para no tener que rehacer tablas en uso cuando lleguen planes, crédito o varios distribuidores
por cuenta.

**Por qué ahora:** DEV está vacío (sin tablas ni migraciones aplicadas). Es el único momento en
que rediseñar no cuesta una migración de datos.

## 2. Objetivos, no-objetivos y anti-objetivos

**Objetivos**

- Aislamiento total entre distribuidores, impuesto por la base de datos (RLS), no por la app.
- Una cuenta por persona, vinculable a varios distribuidores.
- Stock y dinero protegidos en la BD: ningún cliente escribe stock, precios, pedidos ni pagos
  directamente.
- Cubrir desde el día uno: plataforma (planes y suscripciones), identidad y acceso, catálogo,
  inventario, pedidos y cobros.
- Cada módulo con pruebas SQL que verifiquen reglas de negocio y aislamiento.

**No-objetivos (no se construyen en este proyecto)**

- Pasarela de pago para suscripciones. Los pagos de suscripción se registran a mano.
- Pagos en línea de pedidos. Los pagos de pedidos los registra el distribuidor o el repartidor.
- Sistema de almacenes (ubicaciones, lotes, vencimientos). Solo cantidad disponible por producto.
- Envío de notificaciones push. Solo se guarda el token del dispositivo.
- Facturación electrónica (SUNAT).
- Reportes y estadísticas. Se harán después con vistas sobre estas tablas.
- Pantallas de las apps. Este diseño es solo de base de datos y su contrato.

**Anti-objetivos (sería un fracaso aunque funcione)**

- Que un usuario de un distribuidor pueda leer o tocar datos de otro.
- Que el stock quede negativo o que dos pedidos simultáneos vendan la misma unidad.
- Que el rol o el permiso dependa de un dato que el cliente puede editar.
- Que un pedido antiguo cambie de precio o de nombre porque se editó el catálogo.

## 3. Restricciones

- Reglas de `CLAUDE.md`: cambios de BD solo por migraciones, montos en céntimos enteros, toda
  tabla de negocio con `distribuidor_id` y RLS, nombres en español y `snake_case`, fechas
  `timestamptz` en UTC, ids `uuid`.
- Solo la publishable key en el cliente.
- No se aplica nada al remoto sin revisión conjunta.
- `supabase/` pasa a ser responsabilidad de Hz3r. Hay que actualizar `.github/CODEOWNERS` y
  `CLAUDE.md` en el mismo cambio, con el visto bueno de Jair103.
- Supabase, Postgres 17.
- El login por celular con código por SMS exige contratar un proveedor de SMS en Supabase Auth
  (costo por mensaje). No cambia el esquema. Ver pendientes (sección 12).

## 4. Enfoques considerados

| Enfoque | Qué es | Costo |
|---|---|---|
| 1. Una migración grande | Todo el esquema en un archivo | Difícil de revisar y de depurar |
| **2. Diseño completo, migraciones por módulo (elegido)** | Cinco migraciones en orden, cada una con pruebas | Más archivos, pero se revisa por partes |
| 3. Solo el núcleo ahora | Identidad, catálogo y pedidos; cobros y planes después | Obliga a modificar tablas en uso más adelante |

Hz3r eligió el enfoque 2: el esquema queda completo desde el inicio y cada módulo se puede
revisar con Jair por separado.

La migración borrador actual se **reemplaza** (se borra y se escriben las nuevas). Nunca se
aplicó a ningún entorno, así que no rompe la regla de no editar migraciones aplicadas.

## 5. Decisiones tomadas por Hz3r

1. **Varios distribuidores por cuenta.** La cuenta es de la persona. Una tabla de membresías la
   vincula a cada distribuidor con un rol. Cada código de invitación agrega un vínculo.
2. **Stock por producto en unidad base.** El producto tiene un solo stock en unidades base
   (botella, unidad). Cada presentación tiene un factor (caja x12 descuenta 12). Se guardan por
   separado el stock físico y el comprometido.
3. **Cobros: contado y crédito.** Cada distribuidor decide por bodega si le da crédito. Quien no
   tiene crédito paga contra entrega.
4. **Entrega en migraciones por módulo** (enfoque 2).
5. **Pedidos a nombre de la bodega.** El admin y el vendedor pueden crear un pedido para una
   bodega de su distribuidor.

Todo lo demás en este documento es propuesta de diseño y está marcado como tal donde importa.

## 6. Esquema

Convenciones: todos los montos son `bigint` en céntimos. Todas las tablas llevan `creado_en`; las
editables llevan además `actualizado_en`, mantenido por trigger. Todas tienen RLS activo.

Dos esquemas de Postgres:

- `public`: tablas y funciones que la app llama. Expuesto en la Data API.
- `privado`: funciones auxiliares de seguridad. **No** expuesto en la Data API.

### 6.1 Módulo 1: identidad y acceso

| Tabla | Propósito | Columnas clave |
|---|---|---|
| `distribuidores` | Tenant | `nombre`, `slug` único, `rubro`, `documento` (RUC), `telefono`, `estado`, `moneda` (def. `PEN`), `zona_horaria` (def. `America/Lima`), `config_tema` jsonb |
| `perfiles` | Persona, ligada a `auth.users` | `id` = `auth.uid()`, `nombre`, `telefono`, `es_super_admin` |
| `membresias` | Vínculo persona–distribuidor | `perfil_id`, `distribuidor_id`, `rol`, `estado`, `cliente_negocio_id` |
| `clientes_negocio` | Bodega o tienda | `distribuidor_id`, `nombre_negocio`, `documento`, `direccion`, `referencia`, `telefono`, `activo` |
| `invitaciones` | Código para vincular una cuenta | `distribuidor_id`, `codigo` único, `rol`, `cliente_negocio_id`, `creada_por`, `vence_en`, `usada_por`, `usada_en`, `revocada_en` |
| `intentos_canje` | Freno a adivinar códigos | `perfil_id`, `creado_en`, `exitoso` |
| `dispositivos_push` | Token de notificaciones | `perfil_id`, `token` único, `plataforma` |

Enums:

- `estado_distribuidor`: `prueba`, `activo`, `suspendido`, `cancelado`
- `rol_membresia`: `admin`, `vendedor`, `repartidor`, `cliente`
- `estado_membresia`: `activa`, `suspendida`

Reglas:

- `membresias` es única por (`perfil_id`, `distribuidor_id`): una persona tiene un solo rol en
  cada distribuidor.
- `membresias.cliente_negocio_id` es obligatorio si el rol es `cliente` y nulo en los demás
  (restricción `check`). Varias personas pueden pertenecer a la misma bodega (dueño y empleado).
- `perfiles` se crea por trigger al insertarse la fila en `auth.users`. El teléfono se copia de
  `auth.users.phone`.
- `es_super_admin` solo se cambia desde el servidor (SQL con rol de servicio). El usuario puede
  editar de su perfil únicamente `nombre`, mediante permisos por columna.
- El rol `vendedor` (personal del distribuidor que no es dueño) es propuesta de diseño: opera
  pedidos, clientes y cobros, pero no edita catálogo, precios, personal ni la configuración del
  distribuidor.

**Invitaciones**

- Código de 8 caracteres, alfabeto sin caracteres ambiguos (sin `0`, `O`, `1`, `I`, `L`),
  generado en la BD, único en toda la plataforma. Un solo uso. Vence a los 7 días por defecto.
- Función `public.canjear_invitacion(p_codigo text) returns uuid`. En una transacción: valida
  que el código exista, no esté usado, revocado ni vencido; crea la membresía; marca la
  invitación como usada. Devuelve el id de la membresía.
- **Si el código no sirve, devuelve `null` en vez de lanzar un error.** Un error revertiría la
  transacción y con ella el registro del intento, y el freno nunca se activaría. La función
  solo lanza error si no hay sesión (`42501`) o si la cuenta está frenada (`P0005`).
- Si la persona ya tiene membresía en ese distribuidor (activa o suspendida), el canje devuelve
  `null`. Una membresía suspendida la reactiva el admin, no un código nuevo.
- Cada intento queda en `intentos_canje`. Con 5 intentos fallidos en 15 minutos, la función
  rechaza nuevos intentos de esa cuenta hasta que pase la ventana.
- Los admin crean invitaciones para cualquier rol de su distribuidor; los vendedores, solo para
  rol `cliente`. Se crean con la función `public.crear_invitacion(...)`, que genera el código.
- El primer admin de un distribuidor nuevo entra igual: el Super Admin crea el distribuidor y
  una invitación con rol `admin`.

**Funciones auxiliares de seguridad** (esquema `privado`, `security definer`, `stable`,
`search_path` fijo):

| Función | Devuelve |
|---|---|
| `privado.es_super_admin()` | `true` si el perfil actual es Super Admin |
| `privado.es_miembro(p_distribuidor uuid)` | `true` si tiene membresía activa |
| `privado.tiene_rol(p_distribuidor uuid, p_roles rol_membresia[])` | `true` si su rol está en la lista |
| `privado.mi_cliente_en(p_distribuidor uuid)` | id de su bodega en ese distribuidor, o nulo |

La seguridad se valida contra la tabla `membresias`, no contra datos del token de sesión: el
token tarda en refrescarse y una bodega que canjea un código nuevo tendría que cerrar sesión
para ver el catálogo. En las políticas, las llamadas van envueltas en `(select ...)` para que
Postgres las evalúe una vez por consulta y no por fila.

**Distribuidor activo:** la app guarda cuál distribuidor está seleccionado y lo manda como
filtro o parámetro (`distribuidor_id`). La BD nunca confía en ese valor: siempre verifica la
membresía.

### 6.2 Módulo 2: catálogo e inventario

| Tabla | Propósito | Columnas clave |
|---|---|---|
| `categorias` | Agrupa productos | `distribuidor_id`, `nombre`, `orden`, `activo` |
| `productos` | Lo que se inventaría | `distribuidor_id`, `categoria_id`, `nombre`, `descripcion`, `marca`, `sku`, `imagen_url`, `unidad_base`, `stock_fisico`, `stock_comprometido`, `activo` |
| `presentaciones` | Lo que se vende | `distribuidor_id`, `producto_id`, `nombre`, `factor`, `precio_base_centimos`, `orden`, `activo` |
| `precios_volumen` | Descuento por cantidad | `distribuidor_id`, `presentacion_id`, `cantidad_minima`, `precio_centimos` |
| `listas_precios` | Lista opcional por tipo de cliente | `distribuidor_id`, `nombre`, `activo` |
| `precios_lista` | Precio de una presentación en una lista | `distribuidor_id`, `lista_precios_id`, `presentacion_id`, `precio_centimos` |
| `movimientos_stock` | Historial de inventario | `distribuidor_id`, `producto_id`, `tipo`, `delta_fisico`, `delta_comprometido`, `pedido_id`, `hecho_por`, `nota` |

Este módulo agrega a `clientes_negocio` la columna `lista_precios_id` (nula = sin lista).

Enum `tipo_movimiento_stock`: `ingreso`, `ajuste`, `reserva`, `liberacion`, `salida`.

Reglas de stock:

- `unidad_base` es texto libre (`botella`, `unidad`, `kg`). `factor` es entero mayor a cero.
  El enum `tipo_presentacion` del borrador desaparece: cada distribuidor nombra sus
  presentaciones.
- Restricción `check`: `0 <= stock_comprometido <= stock_fisico`.
- **Disponible = `stock_fisico` − `stock_comprometido`**, en unidades base. El disponible de una
  presentación es `disponible / factor` redondeado hacia abajo. Lo calcula la app o una vista;
  no se guarda.
- Nadie escribe `stock_fisico` ni `stock_comprometido` con un `UPDATE` directo. Los permisos por
  columna lo impiden incluso al admin. Solo cambian mediante funciones:
  - `public.registrar_movimiento_stock(p_producto, p_tipo, p_cantidad, p_nota)`: solo admin,
    solo tipos `ingreso` y `ajuste`. Un ajuste que deje el físico por debajo del comprometido
    se rechaza.
  - Los tipos `reserva`, `liberacion` y `salida` los generan únicamente las funciones de
    pedidos.
- `movimientos_stock` es solo de inserción: no tiene políticas de `UPDATE` ni `DELETE`.

Reglas de precio (propuesta de diseño):

1. Precio de partida: el de `precios_lista` si la bodega tiene lista y la presentación tiene
   precio en ella; si no, `precio_base_centimos`.
2. Precio por volumen: el de mayor `cantidad_minima` que no supere la cantidad pedida, si existe.
3. Se cobra **el menor** de los dos. Así un descuento por volumen nunca perjudica a un cliente
   con lista especial.

Borrado: productos, presentaciones, categorías y bodegas se desactivan (`activo = false`), no se
borran, porque los pedidos los referencian. Las claves foráneas desde pedidos son `restrict`.

**Imágenes (Storage):** un bucket `catalogo`, de lectura pública, con rutas
`<distribuidor_id>/...`. Solo el admin de ese distribuidor sube, reemplaza o borra dentro de su
carpeta. Aquí van las fotos de productos y el logo.

### 6.3 Módulo 3: pedidos

| Tabla | Propósito | Columnas clave |
|---|---|---|
| `pedidos` | Pedido de una bodega | `distribuidor_id`, `numero`, `cliente_id`, `creado_por`, `repartidor_id`, `estado`, `despacho`, `direccion_entrega`, `nota_cliente`, `total_centimos`, `condicion_pago`, `metodo_pago`, `estado_pago`, `saldo_pendiente_centimos`, `vence_en`, `motivo_cancelacion`, `clave_idempotencia`, `entregado_en` |
| `pedido_items` | Líneas del pedido | `distribuidor_id`, `pedido_id`, `presentacion_id`, `producto_id`, `nombre_producto`, `nombre_presentacion`, `factor`, `cantidad`, `precio_unitario_centimos`, `subtotal_centimos` |
| `pedido_eventos` | Línea de tiempo | `distribuidor_id`, `pedido_id`, `estado_anterior`, `estado_nuevo`, `hecho_por`, `nota` |
| `contadores_pedido` | Correlativo por distribuidor | `distribuidor_id` (pk), `ultimo_numero` |

Enums:

- `estado_pedido`: `recibido`, `confirmado`, `en_camino`, `listo_recojo`, `entregado`, `cancelado`
- `despacho_pedido`: `recojo`, `reparto`
- `condicion_pago`: `contado`, `credito`
- `metodo_pago`: `efectivo`, `billetera_digital` (Yape, Plin), `transferencia`
- `estado_pago`: `pendiente`, `parcial`, `pagado`

Este módulo agrega a `clientes_negocio` las columnas de crédito: `credito_habilitado` (def.
`false`), `limite_credito_centimos` y `plazo_credito_dias`. Si `credito_habilitado` es `true`,
ambas son obligatorias y mayores a cero (restricción `check`): no existe el crédito sin límite.

Las columnas de pago y las reglas de crédito viven aquí, y no en el módulo de cobros, porque
`crear_pedido` las necesita. Así cada migración funciona y se prueba sin depender de una
posterior.

Reglas:

- `numero` es un correlativo por distribuidor (pedido #1, #2...), único por
  (`distribuidor_id`, `numero`).
- `pedido_items` guarda una copia del nombre, el factor y el precio del momento de la compra.
  Editar el catálogo después no altera pedidos anteriores.
- `direccion_entrega` es una copia de la dirección de la bodega al momento de pedir.
- **Nadie escribe estas tablas directamente.** No hay políticas de `INSERT`, `UPDATE` ni
  `DELETE`. Todo pasa por funciones.

**`public.crear_pedido(...)`**

```
crear_pedido(
  p_distribuidor_id uuid,
  p_items jsonb,                         -- [{"presentacion_id": "<uuid>", "cantidad": <int>}, ...]
  p_clave_idempotencia uuid,
  p_despacho despacho_pedido,            -- obligatorio
  p_condicion_pago condicion_pago,       -- obligatorio
  p_cliente_id uuid default null,        -- nulo si llama la propia bodega
  p_metodo_pago metodo_pago default null,
  p_nota text default null
) returns uuid
```

En una sola transacción:

1. Determina la bodega y verifica el permiso:
   - Si llama un **cliente**: la bodega es la de su membresía. `p_cliente_id` debe ser nulo o
     igual a la suya.
   - Si llama un **admin o vendedor**: `p_cliente_id` es obligatorio y debe ser una bodega de
     ese distribuidor. Es el pedido a nombre de la bodega (por ejemplo, tomado por teléfono).
   - Un repartidor no crea pedidos.

   En ambos casos la bodega debe estar activa y el distribuidor en estado `prueba` o `activo`.
   `pedidos.creado_por` guarda quién lo registró y `cliente_id` para quién es. Precios, lista
   y reglas de crédito se aplican igual, según la bodega y no según quién llama.
2. Si ya existe un pedido de esa bodega con la misma `clave_idempotencia`, devuelve su id sin
   crear otro. Evita pedidos duplicados cuando la app reintenta por mala señal.
3. Valida que haya ítems, que las cantidades sean mayores a cero, y que cada presentación exista,
   esté activa (igual que su producto) y sea de ese distribuidor.
4. Bloquea las filas de `productos` involucradas en orden fijo de id (`FOR UPDATE`), para evitar
   bloqueos mutuos entre pedidos simultáneos.
5. Por cada ítem: calcula unidades base (`cantidad × factor`), valida contra el disponible
   (acumulando lo ya reservado por ítems anteriores del mismo producto), calcula el precio según
   6.2, suma `stock_comprometido` y registra un movimiento `reserva`.
6. Si la condición es `credito`, aplica las reglas de crédito (abajo), con la fila de la
   bodega bloqueada.
7. Asigna el `numero`, crea el pedido en `recibido` con `saldo_pendiente_centimos` igual al
   total y `estado_pago = pendiente`, sus líneas y el primer evento.

Reglas de crédito:

- La bodega debe tener `credito_habilitado`.
- Deuda actual = suma de `saldo_pendiente_centimos` de sus pedidos a crédito no cancelados.
  Deuda actual + total del pedido nuevo no puede superar `limite_credito_centimos`.
- Si tiene algún pedido a crédito con `vence_en` anterior a hoy y saldo mayor a cero, se
  rechaza (propuesta de diseño).
- Solo el admin cambia las condiciones de crédito de una bodega.

Si algo falla, se revierte todo.

Códigos de error (se conservan los del borrador y se agregan dos):

| SQLSTATE | Caso |
|---|---|
| `42501` | No es cliente, admin ni vendedor de ese distribuidor, o la bodega indicada no le corresponde |
| `22023` | Sin ítems, cantidad ≤ 0 o parámetro inválido |
| `P0002` | Presentación inexistente, inactiva o de otro distribuidor |
| `P0001` | Stock insuficiente |
| `P0003` | Distribuidor suspendido o bodega inactiva |
| `P0004` | Crédito no habilitado, límite excedido o deuda vencida |
| `P0005` | Demasiados intentos de canje (solo `canjear_invitacion`) |
| `P0006` | Operación no válida para el estado actual: transición de pedido inválida, pago sobre pedido cancelado, pago ya anulado, cancelar con pagos activos, dejar a un distribuidor sin admin |

**`public.cambiar_estado_pedido(p_pedido uuid, p_estado estado_pedido, p_nota text)`**

Transiciones válidas (cualquier otra se rechaza):

```
recibido     → confirmado | cancelado
confirmado   → en_camino (solo reparto) | listo_recojo (solo recojo) | cancelado
en_camino    → entregado | cancelado
listo_recojo → entregado | cancelado
entregado, cancelado → (finales)
```

| Quién | Qué puede hacer |
|---|---|
| Admin, vendedor | Todas las transiciones, y crear pedidos a nombre de una bodega |
| Repartidor | `confirmado → en_camino` y `en_camino → entregado`, solo en pedidos asignados a él |
| Cliente | `recibido → cancelado`, solo en sus pedidos |

Efecto en el stock:

- `entregado`: baja `stock_fisico` y `stock_comprometido` en las unidades del pedido. Movimiento
  `salida`. Si el pedido es a crédito, fija `vence_en` = fecha de entrega +
  `plazo_credito_dias`, en la zona horaria del distribuidor.
- Entregar **no** exige que el pedido de contado esté pagado (propuesta de diseño). El
  repartidor entrega y registra el pago en el momento; si no lo registra, el pedido queda
  `entregado` con `estado_pago = pendiente` y el distribuidor lo ve como por cobrar.
- `cancelado`: baja `stock_comprometido`. Movimiento `liberacion`. Exige `motivo_cancelacion`.
  Desde el módulo 4, se rechaza si el pedido tiene pagos sin anular (primero hay que
  anularlos); ese módulo redefine la función para agregar esta validación.

Cada cambio inserta una fila en `pedido_eventos`.

**`public.asignar_repartidor(p_pedido uuid, p_repartidor uuid)`**: admin o vendedor. El
repartidor debe tener membresía activa con ese rol en el mismo distribuidor.

**Tiempo real:** `pedidos` y `pedido_eventos` se publican en Realtime para que el panel y la app
vean los cambios al instante. RLS aplica igual a esas suscripciones.

### 6.4 Módulo 4: cobros

| Tabla | Propósito | Columnas clave |
|---|---|---|
| `pagos` | Pago total o parcial de un pedido | `distribuidor_id`, `pedido_id`, `cliente_id`, `monto_centimos`, `metodo`, `referencia`, `nota`, `registrado_por`, `anulado_en`, `anulado_por` |

Reglas:

- Todo pedido, de contado o a crédito, nace con el saldo igual al total (módulo 3). La
  diferencia es solo cuándo se espera el pago.
- `public.registrar_pago(p_pedido, p_monto_centimos, p_metodo, p_referencia, p_nota)`: admin,
  vendedor, o el repartidor asignado. El monto debe ser mayor a cero y no superar el saldo.
  Baja el saldo y actualiza `estado_pago`. No se aceptan pagos en pedidos cancelados.
- `public.anular_pago(p_pago, p_nota)`: solo admin. Marca el pago como anulado y devuelve el
  monto al saldo. Los pagos nunca se borran ni se editan.
- La bodega ve sus pagos y saldos, pero no los escribe.

### 6.5 Módulo 5: plataforma

| Tabla | Propósito | Columnas clave |
|---|---|---|
| `planes` | Oferta comercial | `codigo` único, `nombre`, `precio_mensual_centimos`, `moneda`, `limites` jsonb, `activo` |
| `suscripciones` | Plan vigente de un distribuidor | `distribuidor_id`, `plan_id`, `estado`, `periodo_inicio`, `periodo_fin`, `proveedor_pago`, `referencia_externa` |
| `pagos_suscripcion` | Pago de un periodo | `distribuidor_id`, `suscripcion_id`, `monto_centimos`, `metodo`, `periodo_inicio`, `periodo_fin`, `registrado_por`, `referencia_externa`, `nota` |

Enum `estado_suscripcion`: `prueba`, `activa`, `vencida`, `cancelada`.

Reglas:

- Un distribuidor tiene a lo sumo una suscripción vigente (`prueba` o `activa`), por índice
  único parcial.
- `limites` es un JSON con topes del plan, por ejemplo
  `{"max_clientes": 50, "max_productos": 200, "max_usuarios": 3}`. En este proyecto solo se
  guardan; hacerlos cumplir queda para después.
- `proveedor_pago` y `referencia_externa` quedan nulos por ahora. Están para conectar una
  pasarela sin cambiar la tabla.
- Todo lo de este módulo lo escribe solo el Super Admin. El admin del distribuidor lee su
  suscripción, su plan y sus pagos.
- `public.crear_distribuidor(p_nombre, p_rubro, p_plan_codigo, ...)`: solo Super Admin. Crea el
  distribuidor, su suscripción en `prueba` y devuelve una invitación de rol `admin`.
- El contador de pedidos de un distribuidor lo crea `crear_pedido` la primera vez que hace
  falta, así el módulo 3 no depende del 5. En las pruebas y el seed de los módulos 1 a 4, los
  distribuidores se insertan directamente con el rol de servicio.
- Suspender es cambiar `distribuidores.estado` a `suspendido`. Efecto: `crear_pedido` rechaza
  pedidos nuevos; todo lo demás sigue legible y los pedidos en curso se pueden terminar y
  cobrar. El cambio es manual por ahora (sin tarea automática por vencimiento).

## 7. Matriz de permisos (RLS)

El Super Admin lee todo y escribe el módulo de plataforma. Las demás columnas aplican solo
dentro del distribuidor donde la persona tiene membresía activa.

| Tabla | Admin | Vendedor | Repartidor | Cliente |
|---|---|---|---|---|
| `distribuidores` | lee; edita nombre, teléfono y tema | lee | lee | lee |
| `perfiles` | lee los de su distribuidor | lee los de su distribuidor | lee los de su distribuidor | lee el suyo y el del personal de pedidos suyos |
| `membresias` | lee todas; suspende, reactiva y cambia rol de personal | lee todas | lee la suya | lee la suya |
| `clientes_negocio` | lee y escribe | lee y escribe, sin crédito ni lista | lee los de sus pedidos asignados | lee la suya |
| `invitaciones` | lee, crea y revoca | lee, crea y revoca las de rol cliente | no | no |
| `categorias`, `productos`, `presentaciones` | lee y escribe (sin stock) | lee | lee | lee solo activos |
| `precios_volumen` | lee y escribe | lee | lee | lee |
| `listas_precios`, `precios_lista` | lee y escribe | lee | no | lee solo su lista |
| `movimientos_stock` | lee | lee | no | no |
| `pedidos`, `pedido_items`, `pedido_eventos` | lee todos | lee todos | lee los asignados | lee los suyos |
| `pagos` | lee todos | lee todos | lee los de sus pedidos asignados | lee los suyos |
| `suscripciones`, `pagos_suscripcion` | lee los suyos | no | no | no |
| `planes` | lee | lee | lee | lee |
| `dispositivos_push` | cada persona gestiona solo los suyos | | | |
| `intentos_canje`, `contadores_pedido` | sin acceso directo para nadie | | | |

Reglas generales:

- Todas las políticas usan `to authenticated` más un predicado de pertenencia. `anon` no tiene
  acceso a ninguna tabla ni función.
- Toda política de `UPDATE` lleva `using` y `with check`.
- Toda función `security definer` verifica `auth.uid()` y la membresía en su cuerpo, fija
  `search_path`, y se le revoca `execute` a `public` y `anon`.
- El rol de una membresía lo cambia solo el admin, con
  `public.cambiar_rol_membresia(p_membresia, p_rol)`, y solo entre roles de personal (`admin`,
  `vendedor`, `repartidor`). No se convierte personal en cliente ni al revés. La función impide
  dejar a un distribuidor sin ningún admin activo.

## 8. Entrega

Cinco migraciones, en este orden, cada una con su archivo de pruebas en `supabase/tests/`:

| # | Migración | Pruebas mínimas |
|---|---|---|
| 1 | `identidad_y_acceso` | Aislamiento entre distribuidores; canje válido, vencido, usado y repetido; freno de intentos; nadie se vuelve Super Admin |
| 2 | `catalogo_e_inventario` | Cliente no escribe catálogo ni stock; admin no escribe stock directo; ajuste inválido rechazado; cliente solo ve su lista |
| 3 | `pedidos` | Reserva de stock; rechazo sin efectos parciales; dos presentaciones del mismo producto; regla del menor precio; idempotencia; pedido a nombre de la bodega por vendedor y rechazo para bodega ajena; transiciones válidas e inválidas; entrega y cancelación mueven stock; permisos por rol; límite de crédito; deuda vencida bloquea; distribuidor suspendido no recibe pedidos |
| 4 | `cobros` | Pago parcial y total; no pagar de más; anulación; cancelar con pagos rechazado; repartidor solo cobra pedidos asignados |
| 5 | `plataforma` | Solo Super Admin escribe; admin lee solo su suscripción; `crear_distribuidor` deja el distribuidor listo para canjear su invitación de admin |

El orden es estricto: cada migración se aplica y pasa sus pruebas sin las siguientes.

Además, en el mismo proyecto:

- Borrar la migración borrador y su prueba actual.
- Reescribir `supabase/seed.sql`: 2 distribuidores de rubros distintos (para probar aislamiento),
  con productos, presentaciones, listas, bodegas con y sin crédito, y una persona con membresía
  en ambos.
- Reescribir `docs/contrato.md` para que refleje este esquema.
- Actualizar `.github/CODEOWNERS` y `CLAUDE.md` (propiedad de `supabase/`).
- Actualizar los modelos de `packages/core` al nuevo contrato (`Perfil`, `Membresia`,
  `Invitacion`, `Pago`, etc.; `Usuario` desaparece). Afecta a las dos apps: avisar a Jair103
  antes de fusionar. Las apps hoy solo tienen pantallas de marcador, así que el impacto es bajo.
- Revisar con los asesores de seguridad y rendimiento de Supabase cuando se aplique a DEV.

**Consecuencia conocida para las apps (fuera de este proyecto):** hoy los routers de ambas apps
redirigen leyendo `app_metadata.rol` del token. Con roles por membresía eso deja de existir: la
app debe leer `membresias` tras iniciar sesión y redirigir según el distribuidor elegido. El
contrato nuevo lo documenta, pero el cambio en cada router lo hace el dueño de cada app
(`app_movil`: Hz3r; `panel_web`: Jair103).

**El plan de implementación empieza con una puerta de aprobación:** este documento aprobado por
ambos socios y el acuerdo de Jair103 sobre la propiedad de `supabase/`.

Aplicar a DEV es un paso aparte, que requiere la aprobación de ambos socios.

## 9. Lo que queda a criterio de quien lo construya

- Nombres exactos de índices, restricciones, triggers y políticas.
- Qué índices crear más allá de los obvios (claves foráneas y columnas usadas en RLS).
- Formato interno de `config_tema` (se conserva el actual) y de `limites`.
- Si el disponible por presentación se expone con una vista (`security_invoker`) o lo calcula
  la app.
- Cómo correr las pruebas SQL en local y en CI (Supabase CLI con Docker, o Postgres con un
  esquema `auth` mínimo simulado, como hace la prueba actual).
- División interna de cada migración y orden de las sentencias.
- Mensajes de error en español, siempre que se respeten los SQLSTATE de este documento.

## 10. Riesgos

- **Políticas más complejas que el borrador.** Cada consulta valida membresía. Se mitiga con
  funciones auxiliares `stable`, llamadas envueltas en `(select ...)`, e índices en `membresias`.
- **Funciones `security definer` en `public`.** Son la única vía de escritura de pedidos, stock y
  pagos, así que un descuido en una es grave. Se mitiga con la regla de la sección 7 y con
  pruebas de permiso por cada función.
- **Contención en el contador de pedidos.** Dos pedidos simultáneos del mismo distribuidor
  esperan uno al otro unos milisegundos. Aceptable para el volumen esperado.

## 11. Fuera de este documento, para después

Pasarela de pago, límites de plan obligatorios, suspensión automática por vencimiento, envío de
push, reportes, promociones y cupones, zonas de reparto, facturación electrónica.

## 12. Pendientes que no bloquean el diseño

- **Proveedor de SMS** para el login por celular (decisión de Hz3r y Jair103; tiene costo por
  mensaje). El panel web puede usar correo y contraseña. No cambia el esquema.
- Valores reales de los planes (nombres, precios, topes).
