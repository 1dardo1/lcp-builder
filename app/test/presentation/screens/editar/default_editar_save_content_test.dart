import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/application/use_cases/crear_contenido_use_case.dart';
import 'package:lcp_builder/application/use_cases/mostrar_contenido_use_case.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/infrastructure/file_system/local_file_reader.dart';
import 'package:lcp_builder/infrastructure/file_system/local_file_writer.dart';
import 'package:lcp_builder/infrastructure/lcp/zip_content_pack_exporter.dart';
import 'package:lcp_builder/infrastructure/lcp/zip_content_pack_reader.dart';
import 'package:lcp_builder/presentation/screens/editar/editar_entity_types_screen.dart';

/// Regresión: `EditarEntityTypesScreen._guardar()` construía su valor por
/// defecto de `saveContent` como `widget.saveContent ??
/// EditarContenidoUseCase(...).call` sin anotar el tipo — como
/// `EditarContenidoUseCase.call` usa parámetros nombrados y el campo
/// `saveContent` espera una función posicional, Dart no encontraba un tipo
/// de función común entre ambos lados del `??` e inferría el genérico
/// `Function`, que acepta cualquier forma de llamada en tiempo de
/// compilación (sin error de `flutter analyze` ni fallo de los tests
/// existentes, que siempre inyectaban `saveContent`) y solo fallaba al
/// invocarse de verdad — visto por el equipo de desarrollo como
/// `NoSuchMethodError: Closure call with mismatched arguments` guardando un
/// `.lcp` editado en Android real. `defaultEditarSaveContent()` es ahora el
/// adapter extraído (con tipo estático explícito) que sustituye a ese
/// fallback inline — este test lo ejercita de verdad, con E/S real a
/// disco, sin montar ningún widget (evita el problema ya documentado en
/// `editar_contenido_use_case_test.dart` de E/S real dentro de
/// `pump`/`pumpAndSettle`, que no se resuelve de forma fiable).
void main() {
  test(
    'defaultEditarSaveContent() invoca EditarContenidoUseCase con la forma '
    'correcta y escribe de verdad en disco',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'default_editar_save_content_test',
      );
      final path = '${tempDir.path}/paquete.lcp';

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
          outputPath: path,
        );

        final mostrar = MostrarContenidoUseCase(
          fileReader: LocalFileReader(),
          contentPackReader: ZipContentPackReader(),
        );
        final pack = await mostrar(path);

        // Llamada posicional, tal y como la hace
        // `EditarEntityTypesScreen._guardar()` — si volviera a mezclarse
        // con la firma de parámetros nombrados de
        // `EditarContenidoUseCase.call`, esto lanzaría un
        // NoSuchMethodError en tiempo de ejecución.
        await defaultEditarSaveContent()(pack, path);

        final reread = await mostrar(path);
        expect(
          reread.contentByKey['manufacturers']!.first['name'],
          'General Manufacturing Systems',
        );
      } finally {
        await tempDir.delete(recursive: true);
      }
    },
  );
}
