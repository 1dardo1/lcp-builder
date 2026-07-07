---
tags: [aprendizajes, lcp-builder, arquitectura, decision]
---

# Decisión — catálogo Bonus List y resolución de `IBonusData.val`

Relacionado: [[4. Bonuses]] (catálogo completo transcrito), [[19. Catálogo de casos polimórficos (para el formulario)]] (caso 4).

## Problema

`IBonusData.val` puede ser `NumericOrFormulaValue | bool | List<DieRoll> | MountAssignment`, y qué forma concreta tiene depende de qué `id` se use — un catálogo externo (el Bonus List de COMP/CON) que hasta ahora no estaba transcrito. Sin ese catálogo, el campo `val` solo se podía modelar como `Object` sin ninguna verificación, y el formulario de Crear no tenía forma de saber qué widget mostrar tras elegir un bonus.

## Investigación — cómo se resuelve este problema en otros sitios

Antes de inventar una solución propia, se buscó cómo proyectos y especificaciones ya establecidas resuelven "un campo cuya forma depende de un id externo":

- **JSON Schema / OpenAPI — `discriminator` + `mapping`**: la spec permite declarar explícitamente una tabla que asocia cada valor posible de un campo discriminador con el schema que le corresponde. Es, en esencia, un registro id → forma — el mismo problema que `IBonusData.val`.
- **Zod (TypeScript)** — sus discriminated unions funcionan mediante lo que su propia documentación llama *"discriminator lookup"*: una tabla interna que asocia cada valor del discriminador con el schema de esa variante, en vez de probar cada variante una a una.
- **Foundry VTT (motor donde corre el sistema no oficial de Lancer)**: no se encontró código público accesible que muestre su resolución concreta de bonuses por id — investigación no concluyente en este punto, pero el patrón de "discriminador + tabla de mapeo" ya está confirmado por las dos fuentes anteriores.

**Conclusión de la investigación:** el patrón establecido para este problema es un **registro (lookup table) que asocia cada valor del discriminador con la forma que le corresponde**, no una única unión etiquetada por campo `type` (eso ya lo cubren los casos 1-2 de la sección 19, y no aplica aquí porque el "tag" es un id de un catálogo externo, no un valor fijo conocido de antemano en el propio tipo).

## Por qué encaja con nuestro caso concreto

Este proyecto ya usa, en `enums.dart`, el patrón de **enum enriquecido con un campo asociado** (`enum WeaponType { rifle('Rifle'), ... final String jsonValue; }`) para resolver "un enum cuyo valor real de exportación difiere del nombre idiomático Dart". El mismo mecanismo de Dart (enums con campos) sirve igual de bien para resolver "un enum cuyo id determina qué forma tiene otro campo": basta con añadir, en vez de (o además de) `jsonValue`, un campo `valueKind` que indique la forma esperada.

Se descarta modelar cada bonus como una `sealed class` propia (equivalente a los casos 1-2): con ~90 ids y la inmensa mayoría compartiendo la misma forma (`NumericOrFormulaValue`), sería una jerarquía de 90 clases para ganar muy poca seguridad de tipos adicional frente a un enum con campo asociado + una validación en el constructor.

## Decisión

- `IBonusData.id` pasa de `String` a un enum `BonusId` (uno por cada entrada del Bonus List), con un campo asociado `valueKind: BonusValueKind` (`numericOrFormula | boolean | dieRollList | mountAssignment | unverified`).
- El constructor de `IBonusData` valida en tiempo de construcción que la forma runtime de `val` coincide con `id.valueKind` (mismo principio que los `assert` ya usados en `DiceExpression`/`SemverConstraint`/etc. — fallar rápido en construcción, no en uso posterior).
- Los 4 ids sin confirmar (`mount_damage_type`, `mount_range_type`, `mount_weapon_type`, `sizes` — ver discrepancias en [[4. Bonuses]]) se marcan con `valueKind: unverified` y no fuerzan ninguna validación de forma todavía, para no bloquear el resto del catálogo por una duda puntual.

## Verificación contra nuestro caso — límites reconocidos

La tabla del Bonus List se transcribió de la Wiki, **no verificada id por id contra JSON real** (a diferencia del resto del modelo de dominio, donde sí se exige verificación cruzada antes de dar algo por cerrado). El muestreo puntual de `lib/frames.json` encontró dos discrepancias sin resolver (`cheap_struct` con `val: 1` en vez de boolean; un `val: "1d6"` que no encaja con ningún id documentado) — anotadas en [[4. Bonuses]], no corregidas, siguiendo el mismo criterio ya establecido en el proyecto de "no corregir con un solo ejemplo". Esto es una excepción consciente al nivel de rigor habitual del resto del documento, motivada por el volumen del catálogo (~90 entradas) frente al tiempo disponible — queda pendiente una verificación más exhaustiva antes de dar el catálogo por cerrado del todo.
