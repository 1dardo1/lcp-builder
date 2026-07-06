import '../value_objects/value_objects.dart';
import 'npc_feature_data.dart';

/// Sección 15.3 del modelo de dominio.
///
/// Entidad de catálogo: cada Eidolon se compone de varias layers; la
/// primera ("Core Layer") se asigna automáticamente a cualquier Eidolon.
///
/// Contenido condicionado a un suplemento: solo disponible si el LCP GM
/// "No Room For a Wallflower" está instalado y activado (mismo caso que
/// Bonds, sección 11.7).
///
/// Nota — sintaxis `{X/Y/Z}` en `rules`: tercera forma de variabilidad por
/// tier de esta spec (distinta de [TierValue] y de [NpcSize]) — la
/// interpolación ocurre dentro de un bloque de texto en prosa, sustituyendo
/// por X/Y/Z según el tier 1/2/3 del contexto.
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
