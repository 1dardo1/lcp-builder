import '../entities/lcp_manifest_data.dart';

/// Hexagonal port: serializes domain content to the `.lcp` format (bytes of
/// a single-level zip with `lcp_manifest.json` + one JSON per content type,
/// see `infrastructure/lcp`). It is not platform-specific — unlike
/// [FileWriter], it doesn't need a different adapter per platform, but it
/// still lives behind a port so that `application/use_cases` doesn't depend
/// on `infrastructure/` directly.
///
/// Deliberately entity-agnostic: `content` is a map from file name (without
/// `.json`, e.g. `'weapons'`, `'manufacturers'`) to the list of domain
/// objects of that type. The port doesn't need to know the 24 entities — the
/// one that does (and knows how to translate each to JSON) is the
/// implementation in `infrastructure/lcp/zip_content_pack_exporter.dart`.
abstract class ContentPackExporter {
  List<int> export({
    required ILcpManifestData manifest,
    required Map<String, List<Object>> content,
  });
}
