import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/infrastructure/file_system/local_file_reader.dart';
import 'package:lcp_builder/infrastructure/file_system/local_file_writer.dart';
import 'package:lcp_builder/infrastructure/file_system/local_lcp_directory_lister.dart';
import 'package:lcp_builder/infrastructure/lcp/zip_content_pack_exporter.dart';
import 'package:lcp_builder/infrastructure/lcp/zip_content_pack_reader.dart';
import 'package:lcp_builder/presentation/forms/crear_entidad_configs.dart';
import 'package:lcp_builder/presentation/i18n/locale_controller.dart';
import 'package:lcp_builder/presentation/screens/edit/edit_entity_screen.dart';
import 'package:lcp_builder/presentation/screens/edit/edit_entity_types_screen.dart';
import 'package:lcp_builder/presentation/session/edit_session.dart';

import '../support/minimal_valid_values.dart';
import '../support/test_app.dart';

/// Aceptación de escritorio (Linux/Windows/macOS) sobre el sistema de
/// archivos REAL — el análogo del test de aceptación de Android (que va por
/// SAF), pero por el camino `dart:io` que usan los tres escritorios. Corre
/// con `flutter test` en el runner de cada SO (ver build-*.yml), así que al
/// ejecutarse en `windows-latest` ejercita la E/S real de Windows.
///
/// Genera un `.lcp` con las 20 entidades, lo escribe a disco de verdad con
/// `LocalFileWriter`, lo localiza con `LocalLcpDirectoryLister`, lo relee
/// con `LocalFileReader`, lo parsea, y abre la pantalla de Editar de cada
/// entidad con los datos releídos — cubriendo de una vez escritura, listado,
/// lectura, parseo e hidratación del formulario contra el disco real.
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('desktop_lcp_acceptance');
  });
  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  testWidgets(
    'ciclo real de disco (escribir→listar→leer→parsear→abrir Editar) de las '
    '20 entidades por el camino de escritorio',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // --- Genera un .lcp real con las 20 entidades (datos mínimos válidos,
      // ensamblados de verdad por cada esquema). ---
      final content = <String, List<Object>>{
        for (final config in crearEntidadConfigs)
          config.contentKey: [
            config.fromFormValues(minimalValidValues(config.buildSchema())),
          ],
      };
      final bytes = ZipContentPackExporter().export(
        manifest: const ILcpManifestData(
          name: 'Paquete de escritorio',
          author: 'Test',
          description: 'd',
          version: '1.0.0',
        ),
        content: content,
      );

      final path = '${tempDir.path}${Platform.pathSeparator}paquete.lcp';

      // --- E/S de disco REAL. Va envuelta en `tester.runAsync`: el cuerpo de
      // un `testWidgets` corre bajo tiempo asíncrono FALSO (FakeAsync), donde
      // los `Future` de `dart:io` (escribir, listar, leer) nunca se resuelven
      // y el test se colgaría hasta el límite de 10 min. `runAsync` ejecuta el
      // callback en la zona asíncrona REAL, que es donde el I/O sí completa.
      final reread = await tester.runAsync(() async {
        // Escribe a disco real.
        await LocalFileWriter().write(path, bytes);

        // Lista la carpeta real y encuentra el .lcp. Se compara por nombre, no
        // por ruta completa: `Directory.list()` usa el separador del SO (`\`
        // en Windows), así que comparar rutas a mano falla ahí.
        final listed = await LocalLcpDirectoryLister().listLcpFiles(
          tempDir.path,
        );
        expect(
          listed.map((p) => p.split(RegExp(r'[/\\]')).last),
          contains('paquete.lcp'),
        );

        // Relee del disco real.
        return LocalFileReader().read(path);
      });

      final pack = ZipContentPackReader().read(reread!);
      expect(
        pack.contentByKey.keys,
        containsAll(crearEntidadConfigs.map((c) => c.contentKey)),
      );

      // --- Abre la pantalla de Editar de cada entidad con lo releído. ---
      final session = EditSession()..load(path, pack);
      for (final config in crearEntidadConfigs) {
        final raw = pack.contentByKey[config.contentKey]!.first;
        await tester.pumpWidget(
          wrapWithLocalization(
            EditEntityScreen(
              config: config,
              session: session,
              lcpPath: path,
              contentKey: config.contentKey,
              index: 0,
              rawEntity: raw,
              localeController: LocaleController(),
            ),
          ),
        );
        // Render-only: lo que se comprueba es que la pantalla se CONSTRUYE sin
        // reventar (el bug de la "pantalla gris" es una excepción en build) y
        // que sale el formulario. No se usa `pumpAndSettle` a propósito: aquí
        // no hay entrada ni transición que esperar, y sobre las 20 entidades
        // en un solo test acumular settles (o cualquier animación que no
        // asiente, p. ej. el parpadeo del cursor) agota el presupuesto de 10
        // min. Un par de `pump` bastan para sacar la excepción de build.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(
          tester.takeException(),
          isNull,
          reason: '${config.title}: Editar reventó tras releer del disco real',
        );
        expect(find.byType(TextFormField), findsWidgets);
      }
    },
  );

  /// El análogo de escritorio de la aserción FUERTE del test de aceptación de
  /// Android (`editar_android_acceptance_test`): editar una entidad, GUARDAR
  /// por el camino de guardado REAL de la app (`defaultEditarSaveContent` →
  /// `EditContentUseCase` con el `LocalFileWriter` de escritorio) y releer
  /// los BYTES del disco para comprobar que el cambio persistió y el resto de
  /// entidades quedaron intactas. Cubre en escritorio lo que en Android cazó
  /// los bugs de guardado #37/#38/#39 (que ahí eran de truncado/SAF); es un
  /// `test` normal, no `testWidgets`, así que la E/S real de `dart:io` corre
  /// sin FakeAsync y sin envolver en `runAsync`.
  test(
    'editar una entidad y Guardar persiste en el disco real (y no toca el '
    'resto) — por el camino de guardado de escritorio',
    () async {
      // Genera un .lcp con las 20 entidades y escríbelo a disco real.
      final content = <String, List<Object>>{
        for (final config in crearEntidadConfigs)
          config.contentKey: [
            config.fromFormValues(minimalValidValues(config.buildSchema())),
          ],
      };
      final bytes = ZipContentPackExporter().export(
        manifest: const ILcpManifestData(
          name: 'Paquete de escritorio',
          author: 'Test',
          description: 'd',
          version: '1.0.0',
        ),
        content: content,
      );
      final path = '${tempDir.path}${Platform.pathSeparator}editar.lcp';
      await LocalFileWriter().write(path, bytes);

      // Abre en sesión de edición y cambia el nombre del primer fabricante.
      final pack = ZipContentPackReader().read(await LocalFileReader().read(path));
      final session = EditSession()..load(path, pack);
      final original = Map<String, dynamic>.from(
        pack.contentByKey['manufacturers']!.first,
      );
      session.replaceEntity(path, 'manufacturers', 0, {
        ...original,
        'name': 'Editado en disco real',
      });

      // Guarda con el MISMO adapter que usa la pantalla en escritorio.
      await defaultEditarSaveContent()(session.packFor(path)!, path);
      session.markSaved(path);
      expect(session.isDirty(path), isFalse);

      // Verificación fuerte: releer los BYTES del disco, sin pasar por el
      // estado en memoria de la sesión.
      final reread = ZipContentPackReader().read(
        await LocalFileReader().read(path),
      );
      expect(
        reread.contentByKey['manufacturers']!.first['name'],
        'Editado en disco real',
      );
      // El resto de tipos siguen ahí: guardar no se comió nada.
      expect(
        reread.contentByKey.keys,
        containsAll(crearEntidadConfigs.map((c) => c.contentKey)),
      );
    },
  );
}
