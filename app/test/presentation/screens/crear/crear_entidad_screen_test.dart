import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/presentation/forms/manufacturer_form_schema.dart';
import 'package:lcp_builder/presentation/screens/crear/crear_entidad_screen.dart';

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
      MaterialApp(home: CrearEntidadScreen(config: manufacturerCrearConfig)),
    );

    expect(find.text('Crear fabricante'), findsOneWidget);
    expect(find.text('ID (acrónimo, ej. GMS) *'), findsOneWidget);
    expect(find.text('Crear .lcp'), findsOneWidget);
  });
}
