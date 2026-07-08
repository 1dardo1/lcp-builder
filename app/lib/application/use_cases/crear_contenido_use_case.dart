import '../../domain/domain.dart';
import '../../domain/ports/content_pack_exporter.dart';
import '../../domain/ports/file_writer.dart';

/// Caso de uso Crear, genérico para cualquier entidad del dominio (no solo
/// arma) y para cualquier número de ellas a la vez (un `.lcp` con varias
/// armas y un frame, por ejemplo — ver `CrearSession` en `presentation/`).
/// Orquesta dominio + puertos — no conoce `infrastructure/` en concreto,
/// solo las interfaces de `domain/ports`, inyectadas por quien construya el
/// caso de uso (`presentation/` o, por ahora, `bin/` para la verificación
/// headless).
///
/// `content` usa la misma forma que espera `ContentPackExporter.export`:
/// `contentKey` (nombre de archivo dentro del `.lcp`, sin `.json`, ej.
/// `'weapons'`) → lista de entidades ya ensambladas de ese tipo. El caso de
/// uso no decide esa forma, solo la reenvía — quien la decide es cada
/// esquema de entidad (`contentKey`) y la sesión de Crear (cuántas
/// entidades de cada tipo se acumularon).
class CrearContenidoUseCase {
  final ContentPackExporter exporter;
  final FileWriter fileWriter;

  const CrearContenidoUseCase({
    required this.exporter,
    required this.fileWriter,
  });

  /// Construye un `.lcp` con todo el contenido dado y el manifest indicado,
  /// y lo escribe en `outputPath`.
  Future<void> call({
    required Map<String, List<Object>> content,
    required ILcpManifestData manifest,
    required String outputPath,
  }) async {
    final bytes = exporter.export(manifest: manifest, content: content);
    await fileWriter.write(outputPath, bytes);
  }
}
