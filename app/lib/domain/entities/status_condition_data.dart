import '../enums/enums.dart';

/// Sección 17.4 del modelo de dominio. Entidad de catálogo.
///
/// Cierra la referencia pendiente de `IStatusEffectData.id` (sección 2,
/// value_objects.dart): "debe existir en core data o LCP statuses.json
/// cargado" apunta a este catálogo.
class IStatusConditionData {
  final String id; // único globalmente — referenciado por IStatusEffectData.id
  final String name;
  final StatusConditionType type; // case-sensitive
  final String effects; // v-html
  final String? terse; // preferir el menor número de caracteres posible
  final String? iconSvg;
  final String? iconUrl;
  final ExclusiveTarget?
  exclusive; // si está presente, restringe a quién puede aplicarse

  const IStatusConditionData({
    required this.id,
    required this.name,
    required this.type,
    required this.effects,
    this.terse,
    this.iconSvg,
    this.iconUrl,
    this.exclusive,
  });
}
