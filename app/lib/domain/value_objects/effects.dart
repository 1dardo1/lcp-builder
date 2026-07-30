/// Effect value objects: durations, statuses, resistances, special/other
/// effects and effect saves (vault domain model, section 2).
library;

import '../enums/enums.dart';
import 'shared_value_types.dart';

/// Conjunto cerrado con una parte variable (`round_start_X`/`round_end_X`,
/// X = número de ronda).
class EffectDuration {
  final String value;
  const EffectDuration._(this.value);

  static const nextTurnStartSelf = EffectDuration._('next_turn_start_self');
  static const nextTurnEndSelf = EffectDuration._('next_turn_end_self');
  static const nextTurnStartTarget = EffectDuration._('next_turn_start_target');
  static const nextTurnEndTarget = EffectDuration._('next_turn_end_target');

  factory EffectDuration.roundStart(int round) =>
      EffectDuration._('round_start_$round');
  factory EffectDuration.roundEnd(int round) =>
      EffectDuration._('round_end_$round');

  @override
  bool operator ==(Object other) =>
      other is EffectDuration && other.value == value;
  @override
  int get hashCode => value.hashCode;
}

/// Fuente: Weapons (campo `frequency` de Reactions) — distinto de
/// [ActionFrequency]: admite X entero variable (ej. "2/round").
/// Cualquier valor no reconocido se trata como 'Unlimited' en la UI.
class ReactionFrequency {
  final String value;
  const ReactionFrequency._(this.value);

  static const unlimited = ReactionFrequency._('Unlimited');

  factory ReactionFrequency.perRound(int count) =>
      ReactionFrequency._('$count/round');
  factory ReactionFrequency.perScene(int count) =>
      ReactionFrequency._('$count/scene');
  factory ReactionFrequency.perEncounter(int count) =>
      ReactionFrequency.perScene(count); // alias de perScene
  factory ReactionFrequency.perMission(int count) =>
      ReactionFrequency._('$count/mission');

  @override
  bool operator ==(Object other) =>
      other is ReactionFrequency && other.value == value;
  @override
  int get hashCode => value.hashCode;
}

/// `id` referencia un catálogo compartido (statuses.json), no identidad de
/// instancia propia.
class IStatusEffectData {
  final String id;
  final EffectDuration? duration;
  final MechStat? save;
  final StringOrBool? aoe;
  final TargetType? target; // default: enemy
  const IStatusEffectData({
    required this.id,
    this.duration,
    this.save,
    this.aoe,
    this.target,
  });
}

/// `immunity` admite un valor de [ResistanceValue] o un id de Status/
/// Condition (string libre).
class ImmunityValue {
  final ResistanceValue? knownValue;
  final String? conditionId;
  const ImmunityValue.known(this.knownValue) : conditionId = null;
  const ImmunityValue.conditionId(this.conditionId) : knownValue = null;
}

/// Union discriminada por exclusión mutua de campos (exactamente uno de
/// resist/vulnerability/immunity presente). Campo real: `resist`, no
/// `resistance` — verificado contra lib/frames.json, no "corregir" sin
/// comprobar. `vulnerability` sin confirmar contra datos reales. Ver vault
/// MdD §2.
sealed class IResistanceData {
  final TargetType? target; // default: self
  const IResistanceData({this.target});
}

class ResistEffectData extends IResistanceData {
  final ResistanceValue resist;
  const ResistEffectData({required this.resist, super.target});
}

class VulnerabilityEffectData extends IResistanceData {
  final ResistanceValue vulnerability;
  const VulnerabilityEffectData({required this.vulnerability, super.target});
}

class ImmunityEffectData extends IResistanceData {
  final ImmunityValue immunity;
  const ImmunityEffectData({required this.immunity, super.target});
}

class ISpecialStatusData {
  final String attribute; // requerido — terse, una línea en UI
  final String? detail; // sin HTML; segunda persona presente
  final TargetType? target; // default: enemy
  final EffectDuration? duration;
  const ISpecialStatusData({
    required this.attribute,
    this.detail,
    this.target,
    this.duration,
  });
}

/// Union discriminada por `type`.
sealed class IOtherEffectData {
  final TargetType? target;
  final StringOrBool? aoe;
  const IOtherEffectData({this.target, this.aoe});
}

class OvershieldEffectData extends IOtherEffectData {
  final NumericOrFormulaValue val;
  const OvershieldEffectData({
    required this.val,
    super.target, // default: ally
    super.aoe,
  });
}

class HpEffectData extends IOtherEffectData {
  final NumericOrFormulaValue val;
  const HpEffectData({required this.val, super.target, super.aoe});
}

class RepairEffectData extends IOtherEffectData {
  final NumericOrFormulaValue val;
  const RepairEffectData({required this.val, super.target, super.aoe});
}

class CoverEffectData extends IOtherEffectData {
  final CoverLevel val;
  const CoverEffectData({required this.val, super.target, super.aoe});
}

/// Forma corta admitida en la fuente: un string suelto
/// `'hull'|'agi'|'sys'|'eng'`, equivalente a `{ stat: string, aoe: false }`
/// — expuesta aquí como `IEffectSaveData.shortForm`.
class IEffectSaveData {
  final MechStat stat;
  final bool? aoe;
  const IEffectSaveData({required this.stat, this.aoe});
  factory IEffectSaveData.shortForm(MechStat stat) =>
      IEffectSaveData(stat: stat, aoe: false);
}
