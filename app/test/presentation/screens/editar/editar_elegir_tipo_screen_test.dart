import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/domain/ports/content_pack_reader.dart';
import 'package:lcp_builder/presentation/i18n/locale_controller.dart';
import 'package:lcp_builder/presentation/screens/editar/editar_elegir_tipo_screen.dart';
import 'package:lcp_builder/presentation/session/edit_session.dart';

import '../../../support/test_app.dart';

void main() {
  testWidgets('lista las 24 entidades registradas', (tester) async {
    await tester.pumpWidget(
      wrapWithLocalization(
        EditarElegirTipoScreen(
          session: EditSession(),
          lcpPath: 'paquete.lcp',
          localeController: LocaleController(),
        ),
      ),
    );

    expect(find.text('Elegir tipo de entidad'), findsOneWidget);
    expect(find.text('Crear arma'), findsOneWidget);
    expect(find.text('Crear fabricante'), findsOneWidget);
    expect(find.text('Crear tag'), findsOneWidget);
  });

  testWidgets(
    'elegir un tipo sin ninguna entidad previa crea la primera, y '
    'EditSession registra el contentKey nuevo',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final session = EditSession();
      session.load(
        'paquete.lcp',
        const ParsedContentPack(
          manifest: ILcpManifestData(
            name: 'Paquete',
            author: 'Test',
            description: 'desc',
            version: '1.0.0',
          ),
          // Ningún tag todavía — el contentKey ni siquiera existe.
          contentByKey: {},
        ),
      );

      await tester.pumpWidget(
        wrapWithLocalization(
          EditarElegirTipoScreen(
            session: session,
            lcpPath: 'paquete.lcp',
            localeController: LocaleController(),
          ),
        ),
      );

      await tester.tap(find.text('Crear tag'));
      await tester.pumpAndSettle();

      // Formulario de tag vacío — solo el campo, sin datos precargados.
      expect(find.byKey(const ValueKey('id')), findsOneWidget);

      await tester.enterText(find.byKey(const ValueKey('id')), 'tg_nuevo');
      await tester.enterText(find.byKey(const ValueKey('name')), 'Tag nuevo');
      await tester.enterText(
        find.byKey(const ValueKey('description')),
        'descripción',
      );
      await tester.tap(find.text('Guardar cambios'));
      await tester.pumpAndSettle();

      final tags = session.packFor('paquete.lcp')!.contentByKey['tags'];
      expect(tags, hasLength(1));
      expect(tags!.first['id'], 'tg_nuevo');
      expect(session.isDirty('paquete.lcp'), isTrue);
    },
  );
}
