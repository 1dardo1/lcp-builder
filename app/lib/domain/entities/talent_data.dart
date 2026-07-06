import '../value_objects/value_objects.dart';

/// Sección 11.6 del modelo de dominio. Restricción de 3 ranks (COMP/CON)
/// no forzada aquí como invariante bloqueante — ver vault MdD §11.6.
class ITalentData {
  final String id; // único globalmente
  final String name;
  final String description; // v-html
  final List<IRankData> ranks; // hoy: exactamente 3 en la práctica de COMP/CON
  final String? iconSvg; // sanitizado (DOMPurify), preferido sobre icon_url
  final String? iconUrl; // fallback, también sanitizado
  final String? terse; // descripción corta para UI condensada

  const ITalentData({
    required this.id,
    required this.name,
    required this.description,
    required this.ranks,
    this.iconSvg,
    this.iconUrl,
    this.terse,
  });
}
