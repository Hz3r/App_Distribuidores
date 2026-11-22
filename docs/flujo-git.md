# Flujo de Git

## Modelo de ramas

| Rama | Para qué | Cómo se toca |
|---|---|---|
| `main` | Lo que está en producción o listo para salir | Protegida. Solo entra por PR. |
| `feature/<tema>` | Funcionalidad nueva | Rama corta, se borra al fusionar |
| `fix/<tema>` | Corrección de error | Rama corta |
| `chore/<tema>` | Configuración, dependencias, CI | Rama corta |

Nunca hagas commit directo en `main`.

## Commits (Conventional Commits)

```
<tipo>(<área opcional>): <resumen en imperativo, minúsculas>
```

| Tipo | Uso |
|---|---|
| `feat` | Funcionalidad nueva |
| `fix` | Corrección |
| `chore` | Configuración, dependencias, scripts |
| `docs` | Documentación |
| `refactor` | Cambio interno sin efecto en el comportamiento |
| `test` | Tests |

Ejemplos:
```
feat(core): agregar modelo Pedido con estado
fix(app_movil): redirigir repartidor a su zona
chore(supabase): migración inicial de esquema
```

## Flujo diario

### 1. Crear la rama desde `main` actualizado

```bash
git checkout main
git pull origin main
git checkout -b feature/nombre-corto
```

### 2. Trabajar y commitear en bloques pequeños

```bash
dart format apps packages
dart run melos run analyze
dart run melos run test
git add <archivos>
git commit -m "feat(catalogo): listar productos por categoría"
```

Antes de cada commit: `analyze` y `test` deben pasar.

### 3. Mantener la rama al día con `main` (todos los días)

```bash
git fetch origin
git rebase origin/main
# si hay conflictos: resuélvelos, luego
git rebase --continue
```

Si ya subiste la rama y hiciste rebase, sube con `--force-with-lease` (nunca `--force`):

```bash
git push --force-with-lease
```

### 4. Subir y abrir PR

```bash
git push -u origin feature/nombre-corto
```

Abre el PR hacia `main`. Llena la plantilla (`.github/pull_request_template.md`).

## Revisión

- La revisión del otro socio es opcional: `CODEOWNERS` se la pide, pero no bloquea la fusión.
- Antes de pedir revisión: CI en verde, sin `env/*.json` en el diff, migración incluida si cambia la BD.
- Quien revisa **no hace push a la rama del autor**. Deja comentarios o pide cambios.
- Quien abrió el PR lo fusiona (squash merge) cuando CI pasa.

## Cambios de base de datos

- Cambios de esquema **solo con migración nueva** en `supabase/migrations/`.
- Nunca editar una migración que ya está en `main` o aplicada en DEV.
- Migración y `docs/contrato.md` van en el **mismo PR**.
- Antes de aplicar a DEV: `supabase db reset` en local debe pasar.
- Aplicar a PROD solo después de revisar en DEV, y siempre con ambos socios presentes.

## Conflictos con el otro socio

Si tu cambio toca un área del otro socio, avísale **antes** de empezar (ver `CODEOWNERS` y `CLAUDE.md`).
