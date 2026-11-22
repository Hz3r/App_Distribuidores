# Diseño: modelos Dart del contrato nuevo y acceso por membresías en la app móvil

Fecha: 2026-11-22. Aprobado por Hz3r en conversación, con una condición: **no tocar `apps/panel_web`**
(es de Jair103). Este trabajo cubre solo `packages/core` y `apps/app_movil`.

## Por qué

La base de datos cambió (ver `docs/contrato.md`). `packages/core` todavía describe el esquema
borrador, y la app móvil redirige leyendo `app_metadata.rol` del token, que ya no existe: el rol
vive en la tabla `membresias` y una persona puede pertenecer a varios distribuidores.

## Objetivos

- `packages/core` con un modelo por tabla del contrato, fiel a las columnas reales.
- La app móvil decide a dónde ir según las membresías de la persona, no según el token.
- El panel web sigue compilando y pasando sus pruebas **sin que se le toque un archivo**.

## No-objetivos

- Pantallas de catálogo, carrito, checkout, pedidos, perfil, canje de código o login. Siguen como
  marcadores.
- Cualquier cambio en `apps/panel_web`.
- Consultas de las features (cada una hará su capa `data` cuando se construya).

## Anti-objetivos

- Romper la compilación o las pruebas de `apps/panel_web`.
- Que la app confíe en un dato editable por el usuario para dar acceso. La preferencia de
  distribuidor activo es solo eso, una preferencia: la BD valida la membresía en cada consulta.

## Enfoques

1. **Borrar `RolUsuario` y adaptar los dos routers** (propuesta original). Descartado: obliga a
   tocar el panel de Jair.
2. **Conservar `RolUsuario` en `core` solo para el panel, y migrar la app móvil a `RolMembresia`**
   (elegido). El panel no se entera; Jair lo migra cuando construya su acceso.
3. Dejar `core` como está y poner los modelos nuevos en la app móvil. Descartado: duplica modelos
   que el panel también va a necesitar, contra la regla de `CLAUDE.md`.

## Decisiones

- `RolUsuario` se queda en `enums.dart` con un comentario que dice que solo lo usa `panel_web`
  hasta que migre. Sin `@Deprecated`, porque el análisis del repo falla con avisos.
- Se eliminan `Usuario` y `TipoPresentacion` (nadie fuera de `core` y la app móvil los usa).
- Cada modelo lleva todas las columnas de su tabla. Las relaciones embebidas son opcionales y se
  piden con alias en la consulta (por ejemplo `distribuidor:distribuidores(*)`).
- App móvil, reglas de acceso:
  - Cuentan solo las membresías `activa` de rol `cliente` o `repartidor` cuyo distribuidor es
    visible. `admin` y `vendedor` usan el panel, no la app.
  - Ninguna → pantalla "sin distribuidor" (la actual `sin-rol`). Una → entra directo. Varias →
    elige en `seleccion-distribuidor`, salvo que ya haya una preferencia válida guardada.
  - Cliente → catálogo. Repartidor → su zona. Se conservan las reglas actuales de zona.
  - Mientras cargan las membresías → pantalla de espera. Si la carga falla → pantalla de error con
    reintentar y cerrar sesión.
- El distribuidor preferido se guarda en `user_metadata.distribuidor_activo` de la cuenta
  (`auth.updateUser`). No agrega dependencias y se recuerda entre dispositivos.

## A criterio de quien construya

Nombres internos de widgets y providers, textos de las pantallas (en español), estructura de las
pruebas.
