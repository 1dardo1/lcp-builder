import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lcp_builder/infrastructure/file_system/android_saf_channel.dart';
import 'package:lcp_builder/infrastructure/file_system/android_saf_file_reader.dart';
import 'package:lcp_builder/infrastructure/lcp/zip_content_pack_reader.dart';
import 'package:lcp_builder/l10n/gen/app_localizations.dart';
import 'package:lcp_builder/presentation/forms/crear_entidad_configs.dart';
import 'package:lcp_builder/presentation/forms/entity_crear_config.dart';
import 'package:lcp_builder/presentation/i18n/locale_controller.dart';
import 'package:lcp_builder/presentation/screens/crear/crear_entidad_screen.dart';
import 'package:lcp_builder/presentation/screens/editar/editar_entity_cards_screen.dart';
import 'package:lcp_builder/presentation/screens/editar/editar_entity_types_screen.dart';
import 'package:lcp_builder/presentation/session/crear_session.dart';
import 'package:lcp_builder/presentation/session/edit_session.dart';

// A diferencia de `_wrapWithLocalization` en `editar_android_acceptance_test.dart`
// (deliberadamente duplicado allí por ser un wrapper pequeño), estos dos SÍ
// se importan de `test/support/`: son el algoritmo real que ya se verificó
// contra las 20 entidades en el host (`crear_entidad_screen_all_configs_test.dart`,
// ver PR "Fase 1 de tests de aceptación exhaustivos") — duplicarlos aquí
// significaría mantener dos copias de la misma lógica, justo lo que el
// principio del proyecto de "extraer con un segundo consumidor real" pide
// evitar. `integration_test/` puede importar desde `test/` vía ruta relativa
// sin problema (ambos son directorios normales del paquete, no solo `lib/`).
import '../test/support/android_test_saf.dart';
import '../test/support/fill_required_fields.dart';
import '../test/support/minimal_valid_values.dart';

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

/// Ciclo de aceptación completo (Crear → Guardar → Editar → Guardar →
/// Releer), con E/S real (SAF, sin mocks) — igual que
/// `editar_android_acceptance_test.dart`, pero generalizado a cualquier
/// [EntityCrearConfig] en vez de fijo a fabricante, y con los datos
/// mínimos válidos rellenados por `minimalValidValues`/`fillRequiredFields`
/// en vez de a mano campo a campo.
///
/// El canal nativo (`AndroidSafFileWriter`/`Reader`) es agnóstico a qué
/// entidad se está guardando — solo escribe/lee bytes — así que repetir
/// este ciclo para las 20 entidades no ejercita 20 caminos de código
/// nativo distintos (eso ya lo prueba una vez `editar_android_acceptance_test.dart`,
/// que además documenta la regresión específica de #37/#38/#39); lo que sí
/// cubre es que el ensamblado real de cada una de las 20 entidades (JSON
/// específico, campos propios) sobrevive intacto un roundtrip de disco de
/// verdad, no solo el camino en memoria ya cubierto por los 291 tests de
/// host.
Future<void> _cicloAceptacion(WidgetTester tester, EntityCrearConfig config) async {
  // Algunos esquemas (weapon mod, con 4 grupos onMiss/onAttack/onHit/onCrit)
  // son mucho más largos que la pantalla real del emulador — sin esto, la
  // ListView solo construye lo que cabe en el viewport + cache extent, y
  // find.text/find.byKey no encontrarían lo que queda más abajo (mismo
  // problema, y mismo fix, que en editar_android_acceptance_test.dart).
  tester.view.physicalSize = const Size(1080, 20000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  // Sustituye el selector nativo de guardar/abrir por una URI content://
  // de test — sin esto, `flutter test -d emulator` cuelga al abrir el
  // selector real, que nadie puede automatizar (ver armAndroidTestSaf).
  await armAndroidTestSaf();

  // --- Crear: escribe de verdad, vía el selector interceptado. ---
  final crearSession = CrearSession();
  final schema = config.buildSchema();
  await tester.pumpWidget(
    _wrapWithLocalization(
      CrearEntidadScreen(
        config: config,
        session: crearSession,
        localeController: LocaleController(),
      ),
    ),
  );
  await tester.pumpAndSettle();

  await fillRequiredFields(tester, schema, minimalValidValues(schema));

  await tester.tap(find.text('Finalizar lcp'));
  await tester.pumpAndSettle();

  // El diálogo de nombre del paquete tiene su propio TextField/botón
  // "Continuar" — el formulario de debajo también tiene un botón
  // "Continuar" (para añadir sin finalizar), así que hay que acotar la
  // búsqueda al propio AlertDialog para no ambigüar.
  final dialog = find.byType(AlertDialog);
  await tester.enterText(
    find.descendant(of: dialog, matching: find.byType(TextField)),
    'AcceptanceTestCorp',
  );
  await tester.tap(
    find.descendant(of: dialog, matching: find.text('Continuar')),
  );
  await tester.pumpAndSettle();

  // No se comprueba aquí el SnackBar "Generado: ..." — es un widget
  // efímero con temporizador de verdad, y en tiempo real (a diferencia del
  // reloj simulado que usa `flutter test` en el host) puede autodescartarse
  // antes de esta línea. La comprobación fuerte es releer los bytes reales
  // del disco más abajo.

  // La URI real que acaba de usar Crear — se recupera pidiendo otra vez al
  // selector, que con el override armado devuelve siempre la misma URI
  // durante todo este test (ver useTestSafDocument en MainActivity.kt).
  final lcpUri = await androidSafChannel.invokeMethod<String>('openDocument');
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

  await tester.pumpWidget(
    _wrapWithLocalization(
      EditarEntityCardsScreen(
        session: editSession,
        lcpPath: lcpUri,
        contentKey: config.contentKey,
        localeController: LocaleController(),
      ),
    ),
  );
  await tester.pumpAndSettle();

  // `ensureVisible` antes de cada tap: algunos formularios (weapon mod) son
  // más altos que el viewport y el botón, aunque construido, no es
  // "hitteable" sin desplazarlo a la vista — sin esto el tap se pierde en
  // silencio y la acción no ocurre.
  await tester.ensureVisible(find.text('Editar').first);
  await tester.tap(find.text('Editar').first);
  await tester.pumpAndSettle();

  // Todas las 20 entidades tienen un campo `name` de nivel superior
  // (verificado antes de escribir este test), así que sirve como edición
  // genérica sin conocer nada más del esquema concreto.
  const nombreEditado = 'Editado por el test de aceptación';
  await tester.enterText(find.byKey(const ValueKey('name')), nombreEditado);
  await tester.ensureVisible(find.text('Guardar cambios'));
  await tester.tap(find.text('Guardar cambios'));
  await tester.pumpAndSettle();

  // El cambio llegó a la sesión EN MEMORIA (antes de tocar el disco) — si
  // esto falla, el problema está en la edición/validación del formulario,
  // no en la E/S SAF; si pasa pero la relectura de disco de más abajo no,
  // el problema está en la escritura/lectura real.
  //
  // DIAGNÓSTICO (temporal): si la edición no llegó, capturamos por qué —
  // si el banner de validación está visible, el guardado abortó por un
  // campo requerido vacío (hidratación); y volcamos el JSON crudo que
  // Editar recibió para ver qué campo falta.
  final validacionAbortada =
      find.text('Revisa los campos marcados en rojo.').evaluate().isNotEmpty;
  final rawRecibido =
      editSession.packFor(lcpUri)!.contentByKey[config.contentKey]!.first;
  expect(
    rawRecibido['name'],
    nombreEditado,
    reason: 'DIAG ${config.title}: validacionAbortada=$validacionAbortada '
        'rawRecibido=$rawRecibido',
  );
  expect(editSession.isDirty(lcpUri), isTrue);

  // Guardar de verdad en disco — el canal nativo real, con el truncado
  // explícito que arregló #39.
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

  await tester.ensureVisible(find.text('Guardar .lcp'));
  await tester.tap(find.text('Guardar .lcp'));
  await tester.pumpAndSettle();

  expect(editSession.isDirty(lcpUri), isFalse);

  // --- Verificación fuerte: releer los bytes REALES del disco, sin pasar
  // por el estado en memoria de EditSession. ---
  final rereadBytes = await AndroidSafFileReader().read(lcpUri);
  final reread = ZipContentPackReader().read(rereadBytes);
  expect(reread.contentByKey[config.contentKey]!.first['name'], nombreEditado);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  for (final config in crearEntidadConfigs) {
    testWidgets(
      '${config.title}: ciclo real de escritura/lectura en Android (SAF '
      'real, sin mocks) sobrevive Crear→Guardar→Editar→Guardar→Releer',
      (tester) => _cicloAceptacion(tester, config),
      skip: !Platform.isAndroid,
    );
  }
}
