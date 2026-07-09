import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/presentation/i18n/locale_controller.dart';
import 'package:lcp_builder/presentation/screens/mostrar/mostrar_menu_screen.dart';

import '../../../support/test_app.dart';

void main() {
  testWidgets('muestra las dos opciones de entrada del flujo Mostrar', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithLocalization(
        MostrarMenuScreen(localeController: LocaleController()),
      ),
    );

    expect(find.text('Abrir un .lcp'), findsOneWidget);
    expect(find.text('Abrir una carpeta'), findsOneWidget);
  });
}
