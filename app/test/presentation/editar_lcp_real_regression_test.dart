import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/infrastructure/lcp/zip_content_pack_reader.dart';
import 'package:lcp_builder/presentation/forms/crear_entidad_configs.dart';
import 'package:lcp_builder/presentation/i18n/locale_controller.dart';
import 'package:lcp_builder/presentation/screens/editar/editar_entidad_screen.dart';
import 'package:lcp_builder/presentation/session/edit_session.dart';

import '../support/test_app.dart';

/// Regresión del bug de la "pantalla gris al editar": un `.lcp` real
/// (`test/fixtures/the_butlers_corp.lcp`, aportado por el perfil objetivo)
/// hacía reventar `EditarEntidadScreen` al abrirlo — en release, una
/// excepción al construir un widget se pinta como `ErrorWidget` gris.
///
/// Dos formas reales que el propio Crear serializa pero que el hidratador
/// del formulario no sabía releer (cast duro → crash que tumbaba toda la
/// pantalla):
/// - `weapon.damage[].val` numérico (`1`) en un campo de texto → antes
///   `int is not a subtype of String?`.
/// - `frame.mechtype` como lista de strings (`["Striker","Support"]`) donde
///   el formulario modela una lista de objetos `[{id}]` → antes
///   `String is not a subtype of Map<String,dynamic>`.
///
/// Ahora el hidratador coacciona/degrada en vez de castear a ciegas, así
/// que abrir Editar sobre cualquier `.lcp` no revienta. Este test monta la
/// pantalla de Editar de cada entidad del `.lcp` real y comprueba que se
/// construye sin lanzar.
void main() {
  final bytes = File('test/fixtures/the_butlers_corp.lcp').readAsBytesSync();
  final pack = ZipContentPackReader().read(bytes);

  for (final entry in pack.contentByKey.entries) {
    final config = crearEntidadConfigsByContentKey[entry.key];
    if (config == null || entry.value.isEmpty) continue;

    testWidgets(
      'abrir Editar de "${entry.key}" del .lcp real no revienta la pantalla',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2340);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final session = EditSession()..load('p.lcp', pack);
        await tester.pumpWidget(
          wrapWithLocalization(
            EditarEntidadScreen(
              config: config,
              session: session,
              lcpPath: 'p.lcp',
              contentKey: entry.key,
              index: 0,
              rawEntity: entry.value.first,
              localeController: LocaleController(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          tester.takeException(),
          isNull,
          reason: '"${entry.key}" reventó al abrir Editar (pantalla gris)',
        );
        // No es una pantalla en blanco: el formulario se construyó.
        expect(find.byType(TextFormField), findsWidgets);
      },
    );
  }
}
