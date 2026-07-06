/// Sección 6 del modelo de dominio.
///
/// Entidad de catálogo: `id` identifica una entrada única y persistente del
/// catálogo de tags (core data o `tags.json` de un LCP), no una instancia de
/// uso — eso es [ITagInstance] (en value_objects.dart). Un LCP puede añadir
/// (y en teoría versionar) sus propias entradas de tag.
class ITagData {
  final String id;
  final String name;
  final String description; // v-html, puede contener el token {VAL}
  final bool? hidden; // usado para features de UI interna; no se puede añadir desde una LCP
  final bool? filterIgnore; // evita que aparezca en los filtros de equipo de la UI

  const ITagData({
    required this.id,
    required this.name,
    required this.description,
    this.hidden,
    this.filterIgnore,
  });
}
