---
tags: [aprendizajes, lcp-builder, arquitectura, decision]
---

# Decisión — variabilidad por tier de NPC (caso 6 del catálogo de polimorfismo)

Relacionado: [[19. Catálogo de casos polimórficos (para el formulario)]] (caso 6), [[15. NPC Data]] (`TierValue`, `NpcSize`, `EidolonShardCount`, `ICustomStatData.default`).

## Problema

La spec de NPC (§15) usa **cuatro mecanismos distintos** para expresar "este campo varía según el tier 1/2/3 del NPC":

| Tipo | Formas | Elección real para el usuario |
|---|---|---|
| `TierValue` | número único, o array de 3 | 2 formas |
| `NpcSize` | siempre array de 3 sub-arrays (`List<List<num>>`) | ninguna — forma fija, sin alternativa |
| `EidolonShardCount` | número único, array de 3, o el string literal `'hostile_characters'` | 3 formas |
| `ICustomStatData.defaultValue` | número único, o string `"X/Y/Z"` | 2 formas |

El motor de formulario ya tenía, antes de esta decisión, `ShapeChoiceFieldSpec` (caso 3 del catálogo: el valor puede tener una de **dos** formas, resuelto con un selector binario `optionA`/`optionB`) y `GroupFieldSpec` (sub-formulario de forma fija, una sola instancia, con campos de key propia — usado hoy para `IEffectSaveData`). Ninguna de las dos, tal como estaban definidas, cubría directamente los 4 tipos: `ShapeChoiceFieldSpec` solo tiene sitio para 2 ramas (`EidolonShardCount` necesita 3), y ni una ni otra expresan por sí solas "elige una forma, y si es la rama X, rellena exactamente 3 campos fijos".

## Alternativas consideradas

**A. Inferir la forma a partir de lo que se rellena.** Mostrar siempre 3 casillas (tier 1/2/3) y decidir en el ensamblador: si las 3 casillas tienen el mismo valor (o solo se rellena la primera), es `.single`; si difieren, es `.perTier`; si contienen el texto especial, es `.hostileCharacters()`.

Descartada: introduce un estado ambiguo real (¿rellenar solo la casilla 1 significa "quiero `.single`" o "me falta rellenar las otras 2"?) que no tiene una respuesta correcta sin inventar una regla adicional — y esa regla añade complejidad de ensamblador sin necesidad, cuando el propio dominio ya expone constructores con nombre (`.single`, `.perTier`, `.hostileCharacters`) pensados para una elección explícita, no para inferencia.

**B. Selector explícito de N formas.** Generalizar `ShapeChoiceFieldSpec` de A/B fijos a una lista de opciones (`label` + `FieldSpec` por cada una); el usuario elige una rama y el motor solo pinta los campos de esa rama — sin ambigüedad de relleno parcial, porque las otras ramas ni se muestran.

## Decisión

Se elige la alternativa B, componiendo dos piezas ya existentes en `field_spec.dart` en vez de crear un `FieldSpec` nuevo para este caso:

1. **`ShapeChoiceFieldSpec` generalizado**: pasa de `optionALabel`/`optionA`/`optionBLabel`/`optionB` (2 ramas fijas) a una lista de opciones (`label` + `FieldSpec` por cada una) — cubre tanto los casos de 2 formas (`TierValue`, `ICustomStatData.defaultValue`) como el de 3 (`EidolonShardCount`), sin necesidad de una clase distinta por número de ramas.
2. **`GroupFieldSpec` reutilizado tal cual** para la rama "por tier": 3 campos de key fija (`tier1`/`tier2`/`tier3`), cada uno el `FieldSpec` que corresponda al tipo de dato de esa rama (`NumberFieldSpec` para `TierValue`; `MultiEnumFieldSpec` sobre `{0.5, 1, 2, 3}` para `NpcSize`, que admite varios tamaños válidos por tier). Es el mismo criterio ya usado para descartar `ListFieldSpec` en `IEffectSaveData`: un conjunto **fijo** de campos, no una lista de tamaño libre — aquí "fijo" significa exactamente 3, uno por tier, nunca más ni menos.
3. **`NpcSize` no usa `ShapeChoiceFieldSpec` en absoluto** — no hay elección que ofrecer (el dominio solo tiene un constructor, siempre exige los 3 sub-arrays), así que su campo es directamente el `GroupFieldSpec` de 3 tiers, sin selector previo.
4. **La conversión de forma final es responsabilidad del ensamblador, no del esquema** — mismo principio ya aplicado en el resto del proyecto (`buildXFormSchema()` declara qué se pide, `xFromFormValues()` decide cómo construir el objeto de dominio). Concretamente: para `TierValue`/`EidolonShardCount` el ensamblador convierte el `GroupFieldSpec` en `List<num>`; para `ICustomStatData.defaultValue` lo convierte en el string `"$tier1/$tier2/$tier3"`. El `FieldSpec` es idéntico en ambos casos (3 campos numéricos) — la diferencia de formato final no se filtra al esquema declarativo.

**Consecuencia práctica:** el caso 6 no necesita ningún `FieldSpec` nuevo — se resuelve combinando `ShapeChoiceFieldSpec` (generalizado a N ramas) y `GroupFieldSpec` (ya existente, reutilizado sin cambios), con la diferencia de tipo de dato resuelta en cada función ensambladora.

## Implementación

Ya implementado en `field_spec.dart`/`generic_form_view.dart`: `ShapeChoiceFieldSpec` pasó de `optionALabel`/`optionA`/`optionBLabel`/`optionB` (2 ramas fijas) a `options: List<ShapeChoiceOption>` (N ramas, cada una con `value`/`label`/`field` opcional — `field: null` cubre ramas sin datos adicionales, ej. `hostile_characters`). La generalización se aplicó también a los 7 usos ya existentes del campo (arma `type`, `NumericOrFormulaValue`, `aoe`, `damageSaveField`, `IResistanceData.immunity`, `IBonusData.val`, `TextOrActiveEffect`), preservando el mismo contrato en tiempo de ejecución (`'$key.choice'` sigue guardando un string, cada rama sigue usando `'$key.<value>'` para sus propios campos) — verificado con la suite de tests completa en verde antes de construir las entidades nuevas encima, así ningún fallo posterior podía deberse al propio refactor.

`tierValueField`/`tierValueFromItem`/`npcSizeField`/`npcSizeFromItem` viven en `common_entity_fields.dart`, usados por `INpcClassData` (13 `TierValue` + 1 `NpcSize`), `INpcFeatureData` (variantes tech/weapon) e `IEidolonLayerData` (`EidolonShardCount`, 3 ramas — la primera entidad que necesitó más de 2).
