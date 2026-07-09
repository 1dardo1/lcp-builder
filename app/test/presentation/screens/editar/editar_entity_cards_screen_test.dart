import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/domain/ports/content_pack_reader.dart';
import 'package:lcp_builder/presentation/i18n/locale_controller.dart';
import 'package:lcp_builder/presentation/screens/editar/editar_entity_cards_screen.dart';
import 'package:lcp_builder/presentation/session/edit_session.dart';
import 'package:lcp_builder/presentation/widgets/entity_display_card.dart';

import '../../../support/test_app.dart';

void main() {
  ParsedContentPack buildPack() => ParsedContentPack(
    manifest: const ILcpManifestData(
      name: 'Paquete de prueba',
      author: 'Test',
      description: 'desc',
      version: '1.0.0',
    ),
    contentByKey: {
      'manufacturers': [
        {
          'id': 'GMS',
          'name': 'General Manufacturing Systems',
          'description': 'd',
          'quote': 'q',
          'light': 'FFFFFF',
          'dark': '000000',
        },
        {
          'id': 'IPS-N',
          'name': 'Industrial Printworks Sacrifice-North',
          'description': 'd2',
          'quote': 'q2',
          'light': 'AAAAAA',
          'dark': '111111',
        },
      ],
    },
  );

  testWidgets('pinta una EntityDisplayCard por instancia, con botones de '
      'editar/eliminar', (tester) async {
    final session = EditSession();
    session.load('paquete.lcp', buildPack());

    await tester.pumpWidget(
      wrapWithLocalization(
        EditarEntityCardsScreen(
          session: session,
          lcpPath: 'paquete.lcp',
          contentKey: 'manufacturers',
          localeController: LocaleController(),
        ),
      ),
    );

    expect(find.text('fabricante'), findsOneWidget);
    expect(find.byType(EntityDisplayCard), findsNWidgets(2));
    expect(find.text('Editar'), findsNWidgets(2));
    expect(find.text('Eliminar'), findsNWidgets(2));
  });

  testWidgets('sin entidades restantes muestra el mensaje de "sin entidades"', (
    tester,
  ) async {
    final session = EditSession();
    session.load(
      'paquete.lcp',
      const ParsedContentPack(
        manifest: ILcpManifestData(
          name: 'Paquete',
          author: 'Test',
          description: 'desc',
          version: '1.0.0',
        ),
        contentByKey: {'manufacturers': []},
      ),
    );

    await tester.pumpWidget(
      wrapWithLocalization(
        EditarEntityCardsScreen(
          session: session,
          lcpPath: 'paquete.lcp',
          contentKey: 'manufacturers',
          localeController: LocaleController(),
        ),
      ),
    );

    expect(find.text('No quedan entidades de este tipo.'), findsOneWidget);
  });

  testWidgets('eliminar pide confirmación y, al confirmar, quita la entidad '
      'de la sesión (no de golpe)', (tester) async {
    final session = EditSession();
    session.load('paquete.lcp', buildPack());

    await tester.pumpWidget(
      wrapWithLocalization(
        EditarEntityCardsScreen(
          session: session,
          lcpPath: 'paquete.lcp',
          contentKey: 'manufacturers',
          localeController: LocaleController(),
        ),
      ),
    );

    await tester.tap(find.text('Eliminar').first);
    await tester.pumpAndSettle();

    expect(find.text('Eliminar entidad'), findsOneWidget);
    expect(
      find.text(
        '¿Seguro que quieres eliminar esta entidad? Esta acción no se '
        'puede deshacer.',
      ),
      findsOneWidget,
    );

    // Cancelar no borra nada.
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(session.isDirty('paquete.lcp'), isFalse);
    expect(find.byType(EntityDisplayCard), findsNWidgets(2));

    // Confirmar sí borra, y solo esa entidad.
    await tester.tap(find.text('Eliminar').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar').last);
    await tester.pumpAndSettle();

    expect(session.isDirty('paquete.lcp'), isTrue);
    expect(find.byType(EntityDisplayCard), findsOneWidget);
    expect(
      find.textContaining('Industrial Printworks Sacrifice-North'),
      findsOneWidget,
    );
  });
}
