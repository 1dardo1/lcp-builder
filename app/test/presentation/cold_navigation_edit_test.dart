import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/domain/ports/content_pack_reader.dart';
import 'package:lcp_builder/infrastructure/lcp/domain_json_mapper.dart';
import 'package:lcp_builder/presentation/i18n/locale_controller.dart';
import 'package:lcp_builder/presentation/screens/editar/editar_entity_types_screen.dart';
import 'package:lcp_builder/presentation/session/edit_session.dart';

import '../support/phone_metrics.dart';
import '../support/test_app.dart';

/// Ángulo que faltaba: recorrer la **navegación en frío** completa que hace
/// la persona usuaria — pantalla de tipos → tarjetas → editar, con
/// `Navigator.push` reales entre pantallas — en vez de pumpear cada
/// pantalla por separado como raíz (lo que hace el test de aceptación,
/// saltándose la cadena de navegación). A tamaño de móvil real.
void main() {
  testWidgets(
    'flujo Editar en frío: tipos → tarjetas → editar navega y precarga los '
    'datos, a tamaño de móvil real',
    (tester) async {
      usePhoneMetrics(tester);

      final fabricante = entityDataToJson(
        const IManufacturerData(
          id: 'TBC',
          name: 'The Butlers Corp',
          description: 'Elite hospitality and tactical butlerage.',
          quote: '"Please, remain seated, Madam."',
          light: '#2B2D42',
          dark: '#D4AF37',
        ),
      );
      final pack = ParsedContentPack(
        manifest: const ILcpManifestData(
          name: 'TheButlersCorp', author: 'a', description: 'd', version: '1.0.0'),
        contentByKey: {
          'manufacturers': [fabricante],
        },
      );

      await tester.pumpWidget(
        wrapWithLocalization(
          EditarEntityTypesScreen(
            session: EditSession(),
            lcpPath: 'p.lcp',
            localeController: LocaleController(),
            // Carga en frío desde disco (inyectada): el usuario abre un
            // `.lcp` que la sesión aún no tenía cargado.
            loadContent: (_) async => pack,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Pantalla de tipos: aparece el manifest y el tipo con su recuento.
      expect(find.text('TheButlersCorp'), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);

      // → tarjetas de ese tipo.
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Editar'), findsWidgets);

      // → editar la entidad.
      await tester.ensureVisible(find.text('Editar').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Editar').first, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // Llegamos al formulario de edición, precargado con el dato real.
      expect(find.text('Guardar cambios'), findsOneWidget);
      expect(find.text('The Butlers Corp'), findsOneWidget);
    },
  );
}
