# app/ — Código Flutter/Dart

Carpeta destinada al proyecto Flutter (dominio + adapters + UI).

## Estructura (Clean/Hexagonal, layer-first)

Se eligió layer-first frente a feature-first porque el dominio es único y compartido (Pilot/NPC/Licensed Data, etc.) — son las pantallas (Crear/Editar/Vista) las que lo recorren de formas distintas, no al revés. Ver [[ADR-001 - Seleccion de stack tecnologico]] y "Principios y decisiones clave" en el vault.

```
lib/
├── domain/            # Dart puro, sin dependencia de Flutter ni de plataforma
│   ├── entities/       # 24 entidades del modelo de dominio
│   ├── value_objects/
│   ├── enums/
│   └── ports/          # interfaces que domain/application necesitan del exterior
│                       # (guardar/leer archivo, capturar imagen) — las implementa infrastructure/
├── application/
│   └── use_cases/      # orquestación: Crear, Mostrar/localizar, Editar/eliminar (orden de ADR-003)
├── infrastructure/     # adapters concretos, uno por plataforma cuando haga falta (ADR-002)
│   ├── file_system/     # Linux: navegación abierta / Android: selector restringido
│   ├── camera/
│   └── lcp/             # serialización/parseo .lcp <-> JSON
└── presentation/       # Flutter: widgets, pantallas, view models
    ├── screens/
    │   ├── crear/
    │   ├── editar/
    │   └── vista/
    ├── widgets/
    └── view_models/

test/                  # misma jerarquía que lib/ (domain/, application/, infrastructure/, presentation/)
```

Las carpetas hoja llevan un `.gitkeep` porque están vacías; se elimina en cuanto entre el primer archivo real.

**Pendiente de esta migración:**

1. Traer el dominio Dart ya implementado (27 archivos, ~2893 líneas — `enums.dart`, `value_objects.dart`, 24 entidades, `domain.dart`) a `lib/domain/`, repartido entre `entities/`, `value_objects/` y `enums/` (vivía en el entorno de trabajo anterior).
2. Generar el proyecto Flutter real con `flutter create .` (pubspec.yaml, carpetas `android/`, `ios/`, `linux/`, `macos/`, `windows/` y demás boilerplate) — no se ha creado todavía porque Flutter/Dart no está instalado en este entorno. Esta estructura de `lib/`/`test/` se preparó a mano, antes de correr `flutter create`; conviene revisar que no choque con lo que genere el comando (debería convivir sin problema, ya que `flutter create` no toca `lib/` si ya existe contenido).
3. Ejecutar `dart analyze` para confirmar que compila limpio (acción pendiente ya identificada en `vault/00 - Inicio.md`).
4. A partir de ahí, seguir con el flujo Crear según el plan de fases (`vault/ADRs/ADR-003 - Plan de fases.md`).
