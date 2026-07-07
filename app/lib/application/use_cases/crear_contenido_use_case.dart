import '../../domain/domain.dart';
import '../../domain/ports/content_pack_exporter.dart';
import '../../domain/ports/file_writer.dart';

/// Caso de uso Crear, genérico para cualquier entidad del dominio (no solo
/// arma). Orquesta dominio + puertos — no conoce `infrastructure/` en
/// concreto, solo las interfaces de `domain/ports`, inyectadas por quien
/// construya el caso de uso (`presentation/` o, por ahora, `bin/` para la
/// verificación headless).
///
/// `contentKey` es el nombre de archivo dentro del `.lcp` (sin `.json`,
/// ej. `'weapons'`, `'manufacturers'`) — lo decide el esquema de cada
/// entidad, no el motor genérico.
class CrearContenidoUseCase {
  final ContentPackExporter exporter;
  final FileWriter fileWriter;

  const CrearContenidoUseCase({
    required this.exporter,
    required this.fileWriter,
  });

  /// Construye un `.lcp` de un único elemento de contenido con el manifest
  /// dado y lo escribe en `outputPath`.
  Future<void> call({
    required String contentKey,
    required Object content,
    required ILcpManifestData manifest,
    required String outputPath,
  }) async {
    final bytes = exporter.export(
      manifest: manifest,
      content: {
        contentKey: [content],
      },
    );
    await fileWriter.write(outputPath, bytes);
  }
}
