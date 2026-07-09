import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/domain/ports/content_pack_reader.dart';
import 'package:lcp_builder/presentation/forms/crear_entidad_configs.dart';
import 'package:lcp_builder/presentation/i18n/locale_controller.dart';
import 'package:lcp_builder/presentation/screens/editar/editar_entidad_screen.dart';
import 'package:lcp_builder/presentation/session/edit_session.dart';

import '../../../support/test_app.dart';

void main() {
  final rawManufacturer = {
    'id': 'GMS',
    'name': 'General Manufacturing Systems',
    'description': 'd',
    'quote': 'q',
    'light': 'FFFFFF',
    'dark': '000000',
  };

  ParsedContentPack buildPack() => ParsedContentPack(
    manifest: const ILcpManifestData(
      name: 'Paquete de prueba',
      author: 'Test',
      description: 'desc',
      version: '1.0.0',
    ),
    contentByKey: {
      'manufacturers': [
        rawManufacturer,
        {
          'id': 'IPS-N',
          'name': 'Industrial Printworks Sacrifice-North',
          'description': 'd2',
          'quote': 'q2',
          'light': 'AAAAAA',
          'dark': '111111',
        },
      ],
    },
  );

  testWidgets('el formulario aparece precargado con los datos existentes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final session = EditSession();
    session.load('paquete.lcp', buildPack());

    await tester.pumpWidget(
      wrapWithLocalization(
        EditarEntidadScreen(
          config: crearEntidadConfigsByContentKey['manufacturers']!,
          session: session,
          lcpPath: 'paquete.lcp',
          contentKey: 'manufacturers',
          index: 0,
          rawEntity: rawManufacturer,
          localeController: LocaleController(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('GMS'), findsOneWidget);
    expect(find.text('General Manufacturing Systems'), findsOneWidget);
    expect(find.text('FFFFFF'), findsOneWidget);
  });

  testWidgets(
    'guardar reemplaza solo la entidad editada, sin tocar la otra ni marcar '
    'como no-dirty los campos no cambiados',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final session = EditSession();
      session.load('paquete.lcp', buildPack());

      await tester.pumpWidget(
        wrapWithLocalization(
          EditarEntidadScreen(
            config: crearEntidadConfigsByContentKey['manufacturers']!,
            session: session,
            lcpPath: 'paquete.lcp',
            contentKey: 'manufacturers',
            index: 0,
            rawEntity: rawManufacturer,
            localeController: LocaleController(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('name')),
        'GMS renombrado',
      );
      await tester.tap(find.text('Guardar cambios'));
      await tester.pumpAndSettle();

      final updated =
          session.packFor('paquete.lcp')!.contentByKey['manufacturers']!;
      expect(updated.length, 2);
      expect(updated[0]['name'], 'GMS renombrado');
      // Campos no tocados del mismo registro se conservan.
      expect(updated[0]['description'], 'd');
      expect(updated[0]['light'], 'FFFFFF');
      // La otra entidad no se toca en absoluto.
      expect(updated[1]['name'], 'Industrial Printworks Sacrifice-North');
      expect(session.isDirty('paquete.lcp'), isTrue);
    },
  );
}
