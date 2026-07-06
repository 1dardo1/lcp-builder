import '../enums/enums.dart';
import '../value_objects/value_objects.dart';

/// Sección 15.1 del modelo de dominio. Entidad de catálogo, mismo patrón
/// que [INpcClassData].
///
/// Nota — cálculo aditivo de `optionalPerTier`: mismo mecanismo que
/// `optionalClassPerTier` en [INpcClassData] — se multiplica por el tier
/// actual y se suma a `optionalMin`/`optionalMax`, no los sustituye.
class INpcTemplateData {
  final String id; // único globalmente
  final bool
  template; // literal true — validación de seguridad en formatos de colección
  final String name;
  final String description; // v-html
  final NpcForceTag?
  forceTag; // bloquea el tag NPC, impide modificación por el usuario
  final List<String>?
  prohibitTemplates; // IDs de templates cuya aplicación conjunta se prohíbe
  final int? optionalMin; // default 0 — no restringido a features del template
  final int? optionalMax;
  final int? optionalPerTier; // ver nota de cálculo aditivo
  final int? optionalClassMin;
  final int? optionalClassMax;
  final int? optionalClassPerTier;
  final String?
  caveat; // reglas especiales no trackeadas mecánicamente por COMP/CON
  final List<IActiveEffectData>? activeEffects;

  const INpcTemplateData({
    required this.id,
    this.template = true,
    required this.name,
    required this.description,
    this.forceTag,
    this.prohibitTemplates,
    this.optionalMin,
    this.optionalMax,
    this.optionalPerTier,
    this.optionalClassMin,
    this.optionalClassMax,
    this.optionalClassPerTier,
    this.caveat,
    this.activeEffects,
  });
}
