import '../enums/enums.dart';
import '../value_objects/value_objects.dart';

class INpcClassInfo {
  final String flavor; // texto de Compendium
  final String tactics; // nota de estrategia para el GM
  final String terse; // resumen ultra-corto para el GM
  const INpcClassInfo({
    required this.flavor,
    required this.tactics,
    required this.terse,
  });
}

class INpcClassStats {
  final TierValue armor;
  final TierValue hp;
  final TierValue evade;
  final TierValue edef;
  final TierValue heatcap;
  final TierValue speed;
  final TierValue sensor;
  final TierValue save;
  final TierValue hull;
  final TierValue agility;
  final TierValue systems;
  final TierValue engineering;
  final NpcSize size; // forma especial, ver NpcSize
  final TierValue activations;

  const INpcClassStats({
    required this.armor,
    required this.hp,
    required this.evade,
    required this.edef,
    required this.heatcap,
    required this.speed,
    required this.sensor,
    required this.save,
    required this.hull,
    required this.agility,
    required this.systems,
    required this.engineering,
    required this.size,
    required this.activations,
  });
}

/// Sección 15.1 del modelo de dominio.
///
/// `optionalClassPerTier` — cálculo aditivo con min/max, ver vault MdD §15.1.
class INpcClassData {
  final String id; // único globalmente
  final String name;
  final NpcRole role; // COMP/CON no soporta multi-rol
  final INpcClassInfo info;
  final INpcClassStats stats;
  final int? optionalClassMin; // default 0
  final int? optionalClassMax;
  final int? optionalClassPerTier; // ver nota de cálculo aditivo
  final List<IActiveEffectData>? activeEffects;

  const INpcClassData({
    required this.id,
    required this.name,
    required this.role,
    required this.info,
    required this.stats,
    this.optionalClassMin,
    this.optionalClassMax,
    this.optionalClassPerTier,
    this.activeEffects,
  });
}
