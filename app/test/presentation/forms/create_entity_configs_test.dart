import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/presentation/forms/create_entity_configs.dart';
import 'package:lcp_builder/presentation/forms/generic_form_controller.dart';
import 'package:lcp_builder/presentation/forms/generic_form_view.dart';

import '../../support/test_app.dart';

/// Prueba de humo sobre el registro completo de entidades
/// (`createEntityConfigs`), no sobre una entidad concreta — las 20 pruebas
/// de `fromFormValues` ya existentes (`*_form_schema_test.dart`) cubren el
/// ensamblado de cada tipo, pero ninguna prueba existente recorre el
/// registro en sí. Sin esto, un error de cableado (duplicar un
/// `contentKey`, olvidar traducir un título nuevo, o un `buildSchema()`
/// que lance una excepción al construirse) solo se detectaría manualmente
/// al abrir esa entidad concreta en el menú.
void main() {
  test('no hay contentKey duplicados entre las 20 entidades', () {
    final keys = createEntityConfigs.map((c) => c.contentKey).toList();
    expect(keys.toSet(), hasLength(keys.length));
  });

  test('no hay títulos duplicados entre las 20 entidades', () {
    final titles = createEntityConfigs.map((c) => c.title).toList();
    expect(titles.toSet(), hasLength(titles.length));
  });

  test(
    'createEntityConfigsByContentKey indexa exactamente las mismas 20 '
    'entidades que createEntityConfigs, sin perder ni duplicar ninguna',
    () {
      expect(
        createEntityConfigsByContentKey.length,
        createEntityConfigs.length,
      );
      for (final config in createEntityConfigs) {
        expect(createEntityConfigsByContentKey[config.contentKey], config);
      }
    },
  );

  for (final config in createEntityConfigs) {
    testWidgets(
      '${config.title}: buildSchema() no lanza y GenericFormView la '
      'renderiza sin excepciones',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 6000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final fields = config.buildSchema();
        expect(fields, isNotEmpty);

        await tester.pumpWidget(
          wrapWithLocalization(
            Scaffold(
              body: SingleChildScrollView(
                child: GenericFormView(
                  fields: fields,
                  controller: GenericFormController(),
                  formKey: GlobalKey<FormState>(),
                ),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
      },
    );
  }
}
