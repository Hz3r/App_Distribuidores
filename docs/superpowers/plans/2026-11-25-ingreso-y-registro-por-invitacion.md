# Ingreso y registro por invitación en la app móvil: plan de implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Que una bodega nueva entre a la app con su código de invitación (bienvenida, código, registro) y que quien ya tiene cuenta ingrese con correo y contraseña.

**Architecture:** Una migración nueva agrega la consulta anónima de un código (con freno por dirección de red) y la función con la que la bodega completa sus datos. En la app, una feature `registro` con lógica pura probada, repositorios finos sobre Supabase y un "registro pendiente" guardado en la cuenta que se completa al haber sesión.

**Tech Stack:** PostgreSQL 17 (Supabase), Flutter 3.50 / Dart 3.14, Riverpod con riverpod_generator, go_router, supabase_flutter.

**Spec:** `docs/superpowers/specs/2026-11-25-ingreso-y-registro-por-invitacion-design.md`. Maquetas descritas en la spec. Contrato de datos: `docs/contrato.md`.

## Global Constraints

- Rama de trabajo: `app_movil`. Commits locales; el coordinador hace el push.
- **No modificar ningún archivo bajo `apps/panel_web/`.**
- Las migraciones `20261122100000` a `20261122150000` están aplicadas en DEV: **no se editan**. Todo cambio de esquema va en `supabase/migrations/20261125100000_registro_por_invitacion.sql`.
- No tocar ningún proyecto remoto de Supabase.
- No agregar dependencias a ningún `pubspec.yaml`.
- SQL: reglas de `docs/superpowers/plans/2026-11-22-base-de-datos.md` (sección Global Constraints): `search_path = ''` y nombres calificados en funciones `security definer`, `revoke execute ... from public, anon` en toda función, RLS en toda tabla, permisos explícitos. **Única excepción en todo el esquema:** `public.consultar_invitacion` se concede también a `anon`.
- Dart: capas `data / domain / presentation`; `presentation` no importa `data` salvo en el provider que construye el repositorio; `domain` sin Flutter ni Supabase. Providers con `@riverpod`. Generados (`*.g.dart`) regenerados y commiteados.
- Ninguna prueba toca `Supabase.instance`.
- Textos de interfaz en español, los de la spec y este plan tal cual.
- Antes de cada commit con Dart, desde la raíz (`export PATH=/opt/flutter/bin:$PATH`): `dart run melos run gen && dart format apps packages && dart run melos run analyze && dart run melos run test`. Antes de cada commit con SQL: `su postgres -c "bash supabase/tests/run.sh"` termina en `TODO OK`.
- Conventional Commits.

## Review Focus

1. **Código pegado con espacios, guiones o en minúsculas** (`ab2c-d3e4 `). Se normaliza a 8 caracteres en mayúsculas antes de consultar. (Tarea 2.)
2. **Dos toques seguidos en "Crear cuenta"** o en "Continuar". No se crean dos cuentas ni se canjea dos veces; el botón queda deshabilitado mientras hay una operación en curso. (Tareas 2 y 3.)
3. **La cuenta se crea pero el canje falla** (código vencido entre la consulta y el registro, o usado por otra persona). La persona queda con sesión, ve un mensaje claro y puede escribir otro código; el pendiente no reintenta en bucle. (Tarea 3.)
4. **Correo ya registrado.** El mensaje dice que ya existe una cuenta y ofrece ingresar; no revela nada más. (Tarea 3.)
5. **Consulta frenada** (`P0005`) y **sin conexión**. Cada una con su propio mensaje; ninguna se muestra como "código inválido". (Tarea 2.)

## Estructura de archivos

| Archivo | Responsabilidad |
|---|---|
| `supabase/migrations/20261125100000_registro_por_invitacion.sql` | Consulta anónima, freno por red, completar datos de la bodega |
| `supabase/tests/07_registro_test.sql` | Pruebas de la migración |
| `apps/app_movil/lib/src/shared/tema_app.dart` | Colores y tema de las pantallas previas a tener distribuidor |
| `apps/app_movil/lib/src/features/registro/domain/` | Código, vista previa de invitación, datos y validaciones del registro, registro pendiente |
| `apps/app_movil/lib/src/features/registro/data/` | Llamadas a Supabase |
| `apps/app_movil/lib/src/features/registro/presentation/` | Bienvenida, código, registro, "revisa tu correo" |
| `apps/app_movil/lib/src/features/auth/` | Ingreso con correo y contraseña |

---

### Task 1: Migración de registro por invitación

**Files:**
- Create: `supabase/migrations/20261125100000_registro_por_invitacion.sql`, `supabase/tests/07_registro_test.sql`
- Modify: `supabase/tests/06_seguridad_test.sql` (la regla 6.3 pasa a exigir que `anon` pueda ejecutar exactamente una función: `public.consultar_invitacion(text)`), `docs/contrato.md`

**Interfaces:**
- Consumes: tablas `invitaciones`, `distribuidores`, `clientes_negocio`; `privado.mi_cliente_en(uuid)`.
- Produces:
  - Tabla `public.intentos_consulta (id, direccion_red text not null, exitoso boolean not null, creado_en)`, con RLS y sin ningún `grant`; índice por `(direccion_red, creado_en)`.
  - `public.consultar_invitacion(p_codigo text) returns jsonb`, `security definer`, concedida a `anon` y `authenticated`.
    - Normaliza con `upper(trim(...))`.
    - Dirección de red, de `current_setting('request.headers', true)::jsonb`: la cabecera `cf-connecting-ip` si existe; si no, el **último** elemento de `x-forwarded-for`; si no, `'desconocida'`. (Corregido tras la revisión: el primer elemento de `x-forwarded-for` lo controla el cliente.)
    - Antes de contar toma `pg_advisory_xact_lock` sobre esa dirección. Con 5 o más consultas fallidas de esa dirección en los últimos 15 minutos lanza `P0005`.
    - Devuelve `null` (y registra un intento fallido) si el código no existe, está usado, revocado, vencido o su bodega está inactiva. No lanza error en esos casos, para que el registro del intento no se revierta.
    - Si es canjeable registra un intento exitoso y devuelve:

```json
{
  "distribuidor_id": "<uuid>",
  "distribuidor_nombre": "<config_tema.nombre si no está vacío; si no, distribuidores.nombre>",
  "rol": "cliente",
  "negocio": {
    "nombre_negocio": "...", "documento": null, "direccion": "...",
    "referencia": null, "telefono": null
  }
}
```

    `negocio` es `null` cuando la invitación no es de rol `cliente`.
  - `public.completar_datos_negocio(p_distribuidor_id uuid, p_documento text default null, p_direccion text default null, p_referencia text default null, p_telefono text default null) returns void`, `security definer`, solo `authenticated`.
    - `42501` sin sesión o si quien llama no es cliente activo de ese distribuidor (`privado.mi_cliente_en` devuelve nulo).
    - Cada parámetro se limpia con `trim`; uno nulo o vacío no cambia su columna.
    - `documento` solo se escribe si la columna está nula o vacía; si ya tiene valor, se ignora sin error.
    - Largo máximo tras limpiar: `documento` 20, `telefono` 20, `direccion` 200, `referencia` 200; si se supera, `22023`.
    - Nunca toca `nombre_negocio`, `lista_precios_id`, las columnas de crédito ni `activo`.
- `docs/contrato.md`: agregar la tabla, las dos funciones (firma, quién, qué devuelve, errores) y, donde se afirma que `anon` no ejecuta nada, la excepción de `consultar_invitacion`.

- [ ] **Step 1: Escribir `07_registro_test.sql`** (incluye `soporte/datos_m3.sql`; crea sus invitaciones con `public.crear_invitacion` como A1). Para simular la red: `select set_config('request.headers', '{"x-forwarded-for":"10.0.0.1, 10.9.9.9"}', true);`

| Etiqueta | Actor | Acción | Esperado |
|---|---|---|---|
| 8.1 | anon, red `10.0.0.1` | `consultar_invitacion` con el código de `0b02` en minúsculas y con espacios | `distribuidor_nombre` = "Licores Demo"; `rol` = `cliente`; `negocio.nombre_negocio` = "Bodega Dos"; un intento exitoso registrado con `direccion_red` `10.0.0.1` |
| 8.2 | anon | código `'XXXXXXXX'` | `null`; un intento fallido registrado |
| 8.3 | anon | código usado, revocado, vencido, y de bodega con `activo = false` | `null` en los cuatro |
| 8.4 | anon, red `10.0.0.2` | 5 consultas de `'XXXXXXXX'` y una sexta con un código válido | las 5 dan `null`; la sexta lanza `P0005` |
| 8.5 | anon, red `10.0.0.3` | con `10.0.0.2` frenada, consulta un código válido | devuelve datos (el freno es por dirección) |
| 8.6 | anon, sin cabecera | consulta un código válido | devuelve datos; intento con `direccion_red` `desconocida` |
| 8.7 | A1 | invitación de rol `vendedor`; anon la consulta | `rol` = `vendedor`, `negocio` es `null` |
| 8.8 | servicio | distribuidor con `config_tema` `{"nombre":"Marca X"}`; anon consulta un código suyo | `distribuidor_nombre` = "Marca X" |
| 8.9 | anon | `select` de `intentos_consulta`, de `invitaciones` y de `clientes_negocio` | `42501` en las tres |
| 8.10 | C2 | `completar_datos_negocio(D1, p_documento => ' 20601234567 ', p_direccion => 'Av. Los Olivos 123', p_telefono => '987654321')` | la bodega `0b02` queda con esos tres valores ya limpios; `nombre_negocio` sin cambios |
| 8.11 | C2 | de nuevo con `p_documento => '10111111111'` | el documento sigue en `20601234567`, sin error |
| 8.12 | C2 | `p_direccion => ''` y `p_referencia => null` | dirección y referencia sin cambios |
| 8.13 | C2 | `p_direccion` de 201 caracteres | `22023` |
| 8.14 | C2 | con `D2` (donde no es cliente) | `42501` |
| 8.15 | V1, R1, anon | `completar_datos_negocio(D1, p_direccion => 'x')` | `42501` en los tres |
| 8.16 | C1 | completa datos en D1 | cambia solo la bodega `0b01`; `0b02` intacta |
| 8.17 | servicio | bodega `0b02` con `activo = false`; C2 llama | `42501` |

- [ ] **Step 2: Verificar que falla**

Run: `su postgres -c "bash supabase/tests/run.sh"`
Expected: FAIL en `8.1`, la función `consultar_invitacion` no existe.

- [ ] **Step 3: Escribir la migración; ajustar 6.3 en el barrido; actualizar `docs/contrato.md`**

- [ ] **Step 4: Verificar**

Run: `su postgres -c "bash supabase/tests/run.sh"` y `su postgres -c "bash supabase/tests/run.sh 6"`
Expected: `TODO OK` en ambos, con `OK 8.1` a `OK 8.17` en el primero y salida limpia.

- [ ] **Step 5: Commit**

```bash
git add supabase docs/contrato.md
git commit -m "feat(supabase): consulta anónima de invitación y datos de la bodega"
```

---

### Task 2: Tema, bienvenida y pantalla de código

**Files:**
- Create: `apps/app_movil/lib/src/shared/tema_app.dart`; en `apps/app_movil/lib/src/features/registro/`: `domain/codigo_invitacion.dart`, `domain/invitacion_previa.dart`, `domain/invitaciones_repositorio.dart`, `data/invitaciones_repositorio_supabase.dart`, `presentation/registro_providers.dart`, `presentation/bienvenida_screen.dart`, `presentation/codigo_screen.dart`, `presentation/widgets/casillas_codigo.dart`; pruebas en `apps/app_movil/test/registro/`
- Modify: `apps/app_movil/lib/src/config/rutas.dart`, `apps/app_movil/lib/src/router/destino.dart`, `apps/app_movil/lib/src/router/app_router.dart`, `apps/app_movil/test/router/destino_test.dart`, `apps/app_movil/lib/app.dart`

**Interfaces:**
- Consumes: `consultar_invitacion` y `canjear_invitacion` de la base; `Acceso`, `controlAccesoProvider` (`recargar`).
- Produces (`rutas.dart`): `bienvenida = '/bienvenida'`, `codigo = '/codigo'`, `registro = '/registro'`, `revisaCorreo = '/revisa-correo'`. `auth` se conserva para el ingreso.
- Produces (`destino.dart`): con `SinSesion`, las rutas `bienvenida`, `codigo`, `registro`, `revisaCorreo` y `auth` son válidas (devuelve `null`); cualquier otra va a `bienvenida`. Con `ConAcceso` y membresía activa, esas cinco rutas son "de paso" (se sale al inicio del rol), **excepto `codigo`**, que se permite con sesión para sumar otro distribuidor. Con `ConAcceso` sin membresías, `codigo` también se permite (además de `sinRol`). La ubicación inicial del router pasa a ser `bienvenida`.
- Produces (`codigo_invitacion.dart`, puro):

```dart
const largoCodigo = 8;
/// Quita espacios y guiones, pasa a mayúsculas y corta a [largoCodigo].
String normalizarCodigo(String entrada);
bool codigoCompleto(String codigo);
```

- Produces (`invitacion_previa.dart`, puro): `InvitacionPrevia { distribuidorId, distribuidorNombre, RolMembresia rol, NegocioPrevio? negocio }` y `NegocioPrevio { nombreNegocio, documento?, direccion?, referencia?, telefono? }`, con `InvitacionPrevia.desdeJson(Map<String, dynamic>)`.
- Produces (`invitaciones_repositorio.dart`):

```dart
sealed class ResultadoConsulta { const ResultadoConsulta(); }
final class CodigoValido extends ResultadoConsulta { const CodigoValido(this.invitacion); final InvitacionPrevia invitacion; }
final class CodigoNoValido extends ResultadoConsulta { const CodigoNoValido(); }
final class ConsultaFrenada extends ResultadoConsulta { const ConsultaFrenada(); }   // P0005
final class ConsultaSinConexion extends ResultadoConsulta { const ConsultaSinConexion(); }

abstract interface class InvitacionesRepositorio {
  Future<ResultadoConsulta> consultar(String codigo);
  /// Canjea con la sesión actual. true si quedó vinculada.
  Future<bool> canjear(String codigo);
}
```

- Produces (`tema_app.dart`): `ColoresApp` con `marino` (fondo de la bienvenida), `turquesa` (acento y botón "Tengo un código"), `azul` (botón principal), `azulSuave`, `texto`, `textoSuave`, `borde`, `exito`, `fondoExito`; y `ThemeData temaApp()`. `app.dart` usa `temaApp()` en lugar del tema fijo actual.
- Pantallas:
  - **Bienvenida** (fondo `marino`): marca "DistriApp"; ilustración con tres iconos y "Tu distribuidor · Tu catálogo · Tu pedido"; título "Pide a tu distribuidor en segundos"; texto "Catálogo, precios mayoristas y seguimiento de tus pedidos, solo con el código que te dio tu proveedor."; botón "Tengo un código de invitación" → `codigo`; botón "Ya tengo cuenta · Ingresar" → `auth`; pie "No hay directorio público: solo entras con el código de tu distribuidor."
  - **Código**: botón atrás; título "Ingresa tu código"; texto "Tu distribuidor te entregó un código único para vincular tu negocio con su catálogo."; 8 casillas (un solo campo de texto por debajo; admite pegar); al completar las 8 consulta sola. Estados: consultando; válido → tarjeta "Código válido" con "<distribuidor> te invita como <negocio>" (o "<distribuidor> te invita a su equipo" si no hay negocio) y botón "Continuar" habilitado; no válido → "Este código no es válido o ya fue usado."; frenada → "Demasiados intentos. Espera unos minutos y vuelve a probar."; sin conexión → "No pudimos comprobar el código. Revisa tu conexión." Pie: "¿No tienes código? Pídelo a tu distribuidor."
  - "Continuar": sin sesión → `registro`, pasando el código y la `InvitacionPrevia` (por `extra` de go_router; si `registro` se abre sin eso, vuelve a `codigo`). Con sesión → `canjear`; si devuelve `true`, `recargar()` del control de acceso; si `false`, "No pudimos vincular este código. Pide uno nuevo a tu distribuidor."
  - `registro` y `revisaCorreo` quedan en esta tarea con `PantallaPlaceholder`; la Tarea 3 las reemplaza. `auth` sigue con su marcador actual.

- [ ] **Step 1: Escribir las pruebas**

`codigo_invitacion_test.dart`: `normalizarCodigo('ab2c-d3e4 ')` → `'AB2CD3E4'`; `normalizarCodigo(' a b ')` → `'AB'`; `normalizarCodigo('ABCDEFGH23')` → `'ABCDEFGH'`; `codigoCompleto` solo con 8.
`invitacion_previa_test.dart`: `desdeJson` con el JSON del brief de la Tarea 1 (con `negocio` y con `negocio: null`).
`destino_test.dart`: `SinSesion` en cada una de las cinco rutas públicas → `null`; `SinSesion` en `catalogo` → `bienvenida`; cliente activo en `bienvenida`, `registro`, `auth`, `revisaCorreo` → `catalogo`; cliente activo en `codigo` → `null`; sin membresías en `codigo` → `null`; se mantiene la prueba de estabilidad sobre todas las rutas.
`bienvenida_screen_test.dart`: muestra los dos botones y navega a `codigo` y a `auth`.
`codigo_screen_test.dart` (repositorio doble): al escribir 8 caracteres se consulta una sola vez con el código normalizado; cada `ResultadoConsulta` muestra su texto; "Continuar" deshabilitado hasta `CodigoValido`; pegar `'ab2c-d3e4'` consulta `'AB2CD3E4'`; dos toques en "Continuar" con sesión llaman `canjear` una vez.

- [ ] **Step 2: Verificar que falla**

Run: `cd apps/app_movil && flutter test`
Expected: FAIL de compilación.

- [ ] **Step 3: Implementar**

- [ ] **Step 4: Verificar** con el comando completo de Global Constraints.
Expected: sin avisos; pruebas en verde en los tres paquetes; `git status --short apps/panel_web supabase` vacío.

- [ ] **Step 5: Commit**

```bash
git add apps/app_movil
git commit -m "feat(app_movil): bienvenida y código de invitación"
```

---

### Task 3: Registro, ingreso y registro pendiente

**Files:**
- Create: en `apps/app_movil/lib/src/features/registro/`: `domain/datos_registro.dart`, `domain/registro_pendiente.dart`, `domain/cuentas_repositorio.dart`, `data/cuentas_repositorio_supabase.dart`, `presentation/registro_screen.dart`, `presentation/revisa_correo_screen.dart`; `apps/app_movil/lib/src/features/auth/presentation/ingreso_screen.dart`; pruebas en `apps/app_movil/test/registro/` y `apps/app_movil/test/auth/`
- Modify: `apps/app_movil/lib/src/features/sesion/presentation/control_acceso.dart`, `apps/app_movil/lib/src/features/sesion/domain/membresias_repositorio.dart` y su implementación (solo si hace falta para leer o limpiar el pendiente), `apps/app_movil/lib/src/features/registro/presentation/registro_providers.dart`, `apps/app_movil/lib/src/router/app_router.dart`, `apps/app_movil/lib/src/shared/widgets/sin_rol_screen.dart` (agregar el botón "Tengo un código" → `codigo`), `docs/contrato.md` (sección 7)
- Delete: `apps/app_movil/lib/src/features/auth/presentation/auth_screen.dart` (lo reemplaza `ingreso_screen.dart`)

**Interfaces:**
- Consumes: todo lo de la Tarea 2; `completar_datos_negocio` de la base.
- Produces (`datos_registro.dart`, puro):

```dart
class DatosRegistro {
  const DatosRegistro({required this.nombreEncargado, required this.correo,
    required this.contrasena, this.documento, this.telefono, this.direccion, this.referencia});
  ...
}
/// Devuelve el mensaje de error o null si es válido.
String? validarNombre(String v);      // obligatorio, 2 a 80 caracteres
String? validarCorreo(String v);      // obligatorio, forma a@b.c
String? validarContrasena(String v);  // mínimo 8 caracteres
String? validarDocumento(String v);   // vacío, u 8 dígitos (DNI) u 11 dígitos (RUC)
String? validarTelefono(String v);    // vacío, o 9 dígitos que empiezan en 9 (se aceptan espacios y prefijo +51)
String? validarDireccion(String v);   // vacío o hasta 200 caracteres
```

  Mensajes: "Escribe tu nombre.", "Escribe un correo válido.", "La contraseña debe tener al menos 8 caracteres.", "Debe ser un DNI (8 dígitos) o un RUC (11 dígitos).", "Escribe un celular de 9 dígitos.", "La dirección es demasiado larga."
- Produces (`registro_pendiente.dart`, puro): `RegistroPendiente { codigo, documento?, direccion?, referencia?, telefono? }` con `toMetadata()` y `static RegistroPendiente? desdeMetadata(Map<String, dynamic>? userMetadata)`, bajo la clave `registro_pendiente`. Datos mal formados → `null`.
- Produces (`cuentas_repositorio.dart`):

```dart
enum ResultadoCrearCuenta { conSesion, requiereConfirmarCorreo, correoYaRegistrado, sinConexion, error }
enum ResultadoIngreso { ok, credencialesIncorrectas, correoSinConfirmar, sinConexion, error }

abstract interface class CuentasRepositorio {
  Future<ResultadoCrearCuenta> crearCuenta(DatosRegistro datos, RegistroPendiente pendiente);
  Future<ResultadoIngreso> ingresar(String correo, String contrasena);
  RegistroPendiente? pendienteActual();
  Future<void> limpiarPendiente();
  Future<void> completarDatosNegocio(String distribuidorId, RegistroPendiente pendiente);
}
```

  `crearCuenta` usa `auth.signUp(email, password, data: {'nombre': ..., 'registro_pendiente': ...})`.
- `ControlAcceso`: al cargar con sesión, **antes** de listar membresías, si hay registro pendiente: canjea el código; si el canje vincula, llama `completarDatosNegocio` con el `distribuidorId` de la membresía creada (un fallo aquí se registra y no bloquea la entrada); en todos los casos **limpia el pendiente** (un canje que no vincula no se reintenta). Si el canje no vinculó, el estado resultante lleva un aviso que la pantalla "Sin acceso" muestra: "No pudimos vincular tu código. Pide uno nuevo a tu distribuidor."
- **Registro** (pantalla): encabezado "Crea tu cuenta"; tarjeta "Te unes a <distribuidor>"; campos "Nombre del negocio" (solo lectura), "RUC o DNI" (solo lectura si la invitación ya trae documento), "Nombre del encargado", "Celular", "Dirección de entrega", "Correo", "Contraseña" (con mostrar/ocultar); casilla "Acepto términos y política de privacidad" (obligatoria); botón "Crear cuenta". Los campos de la bodega llegan con los valores de `NegocioPrevio`. Para invitaciones sin negocio (personal) se ocultan los campos de la bodega.
  - Resultados: `conSesion` → el control de acceso se encarga y el router entra; `requiereConfirmarCorreo` → `revisaCorreo`; `correoYaRegistrado` → "Ya existe una cuenta con este correo." con acción "Ingresar"; `sinConexion` → "Revisa tu conexión e inténtalo de nuevo."; `error` → "No pudimos crear tu cuenta. Inténtalo de nuevo."
- **Revisa tu correo**: "Te enviamos un enlace a <correo>. Ábrelo para confirmar tu cuenta y luego ingresa." y botón "Ir a ingresar".
- **Ingreso**: título "Ingresa a tu cuenta"; "Correo", "Contraseña", botón "Ingresar"; enlace "Tengo un código de invitación" → `codigo`. Mensajes: "Correo o contraseña incorrectos.", "Confirma tu correo antes de ingresar.", "Revisa tu conexión e inténtalo de nuevo.", "No pudimos ingresar. Inténtalo de nuevo."
- `docs/contrato.md` sección 7: la app móvil ingresa con correo y contraseña; el registro por invitación y la clave `user_metadata.registro_pendiente`.

- [ ] **Step 1: Escribir las pruebas**

`datos_registro_test.dart`: cada validador con un valor válido y los límites: nombre `'A'` inválido y `'Jo'` válido; correo `'a@b'` inválido y `'a@b.co'` válido; contraseña de 7 inválida y de 8 válida; documento `''`, `'12345678'` y `'20601234567'` válidos, `'123'` y `'2060123456A'` inválidos; teléfono `''`, `'987654321'`, `'+51 987 654 321'` válidos, `'12345'` y `'887654321'` inválidos.
`registro_pendiente_test.dart`: ida y vuelta por `toMetadata`/`desdeMetadata`; `desdeMetadata(null)`, sin la clave, y con la clave en un tipo equivocado → `null`.
`control_acceso_test.dart` (dobles): con pendiente y canje que vincula → se llama `canjear` una vez, luego `completarDatosNegocio` con el distribuidor correcto, luego `limpiarPendiente`, y el estado final es `ConAcceso` con esa membresía; con canje que no vincula → `limpiarPendiente` igual, sin `completarDatosNegocio`, estado con el aviso; con `completarDatosNegocio` que lanza → se entra igual y se limpia; sin pendiente → no se llama nada de eso; una recarga posterior no vuelve a canjear.
`registro_screen_test.dart`: llega precargado; nombre del negocio no editable; documento no editable si viene, editable si viene vacío; "Crear cuenta" no llama al repositorio con la casilla sin marcar ni con campos inválidos (y muestra los mensajes); con todo válido llama una vez aunque se toque dos veces; cada `ResultadoCrearCuenta` muestra su texto o navega.
`ingreso_screen_test.dart`: cada `ResultadoIngreso` muestra su texto; dos toques llaman una vez; el enlace lleva a `codigo`.

- [ ] **Step 2: Verificar que falla**

Run: `cd apps/app_movil && flutter test`
Expected: FAIL de compilación.

- [ ] **Step 3: Implementar; actualizar `docs/contrato.md`**

- [ ] **Step 4: Verificar** con el comando completo de Global Constraints, más `grep -rn "PantallaPlaceholder" apps/app_movil/lib/src/features/registro apps/app_movil/lib/src/features/auth` sin resultados.
Expected: sin avisos; pruebas en verde en los tres paquetes; `git status --short apps/panel_web supabase` vacío.

- [ ] **Step 5: Commit**

```bash
git add apps/app_movil docs/contrato.md
git commit -m "feat(app_movil): registro por invitación e ingreso con correo"
```
