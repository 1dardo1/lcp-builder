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

Las carpetas hoja de `application/`, `infrastructure/`, `presentation/` y `test/` llevan un `.gitkeep` porque siguen vacías; se elimina en cuanto entre el primer archivo real.

## Estado de `lib/domain/`

Implementado completo (27 archivos: `enums/enums.dart`, `value_objects/value_objects.dart`, 24 entidades en `entities/`, `domain.dart` como barrel), transcrito directamente de `vault/Modelo de Dominio/` (secciones 1-17) en el mismo orden topológico del documento fuente. `lib/domain/ports/` sigue vacío — las interfaces hexagonales (guardar/leer archivo, capturar imagen) se añadirán cuando `application/use_cases/` las necesite.

`dart analyze lib/domain` verificado (Dart SDK 3.12.2 instalado en este entorno remoto): **"No issues found!"** — el dominio compila limpio.

**Pendiente:**

1. Generar el proyecto Flutter real con `flutter create .` (pubspec.yaml, carpetas `android/`, `ios/`, `linux/`, `macos/`, `windows/` y demás boilerplate) — Flutter (el SDK completo, no solo Dart) sigue sin instalar en este entorno remoto. Esta estructura de `lib/`/`test/` se preparó a mano, antes de correr `flutter create`; conviene revisar que no choque con lo que genere el comando (debería convivir sin problema, ya que `flutter create` no toca `lib/` si ya existe contenido).
2. A partir de ahí, seguir con el flujo Crear según el plan de fases (`vault/ADRs/ADR-003 - Plan de fases.md`), que empezará a consumir estas entidades desde `application/use_cases/`.
