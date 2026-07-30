import '../entities/lcp_manifest_data.dart';

/// Hexagonal port, the inverse of [ContentPackExporter]: interprets the
/// bytes of an existing `.lcp` for the Show flow.
///
/// Deliberately does NOT rebuild the 24 domain types of each entity — Show
/// only needs to read and render what's there, not operate on it (unlike
/// Create, which does need the real type to assemble it and export it
/// again), so the per-entity-type content stays as raw JSON. The manifest is
/// fully typed — the listing screens need it as-is (pack name, author...),
/// and it's a single type, not 24.
abstract class ContentPackReader {
  ParsedContentPack read(List<int> bytes);
}

/// Result of reading a `.lcp`: the typed manifest, and the rest of the
/// content indexed by `contentKey` (same name as the file inside the zip,
/// without `.json` — e.g. `'weapons'`), each entity still as the
/// `Map<String, dynamic>` exactly as it came in the JSON.
class ParsedContentPack {
  final ILcpManifestData manifest;
  final Map<String, List<Map<String, dynamic>>> contentByKey;

  const ParsedContentPack({
    required this.manifest,
    required this.contentByKey,
  });
}
