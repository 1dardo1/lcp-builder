import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/infrastructure/lcp/domain_json_mapper.dart';
import 'package:lcp_builder/presentation/forms/crear_entidad_configs.dart';
import 'package:lcp_builder/presentation/forms/field_spec.dart';
import 'package:lcp_builder/presentation/forms/form_values_from_json.dart';
import 'package:lcp_builder/presentation/i18n/field_translations.dart';
import 'package:lcp_builder/presentation/widgets/entity_display_card.dart';

import '../../support/minimal_valid_values.dart';
import '../../support/test_app.dart';

/// Regresión de dos bugs reales que encontró el test de aceptación de
/// Android (ver PRs del arreglo del cuelgue):
///
/// 1. `activeEffectGroupField('onMiss'...)` declaraba su `GroupFieldSpec`
///    sin `jsonKey`, así que su clave por defecto era `onMiss` en vez de
///    la snake_case real del `.lcp` (`on_miss`). Resultado: al abrir un
///    weapon mod en Editar, sus efectos `onMiss`/`onAttack`/`onHit`/
///    `onCrit` salían en blanco (`formValuesFromJson` no los encontraba)
///    y, al ser sus campos obligatorios, la validación bloqueaba el
///    guardado — no se podía re-guardar una entidad recién abierta.
///
/// 2. `EntityDisplayCard` casteaba el valor de un `GroupFieldSpec` a
///    `Map<String, dynamic>` sin comprobarlo — un JSON donde ese valor no
///    fuese un mapa (una entidad cuyo grupo es en realidad una lista, o un
///    `.lcp` ajeno) tumbaba toda la tarjeta con un `_TypeError`.
void main() {
  test(
    'formValuesFromJson hidrata los grupos on_miss/on_attack/... de weapon '
    'mod (jsonKey snake_case correcto)',
    () {
      final config = crearEntidadConfigsByContentKey['mods']!;
      final schema = config.buildSchema();
      final createdJson = entityDataToJson(
        config.fromFormValues(minimalValidValues(schema)),
      );
      final hydrated = formValuesFromJson(schema, createdJson);

      for (final key in ['onMiss', 'onAttack', 'onHit', 'onCrit']) {
        final group = hydrated[key];
        expect(
          group,
          isA<Map<String, dynamic>>(),
          reason: 'el grupo $key debería hidratarse desde su jsonKey '
              'snake_case, no quedarse en null',
        );
        expect((group as Map)['name'], 'x');
      }
    },
  );

  testWidgets(
    'EntityDisplayCard no revienta cuando el valor de un GroupFieldSpec no '
    'es un mapa — lo degrada a resumen',
    (tester) async {
      const schema = [
        GroupFieldSpec(
          key: 'stats',
          label: 'Stats',
          fields: [TextFieldSpec(key: 'hp', label: 'HP')],
        ),
      ];
      await tester.pumpWidget(
        wrapWithLocalization(
          // El JSON trae una lista donde el esquema espera un grupo/mapa.
          const EntityDisplayCard(
            schema: schema,
            data: {
              'stats': [1, 2, 3],
            },
          ),
        ),
      );

      // No hay excepción (la tarjeta se construyó) y muestra algo del grupo.
      expect(tester.takeException(), isNull);
      expect(find.textContaining(translateFieldText('Stats', const Locale('es'))),
          findsOneWidget);
    },
  );
}
