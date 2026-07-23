import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/infrastructure/lcp/domain_json_mapper.dart';
import 'package:lcp_builder/infrastructure/lcp/lcp_zip_encoder.dart';
import 'package:lcp_builder/infrastructure/lcp/zip_content_pack_reader.dart';
import 'package:lcp_builder/presentation/forms/crear_entidad_configs.dart';
import 'package:lcp_builder/presentation/forms/entity_crear_config.dart';
import 'package:lcp_builder/presentation/i18n/locale_controller.dart';
import 'package:lcp_builder/presentation/screens/editar/editar_entidad_screen.dart';
import 'package:lcp_builder/presentation/session/edit_session.dart';

import '../support/minimal_valid_values.dart';
import '../support/phone_metrics.dart';
import '../support/test_app.dart';

/// Ángulos que faltaban, combinados: abrir para Editar una entidad que
/// **ha pasado de verdad por el disco** (se serializa con el mapper real,
/// se empaqueta como `.lcp` y se relee, en vez de pasar el objeto en
/// memoria) y hacerlo a **tamaño de móvil real**. El test de aceptación
/// solo editaba entidades recién creadas en la misma sesión, con datos
/// mínimos y en un lienzo gigante — nunca un `.lcp` releído en frío en una
/// pantalla de tamaño real, que es justo lo que hace la persona usuaria.
Future<void> abrirEditarTrasDisco(
  WidgetTester tester,
  EntityCrearConfig config,
  Map<String, dynamic> rawEntity,
) async {
  usePhoneMetrics(tester);

  final bytes = encodeLcpZip(
    manifestJson: lcpManifestDataToJson(
      const ILcpManifestData(
        name: 'Paquete real', author: 'a', description: 'd', version: '1.0.0'),
    ),
    contentByKey: {
      config.contentKey: [rawEntity],
    },
  );
  final pack = ZipContentPackReader().read(bytes);
  final releido = pack.contentByKey[config.contentKey]!.first;

  final session = EditSession()..load('p.lcp', pack);
  await tester.pumpWidget(
    wrapWithLocalization(
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
    reason: '${config.title}: abrir Editar tras releer del disco reventó a '
        'tamaño de móvil real',
  );
  // No es una pantalla en blanco: el formulario se construyó.
  expect(find.byType(TextFormField), findsWidgets);
}

void main() {
  // Cobertura amplia: las 20 entidades, con datos mínimos pero pasando por
  // el ciclo real de disco y a tamaño real.
  for (final config in crearEntidadConfigs) {
    testWidgets(
      '${config.title}: abrir Editar tras Crear→escribir→releer no revienta '
      'a tamaño de móvil real',
      (tester) async {
        final schema = config.buildSchema();
        final rawEntity = entityDataToJson(
          config.fromFormValues(minimalValidValues(schema)),
        );
        await abrirEditarTrasDisco(tester, config, rawEntity);
      },
    );
  }

  // Cobertura profunda del ángulo "datos reales": un fabricante con
  // contenido de verdad — descripción larga, cita con salto de línea,
  // colores con "#" — reproduciendo el caso que reportó la persona usuaria
  // (el .lcp "TheButlersCorp").
  testWidgets(
    'editar un fabricante con datos reales (texto largo, saltos de línea, '
    'colores con #) tras releer del disco no revienta a tamaño real',
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
      await abrirEditarTrasDisco(
        tester,
        crearEntidadConfigsByContentKey['manufacturers']!,
        rawEntity,
      );

      // Los datos reales llegaron precargados al formulario.
      expect(find.text('The Butlers Corp'), findsOneWidget);
    },
  );
}
