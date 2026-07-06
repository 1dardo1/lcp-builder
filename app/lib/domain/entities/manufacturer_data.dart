/// Sección 13.1 del modelo de dominio.
///
/// Excepciones de `source` (Special/Integrated/Exotic Equipment) — ver
/// vault MdD §13.6.
class IManufacturerData {
  final String id; // forma acrónimo/abreviada, ej. GMS
  final String name;
  final String description; // v-html
  final String quote; // v-html
  final String light; // hex #XXXXXX, temas de UI base 'light'
  final String dark; // hex #XXXXXX, temas de UI base 'dark'
  final String? iconSvg; // preferido sobre icon_url
  final String? iconUrl; // fallback si no hay icon_svg

  const IManufacturerData({
    required this.id,
    required this.name,
    required this.description,
    required this.quote,
    required this.light,
    required this.dark,
    this.iconSvg,
    this.iconUrl,
  });
}
