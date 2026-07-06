import '../enums/enums.dart';
import '../value_objects/value_objects.dart';
import 'counter_data.dart';

/// Sección 13.4 del modelo de dominio.
///
/// Entidad de catálogo, mismo patrón que [IWeaponData]/[IFrameData].
///
/// Nota — excepción de `source`/`license`/`license_id` por License
/// Collection: si el item se distribuye dentro de un "License Collection"
/// (formato aún no definido en el vault), estos tres campos se vuelven
/// opcionales porque el contexto del collection ya los implica.
///
/// Riesgo conocido reafirmado por la fuente: COMP/CON no detecta
/// referencias circulares en `integrated` — puede provocar un crash.
class IMechSystemData {
  final String id; // único globalmente
  final String name;
  final String? source; // requerido SALVO License Collection
  final String? license; // requerido SALVO License Collection
  final String? licenseId; // requerido SALVO License Collection
  final int licenseLevel; // 0 a 3
  final SystemType? type; // default 'System' si se omite
  final String? effect; // v-html
  final String? description; // v-html
  final int? sp; // default 0
  final List<ITagInstance>? tags;
  final List<IActionData>? actions;
  final List<IBonusData>? bonuses;
  final bool? noBonus; // default false
  final List<ISynergyData>? synergies;
  final bool? noSynergy; // default false
  final List<IDeployableData>? deployables;
  final List<ICounterData>? counters;
  final List<String>? integrated; // ver nota de riesgo
  final List<String>? specialEquipment;
  final List<IActiveEffectData>?
  activeEffects; // se aplican al instalar, independientes de activación

  const IMechSystemData({
    required this.id,
    required this.name,
    this.source,
    this.license,
    this.licenseId,
    required this.licenseLevel,
    this.type,
    this.effect,
    this.description,
    this.sp,
    this.tags,
    this.actions,
    this.bonuses,
    this.noBonus,
    this.synergies,
    this.noSynergy,
    this.deployables,
    this.counters,
    this.integrated,
    this.specialEquipment,
    this.activeEffects,
  });
}
