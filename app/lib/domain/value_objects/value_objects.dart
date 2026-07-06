/// Value objects del dominio LCP Builder.
///
/// Transcripción directa de `vault/Modelo de Dominio/` (secciones 1-17),
/// mismo orden topológico estricto que el documento fuente. Sobre la
/// igualdad estructural omitida en los VOs con muchos campos de lista, ver
/// "Principios y decisiones clave" en el vault (decisión ya documentada,
/// no una omisión de esta implementación).
library;

import '../enums/enums.dart';
import '../entities/counter_data.dart';
import '../entities/npc_feature_data.dart';

// --- Tipos auxiliares transversales (uniones repetidas ≥3 veces en la spec) ---

/// `string | boolean` — forma repetida en `aoe` de Damage, Active Effects,
/// Other Effects y Effect Save.
class StringOrBool {
  final String? text;
  final bool? flag;
  const StringOrBool.text(this.text) : flag = null;
  const StringOrBool.flag(this.flag) : text = null;
}

/// `string | IActiveEffectData` — forma repetida en Weapon Profile, Weapon y
/// NPC Feature (campo `effect`/`on_attack`/`on_hit`/`on_crit`/`on_miss`).
class TextOrActiveEffect {
  final String? text;
  final IActiveEffectData? effect;
  const TextOrActiveEffect.text(this.text) : effect = null;
  const TextOrActiveEffect.effect(this.effect) : text = null;
}

/// Número fijo, o string evaluado como expresión aritmética con bonus
/// strings entre llaves (`{ll}`, `{grit}`, etc. — ver tabla de Special
/// Values en sección 4 del vault). Solo se valida que sea number o string;
/// la evaluación de la fórmula es lógica de tiempo de ejecución, fuera de
/// alcance de creación/exportación.
class NumericOrFormulaValue {
  final num? numberValue;
  final String? formula;
  const NumericOrFormulaValue.number(this.numberValue) : formula = null;
  const NumericOrFormulaValue.formula(this.formula) : numberValue = null;
}

// --- Sección 1 ---

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

// --- Sección 2 ---

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

// --- Sección 3 ---

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

// --- Sección 4 ---

/// Gramática distinta de [DiceExpression]: solo suma/resta de tiradas y
/// enteros encadenados, sin `*`, `/`, paréntesis, ni bonus strings.
/// Usado únicamente en `IBonusData.val` cuando `id = "overcharge"`.
class DieRoll {
  final String value;
  DieRoll(this.value)
    : assert(_pattern.hasMatch(value), 'DieRoll inválido: $value');
  static final RegExp _pattern = RegExp(
    r'^(\d*d\d+|\d+)([+-](\d*d\d+|\d+))*$',
    caseSensitive: false,
  );
}

/// Extraído del formato de string `add_mount` (`"mount_type:max_mounts"`).
class MountAssignment {
  final MountAssignmentType mountType;
  final int maxMounts;
  const MountAssignment({required this.mountType, required this.maxMounts});
}

/// `id` referencia el Bonus List (catálogo COMP/CON) — el tipo real de
/// `val` depende del id usado. No modelado como union: el catálogo de IDs
/// que decide la forma no es parte de este documento todavía. Ver vault
/// MdD §4 (tabla "Values" del Bonus List).
class IBonusData {
  final String id;
  final Object
  val; // NumericOrFormulaValue | bool | List<DieRoll> | MountAssignment
  final num? accuracy;
  final List<DamageType>? damageTypes; // sin filtro "any" — omitir = todos
  final List<BonusRangeTypeFilter>?
  rangeTypes; // sin filtro "any" — omitir = todos
  final List<BonusWeaponTypeFilter>? weaponTypes; // default 'any' si se omite
  final List<BonusWeaponSizeFilter>? weaponSizes; // default 'any' si se omite
  final bool? overwrite;
  final bool? replace;

  const IBonusData({
    required this.id,
    required this.val,
    this.accuracy,
    this.damageTypes,
    this.rangeTypes,
    this.weaponTypes,
    this.weaponSizes,
    this.overwrite,
    this.replace,
  });
}

// --- Sección 5 ---

/// Conjunto cerrado con una parte variable (`action_X`, X = id de una
/// Action existente) — distinto del patrón `round_start_X` de
/// [EffectDuration], donde X es un entero.
class SynergyLocation {
  final String value;
  const SynergyLocation._(this.value);

  static const rest = SynergyLocation._('rest');
  static const weapon = SynergyLocation._('weapon');
  static const system = SynergyLocation._('system');
  static const deployable = SynergyLocation._('deployable');
  static const drone = SynergyLocation._('drone');
  static const move = SynergyLocation._('move');
  static const boost = SynergyLocation._('boost');
  static const structure = SynergyLocation._('structure');
  static const armor = SynergyLocation._('armor');
  static const hp = SynergyLocation._('hp');
  static const overshield = SynergyLocation._('overshield');
  static const stress = SynergyLocation._('stress');
  static const heat = SynergyLocation._('heat');
  static const repair = SynergyLocation._('repair');
  static const corePower = SynergyLocation._('core_power');
  static const overcharge = SynergyLocation._('overcharge');
  static const hull = SynergyLocation._('hull');
  static const agility = SynergyLocation._('agility');
  static const systems = SynergyLocation._('systems');
  static const engineering = SynergyLocation._('engineering');
  static const pilotWeapon = SynergyLocation._('pilot_weapon');
  static const cascade = SynergyLocation._('cascade');

  factory SynergyLocation.actionX(String actionId) =>
      SynergyLocation._('action_$actionId');

  @override
  bool operator ==(Object other) =>
      other is SynergyLocation && other.value == value;
  @override
  int get hashCode => value.hashCode;
}

/// Mecanismo de último recurso — ver vault MdD §5 (nota de uso: cuándo
/// preferir Actions/Active Effects/Bonuses en su lugar).
class ISynergyData {
  final List<SynergyLocation> locations; // requerido — al menos una
  final String detail; // requerido, v-html
  final List<WeaponType>? weaponTypes; // omitir = todos
  final List<WeaponSize>? weaponSizes; // omitir = todos
  final List<SystemType>? systemTypes; // omitir = todos

  const ISynergyData({
    required this.locations,
    required this.detail,
    this.weaponTypes,
    this.weaponSizes,
    this.systemTypes,
  });
}

// --- Sección 6 ---

/// `id` referencia una entrada del catálogo [ITagData], no identidad de
/// instancia propia.
class ITagInstance {
  final String id;
  final Object? val; // string|number — sustituye el token {VAL} del catálogo
  const ITagInstance({required this.id, this.val});
}

// --- Sección 8 ---

/// Enum abierto (string libre), no cerrado — `Drone`/`Mine` activan
/// defaults especiales. Ver vault MdD §8.
class DeployableType {
  final String value;
  const DeployableType._(this.value);

  static const drone = DeployableType._('Drone');
  static const mine = DeployableType._('Mine');
  static const deployable = DeployableType._('Deployable'); // default

  factory DeployableType.custom(String value) => DeployableType._(value);

  @override
  bool operator ==(Object other) =>
      other is DeployableType && other.value == value;
  @override
  int get hashCode => value.hashCode;
}

/// Sin campo `id` (se genera uno por instancia en tiempo de ejecución).
/// Defaults condicionales según `type` y regla de anidación de
/// `deployables` (no crea jerarquías reales, mismo patrón que
/// Action/ActiveEffect) — ver vault MdD §8.
class IDeployableData {
  final String name; // requerido
  final DeployableType? type; // default "Deployable"
  final String detail; // requerido
  final ActivationType? activation; // default "Quick"
  final ActivationType? deactivation;
  final ActivationType? recall;
  final ActivationType? redeploy;
  final int? instances; // default 1
  final int? cost; // default 1 si el item padre es "limited"
  final num? size;
  final String? sizeSpecial;
  final Object? armor; // num | NumericOrFormulaValue
  final Object? hp; // num | NumericOrFormulaValue
  final Object? evasion;
  final Object? edef;
  final Object? heatcap;
  final Object? repcap;
  final Object? sensorRange;
  final Object? techAttack;
  final Object? save;
  final Object? speed;
  final Object? grapple;
  final Object? attackBonus;
  final List<IDamageData>? damage;
  final List<IRangeData>? range;
  final List<IActionData>? actions; // solo mientras el deployable está activo
  final List<IBonusData>? bonuses;
  final List<ISynergyData>? synergies;
  final List<IDeployableData>? deployables;
  final List<ICounterData>? counters;
  final List<IActiveEffectData>? activeEffects;
  final List<IStatusEffectData>? addStatus;
  final List<ISpecialStatusData>? addSpecial;
  final List<String>? removeSpecial;
  final List<IOtherEffectData>? addOther;
  final List<IResistanceData>? addResist;
  final List<ITagInstance>? tags;
  final bool? pilot; // default true si el item padre es Pilot Equipment
  final bool? mech; // default false si el item padre es Pilot Equipment

  const IDeployableData({
    required this.name,
    this.type,
    required this.detail,
    this.activation,
    this.deactivation,
    this.recall,
    this.redeploy,
    this.instances,
    this.cost,
    this.size,
    this.sizeSpecial,
    this.armor,
    this.hp,
    this.evasion,
    this.edef,
    this.heatcap,
    this.repcap,
    this.sensorRange,
    this.techAttack,
    this.save,
    this.speed,
    this.grapple,
    this.attackBonus,
    this.damage,
    this.range,
    this.actions,
    this.bonuses,
    this.synergies,
    this.deployables,
    this.counters,
    this.activeEffects,
    this.addStatus,
    this.addSpecial,
    this.removeSpecial,
    this.addOther,
    this.addResist,
    this.tags,
    this.pilot,
    this.mech,
  });
}

// --- Sección 9 ---

/// `restricted_*` con precedencia sobre `allowed_*` — vigentes aquí (a
/// diferencia de `IWeaponModData`, §13.5, donde están deprecados). Ver
/// vault MdD §9.
class IAmmoData {
  final String name;
  final String description;
  final int? cost; // default 1
  final List<WeaponType>? allowedTypes; // omitir = todos
  final List<WeaponSize>? allowedSizes; // omitir = todos
  final List<WeaponType>? restrictedTypes;
  final List<WeaponSize>? restrictedSizes;

  const IAmmoData({
    required this.name,
    required this.description,
    this.cost,
    this.allowedTypes,
    this.allowedSizes,
    this.restrictedTypes,
    this.restrictedSizes,
  });
}

// --- Sección 11.7 (Bonds) ---

class IQuestionData {
  final String question;
  final List<String> options;
  const IQuestionData({required this.question, required this.options});
}

/// Sin `id` propio (solo el Bond contenedor lo tiene). `origin` — regla de
/// integridad referencial entre archivos — ver vault MdD §11.7.
class IBondPowerData {
  final String name;
  final String description;
  final ActionFrequency? frequency;
  final String? prerequisite;
  final bool? veteran; // default false — solo disponible en estatus Veteran
  final bool? master; // default false — solo disponible en estatus Master
  final String? origin;

  const IBondPowerData({
    required this.name,
    required this.description,
    this.frequency,
    this.prerequisite,
    this.veteran,
    this.master,
    this.origin,
  });
}

// --- Sección 11.6 (Talents) ---

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

// --- Sección 13.2 (Frames) ---

/// Usado solo dentro de `specialty` de [IFrameData].
class IPrerequisite {
  final String source; // Manufacturer ID
  final int minRank;
  final bool cumulative; // default false

  const IPrerequisite({
    required this.source,
    required this.minRank,
    this.cumulative = false,
  });
}

/// Agrupa el contenido mecánico de un trait; no tiene `id` propio.
class IFrameTraitData {
  final String name;
  final String description;
  final List<IActionData>? actions;
  final List<IBonusData>? bonuses;
  final List<ISynergyData>? synergies;
  final List<IDeployableData>? deployables;
  final List<ICounterData>? counters;
  final List<String>? integrated; // no ocupa espacio de mount, no removible
  final List<String>? specialEquipment; // no se instala automáticamente
  final List<IActiveEffectData>? activeEffects;

  const IFrameTraitData({
    required this.name,
    required this.description,
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

/// Cada Frame tiene exactamente uno; no tiene `id` propio.
class ICoreSystemData {
  final String name;
  final String? description;
  final String activeName;
  final String activeEffect;
  final ActivationType activation;
  final ActivationType?
  deactivation; // si se omite: activo hasta `use` o fin de misión
  final CoreSystemUse? use;
  final List<IActiveEffectData>? activeEffects; // añadidos al mech al activar
  final List<IActionData>? activeActions;
  final List<IBonusData>? activeBonuses;
  final List<ISynergyData>? activeSynergies;
  final String? passiveName;
  final String? passiveEffect;
  final List<IActionData>? passiveActions; // siempre disponibles
  final List<IBonusData>? passiveBonuses; // siempre activos
  final List<ISynergyData>? passiveSynergies; // siempre activas
  final List<IDeployableData>?
  deployables; // usables desde el panel del Core System
  final List<ICounterData>? counters; // siempre presentes
  final List<String>? integrated; // siempre instalado
  final List<String>? specialEquipment; // siempre instalado
  final List<ITagInstance>? tags;

  const ICoreSystemData({
    required this.name,
    this.description,
    required this.activeName,
    required this.activeEffect,
    required this.activation,
    this.deactivation,
    this.use,
    this.activeEffects,
    this.activeActions,
    this.activeBonuses,
    this.activeSynergies,
    this.passiveName,
    this.passiveEffect,
    this.passiveActions,
    this.passiveBonuses,
    this.passiveSynergies,
    this.deployables,
    this.counters,
    this.integrated,
    this.specialEquipment,
    this.tags,
  });
}

// --- Sección 13.3 (Weapons) ---

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

// --- Sección 15.1 (NPC Classes) ---

/// Un valor puede ser un único entero (aplicado a los 3 tiers por igual) o
/// exactamente 3 enteros (uno por tier). Patrón repetido en casi todos los
/// campos de `stats` de [INpcClassData].
class TierValue {
  final num? single;
  final List<num>? perTier;

  const TierValue.single(this.single) : perTier = null;

  TierValue.perTier(List<num> values) : single = null, perTier = values {
    assert(
      values.length == 3,
      'TierValue.perTier requiere exactamente 3 elementos',
    );
  }

  num forTier(int tier) {
    assert(tier >= 1 && tier <= 3);
    return single ?? perTier![tier - 1];
  }
}

/// Caso especial, distinto de [TierValue]: un NPC puede tener varios
/// tamaños válidos simultáneamente dentro de un mismo tier. Valores válidos
/// por tier: 0.5 | 1 | 2 | 3 (valores mayores no soportados; no deberían
/// causar crash, pero no está garantizado).
class NpcSize {
  final List<List<num>> perTier; // exactamente 3 sub-arrays

  NpcSize(this.perTier)
    : assert(
        perTier.length == 3,
        'NpcSize requiere exactamente 3 sub-arrays (uno por tier)',
      );
}

// --- Sección 15.2 (NPC Features) ---

/// Variante restringida de [IDamageData]: `damage` es siempre un array de
/// exactamente 3 enteros (uno por tier), nunca una [DiceExpression].
class INpcDamageData {
  final DamageType type;
  final List<num> damage; // SIEMPRE 3 enteros
  final StringOrBool? aoe;
  final Object? save; // String | IDamageSaveData
  final bool? saveHalf;
  final bool? ap;
  final TargetType? target;

  INpcDamageData({
    required this.type,
    required this.damage,
    this.aoe,
    this.save,
    this.saveHalf,
    this.ap,
    this.target,
  }) : assert(
         damage.length == 3,
         'INpcDamageData.damage requiere exactamente 3 valores (uno por tier)',
       );
}

// --- Sección 15.3 (Eidolons) ---

/// Patrón nuevo, distinto de [TierValue]: además de entero único o array de
/// 3, admite el string literal `'hostile_characters'` con significado
/// dinámico (se resuelve en tiempo de ejecución por COMP/CON, no es un
/// valor fijo de catálogo).
class EidolonShardCount {
  final num? single;
  final List<num>? perTier;
  final bool hostileCharacters;

  const EidolonShardCount.single(this.single)
    : perTier = null,
      hostileCharacters = false;

  EidolonShardCount.perTier(List<num> values)
    : single = null,
      perTier = values,
      hostileCharacters = false {
    assert(values.length == 3);
  }

  const EidolonShardCount.hostileCharacters()
    : single = null,
      perTier = null,
      hostileCharacters = true;
}

/// No tiene `id` propio; vive anidado dentro de un [IEidolonLayerData].
class IEidolonShardData {
  final EidolonShardCount count;
  final String detail;
  final List<INpcFeatureData> features;
  final int? tier; // si se omite, usa el tier del layer padre

  const IEidolonShardData({
    required this.count,
    required this.detail,
    required this.features,
    this.tier,
  });
}

// --- Sección 17.1 (Manifest) ---

/// String con gramática propia, mismo criterio que [DiceExpression]/
/// [MountAssignment]. Formas válidas: `"X.Y.Z"` (versión mínima, acepta esa
/// o cualquier posterior), `"*"` (cualquier versión), `"=X.Y.Z"`
/// (exclusivamente esa versión exacta).
class SemverConstraint {
  final String value;
  SemverConstraint(this.value)
    : assert(_pattern.hasMatch(value), 'SemverConstraint inválida: $value');
  static final RegExp _pattern = RegExp(r'^(\*|=?\d+\.\d+\.\d+)$');
}

class IChangelogItem {
  final String version; // semver estricto X.Y.Z, sin modificadores
  final String date; // YYYY-MM-DD
  final List<String> changes;
  const IChangelogItem({
    required this.version,
    required this.date,
    required this.changes,
  });
}

class ILcpDependency {
  final String
  name; // debe coincidir EXACTAMENTE con el `name` del manifest de la dependencia
  final SemverConstraint version;
  final String? link;
  const ILcpDependency({required this.name, required this.version, this.link});
}

// --- Sección 17.3 (SITREPs) ---

class ISitrepCondition {
  final String title;
  final String condition;
  const ISitrepCondition({required this.title, required this.condition});
}
