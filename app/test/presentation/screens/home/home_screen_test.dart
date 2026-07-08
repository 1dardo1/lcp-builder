import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/presentation/i18n/locale_controller.dart';
import 'package:lcp_builder/presentation/screens/home/home_screen.dart';
import 'package:lcp_builder/presentation/session/crear_session.dart';

import '../../../support/test_app.dart';

void main() {
  testWidgets('HomeScreen muestra las 3 opciones del plan de fases', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithLocalization(
        HomeScreen(session: CrearSession(), localeController: LocaleController()),
      ),
    );

    expect(find.text('Crear'), findsOneWidget);
    expect(find.text('Mostrar'), findsOneWidget);
    expect(find.text('Editar'), findsOneWidget);
  });

  testWidgets('Crear navega al menú de Crear', (tester) async {
    await tester.pumpWidget(
      wrapWithLocalization(
        HomeScreen(session: CrearSession(), localeController: LocaleController()),
      ),
    );

    await tester.tap(find.text('Crear'));
    await tester.pumpAndSettle();

    expect(find.text('Crear arma'), findsOneWidget);
  });

  testWidgets('Mostrar navega a la pantalla de "aún no implementado"', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithLocalization(
        HomeScreen(session: CrearSession(), localeController: LocaleController()),
      ),
    );

    await tester.tap(find.text('Mostrar'));
    await tester.pumpAndSettle();

    expect(find.text('Aún no se ha implementado.'), findsOneWidget);
  });

  testWidgets('Editar navega a la pantalla de "aún no implementado"', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithLocalization(
        HomeScreen(session: CrearSession(), localeController: LocaleController()),
      ),
    );

    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    expect(find.text('Aún no se ha implementado.'), findsOneWidget);
  });
}
