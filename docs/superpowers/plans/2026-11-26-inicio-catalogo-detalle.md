# Inicio, catálogo y detalle de producto: plan de implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Que una bodega con sesión vea su inicio, recorra el catálogo de su distribuidor y abra el detalle de un producto, con precios y disponibilidad reales y un carrito en memoria.

**Architecture:** Lógica pura y probada para precios, disponibilidad, filtros y resúmenes (`domain`); repositorios finos de lectura sobre Supabase (`data`); providers de Riverpod y pantallas (`presentation`). La barra inferior es un `StatefulShellRoute` de go_router solo para el rol cliente.

**Tech Stack:** Flutter 3.50 / Dart 3.14, Riverpod con riverpod_generator, go_router, supabase_flutter, modelos de `packages/core`.

**Spec:** `docs/superpowers/specs/2026-11-26-inicio-catalogo-detalle-design.md`. Contrato de datos: `docs/contrato.md` (tablas `categorias`, `productos`, `presentaciones`, `precios_volumen`, `listas_precios`, `precios_lista`, `pedidos`, `pedido_items`; regla de precio).

## Global Constraints

- Rama de trabajo: `app_movil`. Commits locales; el coordinador hace el push.
- **No modificar nada bajo `apps/panel_web/` ni bajo `supabase/`.** No tocar ningún proyecto remoto de Supabase.
- No agregar dependencias a ningún `pubspec.yaml`. No agregar imágenes ni fuentes: solo iconos de Material.
- Capas: `presentation` no importa `data` salvo en el archivo de providers que construye los repositorios; `domain` sin Flutter ni Supabase. Providers con `@riverpod`; generados regenerados y commiteados.
- Dinero: `int` en céntimos; se muestra con `Dinero.formatear` de `core` (`S/ 62.90`). Nunca `double` para montos.
- La app **solo lee**: en este plan no se llama ninguna función que escriba en la base.
- Los modelos de `core` se usan para leer; si falta un campo o una relación, se agrega en `packages/core` con su prueba (afecta también a `panel_web`: sus pruebas deben seguir pasando).
- Ninguna prueba toca `Supabase.instance`.
- Colores y estilo: `apps/app_movil/lib/src/shared/tema_app.dart` (`ColoresApp`, `radioApp`). Textos en español.
- Antes de cada commit, desde la raíz (`export PATH=/opt/flutter/bin:$PATH`): `dart run melos run gen && dart format apps packages && dart run melos run analyze && dart run melos run test`; `git status --short apps/panel_web supabase` vacío.
- Conventional Commits.

## Review Focus

1. **Producto sin presentaciones activas, o sin categoría.** No rompe la lista: el primero no se muestra en el catálogo; el segundo aparece bajo "Todos" y no bajo ninguna categoría. (Tarea 1 y 2.)
2. **Stock físico menor que el factor** (quedan 5 botellas y la presentación es caja x12): disponible 0, "Agotado", no se puede agregar. (Tarea 1.)
3. **Cantidad en el detalle por encima de lo disponible**, o cambio de presentación con una cantidad ya elegida: la cantidad se limita al disponible de la presentación actual y nunca baja de 1 mientras haya disponible. (Tarea 2.)
4. **Precio de lista mayor que el base, o precio por volumen mayor que el de lista.** Se cobra el menor de los dos que correspondan, igual que la base; la tabla de tramos nunca muestra un precio que no se cobraría. (Tarea 1.)
5. **Cuenta nueva sin pedidos, y primer día del mes** (mes actual sin compras, o mes anterior en cero): sin división entre cero; la variación no se muestra cuando no hay con qué comparar. (Tarea 3.)

## Estructura de archivos

| Archivo | Responsabilidad |
|---|---|
| `apps/app_movil/lib/src/features/catalogo/domain/` | Precio, disponibilidad, filtros y orden; contrato del repositorio |
| `apps/app_movil/lib/src/features/catalogo/data/` | Lectura del catálogo |
| `apps/app_movil/lib/src/features/catalogo/presentation/` | Providers, catálogo, detalle, tarjeta de producto |
| `apps/app_movil/lib/src/features/carrito/domain/carrito.dart` y `presentation/carrito_providers.dart` | Carrito en memoria |
| `apps/app_movil/lib/src/features/inicio/` | Resumen de compras y pantalla de inicio |
| `apps/app_movil/lib/src/shared/widgets/barra_cliente.dart` | Barra inferior |

---

### Task 1: Dominio y datos del catálogo, y carrito en memoria

**Files:**
- Create: en `apps/app_movil/lib/src/features/catalogo/`: `domain/precios.dart`, `domain/disponibilidad.dart`, `domain/catalogo.dart`, `domain/filtros_catalogo.dart`, `domain/catalogo_repositorio.dart`, `data/catalogo_repositorio_supabase.dart`, `presentation/catalogo_providers.dart`; `apps/app_movil/lib/src/features/carrito/domain/carrito.dart`, `apps/app_movil/lib/src/features/carrito/presentation/carrito_providers.dart`; `apps/app_movil/lib/src/features/sesion/presentation/sesion_activa.dart`; pruebas en `apps/app_movil/test/catalogo/` y `apps/app_movil/test/carrito/`
- Modify (solo si falta): `packages/core/lib/src/models/` y `packages/core/test/modelos_test.dart`

**Interfaces:**
- Consumes: `Producto`, `Presentacion`, `PrecioVolumen`, `PrecioLista`, `Categoria`, `Membresia`, `ClienteNegocio` de `core`; `controlAccesoProvider`.
- Produces (`sesion_activa.dart`): `@riverpod Membresia? membresiaActiva(Ref ref)`: la membresía activa de `ConAcceso`, o `null`. De ella salen `distribuidorId`, `distribuidor` y `clienteNegocio` (con `listaPreciosId`).
- Produces (`precios.dart`, puro):

```dart
/// Precio unitario que se cobra por [cantidad] de una presentación: parte de
/// [precioLista] si no es null, o de [precioBase]; el tramo por volumen es
/// el de mayor cantidadMinima que no supere [cantidad]; se cobra el menor.
int precioUnitario({required int precioBase, int? precioLista,
    required List<PrecioVolumen> preciosVolumen, required int cantidad});

class TramoPrecio {
  const TramoPrecio({required this.desde, this.hasta, required this.precioCentimos});
  final int desde;      // cantidad mínima del tramo
  final int? hasta;     // null en el último
  final int precioCentimos;
}

/// Tramos para mostrar, empezando en 1. Tramos contiguos con el mismo
/// precio efectivo se funden en uno. Sin precios por volumen: un solo tramo.
List<TramoPrecio> tramosDePrecio({required int precioBase, int? precioLista,
    required List<PrecioVolumen> preciosVolumen});
```

- Produces (`disponibilidad.dart`, puro): `int disponiblePresentacion({required int stockFisico, required int stockComprometido, required int factor})` = `max(0, (stockFisico - stockComprometido) ~/ factor)`.
- Produces (`catalogo.dart`, puro):

```dart
class Catalogo {
  const Catalogo({required this.categorias, required this.productos, required this.preciosLista});
  final List<Categoria> categorias;      // activas, por `orden` y nombre
  final List<Producto> productos;        // con `presentaciones` y sus `preciosVolumen`
  final Map<String, int> preciosLista;   // presentacionId → céntimos, de la lista del cliente
}

class ProductoEnCatalogo {
  final Producto producto;
  final Presentacion principal;          // activa de menor `orden` (desempate por nombre)
  final int disponible;                  // de la principal
  final int precioCentimos;              // de la principal, para cantidad 1
  bool get agotado => disponible <= 0;
}

/// Productos con al menos una presentación activa. Orden inicial: por nombre.
List<ProductoEnCatalogo> productosDelCatalogo(Catalogo catalogo);
/// Presentaciones activas del producto, por `orden` y nombre.
List<Presentacion> presentacionesActivas(Producto producto);
```

- Produces (`filtros_catalogo.dart`, puro):

```dart
enum OrdenCatalogo { nombre, precioMenor, precioMayor }
class FiltrosCatalogo {
  const FiltrosCatalogo({this.categoriaId, this.marca, this.busqueda = '', this.orden = OrdenCatalogo.nombre});
  ...copyWith con forma de limpiar categoriaId y marca...
}
/// Filtra por categoría, marca y texto (en nombre o marca, sin distinguir
/// mayúsculas ni tildes) y ordena.
List<ProductoEnCatalogo> aplicarFiltros(List<ProductoEnCatalogo> productos, FiltrosCatalogo filtros);
/// Marcas distintas no vacías, ordenadas.
List<String> marcasDisponibles(List<ProductoEnCatalogo> productos);
```

- Produces (`catalogo_repositorio.dart`): `abstract interface class CatalogoRepositorio { Future<Catalogo> cargar({required String distribuidorId, String? listaPreciosId}); }`
- Produces (`catalogo_repositorio_supabase.dart`): tres lecturas filtradas por `distribuidor_id`: `categorias` (`activo = true`); `productos` con `select('*, presentaciones(*, precios_volumen(*))')` y `activo = true`; y, solo si hay `listaPreciosId`, `precios_lista` de esa lista. Sin lógica de negocio.
- Produces (`catalogo_providers.dart`): `catalogoRepositorioProvider`; `@riverpod Future<Catalogo> catalogo(Ref ref)` (según `membresiaActivaProvider`; se recarga al cambiar de distribuidor; con `ref.invalidate` se refresca); `@riverpod class FiltrosCatalogoActuales` (estado `FiltrosCatalogo`).
- Produces (`carrito.dart`, puro): `class Carrito` inmutable con `Map<String, int> cantidades` (presentacionId → cantidad), `agregar(String presentacionId, int cantidad, {required int disponible})` (suma y limita al disponible; con disponible 0 no cambia), `fijar`, `quitar`, `vaciar`, `int get lineas`, `int cantidadDe(String presentacionId)`.
- Produces (`carrito_providers.dart`): `@Riverpod(keepAlive: true) class CarritoActual` con estado `Carrito`; se vacía cuando cambia `membresiaActivaProvider` (otro distribuidor o cierre de sesión).

- [ ] **Step 1: Escribir las pruebas**

`precios_test.dart`:
- Base 6290, sin lista ni volumen, cantidad 1 → 6290.
- Base 6290, volumen [10→6050, 50→5800]: cantidad 9 → 6290; 10 → 6050; 49 → 6050; 50 → 5800.
- Lista 6000, base 6290, volumen [10→6050]: cantidad 10 → 6000 (el menor).
- Lista 7000, base 6290: cantidad 1 → 7000 (la lista sustituye al base; no se toma el menor entre lista y base).
- Volumen mayor que el base (base 6290, [10→6500]): cantidad 10 → 6290.
- `tramosDePrecio` con base 6290 y volumen [10→6050, 50→5800] → `[1–9: 6290, 10–49: 6050, 50–: 5800]`.
- `tramosDePrecio` con lista 6000 y volumen [10→6050, 50→5800] → `[1–49: 6000, 50–: 5800]` (tramos de igual precio fundidos).
- `tramosDePrecio` sin volumen → un tramo `1–` con el precio de partida.
- Volumen con `cantidadMinima` 1 (base 6290, [1→6000]) → un tramo `1–: 6000`.

`disponibilidad_test.dart`: (120, 30, 12) → 7; (5, 0, 12) → 0; (12, 0, 12) → 1; (10, 10, 1) → 0; comprometido mayor que físico → 0.

`catalogo_test.dart`: producto sin presentaciones activas no aparece; la principal es la de menor `orden`; producto sin categoría aparece; `precioCentimos` usa la lista cuando hay.

`filtros_catalogo_test.dart`: por categoría; por marca; búsqueda "ron" encuentra "Ron Añejo" y la marca "RON CARTAVIO"; búsqueda "anejo" encuentra "Añejo"; orden por precio menor y mayor; `marcasDisponibles` sin vacíos ni repetidos.

`carrito_test.dart`: agregar 1 dos veces → 2; agregar por encima del disponible → queda en el disponible; disponible 0 → no cambia; `fijar` 0 quita la línea; `lineas` cuenta presentaciones distintas.

`carrito_providers_test.dart` (con `ProviderContainer`): al cambiar la membresía activa de un distribuidor a otro, el carrito queda vacío.

- [ ] **Step 2: Verificar que falla**

Run: `cd apps/app_movil && flutter test test/catalogo test/carrito`
Expected: FAIL de compilación.

- [ ] **Step 3: Implementar**

- [ ] **Step 4: Verificar** con el comando completo de Global Constraints.
Expected: sin avisos; pruebas en verde en los tres paquetes; `apps/panel_web` y `supabase` sin cambios.

- [ ] **Step 5: Commit**

```bash
git add apps/app_movil packages/core
git commit -m "feat(app_movil): dominio del catálogo, precios y carrito en memoria"
```

---

### Task 2: Barra inferior, catálogo y detalle de producto

**Files:**
- Create: `apps/app_movil/lib/src/shared/widgets/barra_cliente.dart`; en `apps/app_movil/lib/src/features/catalogo/presentation/`: `detalle_producto_screen.dart`, `widgets/tarjeta_producto.dart`, `widgets/imagen_producto.dart`; pruebas en `apps/app_movil/test/catalogo/` y `apps/app_movil/test/shared/`
- Modify: `apps/app_movil/lib/src/features/catalogo/presentation/catalogo_screen.dart`, `apps/app_movil/lib/src/config/rutas.dart`, `apps/app_movil/lib/src/router/app_router.dart`, `apps/app_movil/lib/src/router/destino.dart`, `apps/app_movil/test/router/destino_test.dart`

**Interfaces:**
- Consumes: todo lo de la Tarea 1.
- Produces (`rutas.dart`): `inicio = '/inicio'`; `static String detalleProducto(String id) => '/catalogo/producto/$id'`.
- Produces (`destino.dart`): el inicio del rol cliente pasa a ser `inicio`. Todo lo que hoy manda al cliente a `catalogo` como destino por defecto manda a `inicio`. `inicio` es zona de cliente (un repartidor ahí va a su zona). La prueba de estabilidad sigue cubriendo todas las rutas, incluida una de detalle.
- Router: `StatefulShellRoute.indexedStack` con cinco ramas, en este orden: `inicio`, `catalogo` (con la subruta de detalle, que se abre **por encima** de la barra, sin barra inferior), `carrito`, `pedidos`, `perfil`. En esta tarea `inicio` usa `PantallaPlaceholder` (la Tarea 3 lo reemplaza); `carrito`, `pedidos` y `perfil` conservan sus marcadores actuales.
- **Barra inferior** (`BarraCliente`): cinco destinos con icono y texto: "Inicio", "Catálogo", "Carrito", "Pedidos", "Perfil". El activo en azul con fondo `azulSuave` en forma de píldora detrás del icono. "Carrito" lleva una insignia roja con `carritoActualProvider.lineas` cuando es mayor que 0 (9+ si pasa de 9).
- **Catálogo**:
  - Encabezado "Catálogo" y un botón de lupa que muestra u oculta un campo de búsqueda ("Buscar productos o marcas").
  - Fila de chips desplazable: "Todos" y una por categoría; la elegida, rellena en azul con texto blanco.
  - Fila de controles: "Ordenar" (Nombre, Precio: menor a mayor, Precio: mayor a menor) y "Marca" (Todas y cada marca), como menús; a la derecha, "N productos".
  - Cuadrícula de dos columnas de `TarjetaProducto`: imagen (o un recuadro `azulSuave` con el icono de caja si no hay `imagenUrl` o falla la carga), nombre (hasta 2 líneas), nombre de la presentación principal, disponibilidad ("340 disponibles" en `exito` con un punto, o "Agotado" en `error`), precio (`S/ 62.90`) y debajo "por <presentación en minúsculas>", y un botón cuadrado azul "+" que agrega 1 de la principal al carrito. Agotado: tarjeta atenuada y "+" deshabilitado. Si el carrito ya tiene todo el disponible de esa presentación, "+" deshabilitado.
  - Tocar la tarjeta abre el detalle.
  - Estados: cargando (indicador); error ("No pudimos cargar el catálogo." con "Reintentar"); catálogo vacío ("Tu distribuidor todavía no publicó productos."); sin resultados ("No encontramos productos con esos filtros." con "Quitar filtros"). Deslizar hacia abajo recarga.
- **Detalle** (`DetalleProductoScreen(productoId)`): botón atrás, título "Detalle" y un icono de carrito con la misma insignia, que lleva a `carrito`.
  - Imagen grande; línea "<CATEGORÍA> · <MARCA>" en azul y mayúsculas (se omite lo que falte); nombre; presentación y disponibilidad ("340 disponibles" o "Agotado").
  - Si el producto tiene más de una presentación activa: selector de chips con sus nombres.
  - Tarjeta "Precio mayorista por volumen" con una fila por `TramoPrecio`: a la izquierda "1 – 9", "10 – 49", "50 o más" (un solo tramo: "Desde 1"); a la derecha el precio. La fila del tramo que corresponde a la cantidad elegida va resaltada. Se omite la tarjeta si hay un solo tramo.
  - "Descripción" y el texto, si existe.
  - Barra inferior fija: botones "−" y "+" con la cantidad en medio, y un botón "Agregar · S/ 188.70" con `cantidad × precioUnitario(cantidad)`. La cantidad va de 1 al disponible menos lo que ya está en el carrito de esa presentación; al cambiar de presentación se ajusta a ese rango. Sin disponible: botón "Agotado" deshabilitado. Al agregar: suma al carrito, muestra "Agregado al carrito" y vuelve la cantidad a 1.
  - Producto que no existe o ya no está visible: "Este producto ya no está disponible." con "Volver al catálogo".

- [ ] **Step 1: Escribir las pruebas**

`destino_test.dart`: cliente activo en `auth`, `bienvenida`, `registro`, `cargando` → `inicio`; cliente en `repartidor` → `inicio`; repartidor en `inicio` y en una ruta de detalle → `repartidor`; `inicio` y el detalle sin sesión → `bienvenida`; estabilidad sobre todas las rutas.
`barra_cliente_test.dart`: muestra los cinco textos; con 3 líneas en el carrito muestra "3"; con 12, "9+"; con 0 no hay insignia.
`catalogo_screen_test.dart` (repositorio doble con 4 productos, uno agotado, en 2 categorías y 2 marcas): muestra "4 productos"; tocar una categoría deja solo los suyos; buscar filtra; ordenar por precio cambia el orden; "+" suma una línea al carrito y la segunda vez no agrega otra línea sino cantidad; "+" del agotado no hace nada; el error muestra "Reintentar" y al tocarlo vuelve a cargar; sin resultados muestra "Quitar filtros".
`detalle_producto_test.dart`: muestra los tramos "1 – 9", "10 – 49", "50 o más" con sus precios; con cantidad 3 el botón dice "Agregar · S/ 188.70" (3 × 6290); al subir a 10 el botón usa 6050 y se resalta el segundo tramo; "+" no pasa del disponible; cambiar a una presentación con menos disponible ajusta la cantidad; agregar deja la cantidad en el carrito y muestra "Agregado al carrito"; producto inexistente muestra el mensaje y el botón.

- [ ] **Step 2: Verificar que falla**

Run: `cd apps/app_movil && flutter test`
Expected: FAIL de compilación.

- [ ] **Step 3: Implementar**

- [ ] **Step 4: Verificar** con el comando completo de Global Constraints.

- [ ] **Step 5: Commit**

```bash
git add apps/app_movil
git commit -m "feat(app_movil): barra de navegación, catálogo y detalle de producto"
```

---

### Task 3: Pantalla de inicio

**Files:**
- Create: en `apps/app_movil/lib/src/features/inicio/`: `domain/resumen_compras.dart`, `domain/pedidos_resumen_repositorio.dart`, `data/pedidos_resumen_repositorio_supabase.dart`, `presentation/inicio_providers.dart`, `presentation/inicio_screen.dart`; pruebas en `apps/app_movil/test/inicio/`
- Modify: `apps/app_movil/lib/src/router/app_router.dart` (la rama `inicio` usa `InicioScreen`), `docs/contrato.md` (sección 7: qué lee la app móvil en inicio y catálogo, y que el carrito es solo memoria)

**Interfaces:**
- Consumes: Tareas 1 y 2; `Pedido`, `PedidoItem`, `EstadoPedido` de `core`.
- Produces (`resumen_compras.dart`, puro):

```dart
class ResumenCompras {
  final Pedido? ultimoPedido;            // el más reciente, de cualquier estado
  final int compradoEsteMesCentimos;     // suma de totales, sin cancelados
  final int? variacionPorcentaje;        // contra el mes anterior; null si ese mes fue 0
  final List<String> productosMasPedidos; // ids, de más a menos unidades, máximo 6
}
/// [ahora] se pasa como parámetro para poder probar; los meses se cuentan
/// en la zona horaria [desfaseZona] del distribuidor (America/Lima = UTC−5).
ResumenCompras resumirCompras(List<Pedido> pedidos, {required DateTime ahora, Duration desfaseZona = const Duration(hours: -5)});
String etiquetaEstado(EstadoPedido estado); // "Recibido", "Confirmado", "En camino", "Listo para recoger", "Entregado", "Cancelado"
```

  `variacionPorcentaje` = `((esteMes - mesAnterior) * 100 / mesAnterior)` redondeado. "Más pedidos": suma de `cantidad × factor` por `productoId` en pedidos no cancelados de los últimos 90 días.
- Produces (`pedidos_resumen_repositorio.dart`): `Future<List<Pedido>> recientes({required String distribuidorId, required String clienteId, required DateTime desde})`, con sus líneas embebidas (`select('*, items:pedido_items(*)')`), filtrado por `distribuidor_id`, `cliente_id` y `creado_en >= desde`, del más reciente al más antiguo. `desde` es 90 días atrás o el inicio del mes anterior, lo que sea más antiguo.
- **Inicio** (`InicioScreen`), de arriba abajo:
  - Avatar redondo `marino` con icono de tienda; línea pequeña con el nombre visible del distribuidor; "Hola, <nombre del negocio>"; a la derecha, botón redondo con la campana (sin acción).
  - Campo "Buscar productos o marcas": al enviar, va al catálogo con esa búsqueda puesta.
  - Dos tarjetas lado a lado: "Último pedido" (`#<número>` y una píldora con `etiquetaEstado`; toca → rama Pedidos) y "Comprado este mes" (`S/ 2,340.00` y, si hay variación, "▲ 8% vs <mes anterior>" en `exito` o "▼ 8% vs <mes anterior>" en `error`, con el nombre del mes en español en minúsculas). Sin pedidos: "Aún no tienes pedidos" y `S/ 0.00` sin variación.
  - "Categorías" con "Ver todo" (→ catálogo sin filtros) y una fila desplazable de categorías (icono de etiqueta en un recuadro y el nombre); tocar una va al catálogo con esa categoría elegida.
  - "Lo que más pides" con "Ver todo" (→ catálogo) y una fila desplazable de `TarjetaProducto` de esos productos (los que sigan en el catálogo). Sin historial: la sección se titula "Productos" y muestra los primeros 6 del catálogo.
  - Estados: cargando; error con "Reintentar"; deslizar hacia abajo recarga catálogo y resumen.
  - **No hay cartel** de pedido mínimo, hora de corte ni promociones (ver spec, decisión 1).

- [ ] **Step 1: Escribir las pruebas**

`resumen_compras_test.dart` (con `ahora` = 2026-11-26 15:00 UTC):
- Sin pedidos → `ultimoPedido` null, 0, variación null, lista vacía.
- Pedidos de noviembre por 100000 y 134000 y uno cancelado de 50000; octubre por 216667 → este mes 234000; variación 8.
- Mes anterior en 0 → variación null. Este mes 0 y anterior 100000 → −100.
- Un pedido creado el 2026-11-01 03:00 UTC cuenta para **octubre** (en Lima es 31 de octubre, 22:00).
- Más pedidos: A con 2 cajas de factor 12 y B con 30 unidades de factor 1 → `[B, A]`; un pedido de hace 100 días no cuenta; uno cancelado tampoco.
- `etiquetaEstado` para los seis estados.

`inicio_screen_test.dart` (dobles): muestra "Hola, Bodega Don Pepe" y el distribuidor; con pedidos muestra `#1042`, "En camino", "S/ 2,340.00" y "▲ 8% vs octubre"; sin pedidos muestra "Aún no tienes pedidos" y no hay variación; no existe ningún texto "Pedido mínimo"; tocar una categoría abre el catálogo con ese chip elegido; enviar una búsqueda abre el catálogo con ese texto; "Lo que más pides" muestra los productos en el orden del resumen; el error muestra "Reintentar".

- [ ] **Step 2: Verificar que falla**

Run: `cd apps/app_movil && flutter test test/inicio`
Expected: FAIL de compilación.

- [ ] **Step 3: Implementar; actualizar `docs/contrato.md`**

- [ ] **Step 4: Verificar** con el comando completo de Global Constraints, más `grep -rn "PantallaPlaceholder" apps/app_movil/lib/src/features/inicio apps/app_movil/lib/src/features/catalogo` sin resultados.

- [ ] **Step 5: Commit**

```bash
git add apps/app_movil docs/contrato.md
git commit -m "feat(app_movil): pantalla de inicio con resumen de compras"
```
