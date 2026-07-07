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

## Flujo Crear — arma

Primera entidad completa de principio a fin: dominio → `.lcp` en disco. Verificado dos veces — con un test de aceptación automatizado, y cargando un `.lcp` real generado por el propio pipeline en COMP/CON (confirmado por el equipo de desarrollo).

- `domain/ports/content_pack_exporter.dart`, `domain/ports/file_writer.dart` — puertos hexagonales.
- `infrastructure/lcp/domain_json_mapper.dart` — traduce el dominio a JSON (snake_case, grafía exacta de la spec). Cubre el grafo completo de `IWeaponData`/`ILcpManifestData`; los tipos compartidos (`IDamageData`, `IActionData`, `IBonusData`...) se reutilizarán en el resto de entidades.
- `infrastructure/lcp/zip_content_pack_exporter.dart` — produce el zip de un solo nivel (`lcp_manifest.json` + `weapons.json`) que exige el formato `.lcp`.
- `infrastructure/file_system/local_file_writer.dart` — adapter Linux (escritura abierta, `dart:io`).
- `application/use_cases/crear_arma_use_case.dart` — orquesta ambos puertos.
- `bin/crear_arma_ejemplo.dart` — script ejecutable headless (`dart run bin/crear_arma_ejemplo.dart [ruta.lcp]`), útil para probar el pipeline sin la UI.

Al escribir el mapper se encontraron y corrigieron dos bugs reales del dominio ya mergeado: `DamageType` y `RangeType` (y `BonusRangeTypeFilter`) no tenían `jsonValue` — exportaban en minúscula (`"kinetic"`) en vez de la grafía real de la spec (`"Kinetic"`).

### Motor de formulario genérico

Antes de escalar a más entidades: un único motor (`presentation/forms/`) capaz de renderizar el formulario de cualquier entidad a partir de una descripción declarativa, en vez de una pantalla a mano por entidad. Decisión ya razonada: **esquema escrito a mano** por entidad, no generación de código (`build_runner`) — ver la conversación de arquitectura correspondiente; se revisa esa decisión si la fricción de mantener los esquemas a mano se vuelve real.

- `presentation/forms/field_spec.dart` — el modelo declarativo (`FieldSpec`). Cubre todas las categorías del catálogo de casos polimórficos (`vault/Modelo de Dominio/19...`): campos simples, enum-select, `MultiEnumFieldSpec` (subconjunto de un enum), listas de sub-formulario, caso 3 (`ShapeChoiceFieldSpec`, forma decidida por el valor), caso 4 (`CatalogFieldSpec`, catálogo externo o unión cerrada — usado tanto para `bonuses` vía `BonusId` como para uniones pequeñas como `IResistanceData`/`IOtherEffectData`), y `GroupFieldSpec` (sub-formulario de forma fija, una sola instancia — `IEffectSaveData`, el lado estructurado de un `TextOrActiveEffect`).
- `presentation/forms/generic_form_controller.dart` / `generic_form_view.dart` — el motor en sí: estado + widget Material que interpreta cualquier `List<FieldSpec>`. El renderizado usa una indirección de lectura/escritura (`_FieldContext`) que hace que el mismo `_buildField` sirva en el nivel superior, dentro de cada ítem de una lista, o dentro de un `GroupFieldSpec` — esto permite anidar catálogos/shape-choices en cualquier profundidad. Sin diseño de Figma todavía (`vault/UI-UX`) — deliberadamente funcional, no definitivo.
- `presentation/forms/weapon_form_schema.dart` — esquema **completo** de `IWeaponData` (todos los campos de la entidad), con una única excepción documentada por decisión consciente: `IDeployableData.deployables` (deployable dentro de deployable) queda fuera del formulario — recursión acotada a 1 nivel, ya que el propio dominio anota que en la práctica "no crea jerarquías reales". `IWeaponProfile` reutiliza el mismo bundle de campos que el arma (`_weaponEffectFields()`) en vez de duplicar el esquema.
- `presentation/screens/crear/crear_arma_screen.dart` — pantalla que usa el motor + dispara `CrearArmaUseCase`. Sustituye el `lib/main.dart` de ejemplo de `flutter create`.

Bug real de Dart encontrado al conectar el motor: los campos función genéricos (`EnumFieldSpec<T>.displayLabel`, `CatalogFieldSpec<TId>.idLabel/valueFieldFor`) fallaban en tiempo de ejecución al invocarse a través de una referencia sin el argumento de tipo (variance de funciones — `(T) -> String` no es subtipo de `(dynamic) -> String`). Resuelto con métodos wrapper (`labelFor`, `fieldFor`) definidos dentro de la propia clase genérica, donde `T` sigue fijado.

Tests: mapper JSON (unitarios), aceptación end-to-end del caso de uso (genera un `.lcp` real, lo abre como zip, verifica contenido), ensamblador del formulario (unitarios — catálogo anidado, uniones cerradas de 3/4 vías, `TextOrActiveEffect` anidado, campos `num|NumericOrFormulaValue`, reutilización de esquema en `profiles`, `synergies` con location personalizada), widget tests de `MultiEnumFieldSpec`/`GroupFieldSpec`/catálogo-en-lista, y smoke test de la app completa — cumple la condición de tests bloqueante de ADR-002. `flutter test`: 25/25 pasan. No se pudo ejecutar `flutter run` en este entorno remoto (sin display gráfico) — verificado con tests de widget en su lugar.

**Pendiente:** diseñar en Figma las pantallas Crear/Editar/Vista (para reemplazar el Material por defecto). El esquema de arma ya está completo; el siguiente escalón es extender el mismo motor al resto de las 24 entidades.

### Selector de ubicación de guardado (`file_selector`)

`CrearArmaScreen` ya no escribe en una ruta fija — pide al usuario dónde guardar vía `presentation/platform/lcp_save_location.dart`, un adapter de "selector nativo" (categoría de ADR-002) sobre el paquete [`file_selector`](https://pub.dev/packages/file_selector).

Decisión frente a la alternativa más popular (`file_picker`): `file_selector` es el paquete federado del propio equipo de Flutter (publisher verificado) y llama a APIs nativas del SO en cada plataforma, mientras que `file_picker` en Linux ejecuta comandos de shell (`zenity`/`kdialog`/`qarma`) — más frágil ante problemas del entorno (binario no instalado, versión distinta) y con un bug conocido donde `saveFile` no llega a escribir nada en Linux. En Android, el diálogo de `file_selector` usa el Storage Access Framework nativo, así que no hace falta pedir permisos de almacenamiento amplios para este flujo.

Vive en `presentation/`, no en `infrastructure/`: pedir la ruta es una interacción con el usuario/SO, no una operación de E/S — `CrearArmaUseCase` sigue recibiendo solo la ruta ya resuelta, sin saber que hubo un diálogo (mismo principio que "el dominio solo recibe rutas de archivo", ver `vault/Aprendizajes/Principios y decisiones clave.md`).
