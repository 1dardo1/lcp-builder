import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/presentation/i18n/locale_controller.dart';
import 'package:lcp_builder/presentation/screens/home/home_screen.dart';
import 'package:lcp_builder/presentation/session/crear_session.dart';
import 'package:lcp_builder/presentation/session/edit_session.dart';

import '../../support/test_app.dart';

void main() {
  test('LocaleController arranca en español y toggle() alterna es/en', () {
    final controller = LocaleController();
    expect(controller.locale.languageCode, 'es');

    controller.toggle();
    expect(controller.locale.languageCode, 'en');

    controller.toggle();
    expect(controller.locale.languageCode, 'es');
  });

  test('setLocale no notifica si el idioma no cambia', () {
    final controller = LocaleController();
    var notified = 0;
    controller.addListener(() => notified++);

    controller.setLocale(const Locale('es'));
    expect(notified, 0);

    controller.setLocale(const Locale('en'));
    expect(notified, 1);
  });

  testWidgets(
    'el selector de idioma en la esquina superior derecha cambia el texto '
    'de toda la pantalla al elegir English',
    (tester) async {
      final localeController = LocaleController();
      await tester.pumpWidget(
        wrapWithLocalization(
          HomeScreen(
            session: CrearSession(),
            editSession: EditSession(),
            localeController: localeController,
          ),
          controller: localeController,
        ),
      );

      expect(find.text('Crear'), findsOneWidget);
      expect(find.text('Create'), findsNothing);

      // El icono de idioma abre un menú con "Español"/"English".
      await tester.tap(find.byIcon(Icons.language));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(find.text('Create'), findsOneWidget);
      expect(find.text('Show'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Crear'), findsNothing);
    },
  );
}
