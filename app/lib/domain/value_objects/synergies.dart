/// Synergy value objects (vault domain model, section 5).
library;

import '../enums/enums.dart';

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
