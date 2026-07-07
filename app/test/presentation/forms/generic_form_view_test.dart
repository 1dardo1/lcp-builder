import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/presentation/forms/generic_form_controller.dart';
import 'package:lcp_builder/presentation/forms/generic_form_view.dart';
import 'package:lcp_builder/presentation/forms/weapon_form_schema.dart';

void main() {
  testWidgets(
    'un CatalogFieldSpec anidado dentro de un ListFieldSpec renderiza su sub-campo',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = GenericFormController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: GenericFormView(
                fields: buildWeaponFormSchema(),
                controller: controller,
              ),
            ),
          ),
        ),
      );

      // Sin ítems de "Bonuses" todavía.
      expect(find.text('Añadir Bonuses'), findsOneWidget);

      // Añadir un ítem de bonus.
      await tester.tap(find.text('Añadir Bonuses'));
      await tester.pumpAndSettle();

      final bonusItems = controller.values['bonuses'] as List;
      expect(bonusItems, hasLength(1));

      // Elegir un id concreto (accuracy -> numericOrFormula) directamente en
      // el controlador (equivalente a seleccionarlo en el dropdown) y
      // comprobar que aparece el ShapeChoiceFieldSpec anidado.
      controller.set('bonuses', [
        {
          ...bonusItems.first as Map<String, dynamic>,
          'bonus.id': BonusId.accuracy,
        },
      ]);
      await tester.pumpAndSettle();

      // "Número" aparece dos veces (segmento del choice + label del campo
      // numérico anidado); "Fórmula" solo en el segmento, ya que el campo B
      // no se renderiza hasta que se elija esa opción.
      expect(find.text('Número'), findsNWidgets(2));
      expect(find.text('Fórmula'), findsOneWidget);
      expect(find.byKey(const ValueKey('bonus.value.a')), findsOneWidget);
    },
  );
}
