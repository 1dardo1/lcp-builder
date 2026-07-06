/// Sección 6 del modelo de dominio. Distinto de [ITagInstance]
/// (value_objects.dart): esto es el catálogo, no la instancia de uso.
class ITagData {
  final String id;
  final String name;
  final String description; // v-html, puede contener el token {VAL}
  final bool?
  hidden; // usado para features de UI interna; no se puede añadir desde una LCP
  final bool?
  filterIgnore; // evita que aparezca en los filtros de equipo de la UI

  const ITagData({
    required this.id,
    required this.name,
    required this.description,
    this.hidden,
    this.filterIgnore,
  });
}
