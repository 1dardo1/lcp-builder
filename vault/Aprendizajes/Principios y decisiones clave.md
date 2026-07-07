---
tags: [aprendizajes, lcp-builder, arquitectura]
---

# Principios y decisiones clave

Notas de método acumuladas durante el proyecto. Relacionado: [[ADR-001 - Seleccion de stack tecnologico]], [[ADR-002 - Secuenciacion de desarrollo entre plataformas]], [[00 - Indice|Modelo de Dominio]].

## Sobre el modelo de dominio

- **El orden topológico no es negociable**: ningún tipo se define antes que sus dependencias. Las violaciones se resuelven reordenando físicamente el documento, no con workarounds ni referencias adelantadas.
- **Nunca corregir un enum o nombre de campo solo por la prosa de la Wiki**: verificar siempre contra JSON real antes de corregir. La prosa tiene errores de transcripción recurrentes (`IActiveEffects[]` → `IActiveEffectData[]`, `resistance` → `resist`, `Aux` → `Auxiliary`).
- **Validación de gramática ≠ evaluación de expresión**: evaluar una `DiceExpression` requiere datos de personaje en tiempo de ejecución, imposible en un contexto de solo creación de contenido. Se valida el patrón, se pospone la evaluación.
- Un solo ejemplo real no es suficiente para corregir un enum ya establecido (ver caso `damage.type` en minúscula en `pilot_gear.json`) — se anota como pendiente, no se aplica el cambio.

## Sobre arquitectura y capas

- El **dominio solo recibe rutas de archivo**, sin importar cómo se obtuvieron (selector nativo, drag-and-drop, cámara). Los fallos de adapter se comunican hacia arriba como errores genéricos, sin exponer la causa de plataforma.
- El diseño en Figma puede ir por delante del código Dart porque depende del modelo de dominio (documento), no del dominio compilado.
- La investigación de plugins de plataforma debe preceder a la implementación de adapters, para no invalidar trabajo si el dominio revela nuevas necesidades.
- Objetos de valor grandes con muchos campos de tipo lista omiten intencionadamente la igualdad estructural completa — decisión pendiente de revisar con `equatable` o `package:collection`.
- **Comentarios de código vs. vault**: el vault es la única fuente de verdad para lógica de negocio (reglas del dominio Lancer/COMP-CON) — el código no la duplica, solo referencia la sección (`// Ver vault MdD §X`). Los comentarios en código se reservan para decisiones técnicas de la implementación Dart (por qué esta estructura de tipos, correcciones verificadas contra JSON real que protegen contra una regresión futura tipo "esto no es un typo"). Motivo: evitar que ambas fuentes diverjan con el tiempo — solo el vault se actualiza cuando cambia una regla.
- **Campos polimórficos por catálogo externo (`IBonusData.val`)**: cuando la forma de un campo depende de un id de un catálogo externo (no un `type` fijo conocido de antemano), el patrón ya establecido en otros proyectos (JSON Schema `discriminator`+`mapping`, Zod discriminated unions) es un registro id → forma. En Dart se resuelve con el mismo mecanismo de enum-con-campo-asociado que ya usa el proyecto para `jsonValue` — ver [[Decisión - catálogo Bonus List y resolución de IBonusData.val]].

## Sobre priorización y feedback

- El feedback del cliente es un **desempate**, no un primer filtro. Orden real: coste de arrastre → severidad de impacto → incertidumbre sobre ese coste de arrastre → coste de tiempo comparativo.
- Ante empate entre valor de producto y valor de producción, gana producción (dado que no hay plazos y el objetivo prioritario es aprendizaje) — salvo urgencia real y confirmada del cliente.
- Posponer indefinidamente algo que solo aporta valor de producción equivale, en la práctica, a descartarlo.

## Sobre el propio proceso de mentoría

- Modo socrático para decisiones de diseño que el equipo de desarrollo debe razonar; implementación directa una vez la decisión arquitectónica ya está tomada.
- Excepciones al modo socrático: redacción de documentos formales que recogen decisiones ya tomadas, tareas administrativas/de formato, o petición explícita y justificada.
- Variantes menores de nomenclatura se resuelven de forma autónoma cruzando JSON real; solo se pausa ante tipos genuinamente nuevos sin resolver o contradicciones semánticas reales.
