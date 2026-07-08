import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/application/use_cases/crear_contenido_use_case.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/domain/ports/file_writer.dart';
import 'package:lcp_builder/infrastructure/lcp/zip_content_pack_exporter.dart';
import 'package:lcp_builder/presentation/session/crear_session.dart';
import 'package:lcp_builder/presentation/session/finalizar_lcp.dart';

import '../../support/fake_file_selector_platform.dart';
import '../../support/test_app.dart';

/// Doble de test de `FileWriter` — sin él, un test de widget que ejercite
/// `finalizarLcp` de punta a punta arrastraría E/S real de `dart:io`
/// (`LocalFileWriter`), que no se resuelve de forma fiable con
/// `pump`/`pumpAndSettle`: la escritura real usa el pool de hilos de
/// `dart:io`, y ese future queda "colgado" desde el punto de vista del
/// test aunque el archivo real acabe escribiéndose en disco (`runAsync`
/// tampoco vale sin más — combinarlo con `tester.tap()` deja el test
/// colgado de verdad). El `export()` de `ZipContentPackExporter` en
/// cambio es puramente síncrono (sin E/S), así que no hace falta un doble
/// para él.
class _FakeFileWriter implements FileWriter {
  String? writtenPath;
  List<int>? writtenBytes;
  Object? errorToThrow;

  @override
  Future<void> write(String path, List<int> bytes) async {
    if (errorToThrow != null) throw errorToThrow!;
    writtenPath = path;
    writtenBytes = bytes;
  }
}

/// `finalizar_lcp_test.dart` cubre el camino completo de `finalizarLcp` —
/// hasta ahora solo se probaba (desde `crear_entidad_screen_test.dart`) que
/// cancelar el diálogo de nombre no añade nada a la sesión. Aquí se cubren
/// los dos caminos que le faltaban: éxito (produce un .lcp válido en
/// memoria, limpia la sesión y avisa) y error (la escritura falla y el
/// mensaje se muestra sin perder la entidad pendiente).
///
/// El selector nativo de ubicación (`file_selector`) se sustituye por
/// [FakeFileSelectorPlatform] — no hay diálogo nativo real disponible en
/// el entorno de test, y no es responsabilidad de `finalizarLcp` probarlo
/// (ver `lcp_save_location.dart`).
void main() {
  late FakeFileSelectorPlatform fakeFileSelector;
  late _FakeFileWriter fakeFileWriter;

  setUp(() {
    fakeFileSelector = FakeFileSelectorPlatform();
    FileSelectorPlatform.instance = fakeFileSelector;
    fakeFileWriter = _FakeFileWriter();
  });

  Future<void> pumpFinalizarButton(
    WidgetTester tester,
    CrearSession session, {
    String? pendingContentKey,
    Object? pendingContent,
  }) async {
    await tester.pumpWidget(
      wrapWithLocalization(
        Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () => finalizarLcp(
                context,
                session,
                pendingContentKey: pendingContentKey,
                pendingContent: pendingContent,
                useCase: CrearContenidoUseCase(
                  exporter: ZipContentPackExporter(),
                  fileWriter: fakeFileWriter,
                ),
              ),
              child: const Text('Finalizar lcp'),
            ),
          ),
        ),
      ),
    );
  }

  const manufacturer = IManufacturerData(
    id: 'GMS',
    name: 'General Manufacturing Systems',
    description: 'd',
    quote: 'q',
    light: '#FFFFFF',
    dark: '#000000',
  );

  testWidgets(
    'camino feliz: nombre + ubicación confirmados produce un .lcp válido, '
    'añade la entidad pendiente, limpia la sesión y avisa con un snackbar',
    (tester) async {
      final session = CrearSession();
      const outputPath = '/fake/paquete.lcp';
      fakeFileSelector.nextSaveLocationPath = outputPath;

      await pumpFinalizarButton(
        tester,
        session,
        pendingContentKey: 'manufacturers',
        pendingContent: manufacturer,
      );

      await tester.tap(find.text('Finalizar lcp'));
      await tester.pumpAndSettle();

      expect(find.text('Nombre del paquete'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Mi paquete');
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      // La sesión se limpia tras exportar con éxito.
      expect(session.isEmpty, isTrue);

      // El snackbar de éxito muestra la ruta de salida.
      expect(find.textContaining('Generado:'), findsOneWidget);
      expect(find.textContaining(outputPath), findsOneWidget);

      expect(fakeFileWriter.writtenPath, outputPath);
      final archive = ZipDecoder().decodeBytes(fakeFileWriter.writtenBytes!);
      expect(
        archive.files.map((f) => f.name),
        containsAll(['lcp_manifest.json', 'manufacturers.json']),
      );

      final manifestJson =
          jsonDecode(
                utf8.decode(
                  archive.findFile('lcp_manifest.json')!.content
                      as List<int>,
                ),
              )
              as Map;
      expect(manifestJson['name'], 'Mi paquete');

      final manufacturersJson =
          jsonDecode(
                utf8.decode(
                  archive.findFile('manufacturers.json')!.content
                      as List<int>,
                ),
              )
              as List;
      expect(manufacturersJson, hasLength(1));
      expect(manufacturersJson.first['id'], 'GMS');
    },
  );

  testWidgets(
    'cancelar el selector de ubicación (tras confirmar el nombre) no toca '
    'la sesión',
    (tester) async {
      final session = CrearSession();
      fakeFileSelector.nextSaveLocationPath = null; // usuario cancela

      await pumpFinalizarButton(
        tester,
        session,
        pendingContentKey: 'manufacturers',
        pendingContent: manufacturer,
      );

      await tester.tap(find.text('Finalizar lcp'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Mi paquete');
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      expect(session.isEmpty, isTrue);
      expect(find.textContaining('Generado:'), findsNothing);
      expect(fakeFileWriter.writtenPath, isNull);
    },
  );

  testWidgets(
    'si falla la escritura del .lcp, se muestra el error y la entidad '
    'pendiente ya añadida a la sesión no se pierde (para poder reintentar '
    'sin volver a rellenar el formulario)',
    (tester) async {
      final session = CrearSession();
      fakeFileSelector.nextSaveLocationPath = '/fake/paquete.lcp';
      fakeFileWriter.errorToThrow = const FileSystemException(
        'disco lleno (simulado)',
      );

      await pumpFinalizarButton(
        tester,
        session,
        pendingContentKey: 'manufacturers',
        pendingContent: manufacturer,
      );

      await tester.tap(find.text('Finalizar lcp'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Mi paquete');
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Error:'), findsOneWidget);
      expect(session.content['manufacturers'], hasLength(1));
    },
  );
}
