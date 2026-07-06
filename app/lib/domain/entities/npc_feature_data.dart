import '../value_objects/value_objects.dart';

/// Sección 15.2 del modelo de dominio.
///
/// Entidad de catálogo, union discriminada por `type` con 5 variantes que
/// comparten una base común. Igual que [IPilotGearData], el discriminador
/// vive en el tipo Dart (jerarquía sellada), no como campo redundante.
/// Default en la spec si se omite `type`: `trait`.
sealed class INpcFeatureData {
  final String id; // único globalmente
  final String name;
  final String? origin; // id de NPC Class/Template de origen — ver nota
  final bool? base; // default false — si true, asignado automáticamente vía clase/template
  final bool? deprecated;
  final TextOrActiveEffect? effect;
  final bool? hideActive;
  final bool? buildFeature; // sin efecto en combate; siempre oculto en Active Mode
  final String? mod; // id de otra INpcFeatureData a la que esta feature modifica — ver nota
  final List<ITagInstance>? tags;
  final List<IActionData>? actions; // NPCs ignoran cost/pilot/synergy_locations/tech_attack/log
  final List<IBonusData>? bonuses;
  final List<ISynergyData>? synergies;
  final List<IDeployableData>? deployables; // NPCs ignoran varios campos, ver IDeployableData

  const INpcFeatureData({
    required this.id,
    required this.name,
    this.origin,
    this.base,
    this.deprecated,
    this.effect,
    this.hideActive,
    this.buildFeature,
    this.mod,
    this.tags,
    this.actions,
    this.bonuses,
    this.synergies,
    this.deployables,
  });
}

class INpcTraitFeatureData extends INpcFeatureData {
  const INpcTraitFeatureData({
    required super.id,
    required super.name,
    super.origin,
    super.base,
    super.deprecated,
    super.effect,
    super.hideActive,
    super.buildFeature,
    super.mod,
    super.tags,
    super.actions,
    super.bonuses,
    super.synergies,
    super.deployables,
  });
}

/// Estructuralmente idéntico a [INpcTraitFeatureData]; existe solo para
/// agrupar visualmente en la UI de COMP/CON, sin diferencia de campos ni de
/// comportamiento mecánico.
class INpcSystemFeatureData extends INpcFeatureData {
  const INpcSystemFeatureData({
    required super.id,
    required super.name,
    super.origin,
    super.base,
    super.deprecated,
    super.effect,
    super.hideActive,
    super.buildFeature,
    super.mod,
    super.tags,
    super.actions,
    super.bonuses,
    super.synergies,
    super.deployables,
  });
}

class INpcReactionFeatureData extends INpcFeatureData {
  final String? trigger;
  const INpcReactionFeatureData({
    required super.id,
    required super.name,
    super.origin,
    super.base,
    super.deprecated,
    super.effect,
    super.hideActive,
    super.buildFeature,
    super.mod,
    super.tags,
    super.actions,
    super.bonuses,
    super.synergies,
    super.deployables,
    this.trigger,
  });
}

class INpcTechFeatureData extends INpcFeatureData {
  final TierValue? attackBonus;
  final TierValue? accuracy;
  const INpcTechFeatureData({
    required super.id,
    required super.name,
    super.origin,
    super.base,
    super.deprecated,
    super.effect,
    super.hideActive,
    super.buildFeature,
    super.mod,
    super.tags,
    super.actions,
    super.bonuses,
    super.synergies,
    super.deployables,
    this.attackBonus,
    this.accuracy,
  });
}

/// `weaponType` es formato "{Size} {Type}" (ej. "Superheavy Rifle") — solo
/// UI hoy, mantener la convención por si se usa mecánicamente en el futuro.
class INpcWeaponFeatureData extends INpcFeatureData {
  final String weaponType;
  final List<INpcDamageData> damage;
  final List<IRangeData> range;
  final TierValue attacks;
  final TierValue? attackBonus;
  final TierValue? accuracy;
  final IActiveEffectData? onAttack;
  final IActiveEffectData? onHit;
  final IActiveEffectData? onCrit;
  final IActiveEffectData? onMiss;

  const INpcWeaponFeatureData({
    required super.id,
    required super.name,
    super.origin,
    super.base,
    super.deprecated,
    super.effect,
    super.hideActive,
    super.buildFeature,
    super.mod,
    super.tags,
    super.actions,
    super.bonuses,
    super.synergies,
    super.deployables,
    required this.weaponType,
    required this.damage,
    required this.range,
    required this.attacks,
    this.attackBonus,
    this.accuracy,
    this.onAttack,
    this.onHit,
    this.onCrit,
    this.onMiss,
  });
}
