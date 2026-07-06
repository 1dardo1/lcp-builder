import '../value_objects/value_objects.dart';
import 'counter_data.dart';

/// Sección 11.2 del modelo de dominio.
///
/// Riesgo conocido: COMP/CON no valida referencias circulares en
/// `integrated` (puede crashear la app) — responsabilidad del formulario
/// de creación evitarlo. Ver vault MdD §11.2.
class ICoreBonusData {
  final String id; // único globalmente
  final String name;
  final String source; // debe coincidir con un Manufacturer ID
  final String effect; // v-html
  final String description; // v-html
  final String?
  mountedEffect; // texto para el panel de mount al instalar un Core Bonus de mount
  final List<IActiveEffectData>? activeEffects;
  final List<IActionData>? actions;
  final List<IBonusData>? bonuses;
  final List<ISynergyData>? synergies;
  final List<IDeployableData>? deployables;
  final List<ICounterData>? counters;
  final List<String>? integrated; // instalado automáticamente, no removible
  final List<String>?
  specialEquipment; // disponible en el selector, no instalado automáticamente

  const ICoreBonusData({
    required this.id,
    required this.name,
    required this.source,
    required this.effect,
    required this.description,
    this.mountedEffect,
    this.activeEffects,
    this.actions,
    this.bonuses,
    this.synergies,
    this.deployables,
    this.counters,
    this.integrated,
    this.specialEquipment,
  });
}
