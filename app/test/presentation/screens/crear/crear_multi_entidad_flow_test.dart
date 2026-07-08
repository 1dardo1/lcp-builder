import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/presentation/i18n/locale_controller.dart';
import 'package:lcp_builder/presentation/screens/crear/crear_menu_screen.dart';
import 'package:lcp_builder/presentation/session/crear_session.dart';

import '../../../support/test_app.dart';

/// Test de aceptación del flujo multi-entidad de principio a fin (desde la
/// perspectiva del cliente, ver ADR-002): crea un arma, referencia un
/// fabricante que todavía no existe (creándolo sin salir del formulario de
/// arma), y confirma que "Continuar" acumula la entidad en la sesión
/// mientras vuelve al menú para poder seguir creando — sin necesidad de
/// exportar cada entidad en su propio `.lcp`.
void main() {
  testWidgets(
    'crear un arma referenciando un fabricante nuevo, luego Continuar acumula '
    'ambas entidades en la sesión',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final session = CrearSession();
      await tester.pumpWidget(
        wrapWithLocalization(
          CrearMenuScreen(session: session, localeController: LocaleController()),
        ),
      );

      // Menú → Crear arma.
      await tester.tap(find.text('Crear arma'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const ValueKey('id')), 'mw_test');
      await tester.enterText(find.byKey(const ValueKey('name')), 'Test Rifle');

      // El campo "Fabricante (source)" todavía no tiene el fabricante que
      // necesitamos — se crea desde el propio botón de referencia, sin
      // salir del formulario de arma.
      await tester.scrollUntilVisible(
        find.text('Crear fabricante'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Crear fabricante'));
      await tester.pumpAndSettle();

      // Ahora en el formulario de Manufacturer, apilado sobre el de arma
      // (que sigue vivo debajo, con sus campos intactos).
      expect(find.text('Crear fabricante'), findsWidgets);
      await tester.enterText(
        find.byKey(const ValueKey('id')),
        'TEST_MFR_FLOW',
      );
      await tester.enterText(find.byKey(const ValueKey('name')), 'Test Mfr');
      await tester.enterText(
        find.byKey(const ValueKey('description')),
        'd',
      );
      await tester.enterText(find.byKey(const ValueKey('quote')), 'q');
      await tester.enterText(find.byKey(const ValueKey('light')), '#FFFFFF');
      await tester.enterText(find.byKey(const ValueKey('dark')), '#000000');

      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      // De vuelta en el formulario de arma (no en el menú): el fabricante
      // recién creado ya está en la sesión, y el campo "source" del arma
      // muestra su id sin que el usuario lo escriba a mano.
      expect(find.text('Test Rifle'), findsOneWidget);
      expect(find.text('TEST_MFR_FLOW'), findsOneWidget);
      expect(session.content['manufacturers'], hasLength(1));

      // Completar el resto de campos requeridos del arma y continuar —
      // vuelve al menú, no hace falta exportar todavía.
      await tester.enterText(
        find.byKey(const ValueKey('license')),
        'Test License',
      );
      await tester.enterText(
        find.byKey(const ValueKey('licenseId')),
        'mf_test',
      );
      await tester.enterText(find.byKey(const ValueKey('licenseLevel')), '0');
      await tester.enterText(find.byKey(const ValueKey('effect')), 'e');
      await tester.enterText(find.byKey(const ValueKey('description')), 'd');

      // "Mount" es un desplegable (EnumFieldSpec) — a diferencia de los
      // campos de texto, no basta con `enterText`, hay que elegir una
      // opción de verdad para que el controlador registre el valor.
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('mount')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const ValueKey('mount')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Main').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      // De vuelta en el menú Crear, con las 2 entidades ya acumuladas.
      expect(find.text('Crear arma'), findsOneWidget);
      expect(session.content['weapons'], hasLength(1));
      expect(session.content['manufacturers'], hasLength(1));
      expect(find.textContaining('2 entidad'), findsOneWidget);
    },
  );
}
