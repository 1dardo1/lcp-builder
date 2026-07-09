import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/presentation/i18n/locale_controller.dart';
import 'package:lcp_builder/presentation/screens/editar/editar_menu_screen.dart';
import 'package:lcp_builder/presentation/session/edit_session.dart';

import '../../../support/test_app.dart';

void main() {
  testWidgets('muestra las dos opciones de entrada del flujo Editar', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithLocalization(
        EditarMenuScreen(
          session: EditSession(),
          localeController: LocaleController(),
        ),
      ),
    );

    expect(find.text('Abrir un .lcp'), findsOneWidget);
    expect(find.text('Abrir una carpeta'), findsOneWidget);
  });
}
