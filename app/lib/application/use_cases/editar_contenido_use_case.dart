import '../../domain/ports/file_writer.dart';
import '../../domain/ports/raw_content_pack_exporter.dart';
import '../../domain/ports/content_pack_reader.dart';

/// Caso de uso Editar: reexporta un [ParsedContentPack] ya editado
/// (`EditSession`) a su [outputPath] original. A diferencia de
/// [CrearContenidoUseCase], no reconstruye ningún objeto de dominio —
/// [ParsedContentPack.contentByKey] ya es JSON crudo (las entidades
/// editadas se convirtieron a JSON en el momento de guardar el
/// formulario; las no tocadas nunca dejaron de serlo), así que solo hay
/// que volver a comprimirlo.
class EditarContenidoUseCase {
  final RawContentPackExporter exporter;
  final FileWriter fileWriter;

  const EditarContenidoUseCase({
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
