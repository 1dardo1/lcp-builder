---
tags: [moc, lcp-builder]
---

# LCP Builder — Panel del proyecto

Vehículo de aprendizaje de arquitectura de software (Clean/Hexagonal) y pieza de portfolio, con objetivo secundario de entregar una herramienta usable a un máster de Lancer sin conocimientos técnicos. Stack: Flutter/Dart. Ver [[ADR-001 - Seleccion de stack tecnologico]].

## ADRs
- [[ADR-001 - Seleccion de stack tecnologico]] — Aceptada
- [[ADR-002 - Secuenciacion de desarrollo entre plataformas]] — Aceptada
- [[ADR-003 - Plan de fases]] — Propuesta

## Modelo de dominio
- [[00 - Indice|Índice del modelo de dominio]] (27 archivos Dart implementados, ~2893 líneas)

## Diseño UI
- [[Referencia visual COMP-CON]]

## Aprendizajes
- [[Principios y decisiones clave]]

## Estado actual (resumen)

- Modelo de dominio: documento completo (18 secciones numeradas), implementación Dart completa en 27 archivos.
- Home screen: mockup en Figma (`pk5HXmmuqBJiIlFl8lDamm`) y HTML artifact (no migrado a este repo).
- Pendiente: `dart analyze` local, empezar flujo Crear en Flutter, investigar plugins Linux/Android, diseñar pantallas Crear/Editar/Vista en Figma.

## Próximos pasos (on the horizon)

- [ ] Ejecutar `dart analyze` para confirmar que la capa de dominio compila
- [ ] Empezar implementación Flutter del flujo Crear
- [ ] Investigar plugins Flutter para sistema de archivos en Linux/Android
- [ ] Investigar plugins Flutter para Windows/macOS/iOS (diferido)
- [ ] Diseñar en Figma las pantallas Crear, Editar, Vista
- [ ] Resolver las dos decisiones de UI abiertas (ver [[Referencia visual COMP-CON]])
