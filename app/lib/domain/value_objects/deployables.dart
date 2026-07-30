/// Deployable value objects (vault domain model, section 8).
library;

import '../enums/enums.dart';
import '../entities/counter_data.dart';
import 'actions_and_active_effects.dart';
import 'bonuses.dart';
import 'damage_and_range.dart';
import 'effects.dart';
import 'synergies.dart';
import 'tags.dart';

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
