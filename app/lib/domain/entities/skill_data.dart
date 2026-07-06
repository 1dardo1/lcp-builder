import '../enums/enums.dart';

/// Sección 11.5 del modelo de dominio. Entidad de catálogo.
class ISkillData {
  final String id; // único globalmente
  final String name;
  final String description; // v-html, terso recomendado
  final String detail; // v-html, flavor text
  final SkillFamily family; // solo posición en la lista, sin efecto mecánico

  const ISkillData({
    required this.id,
    required this.name,
    required this.description,
    required this.detail,
    required this.family,
  });
}
