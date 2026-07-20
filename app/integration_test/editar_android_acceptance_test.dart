import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lcp_builder/infrastructure/file_system/android_saf_channel.dart';
import 'package:lcp_builder/infrastructure/file_system/android_saf_file_reader.dart';
import 'package:lcp_builder/infrastructure/lcp/zip_content_pack_reader.dart';
import 'package:lcp_builder/l10n/gen/app_localizations.dart';
import 'package:lcp_builder/presentation/forms/manufacturer_form_schema.dart';
import 'package:lcp_builder/presentation/i18n/locale_controller.dart';
import 'package:lcp_builder/presentation/screens/crear/crear_entidad_screen.dart';
import 'package:lcp_builder/presentation/screens/editar/editar_entity_cards_screen.dart';
import 'package:lcp_builder/presentation/screens/editar/editar_entity_types_screen.dart';
import 'package:lcp_builder/presentation/session/crear_session.dart';
import 'package:lcp_builder/presentation/session/edit_session.dart';

import '../test/support/android_test_saf.dart';

/// Igual que `test/support/test_app.dart`'s `wrapWithLocalization`, pero
/// duplicado aquí en vez de importado — este archivo vive en
/// `integration_test/`, aparte de `test/`, y se mantiene autocontenido.
/// Necesario porque `AppLocalizations.of(context)` lanza un null-check si
/// el `MaterialApp` no registra `localizationsDelegates`/`supportedLocales`.
Widget _wrapWithLocalization(Widget home) => MaterialApp(
  locale: const Locale('es'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

/// Test de aceptación real de Android — corre en un emulador/dispositivo
/// de verdad (`flutter test integration_test/... -d emulator`), NUNCA en el
/// host. A diferencia de todo lo que hay en `test/`, aquí no se inyecta
/// ningún `loadContent`/`saveContent`/`fileWriter` de mentira: se deja que
/// la app use sus adapters reales (`AndroidSafFileWriter`/
/// `AndroidSafFileReader`, el canal nativo de `MainActivity.kt`), que es
/// justo el código donde vivían los tres bugs reales corregidos en
/// #37/#38/#39 — ninguno lo habría atrapado un test con el canal mockeado,
/// porque `Platform.isAndroid` es `false` en el host donde corre
/// `flutter test`.
///
/// Lo único que no es real es el selector nativo de archivos
/// (`ACTION_CREATE_DOCUMENT`/`ACTION_OPEN_DOCUMENT`): `armAndroidTestSaf()`
/// hace que devuelva directamente una URI `content://` de un FileProvider
/// de test (ver `useTestSafDocument` en `MainActivity.kt`), sin abrir la UI
/// de DocumentsUI. Bajo `flutter test -d emulator` esa UI es imposible de
/// automatizar (la app va por el VM service, no por instrumentación) y
/// colgaría el test para siempre; y de todas formas no es lo que este test
/// quiere probar — lo que aporta es la E/S SAF real que viene *después* de
/// esa URI (ContentResolver, truncado, lectura).
///
/// Cada pantalla se monta directamente (como en los tests de `test/`),
/// no navegando desde `HomeScreen` — más robusto para un test que no se
/// puede depurar en caliente, y de todas formas la navegación entre
/// pantallas ya está cubierta por los tests normales; lo que este test
/// aporta es la E/S real.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Crear un fabricante y editarlo sobrevive un ciclo real de '
    'escritura/lectura en Android (SAF real, sin mocks) — regresión de '
    'los bugs de guardado corregidos en #37/#38/#39',
    (tester) async {
      // El formulario es largo — sin esto, en la pantalla real (más
      // pequeña) del emulador, la ListView solo construye lo que cabe en
      // el viewport + cache extent: botones como "Finalizar lcp", más
      // abajo del todo, quedarían fuera del árbol y find.text no los
      // encontraría (mismo problema ya resuelto en widget_test.dart /
      // crear_entidad_screen_test.dart, nunca aplicado aquí).
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Sustituye el selector nativo de guardar/abrir por una URI content://
      // de test — sin esto, `flutter test -d emulator` cuelga al abrir el
      // selector real, que nadie puede automatizar (ver armAndroidTestSaf).
      await armAndroidTestSaf();

      // --- Crear: escribe de verdad, vía el selector interceptado. ---
      final crearSession = CrearSession();
      await tester.pumpWidget(
        _wrapWithLocalization(
          CrearEntidadScreen(
            config: manufacturerCrearConfig,
            session: crearSession,
            localeController: LocaleController(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const ValueKey('id')), 'GMS');
      await tester.enterText(
        find.byKey(const ValueKey('name')),
        'General Manufacturing Systems',
      );
      await tester.enterText(find.byKey(const ValueKey('description')), 'd');
      await tester.enterText(find.byKey(const ValueKey('quote')), 'q');
      await tester.enterText(find.byKey(const ValueKey('light')), 'FFFFFF');
      await tester.enterText(find.byKey(const ValueKey('dark')), '000000');

      await tester.tap(find.text('Finalizar lcp'));
      await tester.pumpAndSettle();

      // El diálogo de nombre del paquete tiene su propio TextField/botón
      // "Continuar" — el formulario de debajo también tiene un botón
      // "Continuar" (para añadir sin finalizar), así que hay que
      // acotar la búsqueda al propio AlertDialog para no ambigüar.
      final dialog = find.byType(AlertDialog);
      await tester.enterText(
        find.descendant(of: dialog, matching: find.byType(TextField)),
        'AcceptanceTestCorp',
      );
      await tester.tap(
        find.descendant(of: dialog, matching: find.text('Continuar')),
      );
      await tester.pumpAndSettle();

      // No se comprueba aquí el SnackBar "Generado: ..." (sí lo hace
      // finalizar_lcp_test.dart, en el host): es un widget efímero con
      // temporizador de verdad, y en un dispositivo/emulador real
      // (IntegrationTestWidgetsFlutterBinding, tiempo real — a diferencia
      // del reloj simulado que usa `flutter test` en el host) puede
      // llegar a autodescartarse antes de esta línea, sobre todo en un
      // emulador de CI lento — visto fallar así en un run real. La
      // comprobación fuerte de este test no es el SnackBar, es releer los
      // bytes reales del disco más abajo.

      // La URI real que acaba de usar Crear — se recupera pidiendo otra
      // vez al selector, que con el override armado devuelve siempre la
      // misma URI durante todo este test (ver useTestSafDocument en
      // MainActivity.kt).
      final lcpUri = await androidSafChannel.invokeMethod<String>(
        'openDocument',
      );
      expect(lcpUri, isNotNull);

      // --- Editar: relee esa misma URI de verdad, sin mocks. ---
      final editSession = EditSession();
      await tester.pumpWidget(
        _wrapWithLocalization(
          EditarEntityTypesScreen(
            session: editSession,
            lcpPath: lcpUri!,
            localeController: LocaleController(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('AcceptanceTestCorp'), findsOneWidget);

      await tester.pumpWidget(
        _wrapWithLocalization(
          EditarEntityCardsScreen(
            session: editSession,
            lcpPath: lcpUri,
            contentKey: 'manufacturers',
            localeController: LocaleController(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('name')),
        'General Manufacturing Systems (editado)',
      );
      await tester.tap(find.text('Guardar cambios'));
      await tester.pumpAndSettle();

      expect(editSession.isDirty(lcpUri), isTrue);

      // Guardar de verdad en disco — el canal nativo real, con el
      // truncado explícito que arregló #39.
      await tester.pumpWidget(
        _wrapWithLocalization(
          EditarEntityTypesScreen(
            session: editSession,
            lcpPath: lcpUri,
            localeController: LocaleController(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Guardar .lcp'));
      await tester.pumpAndSettle();

      expect(editSession.isDirty(lcpUri), isFalse);

      // --- Verificación fuerte: releer los bytes REALES del disco, sin
      // pasar por el estado en memoria de EditSession — justo lo que
      // fallaba en los tres bugs reales corregidos. ---
      final rereadBytes = await AndroidSafFileReader().read(lcpUri);
      final reread = ZipContentPackReader().read(rereadBytes);
      expect(
        reread.contentByKey['manufacturers']!.first['name'],
        'General Manufacturing Systems (editado)',
      );
    },
    skip: !Platform.isAndroid,
  );
}
