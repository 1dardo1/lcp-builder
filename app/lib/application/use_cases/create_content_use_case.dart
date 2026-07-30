import '../../domain/domain.dart';
import '../../domain/ports/content_pack_exporter.dart';
import '../../domain/ports/file_writer.dart';

/// Create use case, generic for any domain entity (not just weapon) and for
/// any number of them at once (a `.lcp` with several weapons and one frame,
/// for example — see `CreateSession` in `presentation/`). It orchestrates
/// domain + ports — it doesn't know `infrastructure/` specifically, only the
/// `domain/ports` interfaces, injected by whoever builds the use case
/// (`presentation/` or, for now, `bin/` for the headless verification).
///
/// `content` uses the same shape `ContentPackExporter.export` expects:
/// `contentKey` (file name inside the `.lcp`, without `.json`, e.g.
/// `'weapons'`) → list of already-assembled entities of that type. The use
/// case doesn't decide that shape, it only forwards it — the ones that decide
/// it are each entity schema (`contentKey`) and the Create session (how many
/// entities of each type were accumulated).
class CreateContentUseCase {
  final ContentPackExporter exporter;
  final FileWriter fileWriter;

  const CreateContentUseCase({
    required this.exporter,
    required this.fileWriter,
  });

  /// Builds a `.lcp` with all the given content and the given manifest, and
  /// writes it to `outputPath`.
  Future<void> call({
    required Map<String, List<Object>> content,
    required ILcpManifestData manifest,
    required String outputPath,
  }) async {
    final bytes = exporter.export(manifest: manifest, content: content);
    await fileWriter.write(outputPath, bytes);
  }
}
