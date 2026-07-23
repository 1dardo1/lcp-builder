import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/infrastructure/lcp/domain_json_mapper.dart';
import 'package:lcp_builder/infrastructure/lcp/lcp_zip_encoder.dart';
import 'package:lcp_builder/infrastructure/lcp/zip_content_pack_reader.dart';
import 'package:lcp_builder/l10n/gen/app_localizations.dart';
import 'package:lcp_builder/presentation/forms/crear_entidad_configs.dart';
import 'package:lcp_builder/presentation/forms/entity_crear_config.dart';
import 'package:lcp_builder/presentation/i18n/locale_controller.dart';
import 'package:lcp_builder/presentation/screens/editar/editar_entidad_screen.dart';
import 'package:lcp_builder/presentation/session/edit_session.dart';

import '../test/support/minimal_valid_values.dart';

/// Cubre el ángulo release/profile de la forma FIABLE: montando la pantalla
/// de Editar (`pumpWidget`) y comprobando que se construye sin reventar,
/// **sin tocar ni escribir nada**. Es la clave para que este test SÍ corra
/// bien con `flutter drive` en profile: la fragilidad de `flutter drive`
/// sobre un emulador real está en la ENTRADA (taps/enterText sobre el
/// lienzo gigante 1080×20000 del test de aceptación, más grande que la
/// pantalla física, no registran) — no en el renderizado. Aquí no hay
/// entrada: solo se pinta la pantalla con datos ya construidos y se
/// verifica que no lanza.
///
/// Es exactamente el camino donde vive el bug de la "pantalla gris al
/// editar": en profile/release, un widget que revienta al construirse
/// muestra el `ErrorWidget` gris (en debug sería la pantalla roja, que
/// `flutter test` sí detectaría). Correr esto en profile es lo que puede
/// cazar esa clase de fallo.
Widget _wrap(Widget home) => MaterialApp(
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

Future<void> _montarEditar(
  WidgetTester tester,
  EntityCrearConfig config,
  Map<String, dynamic> rawEntity,
) async {
  // Tamaño de móvil real, no el lienzo gigante del test de aceptación.
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  // Ciclo real de disco (puro Dart, sin SAF): serializa, empaqueta y relee,
  // para hidratar el formulario desde el mismo JSON que habría en un .lcp.
  final bytes = encodeLcpZip(
    manifestJson: lcpManifestDataToJson(
      const ILcpManifestData(
        name: 'p', author: 'a', description: 'd', version: '1.0.0'),
    ),
    contentByKey: {
      config.contentKey: [rawEntity],
    },
  );
  final pack = ZipContentPackReader().read(bytes);
  final releido = pack.contentByKey[config.contentKey]!.first;

  final session = EditSession()..load('p.lcp', pack);
  await tester.pumpWidget(
    _wrap(
      EditarEntidadScreen(
        config: config,
        session: session,
        lcpPath: 'p.lcp',
        contentKey: config.contentKey,
        index: 0,
        rawEntity: releido,
        localeController: LocaleController(),
      ),
    ),
  );
  await tester.pumpAndSettle();

  expect(
    tester.takeException(),
    isNull,
    reason: '${config.title}: la pantalla de Editar reventó al construirse '
        'en profile (pantalla gris)',
  );
  expect(find.byType(TextFormField), findsWidgets);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Las 20 entidades, con datos mínimos, a tamaño real y en profile.
  for (final config in crearEntidadConfigs) {
    testWidgets(
      '${config.title}: la pantalla de Editar se construye sin reventar '
      '(profile, tamaño de móvil real)',
      (tester) async {
        final rawEntity = entityDataToJson(
          config.fromFormValues(minimalValidValues(config.buildSchema())),
        );
        await _montarEditar(tester, config, rawEntity);
      },
    );
  }

  // El caso real que reportó la persona usuaria: un fabricante con datos de
  // verdad (texto largo, saltos de línea, colores con "#").
  testWidgets(
    'fabricante con datos reales: la pantalla de Editar se construye sin '
    'reventar (profile, tamaño de móvil real)',
    (tester) async {
      final rawEntity = entityDataToJson(
        const IManufacturerData(
          id: 'TBC',
          name: 'The Butlers Corp',
          description:
              'Originally founded as an elite hospitality and domestic '
              'management syndicate for the oligarchy of the Core Worlds, The '
              'Butlers Corp (TBC) has evolved into the premier provider of '
              'high-stakes executive protection and tactical butlerage.',
          quote:
              '"The tea is served at exactly eighty-two degrees, and the '
              'perimeter is completely secure. Please, remain seated, Madam."\n'
              '— Senior Seneschal James Vance, during the Siege of New Kyoto.',
          light: '#2B2D42',
          dark: '#D4AF37',
        ),
      );
      await _montarEditar(
        tester,
        crearEntidadConfigsByContentKey['manufacturers']!,
        rawEntity,
      );
      expect(find.text('The Butlers Corp'), findsOneWidget);
    },
  );

  // Las dos formas concretas del `.lcp` real que hacían pantalla gris al
  // editar (regresión cubierta también en host por
  // `editar_lcp_real_regression_test`), ejercitadas aquí en profile/AOT:
  // un `val` numérico en el daño de un arma, y `mechtype` como lista de
  // strings en un frame.
  testWidgets(
    'arma con val numérico (int) en el daño: Editar no revienta en profile',
    (tester) async {
      final config = crearEntidadConfigsByContentKey['weapons']!;
      final rawEntity = entityDataToJson(
        config.fromFormValues(minimalValidValues(config.buildSchema())),
      )..['damage'] = [
          {'type': 'Kinetic', 'val': 1},
        ];
      await _montarEditar(tester, config, rawEntity);
    },
  );

  testWidgets(
    'frame con mechtype como lista de strings: Editar no revienta en profile',
    (tester) async {
      final config = crearEntidadConfigsByContentKey['frames']!;
      final rawEntity = entityDataToJson(
        config.fromFormValues(minimalValidValues(config.buildSchema())),
      )..['mechtype'] = ['Striker', 'Support'];
      await _montarEditar(tester, config, rawEntity);
    },
  );
}
