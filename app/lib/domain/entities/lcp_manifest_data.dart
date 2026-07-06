import '../value_objects/value_objects.dart';

/// Sección 17.1 del modelo de dominio.
///
/// Entidad: un único manifest por LCP, identificado de facto por la
/// combinación `name` + `version` (sin campo `id` explícito, a diferencia
/// del resto de catálogos). Obligatorio en todo LCP — sin él, COMP/CON no
/// puede cargar el contenido.
class ILcpManifestData {
  final String name;
  final String author;
  final String description; // v-html
  final String version; // semver estricto X.Y.Z
  final String? imageUrl;
  final String?
  website; // requerido SOLO para envíos al Community Content Directory (itch.io)
  final List<ILcpDependency>? dependencies;
  final bool? v3; // default false — fuertemente recomendado true en LCPs nuevos
  final List<IChangelogItem>? versionHistory;

  const ILcpManifestData({
    required this.name,
    required this.author,
    required this.description,
    required this.version,
    this.imageUrl,
    this.website,
    this.dependencies,
    this.v3,
    this.versionHistory,
  });
}
