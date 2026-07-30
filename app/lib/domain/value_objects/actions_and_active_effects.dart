/// Active effect and action value objects (vault domain model, section 3).
library;

import '../enums/enums.dart';
import 'damage_and_range.dart';
import 'effects.dart';

class IActiveEffectData {
  final String name;
  final String detail;
  final String? condition;
  final ActionFrequency? frequency;
  final EffectDuration? duration;
  final DiceExpression? bonusDamage;
  final List<IDamageData>? damage;
  final List<IRangeData>? range;
  final List<IStatusEffectData>? addStatus;
  final List<IResistanceData>? addResist;
  final List<ISpecialStatusData>? addSpecial;
  final List<String>? removeSpecial;
  final List<IOtherEffectData>? addOther;
  final IEffectSaveData? save;
  final AttackType? attack;
  final bool? pilot;
  final bool? mech;
  final num? accuracy;
  final num? attackBonus;

  const IActiveEffectData({
    required this.name,
    required this.detail,
    this.condition,
    this.frequency,
    this.duration,
    this.bonusDamage,
    this.damage,
    this.range,
    this.addStatus,
    this.addResist,
    this.addSpecial,
    this.removeSpecial,
    this.addOther,
    this.save,
    this.attack,
    this.pilot,
    this.mech,
    this.accuracy,
    this.attackBonus,
  });
}

class IActionData {
  final String
  name; // requerido salvo excepción: heredado del item padre en algunos systems
  final ActivationType activation;
  final String detail;
  final ActionFrequency? frequency;
  final String? trigger; // requerido SI activation = Reaction
  final int? cost; // default 1 si el item es "limited"
  final bool? pilot;
  final bool? mech;
  final bool? hideActive;
  final DiceExpression? bonusDamage;
  final IDamageData? damage; // singular — distinto de IActiveEffectData.damage
  final IRangeData? range; // singular — distinto de IActiveEffectData.range
  final List<IStatusEffectData>? addStatus;
  final List<IResistanceData>? addResist;
  final List<ISpecialStatusData>? addSpecial;
  final List<String>? removeSpecial;
  final List<IOtherEffectData>? addOther;
  final List<IActiveEffectData>? activeEffects;
  final IEffectSaveData? save;

  const IActionData({
    required this.name,
    required this.activation,
    required this.detail,
    this.frequency,
    this.trigger,
    this.cost,
    this.pilot,
    this.mech,
    this.hideActive,
    this.bonusDamage,
    this.damage,
    this.range,
    this.addStatus,
    this.addResist,
    this.addSpecial,
    this.removeSpecial,
    this.addOther,
    this.activeEffects,
    this.save,
  });
}
