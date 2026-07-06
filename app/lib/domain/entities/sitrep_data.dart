import '../value_objects/value_objects.dart';

/// Sección 17.3 del modelo de dominio.
///
/// `pcVictory`/`enemyVictory`/`noVictory` confirmados oficiales contra
/// fuentes independientes (la Wiki los omite) — no quitarlos por parecer
/// no documentados. `conditions` es el caso inverso: sin confirmación
/// cruzada. Ver vault MdD §17.3.
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
