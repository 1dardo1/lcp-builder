import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lcp_builder/main.dart';

/// Smoke test de aceptación — corre sobre el binario real compilado
/// (`flutter build linux` + Xvfb en CI, como ya se hace a mano según
/// `app/README.md`), no en `flutter test` sobre el host.
///
/// A diferencia de Android, en Linux el único adapter de E/S real que usa
/// la app (`LocalFileWriter`/`LocalFileReader`, `dart:io` liso) ya está
/// ejercitado de verdad por los tests de aceptación existentes en
/// `test/application/use_cases/` — corren con `flutter test` directamente
/// sobre este mismo Linux, sin mocks, así que ya son "entorno real" para
/// el único código que Linux necesita verificar (ver
/// `vault/Aprendizajes/Principios y decisiones clave.md`). Este test no
/// repite esa cobertura — solo confirma que el binario compilado arranca
/// de verdad y la navegación básica funciona, complementando lo que ya
/// hay.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'el binario compilado arranca en Home y navega Crear → formulario de '
    'arma',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(LcpBuilderApp());
      await tester.pumpAndSettle();

      expect(find.text('Crear'), findsOneWidget);
      expect(find.text('Mostrar'), findsOneWidget);
      expect(find.text('Editar'), findsOneWidget);

      await tester.tap(find.text('Crear'));
      await tester.pumpAndSettle();

      expect(find.text('Crear arma'), findsOneWidget);
      expect(find.text('Crear fabricante'), findsOneWidget);

      await tester.tap(find.text('Crear arma'));
      await tester.pumpAndSettle();

      expect(find.text('Continuar'), findsOneWidget);
      expect(find.text('Finalizar lcp'), findsOneWidget);
    },
  );
}
