import '../../domain/ports/file_writer.dart';
import '../../domain/ports/raw_content_pack_exporter.dart';
import '../../domain/ports/content_pack_reader.dart';

/// Edit use case: re-exports an already-edited [ParsedContentPack]
/// (`EditSession`) to its original [outputPath]. Unlike [CreateContentUseCase],
/// it doesn't rebuild any domain object — [ParsedContentPack.contentByKey] is
/// already raw JSON (the edited entities were converted to JSON when the form
/// was saved; the untouched ones never stopped being JSON), so it only needs
/// to be re-zipped.
class EditContentUseCase {
  final RawContentPackExporter exporter;
  final FileWriter fileWriter;

  const EditContentUseCase({
    required this.exporter,
    required this.fileWriter,
  });

  Future<void> call({
    required ParsedContentPack pack,
    required String outputPath,
  }) async {
    final bytes = exporter.export(
      manifest: pack.manifest,
      content: pack.contentByKey,
    );
    await fileWriter.write(outputPath, bytes);
  }
}
