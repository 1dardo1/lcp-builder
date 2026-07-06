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
- [[00 - Indice|Índice del modelo de dominio]] (27 archivos Dart implementados, ~2893 líneas). 18 secciones en orden topológico: tipos primitivos → active effects → contenedores de efectos → bonuses/synergies/tags/counters/deployables/ammo → tipos compuestos pequeños → Pilot/Licensed/NPC Data (con checklists) → Other → clasificación entidad/value object verificada. Consultar el índice de esa carpeta para saltar directo a la sección concreta sin abrir el resto.

## Diseño UI
- [[Referencia visual COMP-CON]] — Capturas de la app oficial usadas de referencia estética (home screen, formulario de piloto, roster) + 2 decisiones de diseño abiertas (color de CTA, formato de etiquetas de botón) + pantallas Crear/Editar/Vista pendientes de diseñar.

## Aprendizajes
- [[Principios y decisiones clave]] — Reglas ya validadas: orden topológico no negociable, verificar contra JSON real (no solo prosa de la Wiki), validar gramática ≠ evaluar expresión, dominio solo recibe rutas de archivo, feedback de cliente como desempate (no primer filtro), modo socrático vs. excepciones administrativas.

## Estado actual (resumen)

- Modelo de dominio: documento completo (18 secciones numeradas), implementación Dart completa en 27 archivos, ya volcada a `app/lib/domain/` (layer-first, Clean/Hexagonal). `dart analyze lib/domain` verificado sin errores (Dart SDK 3.12.2).
- Home screen: mockup en Figma (`pk5HXmmuqBJiIlFl8lDamm`) y HTML artifact (no migrado a este repo).
- Pendiente: `flutter create .` (Flutter SDK completo, no solo Dart, sigue sin instalar en el entorno remoto), empezar flujo Crear en Flutter, investigar plugins Linux/Android, diseñar pantallas Crear/Editar/Vista en Figma.

## Próximos pasos (on the horizon)

- [x] Ejecutar `dart analyze` para confirmar que la capa de dominio compila — sin errores
- [ ] Ejecutar `flutter create .` en `app/` (pubspec.yaml + carpetas de plataforma) — requiere una máquina con el SDK de Flutter instalado
- [ ] Empezar implementación Flutter del flujo Crear
- [ ] Investigar plugins Flutter para sistema de archivos en Linux/Android
- [ ] Investigar plugins Flutter para Windows/macOS/iOS (diferido)
- [ ] Diseñar en Figma las pantallas Crear, Editar, Vista
- [ ] Resolver las dos decisiones de UI abiertas (ver [[Referencia visual COMP-CON]])
