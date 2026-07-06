import '../value_objects/value_objects.dart';
import 'counter_data.dart';

/// Sección 11.3 del modelo de dominio.
///
/// Entidad de catálogo, union discriminada por `type` en la spec
/// (`'Weapon' | 'Armor' | 'Gear'`). Se modela como jerarquía sellada: el
/// discriminador vive en el tipo Dart en tiempo de compilación, no como
/// campo `type` redundante — `infrastructure/lcp` reconstruye ese campo al
/// serializar, a partir del tipo runtime concreto.
sealed class IPilotGearData {
  final String id;
  final String name;
  const IPilotGearData({required this.id, required this.name});
}

/// Nota — disponibilidad por estado de montura: `actions`/`deployables`
/// solo están disponibles cuando el piloto está UNMOUNTED (desmontado).
class IPilotWeaponData extends IPilotGearData {
  final String? description;
  final String? effect;
  final List<IRangeData>? range;
  final List<IDamageData>? damage;
  final List<ITagInstance>? tags;
  final List<IActionData>?
  actions; // solo disponibles si el piloto está UNMOUNTED
  final List<IBonusData>? bonuses;
  final List<ISynergyData>? synergies;
  final List<IDeployableData>?
  deployables; // solo disponibles si el piloto está UNMOUNTED
  final List<ICounterData>? counters;
  final List<IActiveEffectData>?
  activeEffects; // se aplican al piloto, no al mech

  const IPilotWeaponData({
    required super.id,
    required super.name,
    this.description,
    this.effect,
    this.range,
    this.damage,
    this.tags,
    this.actions,
    this.bonuses,
    this.synergies,
    this.deployables,
    this.counters,
    this.activeEffects,
  });
}

class IPilotArmorData extends IPilotGearData {
  final String? description;
  final List<ITagInstance>? tags;
  final List<IActionData>? actions;
  final List<IBonusData>? bonuses;
  final List<ISynergyData>? synergies;
  final List<IDeployableData>? deployables;
  final List<ICounterData>? counters;

  const IPilotArmorData({
    required super.id,
    required super.name,
    this.description,
    this.tags,
    this.actions,
    this.bonuses,
    this.synergies,
    this.deployables,
    this.counters,
  });
}

class IPilotGearItemData extends IPilotGearData {
  final String? description;
  final List<ITagInstance>? tags;
  final List<IActionData>? actions;
  final List<IBonusData>? bonuses;
  final List<ISynergyData>? synergies;
  final List<IDeployableData>? deployables;
  final List<ICounterData>? counters;

  const IPilotGearItemData({
    required super.id,
    required super.name,
    this.description,
    this.tags,
    this.actions,
    this.bonuses,
    this.synergies,
    this.deployables,
    this.counters,
  });
}
