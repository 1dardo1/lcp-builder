/// Eidolon value objects: shard counts and shard data (vault domain model,
/// section 15.3).
library;

import '../entities/npc_feature_data.dart';

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
