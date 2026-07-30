/// Damage and range value objects (vault domain model, section 1).
library;

import '../enums/enums.dart';
import 'shared_value_types.dart';

/// `number | string`. Como string: `XdY+Z`, `XdY`, o `Z`. Se valida el
/// patrón básico; la evaluación completa (aritmética + bonus strings) se
/// pospone a una fase posterior (validación de gramática ≠ evaluación).
class DiceExpression {
  final num? numberValue;
  final String? formula;

  const DiceExpression.number(this.numberValue) : formula = null;

  DiceExpression.formula(String value) : numberValue = null, formula = value {
    assert(_basicPattern.hasMatch(value), 'DiceExpression inválida: $value');
  }

  static final RegExp _basicPattern = RegExp(r'^[0-9dD+\-*/(){}A-Za-z_ ]+$');
}

/// `string | { stat: string, aoe?: boolean }` — forma ad hoc, sin nombre
/// propio en la fuente. `stat` aquí es string libre, NO el enum `MechStat`
/// (a diferencia de `IEffectSaveData.stat`).
class IDamageSaveData {
  final String stat;
  final bool? aoe;
  const IDamageSaveData({required this.stat, this.aoe});
}

class IDamageData {
  final DamageType type;
  final DiceExpression val;
  final StringOrBool? aoe;
  final Object? save; // String | IDamageSaveData
  final bool? saveHalf;
  final bool? ap;
  final TargetType? target; // default 'enemy'

  const IDamageData({
    required this.type,
    required this.val,
    this.aoe,
    this.save,
    this.saveHalf,
    this.ap,
    this.target,
  });
}

class IRangeData {
  final RangeType type;
  final DiceExpression val;
  final DiceExpression? min;
  const IRangeData({required this.type, required this.val, this.min});
}
