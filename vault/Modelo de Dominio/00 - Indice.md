---
tags: [modelo-dominio, lcp-builder, moc]
---

# Modelo de dominio — LCP Builder — Índice

# Modelo de dominio — LCP Builder

**Propósito de este documento:** definición de tipos del dominio (entidades, value objects, enums) extraídos de la especificación oficial del formato `.lcp` (massif-press/lancer-data, Wiki). Este documento es la única fuente de verdad para la implementación. Las decisiones de modelado (qué es entidad, qué es value object, cómo se nombran los tipos compuestos) ya están tomadas; la tarea de implementación es transcribir esta estructura a Dart sin tomar decisiones de diseño adicionales.

**Convenciones del documento:**
- Los tipos están en **orden topológico**: ningún tipo aparece antes de que todos los tipos de los que depende ya hayan sido definidos.
- `campo: Tipo` = campo obligatorio. `campo?: Tipo` = campo opcional.
- Cada tipo indica su clasificación: **Value Object** (sin identidad propia, intercambiable por valor) o **Entidad** (identidad propia vía `id`, persiste y puede mutar).
- Los comentarios `//` aclaran reglas de negocio que no se pueden expresar solo con la forma del tipo.
- Fuente: https://github.com/massif-press/lancer-data/wiki — cada bloque indica la página de origen.

## Secciones

- [[1. Tipos primitivos compuestos (hojas del árbol de dependencias)]]
- [[2. Subtipos de Active Effects]]
- [[3. Contenedores de efectos]]
- [[4. Bonuses]]
- [[5. Synergies]]
- [[6. Tags]]
- [[7. Counters]]
- [[8. Deployables]]
- [[9. Ammo]]
- [[10. Bloque de tipos compuestos pequeños - CERRADO]]
- [[11. Pilot Data]]
- [[12. Checklist - Pilot Data (COMPLETO)]]
- [[13. Licensed Data]]
- [[14. Checklist - Licensed Data (COMPLETO)]]
- [[15. NPC Data]]
- [[16. Checklist - NPC Data (COMPLETO)]]
- [[17. Other]]
- [[18. Clasificación entidad-value object - verificada (revisión completa del documento)]]
- [[Recordatorio de método (no es parte del modelo, es nota de proceso)]]
