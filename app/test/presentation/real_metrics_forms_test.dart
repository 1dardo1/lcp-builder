import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/presentation/forms/crear_entidad_configs.dart';
import 'package:lcp_builder/presentation/i18n/locale_controller.dart';
import 'package:lcp_builder/presentation/screens/crear/crear_entidad_screen.dart';
import 'package:lcp_builder/presentation/session/crear_session.dart';

import '../support/phone_metrics.dart';
import '../support/test_app.dart';

/// Ángulo que faltaba: montar cada formulario a **tamaño de móvil real**,
/// no en el lienzo gigante (1080×20000) del test de aceptación. A tamaño
/// real aparecen overflows y fallos de layout acotado que el lienzo
/// gigante esconde — cualquiera de ellos se registra como excepción que
/// `takeException()` recoge, así que un formulario que reviente al
/// construirse en una pantalla pequeña hace fallar este test.
void main() {
  for (final config in crearEntidadConfigs) {
    testWidgets(
      '${config.title}: el formulario de Crear se construye sin fallos de '
      'layout a tamaño de móvil real',
      (tester) async {
        usePhoneMetrics(tester);
        await tester.pumpWidget(
          wrapWithLocalization(
            CrearEntidadScreen(
              config: config,
              session: CrearSession(),
              localeController: LocaleController(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          tester.takeException(),
          isNull,
          reason: '${config.title} lanzó al construirse a tamaño real '
              '(típicamente un overflow de layout que el lienzo gigante '
              'del test de aceptación esconde)',
        );
        // El formulario se construyó de verdad (no una pantalla en blanco):
        // hay al menos un campo de texto arriba. No se comprueba que el
        // botón "Finalizar lcp" esté visible — en un móvil real puede
        // quedar por debajo del scroll y la `ListView` no lo construye
        // hasta desplazarse, cosa normal, no un fallo.
        expect(find.byType(TextFormField), findsWidgets);
      },
    );
  }
}
