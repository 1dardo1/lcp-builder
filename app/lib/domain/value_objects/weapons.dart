/// Weapon profile value object (vault domain model, section 13.3).
library;

import '../entities/counter_data.dart';
import 'actions_and_active_effects.dart';
import 'bonuses.dart';
import 'damage_and_range.dart';
import 'deployables.dart';
import 'shared_value_types.dart';
import 'synergies.dart';

/// Máximo 1 nivel de anidación; campos ausentes heredan el arma
/// contenedora. Ver vault MdD §13.3 (default = profile de índice 0).
class IWeaponProfile {
  final String name; // único campo realmente obligatorio
  final TextOrActiveEffect? effect;
  final bool? skirmish;
  final bool? barrage;
  final int? cost;
  final TextOrActiveEffect? onAttack;
  final TextOrActiveEffect? onHit;
  final TextOrActiveEffect? onCrit;
  final TextOrActiveEffect? onMiss;
  final List<IActiveEffectData>? activeEffects;
  final List<IDamageData>? damage;
  final List<IRangeData>? range;
  final List<IActionData>? actions;
  final List<IBonusData>? bonuses;
  final List<ISynergyData>? synergies;
  final List<IDeployableData>? deployables;
  final List<ICounterData>? counters;
  final List<String>? integrated;
  final List<String>? specialEquipment;

  const IWeaponProfile({
    required this.name,
    this.effect,
    this.skirmish,
    this.barrage,
    this.cost,
    this.onAttack,
    this.onHit,
    this.onCrit,
    this.onMiss,
    this.activeEffects,
    this.damage,
    this.range,
    this.actions,
    this.bonuses,
    this.synergies,
    this.deployables,
    this.counters,
    this.integrated,
    this.specialEquipment,
  });
}
