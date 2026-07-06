import '../enums/enums.dart';
import '../value_objects/value_objects.dart';
import 'counter_data.dart';

/// Sección 13.3 del modelo de dominio.
///
/// `mount` (singular) vs. `mounts` (plural, Frames): aquí el arma ocupa
/// exactamente un tipo de mount concreto, no varios alternativos.
class IWeaponData {
  final String id; // único globalmente
  final String name;
  final String source; // Manufacturer ID (salvo excepciones documentadas)
  final String license; // nombre de display de la licencia contenedora
  final String licenseId; // debe coincidir con el id de un Frame
  final int licenseLevel; // 0 a 3
  final String effect; // v-html, texto de reglas
  final String description; // v-html
  final MountType mount; // único valor
  final Object type; // WeaponType | List<WeaponType>
  final List<IAmmoData>? ammo;
  final int? cost; // requerido SOLO si tiene tag "limited" — default 1
  final bool? barrage; // default true salvo Superheavy
  final bool? skirmish; // default true salvo Superheavy
  final bool? noAttack; // suprime generación de acciones Skirmish/Barrage
  final bool? noMods; // impide añadir mods a este arma
  final bool?
  noCoreBonus; // suprime bonificadores de mount-sensitive core bonuses
  final List<IDamageData>? damage;
  final List<IRangeData>? range;
  final List<ITagInstance>? tags;
  final int? sp; // default 0
  final TextOrActiveEffect? onAttack;
  final TextOrActiveEffect? onHit;
  final TextOrActiveEffect? onCrit;
  final TextOrActiveEffect? onMiss;
  final List<IActiveEffectData>? activeEffects;
  final List<IActionData>? actions;
  final List<IBonusData>? bonuses;
  final bool? noBonus; // default false
  final List<ISynergyData>? synergies;
  final bool? noSynergy; // default false
  final List<IDeployableData>? deployables;
  final List<ICounterData>? counters;
  final List<String>? integrated;
  final List<String>? specialEquipment;
  final List<IWeaponProfile>? profiles; // máximo 1 nivel de anidación

  const IWeaponData({
    required this.id,
    required this.name,
    required this.source,
    required this.license,
    required this.licenseId,
    required this.licenseLevel,
    required this.effect,
    required this.description,
    required this.mount,
    required this.type,
    this.ammo,
    this.cost,
    this.barrage,
    this.skirmish,
    this.noAttack,
    this.noMods,
    this.noCoreBonus,
    this.damage,
    this.range,
    this.tags,
    this.sp,
    this.onAttack,
    this.onHit,
    this.onCrit,
    this.onMiss,
    this.activeEffects,
    this.actions,
    this.bonuses,
    this.noBonus,
    this.synergies,
    this.noSynergy,
    this.deployables,
    this.counters,
    this.integrated,
    this.specialEquipment,
    this.profiles,
  });
}
