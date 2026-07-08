import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/presentation/forms/manufacturer_form_schema.dart';
import 'package:lcp_builder/presentation/i18n/locale_controller.dart';
import 'package:lcp_builder/presentation/screens/crear/crear_entidad_screen.dart';
import 'package:lcp_builder/presentation/session/crear_session.dart';

import '../../../support/test_app.dart';

/// Prueba que `CrearEntidadScreen` es genuinamente genérica: renderiza el
/// esquema de una entidad *distinta* de arma (fabricante) sin ningún
/// código específico de esa entidad en la pantalla.
void main() {
  testWidgets('CrearEntidadScreen renderiza el esquema de la config recibida', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      wrapWithLocalization(
        CrearEntidadScreen(
          config: manufacturerCrearConfig,
          session: CrearSession(),
          localeController: LocaleController(),
        ),
      ),
    );

    expect(find.text('Crear fabricante'), findsOneWidget);
    expect(find.text('ID (acrónimo, ej. GMS) *'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
    expect(find.text('Finalizar lcp'), findsOneWidget);
  });

  testWidgets(
    'cancelar el diálogo de nombre al pulsar Finalizar lcp no añade la '
    'entidad a la sesión — reintentar no la duplica (regresión: session.add '
    'se llamaba antes de que el diálogo cancelable pudiera cancelar)',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final session = CrearSession();
      await tester.pumpWidget(
        wrapWithLocalization(
          CrearEntidadScreen(
            config: manufacturerCrearConfig,
            session: session,
            localeController: LocaleController(),
          ),
        ),
      );

      Future<void> fillRequiredFields() async {
        await tester.enterText(find.byKey(const ValueKey('id')), 'GMS');
        await tester.enterText(
          find.byKey(const ValueKey('name')),
          'General Manufacturing Systems',
        );
        await tester.enterText(
          find.byKey(const ValueKey('description')),
          'd',
        );
        await tester.enterText(find.byKey(const ValueKey('quote')), 'q');
        await tester.enterText(
          find.byKey(const ValueKey('light')),
          '#FFFFFF',
        );
        await tester.enterText(
          find.byKey(const ValueKey('dark')),
          '#000000',
        );
      }

      await fillRequiredFields();
      await tester.tap(find.text('Finalizar lcp'));
      await tester.pumpAndSettle();

      expect(find.text('Nombre del paquete'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(session.isEmpty, isTrue);

      await fillRequiredFields();
      await tester.tap(find.text('Finalizar lcp'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(session.isEmpty, isTrue);
      expect(session.content['manufacturers'], isNull);
    },
  );
}
