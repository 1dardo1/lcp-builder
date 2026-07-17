import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/presentation/forms/crear_entidad_configs.dart';
import 'package:lcp_builder/presentation/i18n/locale_controller.dart';
import 'package:lcp_builder/presentation/screens/crear/crear_entidad_screen.dart';
import 'package:lcp_builder/presentation/session/crear_session.dart';

import '../../../support/fill_required_fields.dart';
import '../../../support/minimal_valid_values.dart';
import '../../../support/test_app.dart';

/// Camino feliz de "Crear" para las 20 entidades del registro
/// (`crearEntidadConfigs`), con datos mínimos válidos rellenados vía
/// interacción real de UI (`fillRequiredFields`, no inyectados
/// directamente en el controller) — pulsar "Continuar" con esos datos no
/// debe mostrar ningún "Requerido" y debe añadir la entidad a la sesión.
///
/// Este es justo el paso de verificación previo que permite escribir los
/// tests de aceptación reales de Android (lentos, uno por uno en un
/// emulador, sin forma de depurarlos en este entorno) con confianza: si el
/// helper de relleno funciona aquí para las 20, en Android solo queda por
/// demostrar la parte que este test NO cubre — la E/S real (SAF).
void main() {
  for (final config in crearEntidadConfigs) {
    testWidgets(
      '${config.title}: Continuar con datos mínimos válidos añade la '
      'entidad a la sesión sin mostrar "Requerido"',
      (tester) async {
        // Algunos esquemas (weapon mod, con 4 grupos onMiss/onAttack/onHit/
        // onCrit, cada uno con su propio sub-grupo save) son mucho más
        // largos que 4000px — sin suficiente alto, `fillRequiredFields`
        // intenta tocar un campo fuera de los límites del viewport
        // simulado y falla el hit test.
        tester.view.physicalSize = const Size(1080, 20000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final session = CrearSession();
        await tester.pumpWidget(
          wrapWithLocalization(
            CrearEntidadScreen(
              config: config,
              session: session,
              localeController: LocaleController(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final schema = config.buildSchema();
        await fillRequiredFields(tester, schema, minimalValidValues(schema));

        await tester.tap(find.text('Continuar'));
        await tester.pumpAndSettle();

        expect(find.text('Requerido'), findsNothing);
        expect(session.content[config.contentKey], hasLength(1));
      },
    );
  }
}
