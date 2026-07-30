/// Cross-cutting union value types, reused across several domain sections
/// (each repeated 3+ times in the source spec).
library;

import 'actions_and_active_effects.dart';

/// `string | boolean` — forma repetida en `aoe` de Damage, Active Effects,
/// Other Effects y Effect Save.
class StringOrBool {
  final String? text;
  final bool? flag;
  const StringOrBool.text(this.text) : flag = null;
  const StringOrBool.flag(this.flag) : text = null;
}

/// `string | IActiveEffectData` — forma repetida en Weapon Profile, Weapon y
/// NPC Feature (campo `effect`/`on_attack`/`on_hit`/`on_crit`/`on_miss`).
class TextOrActiveEffect {
  final String? text;
  final IActiveEffectData? effect;
  const TextOrActiveEffect.text(this.text) : effect = null;
  const TextOrActiveEffect.effect(this.effect) : text = null;
}

/// Número fijo, o string evaluado como expresión aritmética con bonus
/// strings entre llaves (`{ll}`, `{grit}`, etc. — ver tabla de Special
/// Values en sección 4 del vault). Solo se valida que sea number o string;
/// la evaluación de la fórmula es lógica de tiempo de ejecución, fuera de
/// alcance de creación/exportación.
class NumericOrFormulaValue {
  final num? numberValue;
  final String? formula;
  const NumericOrFormulaValue.number(this.numberValue) : formula = null;
  const NumericOrFormulaValue.formula(this.formula) : numberValue = null;
}
