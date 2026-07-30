/// Talent rank value object (vault domain model, section 11.6).
library;

import '../entities/counter_data.dart';
import 'actions_and_active_effects.dart';
import 'bonuses.dart';
import 'deployables.dart';
import 'synergies.dart';

/// Sin `id` propio (el talento entero lo tiene). `exclusive` es relacional
/// entre los ranks de un mismo talento, no del rank aislado — ver vault
/// MdD §11.6.
class IRankData {
  final String name;
  final String description;
  final bool? exclusive; // default false
  final List<IActionData>? actions;
  final List<IBonusData>? bonuses;
  final List<ISynergyData>? synergies;
  final List<IDeployableData>? deployables;
  final List<ICounterData>? counters;
  final List<String>? integrated;
  final List<String>? specialEquipment;
  final List<IActiveEffectData>? activeEffects;

  const IRankData({
    required this.name,
    required this.description,
    this.exclusive,
    this.actions,
    this.bonuses,
    this.synergies,
    this.deployables,
    this.counters,
    this.integrated,
    this.specialEquipment,
    this.activeEffects,
  });
}
