import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/domain/ports/content_pack_reader.dart';
import 'package:lcp_builder/presentation/i18n/locale_controller.dart';
import 'package:lcp_builder/presentation/screens/mostrar/lcp_entity_types_screen.dart';

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
        LcpEntityTypesScreen(
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
    // "tags" no tiene ninguna instancia — no debe listarse.
    expect(find.textContaining('tag'), findsNothing);
  });

  testWidgets('un error de lectura se muestra, no rompe la pantalla', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithLocalization(
        LcpEntityTypesScreen(
          lcpPath: 'irrelevante.lcp',
          localeController: LocaleController(),
          loadContent: (_) async => throw const FormatException('roto'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Error'), findsOneWidget);
  });
}
