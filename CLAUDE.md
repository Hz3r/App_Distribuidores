# CLAUDE.md: convenciones del proyecto

Este archivo lo leen las sesiones de Claude Code. Sigue estas reglas en cada cambio.

## Contexto

SaaS de pedidos B2B para distribuidores. Piloto: distribuidor de licores.
Dos socios trabajan en paralelo:
- **Hz3r**: `apps/app_movil` (cliente y repartidor) y `supabase/` (BD, funciones)
- **Jair103**: `apps/panel_web` (panel del distribuidor)
- `packages/core` y archivos raíz: los dos.

## Stack (no cambiar sin acuerdo de ambos)

- Flutter + Dart. Versión fijada en `.fvmrc` (FVM).
- Supabase: PostgreSQL, Auth, Storage, Realtime, Edge Functions. Solo la **publishable key** en el cliente.
- Firebase Cloud Messaging: preparado, no inicializado.
- Estado: **Riverpod con riverpod_generator** (`@riverpod`). No usar providers escritos a mano si puede ser generado.
- Navegación: **go_router**.
- Modelos: **freezed + json_serializable**. Campos en camelCase en Dart; el JSON es snake_case (ver `packages/core/build.yaml`).
- Lints: `flutter_lints` (ver `analysis_options.yaml` raíz).

## Estructura

- Feature-first con capas `data / domain / presentation` dentro de `lib/src/features/<feature>/`.
- Los modelos compartidos van en `packages/core`, nunca duplicados en una app.
- Nada de `packages/core` depende de una app. Las apps no se importan entre sí.

## Reglas de base de datos

- **Nunca editar la BD fuera de migraciones.** Ni con SQL suelto, ni desde el dashboard en DEV/PROD.
- Migraciones nuevas: `supabase/migrations/<timestamp>_<nombre>.sql`. Nunca editar una ya aplicada.
- Toda tabla de negocio: `distribuidor_id` y RLS activado.
- Montos en **céntimos enteros**. Nunca `double` para dinero.
- Stock y precios se protegen en la BD (`crear_pedido`, con bloqueo de fila), no solo en la app.
- No aplicar migraciones al remoto (`db push`) sin revisión conjunta.
- Cambios de BD → actualizar `docs/contrato.md` en el mismo cambio.

## Secretos

- **Nunca** commitear claves reales, `env/*.json` (salvo `*.example.json`), `google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`.
- **Nunca** usar ni pedir la secret key (`sb_secret_...`) en el cliente. Solo la publishable key.
- Si necesitas una credencial, pídela al socio por fuera del chat. No la pegues en archivos.

## Trabajo entre socios

- **No toques el área del otro socio sin avisar.** Ver `.github/CODEOWNERS`.
- Si un cambio en `packages/core` afecta a las dos apps, avisa a los dos.
- Ramas: `main` protegida. Trabaja en `feature/`, `fix/` o `chore/`. Nunca commit directo en `main`.

## Antes de cada commit

```bash
dart format apps packages
dart run melos run analyze   # 0 errores
dart run melos run test      # en verde
```

Si cambiaste modelos freezed o providers de Riverpod: `dart run melos run gen` antes de analizar.

## Commits

Conventional Commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`.
Scope opcional entre paréntesis: `feat(catalogo): ...`.

## Orden al implementar una feature

1. Modelo o contrato en `docs/contrato.md` (si toca BD).
2. Migración + prueba SQL (si toca BD).
3. Modelo en `packages/core` (si lo usan dos apps).
4. `data` → `domain` → `presentation`.
5. Tests del paquete o de la lógica pura (redirección, formato, parseo).
