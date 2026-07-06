import '../value_objects/value_objects.dart';
import 'npc_feature_data.dart';

/// Sección 15.3 del modelo de dominio. Entidad de catálogo (varias layers
/// por Eidolon). Contenido condicionado a un suplemento (mismo caso que
/// Bonds, §11.7). `rules` admite sintaxis `{X/Y/Z}` — tercera forma de
/// variabilidad por tier de esta spec, distinta de [TierValue]/[NpcSize].
/// Ver vault MdD §15.3.
class IEidolonLayerData {
  final String id; // único globalmente
  final String name;
  final String appearance; // v-html
  final String hints; // v-html, dirigido a jugadores
  final String rules; // v-html, admite sintaxis {X/Y/Z}
  final List<INpcFeatureData>? features;
  final IEidolonShardData? shards;
  final List<IActiveEffectData>? activeEffects;

  const IEidolonLayerData({
    required this.id,
    required this.name,
    required this.appearance,
    required this.hints,
    required this.rules,
    this.features,
    this.shards,
    this.activeEffects,
  });
}
