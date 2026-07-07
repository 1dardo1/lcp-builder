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

Las carpetas hoja de `presentation/` y `test/presentation/` siguen vacías (llevan `.gitkeep`) — pendiente el diseño en Figma antes de construir el formulario real.

## Estado de `lib/domain/`

Implementado completo (27 archivos: `enums/enums.dart`, `value_objects/value_objects.dart`, 24 entidades en `entities/`, `domain.dart` como barrel), transcrito directamente de `vault/Modelo de Dominio/` (secciones 1-17) en el mismo orden topológico del documento fuente. `lib/domain/ports/` sigue vacío — las interfaces hexagonales (guardar/leer archivo, capturar imagen) se añadirán cuando `application/use_cases/` las necesite.

`dart analyze lib/domain` verificado (Dart SDK 3.12.2 instalado en este entorno remoto): **"No issues found!"** — el dominio compila limpio.

## Proyecto Flutter

`flutter create --project-name lcp_builder --platforms=android,ios,linux,macos,windows .` ejecutado (Flutter 3.44.4 stable instalado en este entorno remoto), generando `pubspec.yaml`, las carpetas de plataforma (`android/`, `ios/`, `linux/`, `macos/`, `windows/` — sin `web/`, fuera del alcance del ADR-001), `lib/main.dart` (demo por defecto, pendiente de sustituir por el flujo Crear) y `test/widget_test.dart` (test de ejemplo). No tocó nada dentro de `lib/domain/` ni el resto de la estructura ya preparada. `flutter analyze` sobre el proyecto completo: **"No issues found!"**.

## Flujo Crear — arma (verificación headless, sin formulario todavía)

Primera entidad completa de principio a fin: dominio → `.lcp` en disco, sin interfaz — para verificar que el `.lcp` generado es correcto antes de construir el formulario real (pendiente de diseño en Figma).

- `domain/ports/content_pack_exporter.dart`, `domain/ports/file_writer.dart` — puertos hexagonales.
- `infrastructure/lcp/domain_json_mapper.dart` — traduce el dominio a JSON (snake_case, grafía exacta de la spec). Cubre el grafo completo de `IWeaponData`/`ILcpManifestData`; los tipos compartidos (`IDamageData`, `IActionData`, `IBonusData`...) se reutilizarán en el resto de entidades.
- `infrastructure/lcp/zip_content_pack_exporter.dart` — produce el zip de un solo nivel (`lcp_manifest.json` + `weapons.json`) que exige el formato `.lcp`.
- `infrastructure/file_system/local_file_writer.dart` — adapter Linux (escritura abierta, `dart:io`).
- `application/use_cases/crear_arma_use_case.dart` — orquesta ambos puertos.
- `bin/crear_arma_ejemplo.dart` — script ejecutable (`dart run bin/crear_arma_ejemplo.dart [ruta.lcp]`) que genera un `.lcp` real con un arma de ejemplo, para probarlo cargándolo en COMP/CON.

Al escribir el mapper se encontraron y corrigieron dos bugs reales del dominio ya mergeado: `DamageType` y `RangeType` (y `BonusRangeTypeFilter`) no tenían `jsonValue` — exportaban en minúscula (`"kinetic"`) en vez de la grafía real de la spec (`"Kinetic"`).

Tests: `test/infrastructure/lcp/domain_json_mapper_test.dart` (unitarios) y `test/application/use_cases/crear_arma_use_case_test.dart` (aceptación end-to-end: genera un `.lcp` real en un directorio temporal, lo abre como zip y verifica su contenido) — cumple la condición de tests bloqueante de ADR-002 para esta iteración. `flutter test`: 9/9 pasan.

**Pendiente:** diseñar en Figma las pantallas Crear/Editar/Vista y construir el formulario real en `presentation/`, sustituyendo `lib/main.dart` y este script headless.
