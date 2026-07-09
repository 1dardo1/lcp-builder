import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/presentation/i18n/locale_controller.dart';
import 'package:lcp_builder/presentation/screens/editar/editar_folder_screen.dart';
import 'package:lcp_builder/presentation/session/edit_session.dart';

import '../../../support/test_app.dart';

void main() {
  testWidgets('carpeta sin .lcp muestra el mensaje de "sin contenido"', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithLocalization(
        EditarFolderScreen(
          session: EditSession(),
          directoryPath: '/carpeta',
          localeController: LocaleController(),
          listLcpFiles: (_) async => const [],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Esta carpeta no tiene ningún archivo .lcp.'),
      findsOneWidget,
    );
  });

  testWidgets('lista los .lcp encontrados por su nombre legible', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithLocalization(
        EditarFolderScreen(
          session: EditSession(),
          directoryPath: '/carpeta',
          localeController: LocaleController(),
          listLcpFiles: (_) async => const [
            '/carpeta/paquete_a.lcp',
            '/carpeta/paquete_b.lcp',
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('paquete_a.lcp'), findsOneWidget);
    expect(find.text('paquete_b.lcp'), findsOneWidget);
  });

  testWidgets('tocar un .lcp navega a la pantalla de tipos de entidad', (
    tester,
  ) async {
    final session = EditSession();
    await tester.pumpWidget(
      wrapWithLocalization(
        EditarFolderScreen(
          session: session,
          directoryPath: '/carpeta',
          localeController: LocaleController(),
          listLcpFiles: (_) async => const ['/carpeta/paquete.lcp'],
          // Se reenvía a EditarEntityTypesScreen al navegar — evita que el
          // test dependa de dart:io real (poco fiable en flutter test, ver
          // finalizar_lcp_test.dart) para confirmar la navegación.
          loadContent: (_) async => throw Exception('fake'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('paquete.lcp'));
    await tester.pumpAndSettle();

    expect(find.text('paquete.lcp'), findsNothing);
    expect(find.textContaining('Error'), findsOneWidget);
  });
}
