import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/presentation/i18n/locale_controller.dart';
import 'package:lcp_builder/presentation/screens/mostrar/lcp_entity_cards_screen.dart';
import 'package:lcp_builder/presentation/widgets/entity_display_card.dart';

import '../../../support/test_app.dart';

void main() {
  testWidgets('pinta una EntityDisplayCard por instancia, con el título sin "Crear"', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithLocalization(
        LcpEntityCardsScreen(
          contentKey: 'manufacturers',
          entities: const [
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
          localeController: LocaleController(),
        ),
      ),
    );

    expect(find.text('fabricante'), findsOneWidget);
    expect(find.byType(EntityDisplayCard), findsNWidgets(2));
    expect(find.textContaining('General Manufacturing Systems'), findsOneWidget);
    expect(
      find.textContaining('Industrial Printworks Sacrifice-North'),
      findsOneWidget,
    );
  });

  testWidgets('un contentKey no registrado se muestra tal cual, sin romper', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithLocalization(
        LcpEntityCardsScreen(
          contentKey: 'algo_desconocido',
          entities: const [],
          localeController: LocaleController(),
        ),
      ),
    );

    expect(find.text('algo_desconocido'), findsOneWidget);
  });
}
