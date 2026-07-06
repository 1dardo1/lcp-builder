import '../value_objects/value_objects.dart';

/// Sección 17.3 del modelo de dominio. Entidad de catálogo.
///
/// `pcVictory`/`enemyVictory`/`noVictory` confirmados como oficiales
/// contra múltiples fuentes independientes (npm `@massif/lancer-data`,
/// Skypack, Openbase, fork whitespine) — la página de la Wiki consultada
/// tenía una definición incompleta que no los incluía.
///
/// `conditions` aparece en la Wiki pero no en npm/Skypack — se mantiene por
/// precaución (podría ser un añadido v3 posterior a esas publicaciones),
/// pero sin confirmación cruzada (caso inverso al de los campos de victoria).
class ISitrepData {
  final String id; // único globalmente
  final String name;
  final String description; // v-html
  final String? deployment; // v-html
  final String? objective; // v-html
  final String? extraction; // v-html
  final List<ISitrepCondition>? conditions; // no confirmado de forma cruzada
  final String? pcVictory; // v-html — confirmado oficial
  final String? enemyVictory; // v-html — confirmado oficial
  final String? noVictory; // v-html — confirmado oficial

  const ISitrepData({
    required this.id,
    required this.name,
    required this.description,
    this.deployment,
    this.objective,
    this.extraction,
    this.conditions,
    this.pcVictory,
    this.enemyVictory,
    this.noVictory,
  });
}
