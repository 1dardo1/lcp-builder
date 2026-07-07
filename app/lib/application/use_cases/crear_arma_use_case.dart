import '../../domain/domain.dart';
import '../../domain/ports/content_pack_exporter.dart';
import '../../domain/ports/file_writer.dart';

/// Caso de uso Crear (primera entidad: arma). Orquesta dominio + puertos —
/// no conoce `infrastructure/` en concreto, solo las interfaces de
/// `domain/ports`, inyectadas por quien construya el caso de uso
/// (`presentation/` o, por ahora, `bin/` para la verificación headless).
class CrearArmaUseCase {
  final ContentPackExporter exporter;
  final FileWriter fileWriter;

  const CrearArmaUseCase({required this.exporter, required this.fileWriter});

  /// Construye un `.lcp` de un único arma con el manifest dado y lo
  /// escribe en `outputPath`.
  Future<void> call({
    required IWeaponData weapon,
    required ILcpManifestData manifest,
    required String outputPath,
  }) async {
    final bytes = exporter.exportWeapons(manifest: manifest, weapons: [weapon]);
    await fileWriter.write(outputPath, bytes);
  }
}
