import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/domain/ports/content_pack_reader.dart';
import 'package:lcp_builder/presentation/i18n/locale_controller.dart';
import 'package:lcp_builder/presentation/screens/editar/editar_entity_types_screen.dart';
import 'package:lcp_builder/presentation/session/edit_session.dart';

import '../../../support/test_app.dart';

void main() {
  final parsed = ParsedContentPack(
    manifest: const ILcpManifestData(
      name: 'Paquete de prueba',
      author: 'Test',
      description: 'desc',
      version: '1.0.0',
    ),
    contentByKey: {
      'manufacturers': [
        {'id': 'GMS'},
      ],
      'weapons': [
        {'id': 'w1'},
        {'id': 'w2'},
      ],
      'tags': const [],
    },
  );

  testWidgets('muestra el nombre del manifest y los tipos con contenido', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithLocalization(
        EditarEntityTypesScreen(
          session: EditSession(),
          lcpPath: 'irrelevante.lcp',
          localeController: LocaleController(),
          loadContent: (_) async => parsed,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Paquete de prueba'), findsOneWidget);
    expect(find.text('fabricante'), findsOneWidget);
    expect(find.text('arma'), findsOneWidget);
    expect(find.textContaining('tag'), findsNothing);
  });

  testWidgets('un error de lectura se muestra, no rompe la pantalla', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithLocalization(
        EditarEntityTypesScreen(
          session: EditSession(),
          lcpPath: 'irrelevante.lcp',
          localeController: LocaleController(),
          loadContent: (_) async => throw const FormatException('roto'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Error'), findsOneWidget);
  });

  testWidgets(
    'si el .lcp ya estaba cargado en la sesión (con cambios), no se relee '
    'del disco',
    (tester) async {
      final session = EditSession();
      session.load('paquete.lcp', parsed);
      session.deleteEntity('paquete.lcp', 'weapons', 0);
      expect(session.isDirty('paquete.lcp'), isTrue);

      var loadCalled = false;
      await tester.pumpWidget(
        wrapWithLocalization(
          EditarEntityTypesScreen(
            session: session,
            lcpPath: 'paquete.lcp',
            localeController: LocaleController(),
            loadContent: (_) async {
              loadCalled = true;
              return parsed;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(loadCalled, isFalse);
      // Solo queda 1 arma (se borró una) — el cambio sin guardar persiste,
      // tanto ella como el fabricante (que seguía teniendo 1) muestran "1
      // entidad".
      expect(find.text('1 entidad'), findsNWidgets(2));
    },
  );

  testWidgets(
    'el botón "Guardar .lcp" solo aparece cuando el paquete tiene cambios, '
    'y al guardar marca la sesión como no-dirty',
    (tester) async {
      final session = EditSession();
      var savedPath = '';
      await tester.pumpWidget(
        wrapWithLocalization(
          EditarEntityTypesScreen(
            session: session,
            lcpPath: 'paquete.lcp',
            localeController: LocaleController(),
            loadContent: (_) async => parsed,
            saveContent: (pack, outputPath) async {
              savedPath = outputPath;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Guardar .lcp'), findsNothing);

      session.deleteEntity('paquete.lcp', 'weapons', 0);
      await tester.pumpAndSettle();

      expect(find.text('Guardar .lcp'), findsOneWidget);

      await tester.tap(find.text('Guardar .lcp'));
      await tester.pumpAndSettle();

      expect(savedPath, 'paquete.lcp');
      expect(session.isDirty('paquete.lcp'), isFalse);
      expect(find.text('Guardar .lcp'), findsNothing);
    },
  );

  testWidgets(
    'el botón "Crear entidad de tipo nuevo" navega a la pantalla de elegir '
    'tipo, con las 24 entidades registradas (no solo las que ya tiene el '
    '.lcp)',
    (tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(
          EditarEntityTypesScreen(
            session: EditSession(),
            lcpPath: 'paquete.lcp',
            localeController: LocaleController(),
            loadContent: (_) async => parsed,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Crear entidad de tipo nuevo'));
      await tester.pumpAndSettle();

      expect(find.text('Elegir tipo de entidad'), findsOneWidget);
      // "tags" tiene 0 instancias en el .lcp actual — no aparece en esta
      // pantalla, pero sí en la de elegir tipo, porque el objetivo es
      // justo poder crear la primera.
      expect(find.text('Crear tag'), findsOneWidget);
    },
  );
}
