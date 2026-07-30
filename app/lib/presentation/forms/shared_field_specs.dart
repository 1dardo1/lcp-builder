/// Cross-cutting field builders reused by several sections: numeric-or-formula
/// values, the `aoe` string-or-bool field, and the dice/effect-duration
/// patterns.
library;

import '../../domain/domain.dart';
import 'field_spec.dart';

final diceExpressionPattern = RegExp(r'^[0-9dD+\-*/(){}A-Za-z_ ]+$');
final effectDurationPattern = RegExp(
  r'^(next_turn_(start|end)_(self|target)|round_(start|end)_\d+)$',
);
/// `num | NumericOrFormulaValue` — patrón repetido en `IDeployableData`
/// (armor/hp/evasion/edef/heatcap/repcap/sensorRange/techAttack/save/speed/
/// grapple/attackBonus). Se resuelve siempre como `NumericOrFormulaValue`
/// (miembro válido de la unión) para no añadir un tercer camino de
/// ensamblado — mismo mecanismo ya usado en `IBonusData.val` con
/// `numericOrFormula`.
/// [jsonKey]: la clave real del `.lcp`, si difiere de [key] (ej.
/// `otherEffect.value` en el formulario, `val` en el JSON — ver
/// `otherEffectCatalogField`). Por defecto igual a [key], como en
/// [FieldSpec.jsonKey].
FieldSpec numericOrFormulaField(String key, String label, {String? jsonKey}) {
  final realKey = jsonKey ?? key;
  return ShapeChoiceFieldSpec(
    key: key,
    jsonKey: realKey,
    label: label,
    // El propio valor crudo ya dice qué rama es: un número o un string.
    branchFromJson: (json) {
      final raw = json[realKey];
      if (raw is num) return 'A';
      if (raw is String) return 'B';
      return null;
    },
    options: [
      ShapeChoiceOption(
        value: 'A',
        label: 'Número',
        field: NumberFieldSpec(
          key: '$key.a',
          jsonKey: realKey,
          label: label,
          allowDecimal: true,
        ),
      ),
      ShapeChoiceOption(
        value: 'B',
        label: 'Fórmula',
        field: TextFieldSpec(
          key: '$key.b',
          jsonKey: realKey,
          label: 'Fórmula (ej. {grit}+2)',
          helpText:
              'Fórmula en vez de número fijo — usa llaves para referirte a '
              'un stat del piloto/mech, ej. "{grit}+2" o "{level}".',
        ),
      ),
    ],
  );
}

NumericOrFormulaValue? numericOrFormulaFromItem(
  Map<String, dynamic> item,
  String key,
) {
  final choice = item['$key.choice'] as String? ?? 'A';
  if (choice == 'A') {
    final a = item['$key.a'] as num?;
    return a == null ? null : NumericOrFormulaValue.number(a);
  }
  final b = item['$key.b'] as String?;
  return (b == null || b.isEmpty) ? null : NumericOrFormulaValue.formula(b);
}
/// `StringOrBool` para `aoe` — repetido literalmente en `IDamageData`,
/// `IStatusEffectData` e `IOtherEffectData` (y también en `INpcDamageData`,
/// que restringe `damage` pero no `aoe`), de ahí la extracción.
FieldSpec aoeField() => const ShapeChoiceFieldSpec(
  key: 'aoe',
  label: 'AoE',
  branchFromJson: _aoeBranchFromJson,
  options: [
    ShapeChoiceOption(
      value: 'A',
      label: 'Texto',
      field: TextFieldSpec(
        key: 'aoe.a',
        jsonKey: 'aoe',
        label: 'AoE (texto)',
        helpText:
            'Forma del área de efecto, como aparece en la tarjeta — ej. '
            '"3-cone", "1-line", "burst 1".',
      ),
    ),
    ShapeChoiceOption(
      value: 'B',
      label: 'Sí/No',
      field: BoolFieldSpec(key: 'aoe.b', jsonKey: 'aoe', label: 'AoE'),
    ),
  ],
);

/// `aoe` es un string o un bool directamente (`stringOrBoolToJson`) — la
/// forma del propio valor ya dice qué rama es.
String? _aoeBranchFromJson(Map<String, dynamic> json) {
  final raw = json['aoe'];
  if (raw is String) return 'A';
  if (raw is bool) return 'B';
  return null;
}
StringOrBool? stringOrBoolFromItem(Map<String, dynamic> item, String key) {
  final choice = item['$key.choice'] as String? ?? 'A';
  if (choice == 'A') {
    final text = item['$key.a'] as String?;
    return (text == null || text.isEmpty) ? null : StringOrBool.text(text);
  }
  final flag = item['$key.b'] as bool?;
  return flag == null ? null : StringOrBool.flag(flag);
}
DiceExpression diceExpressionFromInput(String raw) {
  final n = num.tryParse(raw);
  return n != null ? DiceExpression.number(n) : DiceExpression.formula(raw);
}
