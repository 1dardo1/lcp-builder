# app/ — Código Flutter/Dart

Carpeta destinada al proyecto Flutter (dominio + adapters + UI).

**Pendiente de esta migración:** el dominio Dart ya implementado (27 archivos, ~2893 líneas — `enums.dart`, `value_objects.dart`, 24 entidades bajo `entities/`, `domain.dart`) vivía en el entorno de trabajo anterior y no se ha volcado aquí todavía. Antes de continuar con Claude Code:

1. Traer esos archivos a `app/lib/domain/` (o generar un proyecto Flutter nuevo con `flutter create` y copiar el dominio dentro).
2. Ejecutar `dart analyze` para confirmar que compila limpio (acción pendiente ya identificada en `vault/00 - Inicio.md`).
3. A partir de ahí, seguir con el flujo Crear según el plan de fases (`vault/ADRs/ADR-003 - Plan de fases.md`).
