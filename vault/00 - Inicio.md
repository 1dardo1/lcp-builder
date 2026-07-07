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
- Motor de formulario genérico (`app/lib/presentation/forms/`) para las 24 entidades: esquema declarativo escrito a mano (decisión ya tomada, no codegen), interpretado por un único motor. Cubre representativamente los casos polimórficos del catálogo (§19).
- Pendiente: diseñar pantallas Crear/Editar/Vista en Figma (para reemplazar el Material por defecto), extender el motor para listas de catálogo (varios bonuses), investigar plugins Linux/Android.

## Próximos pasos (on the horizon)

- [x] Ejecutar `dart analyze` para confirmar que la capa de dominio compila — sin errores
- [x] Ejecutar `flutter create .` en `app/` (pubspec.yaml + carpetas de plataforma) — hecho, `flutter analyze` sin errores
- [x] Verificar de principio a fin el flujo Crear con una entidad (arma) — dominio → `.lcp` en disco, verificado en COMP/CON
- [x] Motor de formulario genérico (esquema a mano) + formulario real de Crear arma
- [ ] Diseñar en Figma las pantallas Crear/Editar/Vista (sustituir el Material por defecto)
- [ ] Extender el esquema de arma con `actions`/`active_effects`/`synergies`/`deployables`/`profiles` y listas de catálogo (varios bonuses)
- [ ] Investigar plugins Flutter para sistema de archivos en Linux/Android
- [ ] Investigar plugins Flutter para Windows/macOS/iOS (diferido)
- [ ] Diseñar en Figma las pantallas Crear, Editar, Vista
- [ ] Resolver las dos decisiones de UI abiertas (ver [[Referencia visual COMP-CON]])
