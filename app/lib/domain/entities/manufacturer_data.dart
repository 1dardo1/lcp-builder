/// Sección 13.1 del modelo de dominio.
///
/// Entidad de catálogo: referenciado por `source` desde Core Bonuses,
/// Frames y todo el equipo licenciado. `id` debe ser único globalmente —
/// es la clave por la que se referencia desde el resto del LCP.
///
/// Nota — excepciones de `source`: Special Equipment, Integrated Equipment
/// y Exotic Equipment no requieren manufacturer asociado (ver sección 13.6
/// del vault — no son tipos de dato propios, son mecanismos de instalación).
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
