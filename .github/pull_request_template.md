## Qué hace este PR

<!-- Resumen corto del cambio y por qué. Enlaza la tarea si existe. -->

## Cómo probarlo

<!-- Pasos concretos para verificar el cambio en local. -->

1.
2.

## Capturas / video

<!-- Obligatorio si cambia UI (app móvil o panel web). Borra la sección si no aplica. -->

## Checklist

- [ ] `dart format --output=none --set-exit-if-changed apps packages` pasa
- [ ] `dart run melos run analyze` sin errores
- [ ] `dart run melos run test` en verde
- [ ] Si cambia la BD: migración nueva en `supabase/migrations/` (nunca editar una migración ya aplicada)
- [ ] Si cambia la BD: `docs/contrato.md` actualizado
- [ ] Si toca código del otro socio (ver CODEOWNERS), avisé en el PR
- [ ] Sin secretos ni `env/*.json` reales en el diff
