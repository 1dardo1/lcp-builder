import '../entities/lcp_manifest_data.dart';

/// Puerto hexagonal: serializa contenido del dominio al formato `.lcp`
/// (bytes de un zip de un solo nivel con `lcp_manifest.json` + un JSON por
/// tipo de contenido, ver `infrastructure/lcp`). No es específico de
/// plataforma — a diferencia de [FileWriter], no necesita un adapter
/// distinto por plataforma, pero vive detrás de un puerto igualmente para
/// que `application/use_cases` no dependa de `infrastructure/` en directo.
///
/// Deliberadamente agnóstico de entidad: `content` es un mapa de nombre de
/// archivo (sin `.json`, ej. `'weapons'`, `'manufacturers'`) a la lista de
/// objetos de dominio de ese tipo. El puerto no necesita conocer las 24
/// entidades — quien sí las conoce (y sabe traducir cada una a JSON) es la
/// implementación en `infrastructure/lcp/zip_content_pack_exporter.dart`.
abstract class ContentPackExporter {
  List<int> export({
    required ILcpManifestData manifest,
    required Map<String, List<Object>> content,
  });
}
