import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/domain/ports/content_pack_reader.dart';
import 'package:lcp_builder/presentation/i18n/locale_controller.dart';
import 'package:lcp_builder/presentation/screens/editar/editar_manifest_screen.dart';
import 'package:lcp_builder/presentation/session/edit_session.dart';

import '../../../support/test_app.dart';

void main() {
  EditSession sessionConManifest(ILcpManifestData manifest) {
    final session = EditSession();
    session.load(
      'paquete.lcp',
      ParsedContentPack(manifest: manifest, contentByKey: const {}),
    );
    return session;
  }

  Widget pantalla(EditSession session) => wrapWithLocalization(
        EditarManifestScreen(
          session: session,
          lcpPath: 'paquete.lcp',
          localeController: LocaleController(),
        ),
      );

  testWidgets('arranca precargado con el manifest actual', (tester) async {
    final session = sessionConManifest(
      const ILcpManifestData(
        name: 'Mi paquete',
        author: 'Autora',
        description: 'desc',
        version: '1.2.3',
      ),
    );
    await tester.pumpWidget(pantalla(session));
    await tester.pumpAndSettle();

    expect(find.text('Mi paquete'), findsOneWidget);
    expect(find.text('Autora'), findsOneWidget);
    expect(find.text('1.2.3'), findsOneWidget);
  });

  testWidgets(
    'guardar actualiza el manifest en la sesión, marca dirty y conserva los '
    'campos no editados (imageUrl/dependencies/v3/versionHistory)',
    (tester) async {
      final session = sessionConManifest(
        ILcpManifestData(
          name: 'Antiguo',
          author: 'Autora',
          description: 'desc',
          version: '1.0.0',
          imageUrl: 'https://img',
          website: 'https://web',
          v3: true,
          dependencies: [
            ILcpDependency(name: 'Core', version: SemverConstraint('1.0.0')),
          ],
        ),
      );
      await tester.pumpWidget(pantalla(session));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('manifestName')),
        'Nuevo nombre',
      );
      await tester.enterText(
        find.byKey(const ValueKey('manifestVersion')),
        '2.0.0',
      );
      await tester.tap(find.text('Guardar cambios'));
      await tester.pumpAndSettle();

      final manifest = session.packFor('paquete.lcp')!.manifest;
      expect(manifest.name, 'Nuevo nombre');
      expect(manifest.version, '2.0.0');
      // Campos no expuestos en la pantalla: intactos, no descartados.
      expect(manifest.imageUrl, 'https://img');
      expect(manifest.website, 'https://web');
      expect(manifest.v3, true);
      expect(manifest.dependencies, hasLength(1));
      expect(manifest.dependencies!.first.name, 'Core');
      expect(session.isDirty('paquete.lcp'), isTrue);
    },
  );

  testWidgets('no guarda si un campo obligatorio queda vacío', (tester) async {
    final session = sessionConManifest(
      const ILcpManifestData(
        name: 'Nombre',
        author: 'Autora',
        description: 'desc',
        version: '1.0.0',
      ),
    );
    await tester.pumpWidget(pantalla(session));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('manifestName')), '');
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    // La validación bloquea el guardado: la sesión no se marca dirty.
    expect(session.isDirty('paquete.lcp'), isFalse);
  });
}
