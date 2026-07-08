import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/main.dart';

void main() {
  testWidgets(
    'La app arranca en el menú Crear y navega al formulario de arma',
    (tester) async {
      // El formulario es largo (muchos campos) — viewport grande para que
      // find.text encuentre widgets fuera de la vista inicial sin necesidad
      // de hacer scroll explícito en el test.
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(LcpBuilderApp());

      // Pantalla de inicio (Crear/Mostrar/Editar) antes de llegar al menú.
      expect(find.text('Crear'), findsOneWidget);
      await tester.tap(find.text('Crear'));
      await tester.pumpAndSettle();

      // Menú con al menos arma y una de las entidades simples nuevas.
      expect(find.text('Crear arma'), findsOneWidget);
      expect(find.text('Crear fabricante'), findsOneWidget);

      await tester.tap(find.text('Crear arma'));
      await tester.pumpAndSettle();

      expect(find.text('Continuar'), findsOneWidget);
      expect(find.text('Finalizar lcp'), findsOneWidget);
    },
  );
}
