/// Damage and range field builders and assemblers (domain section 1).
library;

import '../../domain/domain.dart';
import 'field_spec.dart';
import 'shared_field_specs.dart';

// --- Sección 1: IDamageData / IRangeData ---

/// `save`: `String | IDamageSaveData`. `IDamageSaveData.stat` es string
/// libre (no el enum `MechStat`) — ver vault MdD §1.
FieldSpec damageSaveField() => const ShapeChoiceFieldSpec(
  key: 'save',
  label: 'Save',
  branchFromJson: _damageSaveBranchFromJson,
  options: [
    ShapeChoiceOption(
      value: 'A',
      label: 'Texto',
      field: TextFieldSpec(
        key: 'save.a',
        jsonKey: 'save',
        label: 'Save (texto libre)',
        helpText:
            'Texto de reglas tal cual aparece en la tarjeta, ej. "On a hit, '
            'target must succeed a HULL save or take 5 heat."',
      ),
    ),
    ShapeChoiceOption(
      value: 'B',
      label: 'Estructurado',
      field: GroupFieldSpec(
        key: 'save.b',
        jsonKey: 'save',
        label: 'Save estructurado',
        fields: [
          TextFieldSpec(
            key: 'stat',
            label: 'Stat',
            required: true,
            helpText:
                'El stat contra el que tira el objetivo, en minúsculas '
                '(ej. "hull", "agility", "systems", "engineering").',
          ),
          BoolFieldSpec(key: 'aoe', label: 'AoE'),
        ],
      ),
    ),
  ],
);

/// `save` es un string suelto o un objeto `{stat, aoe}` — la forma del
/// propio valor ya dice qué rama es.
String? _damageSaveBranchFromJson(Map<String, dynamic> json) {
  final raw = json['save'];
  if (raw is String) return 'A';
  if (raw is Map) return 'B';
  return null;
}

Object? damageSaveFromItem(Map<String, dynamic> item) {
  final choice = item['save.choice'] as String? ?? 'A';
  if (choice == 'A') {
    final text = item['save.a'] as String?;
    return (text == null || text.isEmpty) ? null : text;
  }
  final group = item['save.b'] as Map<String, dynamic>?;
  final stat = group?['stat'] as String?;
  if (stat == null || stat.isEmpty) return null;
  return IDamageSaveData(stat: stat, aoe: group?['aoe'] as bool?);
}
List<FieldSpec> damageItemFields() => [
  EnumFieldSpec<DamageType>(
    key: 'type',
    label: 'Tipo de daño',
    required: true,
    options: DamageType.values,
    displayLabel: (d) => d.jsonValue,
    fromJsonValue: (s) => DamageType.values.firstWhere((d) => d.jsonValue == s),
  ),
  PatternTextFieldSpec(
    key: 'val',
    label: 'Valor (número o dados)',
    required: true,
    pattern: diceExpressionPattern,
    patternHint: 'ej. 2d6, 10, 1d6+{grit}',
  ),
  aoeField(),
  damageSaveField(),
  const BoolFieldSpec(
    key: 'saveHalf',
    jsonKey: 'save_half',
    label: 'Mitad de daño con save',
  ),
  const BoolFieldSpec(key: 'ap', label: 'AP (ignora armadura)'),
  EnumFieldSpec<TargetType>(
    key: 'target',
    label: 'Target',
    options: TargetType.values,
    displayLabel: (t) => t.name,
    fromJsonValue: (s) => TargetType.values.byName(s),
  ),
];
IDamageData damageDataFromItem(Map<String, dynamic> item) => IDamageData(
  type: item['type'] as DamageType,
  val: diceExpressionFromInput(item['val'] as String? ?? '0'),
  aoe: stringOrBoolFromItem(item, 'aoe'),
  save: damageSaveFromItem(item),
  saveHalf: item['saveHalf'] as bool?,
  ap: item['ap'] as bool?,
  target: item['target'] as TargetType?,
);

List<FieldSpec> rangeItemFields() => [
  EnumFieldSpec<RangeType>(
    key: 'type',
    label: 'Tipo de alcance',
    required: true,
    options: RangeType.values,
    displayLabel: (r) => r.jsonValue,
    fromJsonValue: (s) => RangeType.values.firstWhere((r) => r.jsonValue == s),
  ),
  PatternTextFieldSpec(
    key: 'val',
    label: 'Valor',
    required: true,
    pattern: diceExpressionPattern,
    patternHint: 'ej. 10, 1d6',
  ),
  PatternTextFieldSpec(
    key: 'min',
    label: 'Mínimo (opcional)',
    pattern: diceExpressionPattern,
    patternHint: 'ej. 5',
  ),
];

IRangeData rangeDataFromItem(Map<String, dynamic> item) => IRangeData(
  type: item['type'] as RangeType,
  val: diceExpressionFromInput(item['val'] as String? ?? '0'),
  min: (item['min'] as String?)?.isNotEmpty == true
      ? diceExpressionFromInput(item['min'] as String)
      : null,
);
