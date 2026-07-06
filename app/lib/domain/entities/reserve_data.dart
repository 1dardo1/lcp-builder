import '../enums/enums.dart';
import '../value_objects/value_objects.dart';
import 'counter_data.dart';

/// Sección 11.4 del modelo de dominio. Entidad de catálogo — comportamiento
/// de `consumable` y ciclo de vida "Used" en vault MdD §11.4.
class IReserveData {
  final String id;
  final String name;
  final ReserveType type; // solo agrupa en pestañas de UI, sin efecto mecánico
  final String? label; // default: el propio name
  final String? description; // v-html
  final bool? consumable; // default false
  final List<IActionData>? actions;
  final List<IBonusData>? bonuses;
  final List<ISynergyData>? synergies;
  final List<IDeployableData>? deployables;
  final List<ICounterData>? counters;
  final List<String>? integrated;
  final List<String>? specialEquipment;
  final List<IActiveEffectData>? activeEffects;

  const IReserveData({
    required this.id,
    required this.name,
    required this.type,
    this.label,
    this.description,
    this.consumable,
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
