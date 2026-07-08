import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/presentation/forms/crear_entidad_configs.dart';
import 'package:lcp_builder/presentation/i18n/locale_controller.dart';
import 'package:lcp_builder/presentation/screens/crear/crear_menu_screen.dart';
import 'package:lcp_builder/presentation/session/crear_session.dart';

import '../../../support/test_app.dart';

/// `crear_multi_entidad_flow_test.dart` ya cubre el flujo de punta a punta
/// arma+fabricante, pero solo ejercita 2 de las 20 entidades del menú y
/// nunca pulsa el botón "Finalizar lcp" propio de `CrearMenuScreen` (el de
/// la fila de resumen de sesión, distinto del de `CrearEntidadScreen` que sí
/// tiene su propio test). Este archivo cubre lo que faltaba: que las 20
/// entidades registradas aparecen en el menú, y el comportamiento de la
/// fila de resumen (oculta con la sesión vacía, visible con el recuento
/// correcto y singular/plural correctos en cuanto hay algo).
void main() {
  testWidgets(
    'con la sesión vacía, no se muestra la fila de resumen ni el botón '
    'Finalizar lcp',
    (tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(
          CrearMenuScreen(session: CrearSession(), localeController: LocaleController()),
        ),
      );

      expect(find.text('Finalizar lcp'), findsNothing);
      expect(find.textContaining('entidad'), findsNothing);
    },
  );

  testWidgets(
    'las 20 entidades registradas en crearEntidadConfigs aparecen como '
    'entradas del menú',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapWithLocalization(
          CrearMenuScreen(session: CrearSession(), localeController: LocaleController()),
        ),
      );

      expect(crearEntidadConfigs, hasLength(20));
      for (final config in crearEntidadConfigs) {
        expect(
          find.text(config.title),
          findsOneWidget,
          reason: '"${config.title}" no aparece en el menú Crear',
        );
      }
    },
  );

  testWidgets(
    'con 1 entidad en la sesión, el resumen usa la forma singular y '
    'Finalizar lcp abre el diálogo de nombre',
    (tester) async {
      final session = CrearSession()
        ..add(
          'manufacturers',
          const IManufacturerData(
            id: 'GMS',
            name: 'General Manufacturing Systems',
            description: 'd',
            quote: 'q',
            light: '#FFFFFF',
            dark: '#000000',
          ),
        );

      await tester.pumpWidget(
        wrapWithLocalization(
          CrearMenuScreen(session: session, localeController: LocaleController()),
        ),
      );

      expect(find.text('1 entidad en el .lcp actual'), findsOneWidget);
      expect(find.text('Finalizar lcp'), findsOneWidget);

      await tester.tap(find.text('Finalizar lcp'));
      await tester.pumpAndSettle();

      expect(find.text('Nombre del paquete'), findsOneWidget);
    },
  );

  testWidgets(
    'con varias entidades, el resumen usa la forma plural con el recuento '
    'total (sumando todos los contentKey, no solo uno)',
    (tester) async {
      final session = CrearSession()
        ..add(
          'manufacturers',
          const IManufacturerData(
            id: 'GMS',
            name: 'General Manufacturing Systems',
            description: 'd',
            quote: 'q',
            light: '#FFFFFF',
            dark: '#000000',
          ),
        )
        ..add(
          'tags',
          const ITagData(id: 'tg_test', name: 'Test', description: 'd'),
        );

      await tester.pumpWidget(
        wrapWithLocalization(
          CrearMenuScreen(session: session, localeController: LocaleController()),
        ),
      );

      expect(find.text('2 entidades en el .lcp actual'), findsOneWidget);
    },
  );
}
