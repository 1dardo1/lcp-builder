import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/application/use_cases/crear_contenido_use_case.dart';
import 'package:lcp_builder/application/use_cases/mostrar_contenido_use_case.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/infrastructure/file_system/local_file_reader.dart';
import 'package:lcp_builder/infrastructure/file_system/local_file_writer.dart';
import 'package:lcp_builder/infrastructure/lcp/zip_content_pack_exporter.dart';
import 'package:lcp_builder/infrastructure/lcp/zip_content_pack_reader.dart';

/// Test de aceptación end-to-end de Mostrar: genera un `.lcp` real en
/// disco con `CrearContenidoUseCase` (ya probado por su cuenta) y lo
/// vuelve a leer con `MostrarContenidoUseCase`, confirmando que ambos
/// extremos del ciclo (Crear escribe, Mostrar lee) encajan de verdad —
/// no solo cada mitad probada por separado.
void main() {
  test('lee de vuelta un .lcp generado por CrearContenidoUseCase', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'mostrar_contenido_use_case_test',
    );
    final outputPath = '${tempDir.path}/paquete.lcp';

    try {
      await CrearContenidoUseCase(
        exporter: ZipContentPackExporter(),
        fileWriter: LocalFileWriter(),
      )(
        content: {
          'manufacturers': const [
            IManufacturerData(
              id: 'GMS',
              name: 'General Manufacturing Systems',
              description: 'd',
              quote: 'q',
              light: '#FFFFFF',
              dark: '#000000',
            ),
          ],
        },
        manifest: const ILcpManifestData(
          name: 'Paquete de prueba',
          author: 'Test',
          description: 'desc',
          version: '1.0.0',
        ),
        outputPath: outputPath,
      );

      final parsed = await MostrarContenidoUseCase(
        fileReader: LocalFileReader(),
        contentPackReader: ZipContentPackReader(),
      )(outputPath);

      expect(parsed.manifest.name, 'Paquete de prueba');
      expect(parsed.contentByKey['manufacturers'], hasLength(1));
      expect(parsed.contentByKey['manufacturers']!.first['id'], 'GMS');
    } finally {
      await tempDir.delete(recursive: true);
    }
  });
}
