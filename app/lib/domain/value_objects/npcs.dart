/// NPC value objects: tier values, sizes and per-tier damage (vault domain
/// model, sections 15.1 and 15.2).
library;

import '../enums/enums.dart';
import 'shared_value_types.dart';

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
