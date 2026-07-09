---
tags: [moc, lcp-builder]
---

# LCP Builder — Panel del proyecto

Vehículo de aprendizaje de arquitectura de software (Clean/Hexagonal) y pieza de portfolio, con objetivo secundario de entregar una herramienta usable a un máster de Lancer sin conocimientos técnicos. Stack: Flutter/Dart. Ver [[ADR-001 - Seleccion de stack tecnologico]].

## ADRs
- [[ADR-001 - Seleccion de stack tecnologico]] — Aceptada. Por qué Flutter/Dart, por qué Clean/Hexagonal, alcance multiplataforma (Linux/Android reales, resto aprendizaje), restricciones (sin servidor, sin plazos, spec-first).
- [[ADR-002 - Secuenciacion de desarrollo entre plataformas]] — Aceptada. Orden núcleo común → Linux/Android → Windows/macOS/iPhone/iPad; categorías de adapters de plataforma (almacenamiento, cámara, selector nativo, permisos, drag-and-drop).
- [[ADR-003 - Plan de fases]] — Propuesta (falta Trade-off analysis/Consequences). Orden de funcionalidades dentro de Linux/Android (Crear → Mostrar/localizar → Editar/eliminar → mantenimiento), criterios de entrada de funcionalidad nueva, relación plan de fases/feedback de cliente.

## Modelo de dominio
- [[00 - Indice|Índice del modelo de dominio]] (27 archivos Dart implementados, ~2893 líneas). 19 secciones en orden topológico: tipos primitivos → active effects → contenedores de efectos → bonuses/synergies/tags/counters/deployables/ammo → tipos compuestos pequeños → Pilot/Licensed/NPC Data (con checklists) → Other → clasificación entidad/value object verificada → catálogo de casos polimórficos. Consultar el índice de esa carpeta para saltar directo a la sección concreta sin abrir el resto.

## Diseño UI
- [[Referencia visual COMP-CON]] — Capturas de la app oficial usadas de referencia estética (home screen, formulario de piloto, roster) + 2 decisiones de diseño abiertas (color de CTA, formato de etiquetas de botón) + pantallas Crear/Editar/Vista pendientes de diseñar.

## Aprendizajes
- [[Principios y decisiones clave]] — Reglas ya validadas: orden topológico no negociable, verificar contra JSON real (no solo prosa de la Wiki), validar gramática ≠ evaluar expresión, dominio solo recibe rutas de archivo, feedback de cliente como desempate (no primer filtro), modo socrático vs. excepciones administrativas.

## Estado actual (resumen)

- Modelo de dominio: documento completo (18 secciones numeradas), implementación Dart completa en 27 archivos, ya volcada a `app/lib/domain/` (layer-first, Clean/Hexagonal). `dart analyze lib/domain` verificado sin errores (Dart SDK 3.12.2).
- Proyecto Flutter real generado (`flutter create`, Flutter 3.44.4 stable) con `pubspec.yaml` y carpetas de plataforma Android/iOS/Linux/macOS/Windows. `flutter analyze` sobre el proyecto completo, sin errores.
- Home screen: mockup en Figma (`pk5HXmmuqBJiIlFl8lDamm`) y HTML artifact (no migrado a este repo).
- Flujo Crear (arma) funcionando de principio a fin, **con formulario real** (Material sin diseño definitivo, motor genérico) y verificado cargando un `.lcp` real en COMP/CON. Ver "Flujo Crear — arma" en `app/README.md`.
- Motor de formulario genérico (`app/lib/presentation/forms/`) para las 24 entidades: esquema declarativo escrito a mano (decisión ya tomada, no codegen), interpretado por un único motor. Cubre **todos** los casos polimórficos del catálogo (§19), incluidos catálogo anidado dentro de lista, uniones cerradas de 3-4 vías reutilizando `CatalogFieldSpec`, selección múltiple de enum (`MultiEnumFieldSpec`) y sub-formulario de forma fija (`GroupFieldSpec`).
- Esquema de `IWeaponData` **completo** (todos los campos de la entidad) — única excepción documentada: `deployables` dentro de `deployables` queda fuera del formulario (recursión acotada a 1 nivel, decisión consciente, no limitación técnica).
- Adapter de "selector nativo" (ADR-002): la pantalla Crear ya pide al usuario dónde guardar el `.lcp` en vez de usar una ruta fija, vía `file_selector` (paquete federado del equipo de Flutter, decisión ya documentada en `app/README.md`).
- Crear ya no es solo arma: se generalizó el puerto exportador, el caso de uso y la pantalla (`CrearEntidadScreen` + `EntityCrearConfig`, ver "Crear multi-entidad" en `app/README.md`) a cualquier entidad, con un menú de inicio.
- El "paquete" de actions/bonuses/synergies/deployables/counters/activeEffects (antes atrapado en `weapon_form_schema.dart`) se extrajo a `presentation/forms/common_entity_fields.dart`, verificado sin regresiones antes de reutilizarlo.
- **Las 24 entidades de contenido tienen esquema completo — "Crear" está cerrado del todo.** 8 "trivial" (fabricante, tag, skill, status/condition, sitrep, entorno, background, bond), 3 "medium" (reserve, core bonus, talent, reutilizan el paquete común), arma, y las 8 con casos polimórficos propios (mech system, weapon mod, pilot gear, frame, NPC feature, NPC class, NPC template, eidolon layer).
- Caso 6 del catálogo de polimorfismo (variabilidad por tier de NPC: `TierValue`, `NpcSize`, `EidolonShardCount`) ya está **implementado**, no solo decidido: `ShapeChoiceFieldSpec` generalizado de A/B fijos a una lista de `ShapeChoiceOption` (N ramas) + `GroupFieldSpec` reutilizado para "exactamente 3 campos, uno por tier" — la generalización se aplicó también a los 7 usos ya existentes del campo (sin cambiar su comportamiento, verificado con la suite completa antes de construir encima). Caso 1/2 (unión discriminada por `type`: pilot gear, NPC feature) resuelto con la misma composición, sin `FieldSpec` nuevo tampoco. Ver [[Decisión - variabilidad por tier de NPC (caso 6 del catálogo de polimorfismo)]].
- **Fase "Mostrar/localizar" (ADR-003) completa**: abrir un `.lcp` suelto o una carpeta, listar sus tipos de entidad con recuento y ver cada instancia en una tarjeta de solo lectura (`EntityDisplayCard`, reutilizada después en Editar).
- **Fase "Editar/eliminar" (ADR-003) completa**: mismo flujo de entrada que Mostrar, con botones de editar/eliminar por tarjeta (eliminar pide confirmación). Editar abre el mismo motor de formulario de Crear, precargado con los datos existentes vía `formValuesFromJson` — para eso hizo falta que cada `FieldSpec` polimórfico (`EnumFieldSpec`/`ShapeChoiceFieldSpec`/`CatalogFieldSpec`) ganara su inverso de lectura explícito (`fromJsonValue`/`branchFromJson`/`idFromJson`), auditado en las 24 entidades. Guardar reemplaza solo la entidad tocada sin reconstruir el resto como objetos de dominio tipados (`RawContentPackExporter`), y `EditSession` mantiene el estado de varios `.lcp` abiertos en el mismo procedimiento sin perder cambios sin guardar. Ver las entradas correspondientes en [[Principios y decisiones clave]] y [[Decisión - variabilidad por tier de NPC (caso 6 del catálogo de polimorfismo)]].
- Pendiente: diseñar pantallas Crear/Editar/Vista en Figma (para reemplazar el Material por defecto) — con las 3 fases de ADR-003 funcionalmente completas en Material, el siguiente paso natural de producto es esa fase de diseño visual, o el "mantenimiento" que cierra el plan de fases.

## Próximos pasos (on the horizon)

- [x] Ejecutar `dart analyze` para confirmar que la capa de dominio compila — sin errores
- [x] Ejecutar `flutter create .` en `app/` (pubspec.yaml + carpetas de plataforma) — hecho, `flutter analyze` sin errores
- [x] Verificar de principio a fin el flujo Crear con una entidad (arma) — dominio → `.lcp` en disco, verificado en COMP/CON
- [x] Motor de formulario genérico (esquema a mano) + formulario real de Crear arma
- [x] Extender el motor para anidar catálogo dentro de una lista (varios bonuses por arma)
- [x] Completar el esquema de arma con el resto de campos (`ammo`, `actions`, `active_effects`, `synergies`, `deployables`, `profiles`, `on_attack`/`on_hit`/`on_crit`/`on_miss`, filtros de `bonuses`) — motor extendido con `MultiEnumFieldSpec` y `GroupFieldSpec`
- [x] Investigar y añadir plugin de selector de archivo para Linux/Android (`file_selector`) — la pantalla Crear ya no usa una ruta fija
- [x] Generalizar Crear a cualquier entidad (puerto exportador + caso de uso + pantalla genérica + menú), y construir esquema completo para 8 entidades simples (fabricante, tag, skill, status/condition, sitrep, entorno, background, bond)
- [x] Extraer a un módulo común el "paquete" actions/bonuses/synergies/deployables (hoy en `common_entity_fields.dart`) y completar Reserve/CoreBonus/Talent
- [x] Decidir el mecanismo del caso 6 (variabilidad por tier de NPC) — `ShapeChoiceFieldSpec` generalizado a N ramas + `GroupFieldSpec`, sin `FieldSpec` nuevo
- [x] Implementar el caso 6 en `field_spec.dart`/`generic_form_view.dart` (generalizar `ShapeChoiceFieldSpec` de A/B a N ramas)
- [x] Completar las entidades con casos polimórficos propios (Frame, PilotGear, NpcFeature, NpcClass, NpcTemplate, MechSystem, WeaponMod, EidolonLayer) — **"Crear" cerrado al 100% (24/24 entidades)**
- [x] Fase Mostrar/localizar: abrir `.lcp`/carpeta, listar tipos con recuento, tarjeta de solo lectura por entidad
- [x] Hidratar el motor de formulario desde JSON real (`fromJsonValue`/`branchFromJson`/`idFromJson`, auditado en las 24 entidades) — condición previa para que Editar pudiera precargar el formulario sin perder campos
- [x] `EditSession` + `RawContentPackExporter`: guardar una edición sin reconstruir como objetos tipados las entidades no tocadas
- [x] Fase Editar/eliminar: mismo flujo que Mostrar + editar (formulario precargado) / eliminar (con confirmación), multi-entidad y multi-`.lcp` en el mismo procedimiento — **las 3 fases de ADR-003 funcionalmente completas**
- [ ] Diseñar en Figma las pantallas Crear/Editar/Vista (sustituir el Material por defecto)
- [ ] Investigar plugins Flutter para Windows/macOS/iOS (diferido)
- [ ] Resolver las dos decisiones de UI abiertas (ver [[Referencia visual COMP-CON]])
