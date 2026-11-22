# Modelos Dart y acceso por membresías en la app móvil: plan de implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Poner `packages/core` al día con el esquema real y hacer que la app móvil redirija según las membresías de la persona, sin tocar `apps/panel_web`.

**Architecture:** Un modelo `freezed` por tabla del contrato. En la app móvil, una feature `sesion` con lógica pura de acceso (probada sin Flutter), un repositorio que lee `membresias` y un provider de Riverpod que alimenta la redirección de `go_router`.

**Tech Stack:** Flutter 3.50 / Dart 3.14, freezed, json_serializable, Riverpod con riverpod_generator, go_router, supabase_flutter.

**Spec:** `docs/superpowers/specs/2026-11-22-modelos-dart-y-acceso-movil-design.md`. Fuente de verdad de tablas, columnas y enums: `supabase/migrations/*.sql` y `docs/contrato.md` sección 2.

## Global Constraints

- **No modificar ningún archivo bajo `apps/panel_web/`.** Debe seguir compilando y pasando sus pruebas tal cual.
- No modificar nada bajo `supabase/`. No tocar ningún proyecto remoto de Supabase.
- Stack fijo: no agregar dependencias a ningún `pubspec.yaml`.
- Modelos: `freezed` + `json_serializable`, campos en camelCase; el JSON es snake_case automático (`packages/core/build.yaml`). Enums con `@JsonValue('<valor de la BD>')`.
- Dinero: `int` en céntimos. Nunca `double`.
- `core` no importa nada de una app, ni `go_router`. Las apps no se importan entre sí.
- Capas en la app: `presentation` no importa `data` directamente; `domain` no importa Flutter ni Supabase.
- Providers con `@riverpod` (generados), no escritos a mano.
- Los archivos generados (`*.g.dart`, `*.freezed.dart`) se regeneran con `dart run melos run gen` y **se commitean**.
- Antes de cada commit, desde la raíz: `dart format apps packages`, `dart run melos run analyze` (sin errores, avisos ni infos) y `dart run melos run test` (en verde, incluidas las pruebas de `panel_web`).
- Textos de interfaz y comentarios en español. Conventional Commits.

## Review Focus

1. **Fila de la BD con columnas nulas que el modelo marca como obligatorias.** `Producto.categoriaId`, `Pedido.repartidorId`, `Pedido.metodoPago`, `Pedido.venceEn`, `ClienteNegocio.limiteCreditoCentimos` y similares llegan `null`; `fromJson` no debe fallar. (Tarea 1: prueba por modelo con los opcionales en `null`.)
2. **Valor de enum desconocido** (la BD agrega un estado nuevo antes de actualizar la app). `fromJson` lanza un error claro de `json_serializable`; no se silencia. (Tarea 1: una prueba que lo fije.)
3. **Membresía activa cuyo distribuidor llega `null`** (bodega desactivada: RLS oculta el distribuidor). No cuenta como acceso. (Tarea 2.)
4. **Preferencia guardada que ya no es válida** (membresía suspendida o distribuidor que ya no está). Se ignora y se vuelve a elegir. (Tarea 2.)
5. **Persona con membresías solo de `admin` o `vendedor`** que abre la app móvil. Va a "sin distribuidor", no a una pantalla en blanco ni a un bucle de redirección. (Tarea 2.)

## Estructura de archivos

| Archivo | Responsabilidad |
|---|---|
| `packages/core/lib/src/models/enums.dart` | Todos los enums de la BD |
| `packages/core/lib/src/models/<modelo>.dart` | Un modelo por tabla |
| `packages/core/lib/core.dart` | Exporta los modelos |
| `packages/core/test/modelos_test.dart` | Pruebas de serialización |
| `apps/app_movil/lib/src/features/sesion/domain/acceso.dart` | Estado de acceso y reglas puras |
| `apps/app_movil/lib/src/features/sesion/domain/membresias_repositorio.dart` | Contrato del repositorio |
| `apps/app_movil/lib/src/features/sesion/data/membresias_repositorio_supabase.dart` | Lectura de `membresias` y preferencia |
| `apps/app_movil/lib/src/features/sesion/presentation/control_acceso.dart` | Provider del estado de acceso |
| `apps/app_movil/lib/src/features/sesion/presentation/*_screen.dart` | Espera y error |
| `apps/app_movil/lib/src/router/destino.dart` | Redirección pura |

---

### Task 1: Modelos y enums de `packages/core`

**Files:**
- Modify: `packages/core/lib/src/models/enums.dart`, `distribuidor.dart`, `cliente_negocio.dart`, `categoria.dart`, `producto.dart`, `presentacion.dart`, `precio_volumen.dart`, `pedido.dart`, `pedido_item.dart`, `packages/core/lib/core.dart`, `packages/core/test/core_test.dart`
- Create (en `packages/core/lib/src/models/`): `perfil.dart`, `membresia.dart`, `invitacion.dart`, `lista_precios.dart`, `precio_lista.dart`, `movimiento_stock.dart`, `pedido_evento.dart`, `pago.dart`, `plan.dart`, `suscripcion.dart`, `pago_suscripcion.dart`; y `packages/core/test/modelos_test.dart`
- Delete: `packages/core/lib/src/models/usuario.dart` y sus generados
- Modify (mínimo para compilar, la lógica cambia en la Tarea 2): nada en apps. `RolUsuario` se conserva, así que las apps siguen compilando.

**Interfaces:**
- Produces (enums en `enums.dart`, nombre Dart ← valores de la BD):
  - `EstadoPedido` (sin cambios)
  - `RolUsuario` (sin cambios; agregar el comentario `/// Solo lo usa apps/panel_web hasta que migre a [RolMembresia].`)
  - `RolMembresia`: `admin`, `vendedor`, `repartidor`, `cliente`
  - `EstadoMembresia`: `activa`, `suspendida`
  - `EstadoDistribuidor`: `prueba`, `activo`, `suspendido`, `cancelado`
  - `TipoMovimientoStock`: `ingreso`, `ajuste`, `reserva`, `liberacion`, `salida`
  - `DespachoPedido`: `recojo`, `reparto`
  - `CondicionPago`: `contado`, `credito`
  - `MetodoPago`: `efectivo`, `billeteraDigital` ← `billetera_digital`, `transferencia`
  - `EstadoPago`: `pendiente`, `parcial`, `pagado`
  - `EstadoSuscripcion`: `prueba`, `activa`, `vencida`, `cancelada`
  - Se elimina `TipoPresentacion`.
- Produces (modelos; clase ← tabla): `Distribuidor` ← `distribuidores`, `Perfil` ← `perfiles`, `Membresia` ← `membresias`, `ClienteNegocio` ← `clientes_negocio`, `Invitacion` ← `invitaciones`, `Categoria` ← `categorias`, `Producto` ← `productos`, `Presentacion` ← `presentaciones`, `PrecioVolumen` ← `precios_volumen`, `ListaPrecios` ← `listas_precios`, `PrecioLista` ← `precios_lista`, `MovimientoStock` ← `movimientos_stock`, `Pedido` ← `pedidos`, `PedidoItem` ← `pedido_items`, `PedidoEvento` ← `pedido_eventos`, `Pago` ← `pagos`, `Plan` ← `planes`, `Suscripcion` ← `suscripciones`, `PagoSuscripcion` ← `pagos_suscripcion`. `ConfigTema` no cambia.
- Reglas para derivar los campos de cada modelo (leer las columnas en las seis migraciones, contando los `alter table ... add column` posteriores):
  - Un campo por cada columna de la tabla, en camelCase, **excepto `actualizado_en`**.
  - `uuid` y `text` → `String`; `integer` y `bigint` → `int`; `boolean` → `bool`; `timestamptz` y `date` → `DateTime`; enum de la BD → su enum Dart; `jsonb` → `Map<String, dynamic>`, salvo `distribuidores.config_tema` → `ConfigTema`.
  - Columna `not null` → `required`. Columna que admite nulo → tipo anulable sin `required`.
  - Relaciones embebidas, opcionales y fuera de las columnas:
    - `Membresia.distribuidor` (`Distribuidor?`) y `Membresia.clienteNegocio` (`ClienteNegocio?`)
    - `Producto.presentaciones` (`@Default(<Presentacion>[])`)
    - `Presentacion.preciosVolumen` (`@Default(<PrecioVolumen>[])`)
    - `Pedido.items` (`@Default(<PedidoItem>[])`, se conserva el nombre actual) y `Pedido.eventos` (`@Default(<PedidoEvento>[])`)
  - Getters de conveniencia (en una `extension` o con `const Modelo._()`): `Producto.stockDisponible` = `stockFisico - stockComprometido`; `Presentacion.disponiblePara(Producto p)` = `p.stockDisponible ~/ factor`; `Membresia.estaActiva`.
- En el comentario de clase de `Membresia`, `Producto`, `Presentacion` y `Pedido`, documentar el alias de consulta que llena cada relación, por ejemplo: `select('*, distribuidor:distribuidores(*), cliente_negocio:clientes_negocio(*)')`.

- [ ] **Step 1: Escribir `packages/core/test/modelos_test.dart`**

Una prueba por modelo, con este patrón. El JSON de cada prueba reproduce una fila real: mismas claves que las columnas de la tabla, incluida `actualizado_en` (que el modelo debe ignorar sin fallar).

```dart
test('Pedido lee una fila de contado recién creada', () {
  final pedido = Pedido.fromJson(<String, dynamic>{
    'id': 'p1', 'distribuidor_id': 'd1', 'numero': 7, 'cliente_id': 'c1',
    'creado_por': 'u1', 'repartidor_id': null, 'estado': 'recibido',
    'despacho': 'reparto', 'direccion_entrega': 'Av. Uno 123', 'nota_cliente': null,
    'total_centimos': 32604, 'condicion_pago': 'contado', 'metodo_pago': null,
    'estado_pago': 'pendiente', 'saldo_pendiente_centimos': 32604,
    'plazo_credito_dias': null, 'vence_en': null, 'motivo_cancelacion': null,
    'clave_idempotencia': 'k1', 'entregado_en': null,
    'creado_en': '2026-11-22T18:00:00Z', 'actualizado_en': '2026-11-22T18:00:00Z',
  });
  expect(pedido.numero, 7);
  expect(pedido.despacho, DespachoPedido.reparto);
  expect(pedido.condicionPago, CondicionPago.contado);
  expect(pedido.metodoPago, isNull);
  expect(pedido.saldoPendienteCentimos, 32604);
  expect(pedido.items, isEmpty);
  expect(pedido.toJson()['estado_pago'], 'pendiente');
});
```

Casos obligatorios además de uno por modelo:
- `Pedido` a crédito entregado: `plazo_credito_dias` 15, `vence_en` `'2026-12-07'` → `venceEn` es `DateTime(2026, 12, 7)`.
- `Pedido` con `items` y `eventos` embebidos (2 y 1 elementos).
- `Membresia` de cliente con `distribuidor` y `cliente_negocio` embebidos; y otra con `distribuidor: null` → `distribuidor` es `null`.
- `Producto` con `categoria_id: null`, `stock_fisico` 120, `stock_comprometido` 30 → `stockDisponible` 90; con una `Presentacion` de `factor` 12 → `disponiblePara` 7.
- `ClienteNegocio` sin crédito (`limite_credito_centimos` y `plazo_credito_dias` nulos) y con crédito (500000, 15).
- `Distribuidor` con `config_tema` del contrato (sección 6) → `configTema.colorPrimario` es `'#1F3A5F'`.
- `MetodoPago.billeteraDigital` ↔ `'billetera_digital'` en ida y vuelta.
- Valor de enum desconocido: `Pedido.fromJson` con `'estado': 'devuelto'` lanza (`throwsA(isA<ArgumentError>())` o el tipo que lance `json_serializable`; fija el que sea).

Actualizar `core_test.dart`: quitar las pruebas de `Usuario` y de `TipoPresentacion`, y adaptar las de `Producto`, `Pedido` y `Presentacion` a los campos nuevos (o moverlas a `modelos_test.dart`).

- [ ] **Step 2: Verificar que falla**

Run: `cd packages/core && flutter test`
Expected: FAIL de compilación (`DespachoPedido` y los modelos nuevos no existen).

- [ ] **Step 3: Escribir enums y modelos, actualizar `core.dart`, borrar `usuario.dart` y sus generados**

- [ ] **Step 4: Generar y verificar**

Run (desde la raíz): `dart run melos run gen && dart format apps packages && dart run melos run analyze && dart run melos run test`
Expected: generación sin conflictos; análisis sin ningún aviso en los tres paquetes; pruebas en verde en `core`, `app_movil` y `panel_web`. `git status --short apps/panel_web` no muestra nada.

- [ ] **Step 5: Commit**

```bash
git add packages/core
git commit -m "feat(core): modelos y enums del contrato nuevo"
```

---

### Task 2: Acceso por membresías en la app móvil (lógica pura y datos)

**Files:**
- Create: `apps/app_movil/lib/src/features/sesion/domain/acceso.dart`, `apps/app_movil/lib/src/features/sesion/domain/membresias_repositorio.dart`, `apps/app_movil/lib/src/features/sesion/data/membresias_repositorio_supabase.dart`, `apps/app_movil/test/sesion/acceso_test.dart`
- Modify: `apps/app_movil/lib/src/router/destino.dart`, `apps/app_movil/lib/src/config/rutas.dart`, `apps/app_movil/test/router/destino_test.dart`
- Modify (mínimo para compilar; el cableado real es la Tarea 3): `apps/app_movil/lib/src/router/app_router.dart` pasa un `Acceso` provisional calculado solo con la sesión (`SinSesion` o `Cargando`).

**Interfaces:**
- Consumes: `Membresia`, `RolMembresia`, `EstadoMembresia`, `Distribuidor` de `core`.
- Produces (`acceso.dart`, sin imports de Flutter ni Supabase):

```dart
sealed class Acceso { const Acceso(); }
final class SinSesion extends Acceso { const SinSesion(); }
final class Cargando extends Acceso { const Cargando(); }
final class ErrorAcceso extends Acceso { const ErrorAcceso(this.mensaje); final String mensaje; }
final class ConAcceso extends Acceso {
  const ConAcceso({required this.membresias, required this.activa});
  /// Solo las membresías útiles para la app móvil.
  final List<Membresia> membresias;
  /// `null` si hay varias y aún no se eligió.
  final Membresia? activa;
}

/// Membresías que dan acceso en la app móvil: estado activa, rol cliente o
/// repartidor, y distribuidor visible (no nulo). Conserva el orden de entrada.
List<Membresia> membresiasUtiles(List<Membresia> todas);

/// La membresía con la que se entra. Si hay una sola, esa. Si hay varias, la
/// del distribuidor preferido cuando sigue entre las útiles; si no, null.
Membresia? elegirActiva(List<Membresia> utiles, String? distribuidorPreferido);

/// Arma el acceso a partir de todas las membresías de la persona.
ConAcceso accesoDesde(List<Membresia> todas, String? distribuidorPreferido);
```

- Produces (`membresias_repositorio.dart`):

```dart
abstract interface class MembresiasRepositorio {
  /// Membresías de la persona con sesión, con su distribuidor embebido.
  Future<List<Membresia>> listarMias();
  /// Distribuidor preferido guardado en la cuenta, o null.
  String? distribuidorPreferido();
  Future<void> guardarDistribuidorPreferido(String distribuidorId);
}
```

- Produces (`membresias_repositorio_supabase.dart`): `class MembresiasRepositorioSupabase implements MembresiasRepositorio`, que recibe un `SupabaseClient`. `listarMias`: `from('membresias').select('*, distribuidor:distribuidores(*), cliente_negocio:clientes_negocio(*)').eq('perfil_id', <uid>)` (el filtro por `perfil_id` es necesario: un admin vería las de todo su distribuidor). Preferencia: lee `currentUser.userMetadata['distribuidor_activo']` (solo si es `String`) y guarda con `auth.updateUser(UserAttributes(data: {'distribuidor_activo': id}))`.
- Produces (`rutas.dart`): agregar `static const String cargando = '/cargando';` y `static const String errorAcceso = '/error-acceso';`. Las demás rutas no cambian.
- Produces (`destino.dart`):

```dart
String? destinoRedireccion({required Acceso acceso, required String ubicacion});
```

Reglas, en este orden:

| Acceso | Regla |
|---|---|
| `SinSesion` | a `auth`, salvo que ya esté ahí |
| `Cargando` | a `cargando`, salvo que ya esté ahí |
| `ErrorAcceso` | a `errorAcceso`, salvo que ya esté ahí |
| `ConAcceso` sin membresías | a `sinRol`, salvo que ya esté ahí |
| `ConAcceso` con `activa == null` | a `seleccionDistribuidor`, salvo que ya esté ahí |
| `ConAcceso` con activa, ubicación en `auth`, `cargando`, `errorAcceso` o `sinRol` | al inicio del rol: `cliente` → `catalogo`, `repartidor` → `repartidor` |
| activa, ubicación `seleccionDistribuidor` | se permite solo si hay más de una membresía; si hay una, al inicio del rol |
| activa de rol `repartidor`, fuera de su zona | a `repartidor`, salvo `perfil` (permitido) |
| activa de rol `cliente`, dentro de la zona de repartidor | a `catalogo` |
| cualquier otro caso | `null` |

- [ ] **Step 1: Escribir `acceso_test.dart` y reescribir `destino_test.dart`**

`acceso_test.dart` (usa un constructor auxiliar de `Membresia` dentro de la prueba):
- `membresiasUtiles` descarta: `suspendida`; rol `admin`; rol `vendedor`; `distribuidor == null`. Conserva `cliente` y `repartidor` activas, en el orden de entrada.
- `elegirActiva`: lista vacía → `null`; una → esa, aunque la preferencia sea otra; dos sin preferencia → `null`; dos con preferencia que coincide → esa; dos con preferencia de un distribuidor que no está → `null`.
- `accesoDesde`: solo membresías de `admin` → `ConAcceso` con `membresias` vacía y `activa` nula.

`destino_test.dart`: una prueba por fila de la tabla de reglas, más estas:
- Ninguna combinación produce un bucle: para cada `Acceso` de prueba y cada ruta de `AppRutas`, aplicar `destinoRedireccion` sobre su propio resultado devuelve `null` (el destino es estable).
- Repartidor en `perfil` → `null`. Repartidor en `catalogo` → `repartidor`. Cliente en `repartidor` → `catalogo`.
- Con dos membresías y activa elegida, `seleccionDistribuidor` → `null`.

- [ ] **Step 2: Verificar que falla**

Run: `cd apps/app_movil && flutter test`
Expected: FAIL de compilación (`Acceso` no existe).

- [ ] **Step 3: Implementar `acceso.dart`, el contrato y la implementación del repositorio, `rutas.dart`, `destino.dart`, y el ajuste mínimo de `app_router.dart`**

- [ ] **Step 4: Verificar**

Run (desde la raíz): `dart run melos run gen && dart format apps packages && dart run melos run analyze && dart run melos run test`
Expected: sin avisos; pruebas en verde en los tres paquetes; `git status --short apps/panel_web` vacío.

- [ ] **Step 5: Commit**

```bash
git add apps/app_movil
git commit -m "feat(app_movil): reglas de acceso por membresías"
```

---

### Task 3: Cableado del acceso en la app móvil y documentación

**Files:**
- Create: `apps/app_movil/lib/src/features/sesion/presentation/control_acceso.dart` (y su generado), `apps/app_movil/lib/src/features/sesion/presentation/cargando_screen.dart`, `apps/app_movil/lib/src/features/sesion/presentation/error_acceso_screen.dart`, `apps/app_movil/test/sesion/control_acceso_test.dart`, `apps/app_movil/test/sesion/seleccion_distribuidor_test.dart`
- Modify: `apps/app_movil/lib/src/router/app_router.dart` (y su generado), `apps/app_movil/lib/src/features/seleccion_distribuidor/presentation/seleccion_distribuidor_screen.dart`, `apps/app_movil/lib/src/shared/widgets/sin_rol_screen.dart`, `docs/contrato.md` (secciones 5 y 7)

**Interfaces:**
- Consumes: todo lo de la Tarea 2.
- Produces (`control_acceso.dart`):

```dart
/// Repositorio inyectable; las pruebas lo reemplazan con un doble.
@Riverpod(keepAlive: true)
MembresiasRepositorio membresiasRepositorio(Ref ref);

/// Flujo de "hay sesión / no hay sesión"; las pruebas lo reemplazan.
@Riverpod(keepAlive: true)
Stream<bool> haySesion(Ref ref);

@Riverpod(keepAlive: true)
class ControlAcceso extends _$ControlAcceso {
  @override
  Acceso build();                       // SinSesion, o Cargando y dispara la carga
  Future<void> recargar();              // vuelve a leer membresías
  Future<void> elegirDistribuidor(String distribuidorId); // guarda preferencia y actualiza `activa`
}
```

  Comportamiento: sin sesión → `SinSesion`. Al aparecer una sesión → `Cargando`, luego `accesoDesde(...)` o `ErrorAcceso` si la lectura lanza. Si llega el resultado de una carga antigua después de cerrar sesión, se descarta. `elegirDistribuidor` con un distribuidor que no está entre las membresías útiles no cambia nada.
- `app_router.dart`: `redirect` usa `ref.read(controlAccesoProvider)`; `refreshListenable` es un `ChangeNotifier` que notifica cuando cambia `controlAccesoProvider` (con `ref.listen`). Agregar las rutas `cargando` y `errorAcceso`. Quitar `_rolDe` y todo uso de `RolUsuario` y de `app_metadata`.
- `SeleccionDistribuidorScreen`: lista las membresías útiles (nombre del distribuidor y rol legible: "Cliente" o "Repartidor"); al tocar una llama `elegirDistribuidor`. Marca la activa.
- `SinRolScreen`: título "Sin distribuidor"; texto: "Tu cuenta todavía no está vinculada a ningún distribuidor. Pídele a tu distribuidor un código de invitación." Conserva el botón de cerrar sesión. (El canje del código es otra tarea.)
- `ErrorAccesoScreen`: mensaje, botón "Reintentar" (`recargar`) y "Cerrar sesión". `CargandoScreen`: indicador de progreso centrado.
- `docs/contrato.md` sección 5: quitar el aviso de DESACTUALIZADA; listar los modelos y enums que existen; decir que `RolUsuario` queda solo para `panel_web` hasta que migre; documentar los alias de consulta de las relaciones embebidas. Sección 7: agregar que la app móvil ya lo implementa (membresías útiles, preferencia en `user_metadata.distribuidor_activo`) y que el panel web aún lee `app_metadata.rol` y está pendiente de migrar.

- [ ] **Step 1: Escribir las pruebas**

`control_acceso_test.dart` (con `ProviderContainer`, un doble de `MembresiasRepositorio` y un `StreamController<bool>` para `haySesionProvider`):
- Sin sesión → `SinSesion`.
- Sesión con una membresía de cliente → pasa por `Cargando` y termina en `ConAcceso` con `activa` esa.
- Sesión y el repositorio lanza → `ErrorAcceso`; tras `recargar()` con el repositorio ya sano → `ConAcceso`.
- Dos membresías sin preferencia → `activa` nula; tras `elegirDistribuidor('d2')` → `activa` es la de `d2` y el doble registró `guardarDistribuidorPreferido('d2')`.
- `elegirDistribuidor('no-existe')` → no cambia el estado ni guarda nada.
- Se cierra la sesión mientras la carga está pendiente → queda en `SinSesion` aunque la carga termine después.

`seleccion_distribuidor_test.dart` (widget, con el provider sobreescrito): muestra los dos nombres de distribuidor; al tocar el segundo se llama `elegirDistribuidor` con su id.

- [ ] **Step 2: Verificar que falla**

Run: `cd apps/app_movil && flutter test`
Expected: FAIL de compilación (`controlAccesoProvider` no existe).

- [ ] **Step 3: Implementar provider, pantallas y router; actualizar `docs/contrato.md`**

- [ ] **Step 4: Verificar**

Run (desde la raíz): `dart run melos run gen && dart format apps packages && dart run melos run analyze && dart run melos run test && (cd apps/panel_web && flutter build web --dart-define-from-file=../../env/dev.example.json)`
Expected: sin avisos; pruebas en verde en los tres paquetes; el panel compila; `git status --short apps/panel_web` vacío; `grep -rn "RolUsuario\|appMetadata" apps/app_movil/lib` no devuelve nada.

- [ ] **Step 5: Commit**

```bash
git add apps/app_movil docs/contrato.md
git commit -m "feat(app_movil): redirección por membresías y selección de distribuidor"
```
