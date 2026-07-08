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
- `infrastructure/lcp/domain_json_mapper.dart` — traduce el dominio a JSON (snake_case, grafía exacta de la spec). Cubre el grafo completo de `IWeaponData`/`ILcpManifestData`; los tipos compartidos (`IDamageData`, `IActionData`, `IBonusData`...) se reutilizan al mapear el resto de entidades.
- `infrastructure/lcp/zip_content_pack_exporter.dart` — produce el zip de un solo nivel (`lcp_manifest.json` + un archivo por tipo de contenido) que exige el formato `.lcp`.
- `infrastructure/file_system/local_file_writer.dart` — adapter Linux (escritura abierta, `dart:io`).
- `application/use_cases/crear_contenido_use_case.dart` — orquesta ambos puertos, genérico para cualquier entidad (ver "Crear multi-entidad" más abajo).
- `bin/generar_lcp_pruebas.dart` — script ejecutable headless (`dart run bin/generar_lcp_pruebas.dart [ruta.lcp]`, por defecto `build/weapons.lcp`), útil para probar el pipeline sin la UI y para verificación manual en COMP/CON: genera varias armas, cada una centrada en una combinación distinta de campos/casos polimórficos.

Al escribir el mapper se encontraron y corrigieron dos bugs reales del dominio ya mergeado: `DamageType` y `RangeType` (y `BonusRangeTypeFilter`) no tenían `jsonValue` — exportaban en minúscula (`"kinetic"`) en vez de la grafía real de la spec (`"Kinetic"`).

### Motor de formulario genérico

Antes de escalar a más entidades: un único motor (`presentation/forms/`) capaz de renderizar el formulario de cualquier entidad a partir de una descripción declarativa, en vez de una pantalla a mano por entidad. Decisión ya razonada: **esquema escrito a mano** por entidad, no generación de código (`build_runner`) — ver la conversación de arquitectura correspondiente; se revisa esa decisión si la fricción de mantener los esquemas a mano se vuelve real.

- `presentation/forms/field_spec.dart` — el modelo declarativo (`FieldSpec`). Cubre todas las categorías del catálogo de casos polimórficos (`vault/Modelo de Dominio/19...`): campos simples, enum-select, `MultiEnumFieldSpec` (subconjunto de un enum), listas de sub-formulario, caso 3 (`ShapeChoiceFieldSpec`, forma decidida por el valor), caso 4 (`CatalogFieldSpec`, catálogo externo o unión cerrada — usado tanto para `bonuses` vía `BonusId` como para uniones pequeñas como `IResistanceData`/`IOtherEffectData`), y `GroupFieldSpec` (sub-formulario de forma fija, una sola instancia — `IEffectSaveData`, el lado estructurado de un `TextOrActiveEffect`).
- `presentation/forms/generic_form_controller.dart` / `generic_form_view.dart` — el motor en sí: estado + widget Material que interpreta cualquier `List<FieldSpec>`. El renderizado usa una indirección de lectura/escritura (`_FieldContext`) que hace que el mismo `_buildField` sirva en el nivel superior, dentro de cada ítem de una lista, o dentro de un `GroupFieldSpec` — esto permite anidar catálogos/shape-choices en cualquier profundidad. Sin diseño de Figma todavía (`vault/UI-UX`) — deliberadamente funcional, no definitivo.
- `presentation/forms/weapon_form_schema.dart` — esquema **completo** de `IWeaponData` (todos los campos de la entidad), con una única excepción documentada por decisión consciente: `IDeployableData.deployables` (deployable dentro de deployable) queda fuera del formulario — recursión acotada a 1 nivel, ya que el propio dominio anota que en la práctica "no crea jerarquías reales". `IWeaponProfile` reutiliza el mismo bundle de campos que el arma (`_weaponEffectFields()`) en vez de duplicar el esquema.

Bug real de Dart encontrado al conectar el motor: los campos función genéricos (`EnumFieldSpec<T>.displayLabel`, `CatalogFieldSpec<TId>.idLabel/valueFieldFor`) fallaban en tiempo de ejecución al invocarse a través de una referencia sin el argumento de tipo (variance de funciones — `(T) -> String` no es subtipo de `(dynamic) -> String`). Resuelto con métodos wrapper (`labelFor`, `fieldFor`) definidos dentro de la propia clase genérica, donde `T` sigue fijado.

### Crear multi-entidad

Antes de esta pieza, "Crear" solo sabía construir un arma — cada entidad nueva habría exigido su propia pantalla y su propio caso de uso. Se generalizó a las 24 entidades sin tocar el motor de formularios:

- `domain/ports/content_pack_exporter.dart` — el puerto ya no tiene un método `exportWeapons`; tiene `export({manifest, content})`, donde `content` es `Map<String, List<Object>>` (nombre de archivo → lista de objetos de dominio). El puerto no conoce las 24 entidades — solo `infrastructure/lcp/zip_content_pack_exporter.dart` las conoce, con un `switch` sobre el tipo real que despacha a la función de `domain_json_mapper.dart` que toque.
- `application/use_cases/crear_contenido_use_case.dart` — un único caso de uso (`contentKey`, `content`, `manifest`, `outputPath`) sustituye a lo que antes era `CrearArmaUseCase`.
- `presentation/forms/entity_crear_config.dart` — `EntityCrearConfig`: describe cómo tratar una entidad (título, `contentKey`, esquema, ensamblador, cómo extraer `id`/`name` del objeto ya ensamblado) sin que la pantalla necesite conocer el tipo concreto. Cada esquema de entidad exporta la suya (`weaponCrearConfig`, `manufacturerCrearConfig`...).
- `presentation/screens/crear/crear_entidad_screen.dart` — pantalla Crear genérica, una sola implementación para las 24 entidades, parametrizada por `EntityCrearConfig`. Sustituye a la antigua `CrearArmaScreen`.
- `presentation/screens/crear/crear_menu_screen.dart` — menú de inicio: lista `crearEntidadConfigs` y navega a `CrearEntidadScreen` con la config elegida. Es el nuevo `home` de la app.
- `bin/generar_lcp_pruebas_entidades.dart` — mismo objetivo que `generar_lcp_pruebas.dart` pero para el resto de entidades: genera **un `.lcp` por entidad** (19 archivos, uno por `contentKey`), no uno combinado — así, si COMP/CON rechaza alguno al importar, el archivo mismo señala cuál falla, sin tener que aislarlo a mano dentro de un paquete con varias entidades mezcladas. Convención de nombre compartida con `generar_lcp_pruebas.dart` (`weapons.lcp`): el nombre del archivo es el `contentKey`.

**Las 24 entidades de contenido tienen esquema completo — "Crear" está cerrado.** Se dividieron en 4 grupos según qué mecanismo del motor necesitaban:
- **Trivial** (8, sin casos polimórficos ni paquete común): `IManufacturerData`, `ITagData`, `ISkillData`, `IStatusConditionData`, `ISitrepData`, `IEnvironmentData`, `IBackgroundData`, `IBondData`.
- **Medium** (3, reutilizan el paquete actions/bonuses/synergies/deployables/counters/activeEffects de arma): `IReserveData`, `ICoreBonusData`, `ITalentData` (esta última lo anida dentro de cada `IRankData`, no al nivel del talento).
- **Polimórficas** (8, casos 1/2/3/6 del catálogo — ver más abajo): `IMechSystemData`, `IWeaponModData`, `IPilotGearData`, `IFrameData`, `INpcFeatureData`, `INpcClassData`, `INpcTemplateData`, `IEidolonLayerData`.
- **Arma** (`IWeaponData`), la primera, con esquema completo desde el principio.

Cada una en su propio `presentation/forms/<entidad>_form_schema.dart`, siguiendo el mismo patrón (esquema declarativo + función ensambladora + mapper JSON en `domain_json_mapper.dart`).

- `presentation/forms/common_entity_fields.dart` — al completar Reserve/CoreBonus/Talent quedó claro que el paquete actions/bonuses/synergies/deployables/counters/activeEffects (y sus tipos anidados: daño, rango, efectos de estado, resistencias, saves...) no era exclusivo de arma. Se extrajo de `weapon_form_schema.dart` a este módulo común, verificado sin regresiones antes de reutilizarlo. También vive aquí `tierValueField`/`npcSizeField` (caso 6) y `mechSystemBaseFields`/`MechSystemBaseValues` (paquete de `IMechSystemData`, compartido con `IWeaponModData`, que lo extiende).

**Las 8 entidades polimórficas — ningún `FieldSpec` nuevo hizo falta:**
- **Caso 1/2** (unión discriminada por tag `type`, `IPilotGearData` 3 variantes e `INpcFeatureData` 5 variantes): se resuelve con la misma composición que el caso 6 (ver abajo) — `ShapeChoiceFieldSpec` para elegir la variante, `GroupFieldSpec` para los campos propios de cada una. `INpcFeatureData` expone además su bundle de campos (`npcFeatureItemFields()`/`npcFeatureFromFormValues()`) como funciones públicas en `npc_feature_form_schema.dart`, porque `IEidolonLayerData` anida listas de `INpcFeatureData`.
- **Caso 3** (forma decidida por el propio valor, sin tag — `IFrameData.specialty: bool | IPrerequisite`): `ShapeChoiceFieldSpec` de 2 ramas, igual que el resto de casos 3 ya resueltos en arma.
- **Caso 6** (variabilidad por tier de NPC — `TierValue`/`NpcSize`/`EidolonShardCount`, en `INpcClassData`, `INpcFeatureData` y `IEidolonLayerData`): decisión ya documentada en el vault (`Decisión - variabilidad por tier de NPC`) — `ShapeChoiceFieldSpec` generalizado de A/B fijos a una lista de `ShapeChoiceOption` (N ramas), más `GroupFieldSpec` reutilizado para pedir "exactamente 3 campos, uno por tier". Esa generalización se aplicó también a los 7 usos ya existentes de `ShapeChoiceFieldSpec` (arma, bonuses, aoe, save...), sin cambiar su comportamiento — verificado con la suite completa en verde antes de construir las entidades nuevas encima.
- `IMechSystemData`/`IWeaponModData` no tienen caso polimórfico propio — comparten el bundle base (`mechSystemBaseFields()`) porque `IWeaponModData` extiende todos los campos de `IMechSystemData`, y al ser clases de dominio distintas cada una necesita construir su propia instancia.

Tests: mapper JSON (unitarios, las 24 entidades), aceptación end-to-end del caso de uso (genera un `.lcp` real, lo abre como zip, verifica contenido) incluyendo un test de exportación multi-contenido (varias entidades en el mismo `.lcp`), ensamblador del formulario (unitarios, las 24 entidades), widget tests de `MultiEnumFieldSpec`/`GroupFieldSpec`/`ShapeChoiceFieldSpec` de N ramas/catálogo-en-lista/`CrearEntidadScreen` genérico, y smoke test de la app completa (menú → formulario de arma) — cumple la condición de tests bloqueante de ADR-002. `flutter test`: 97/97 pasan.

Verificado además en real: `flutter build linux --release` (funciona en este entorno tras instalar `libgtk-3-dev`; `flutter build apk` sigue bloqueado por política de red del entorno, `dl.google.com` denegado por el proxy) y el binario resultante ejecutado bajo Xvfb (X virtual framebuffer) con `xdotool`/`import` para capturar pantallas reales del flujo completo — no solo tests de widget.

### Sesión multi-entidad, ayuda de campo y creación por referencia

Tres carencias de UX quedaban tras cerrar las 24 entidades: (1) el flujo solo permitía rellenar una entidad y exportar — ninguna forma de acumular varias en un mismo `.lcp`; (2) campos que referencian el id de otra entidad (`IWeaponData.source` → `IManufacturerData.id`) no tenían pista de si había que escribir el id o el nombre visible; (3) si esa entidad referenciada aún no existía, había que cancelar, ir a crearla, y volver a empezar el formulario desde cero.

- `presentation/session/crear_session.dart` — `CrearSession` (`ChangeNotifier`): acumula `Map<String, List<Object>>` a lo largo de una sesión de Crear, sin tocar el dominio ni el caso de uso (que ya aceptaba ese mismo tipo desde el cierre de multi-entidad).
- `presentation/session/finalizar_lcp.dart` — `finalizarLcp()`: pide nombre del paquete (diálogo) y ubicación (`file_selector`), exporta `session.content` completo, limpia la sesión y vuelve al menú. Común a `CrearMenuScreen` (exportar lo ya acumulado) y `CrearEntidadScreen` (exportar añadiendo antes la entidad que se estaba rellenando).
- `presentation/forms/field_spec.dart` — `FieldSpec.helpText` (base, cualquier campo) y `TextFieldSpec.referenceEntityKey`/`referenceLabel` (solo campos que referencian otra entidad por id). `field_spec.dart` no importa `entity_crear_config.dart` a propósito — la resolución de qué pantalla abrir para crear la referencia vive en `CrearEntidadScreen`, inyectada en `GenericFormView` como callback (`onCreateReference`), para no crear un import circular entre el modelo de campos y el registro de entidades.
- `presentation/forms/generic_form_view.dart` — botón de ayuda (`?`) junto a cualquier campo con `helpText`; botón "Crear `referencia`" junto a un `TextFieldSpec` con `referenceEntityKey` (si se pasó `onCreateReference`), que navega a crear esa entidad y rellena el campo con su id al volver. Bug real de Flutter encontrado y corregido en el camino: `TextFormField.initialValue` solo se aplica en el primer build, así que rellenar el campo "desde fuera" (al volver de crear la referencia) no se veía en pantalla aunque el controlador sí tuviera el valor correcto — resuelto con `_ControlledTextField`, un `StatefulWidget` con su propio `TextEditingController` sincronizado en `didUpdateWidget`.
- `presentation/screens/crear/crear_entidad_screen.dart` — el antiguo botón único "Crear .lcp" se divide en dos: **Continuar** (añade la entidad a la sesión y vuelve a la pantalla anterior — el menú, o el formulario que pidió esta entidad como referencia, con sus campos intactos gracias a que `Navigator.push` nunca destruye esa pantalla, solo queda debajo en la pila) y **Finalizar lcp** (añade la entidad y exporta toda la sesión acumulada).
- `presentation/forms/crear_entidad_configs.dart` — el registro `crearEntidadConfigs`/`crearEntidadConfigsByContentKey` se extrajo de `crear_menu_screen.dart` a su propio archivo: ahora `CrearEntidadScreen` también lo necesita (para resolver a qué pantalla navega un botón de referencia), y ya importaba `crear_entidad_screen.dart` desde `crear_menu_screen.dart` — mantenerlo en `crear_menu_screen.dart` habría creado un ciclo.

Bug real encontrado (y corregido, con test de regresión) durante la demo manual: `_finalizar()` añadía la entidad a `session` *antes* de los diálogos cancelables (nombre del paquete, ubicación de guardado). Si el usuario cancelaba cualquiera de los dos y volvía a pulsar "Finalizar lcp", la entidad se añadía una segunda vez — duplicado silencioso en el `.lcp` exportado. Se corrigió pasando la entidad pendiente a `finalizarLcp()` (`pendingContentKey`/`pendingContent`), que ahora la añade a la sesión solo después de que ambos diálogos se confirmen.

**Cobertura de `helpText`**: tras la demo, se extendió de un puñado de campos (arma + referencias) a prácticamente todos los campos de texto de las 24 entidades — cada `TextFieldSpec`/rama de texto de un `ShapeChoiceFieldSpec` explica qué se espera (id vs. nombre visible, formato esperado, ejemplo concreto). Quedan sin `helpText` explícito los `PatternTextFieldSpec` (`DiceExpression`, `EffectDuration`, `SynergyLocation`...), porque ya muestran su `patternHint` siempre visible bajo el campo, sin necesidad de pulsar el botón de ayuda.

### Pantalla de inicio (Crear / Mostrar / Editar)

`main.dart` ya no arranca directamente en el menú de Crear — arranca en `presentation/screens/home/home_screen.dart`, con las 3 fases del plan de ADR-003 (Crear → Mostrar/localizar → Editar/eliminar) como opciones. Solo "Crear" navega a una pantalla funcional (`CrearMenuScreen`); "Mostrar" y "Editar" navegan a `presentation/screens/no_implementado_screen.dart`, un placeholder compartido que no depende de ninguna de las dos fases todavía sin construir — se sustituirá cuando a cada una le toque su turno.

### Selector de ubicación de guardado (`file_selector`)

`CrearEntidadScreen` no escribe en una ruta fija — pide al usuario dónde guardar vía `presentation/platform/lcp_save_location.dart`, un adapter de "selector nativo" (categoría de ADR-002) sobre el paquete [`file_selector`](https://pub.dev/packages/file_selector).

Decisión frente a la alternativa más popular (`file_picker`): `file_selector` es el paquete federado del propio equipo de Flutter (publisher verificado) y llama a APIs nativas del SO en cada plataforma, mientras que `file_picker` en Linux ejecuta comandos de shell (`zenity`/`kdialog`/`qarma`) — más frágil ante problemas del entorno (binario no instalado, versión distinta) y con un bug conocido donde `saveFile` no llega a escribir nada en Linux. En Android, el diálogo de `file_selector` usa el Storage Access Framework nativo, así que no hace falta pedir permisos de almacenamiento amplios para este flujo.

Vive en `presentation/`, no en `infrastructure/`: pedir la ruta es una interacción con el usuario/SO, no una operación de E/S — `CrearContenidoUseCase` sigue recibiendo solo la ruta ya resuelta, sin saber que hubo un diálogo (mismo principio que "el dominio solo recibe rutas de archivo", ver `vault/Aprendizajes/Principios y decisiones clave.md`).
