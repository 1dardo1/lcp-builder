import '../entities/lcp_manifest_data.dart';

/// Hexagonal port for Edit, the inverse of [ContentPackReader] rather than
/// [ContentPackExporter]: serializes content that already comes as raw JSON
/// (`Map<String, dynamic>` per entity, the same shape [ContentPackReader]
/// produces), not typed domain objects.
///
/// Why not reuse [ContentPackExporter] as-is: Edit saves a
/// `ParsedContentPack` where only the entity the user touched was rebuilt as
/// a domain object (via `fromFormValues`, to reuse the same Create form) —
/// the rest stays as raw JSON exactly as it was read, precisely so as not to
/// risk losing information by forcing a typed reconstruction nobody asked
/// for. An exporter that only accepts domain objects would force "inventing"
/// a typed object for every untouched entity, with the risk that the
/// reconstruction isn't perfect — this port avoids that problem at the root:
/// it never rebuilds anything that wasn't edited.
abstract class RawContentPackExporter {
  List<int> export({
    required ILcpManifestData manifest,
    required Map<String, List<Map<String, dynamic>>> content,
  });
}
