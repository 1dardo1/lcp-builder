import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/main.dart';

void main() {
  testWidgets('La app arranca en la pantalla de Crear arma', (tester) async {
    // El formulario es largo (muchos campos) — viewport grande para que
    // find.text encuentre widgets fuera de la vista inicial sin necesidad
    // de hacer scroll explícito en el test.
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const LcpBuilderApp());

    expect(find.text('Crear arma'), findsOneWidget);
    expect(find.text('Crear .lcp'), findsOneWidget);
  });
}
