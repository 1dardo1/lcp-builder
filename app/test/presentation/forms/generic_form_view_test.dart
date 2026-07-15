import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/presentation/forms/field_spec.dart';
import 'package:lcp_builder/presentation/forms/generic_form_controller.dart';
import 'package:lcp_builder/presentation/forms/generic_form_view.dart';
import 'package:lcp_builder/presentation/forms/weapon_form_schema.dart';

import '../../support/test_app.dart';

Future<GenericFormController> _pumpFields(
  WidgetTester tester,
  List<FieldSpec> fields, {
  Future<String?> Function(String)? onCreateReference,
}) async {
  final controller = GenericFormController();
  await tester.pumpWidget(
    wrapWithLocalization(
      Scaffold(
        body: SingleChildScrollView(
          child: GenericFormView(
            fields: fields,
            controller: controller,
            formKey: GlobalKey<FormState>(),
            onCreateReference: onCreateReference,
          ),
        ),
      ),
    ),
  );
  return controller;
}

void main() {
  testWidgets(
    'MultiEnumFieldSpec: cada opción es un FilterChip que alterna en la lista',
    (tester) async {
      final controller = await _pumpFields(tester, [
        MultiEnumFieldSpec<DamageType>(
          key: 'damageTypes',
          label: 'Tipos de daño',
          options: DamageType.values,
          displayLabel: (d) => d.jsonValue,
        ),
      ]);

      expect(find.text('Kinetic'), findsOneWidget);
      expect(find.text('Energy'), findsOneWidget);

      await tester.tap(find.text('Kinetic'));
      await tester.pump();
      expect(controller.values['damageTypes'], [DamageType.kinetic]);

      await tester.tap(find.text('Energy'));
      await tester.pump();
      expect(controller.values['damageTypes'], [
        DamageType.kinetic,
        DamageType.energy,
      ]);

      await tester.tap(find.text('Kinetic'));
      await tester.pump();
      expect(controller.values['damageTypes'], [DamageType.energy]);
    },
  );

  testWidgets(
    'GroupFieldSpec: sus campos escriben en un único mapa bajo su key, no una lista',
    (tester) async {
      final controller = await _pumpFields(tester, [
        const GroupFieldSpec(
          key: 'save',
          label: 'Save',
          fields: [
            TextFieldSpec(key: 'stat', label: 'Stat', required: true),
            BoolFieldSpec(key: 'aoe', label: 'AoE'),
          ],
        ),
      ]);

      await tester.enterText(
        find.byKey(const ValueKey('save.stat')),
        'hull',
      );
      await tester.tap(find.byKey(const ValueKey('save.aoe')));
      await tester.pump();

      expect(controller.values['save'], {'stat': 'hull', 'aoe': true});
    },
  );

  testWidgets(
    'ShapeChoiceFieldSpec: admite más de 2 ramas, y una rama sin campo no pinta nada',
    (tester) async {
      final controller = await _pumpFields(tester, [
        const ShapeChoiceFieldSpec(
          key: 'count',
          label: 'Count',
          options: [
            ShapeChoiceOption(
              value: 'single',
              label: 'Único',
              field: NumberFieldSpec(key: 'count.single', label: 'Número'),
            ),
            ShapeChoiceOption(
              value: 'perTier',
              label: 'Por tier',
              field: GroupFieldSpec(
                key: 'count.perTier',
                label: 'Por tier',
                fields: [
                  NumberFieldSpec(key: 'tier1', label: 'Tier 1'),
                  NumberFieldSpec(key: 'tier2', label: 'Tier 2'),
                  NumberFieldSpec(key: 'tier3', label: 'Tier 3'),
                ],
              ),
            ),
            ShapeChoiceOption(value: 'hostile', label: 'Hostile characters'),
          ],
        ),
      ]);

      // Las 3 ramas están disponibles como segmentos, y por defecto se
      // muestra la primera (con su campo numérico anidado).
      expect(find.text('Único'), findsOneWidget);
      expect(find.text('Por tier'), findsOneWidget);
      expect(find.text('Hostile characters'), findsOneWidget);
      expect(find.byKey(const ValueKey('count.single')), findsOneWidget);

      await tester.tap(find.text('Por tier'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('count.single')), findsNothing);
      expect(find.byKey(const ValueKey('count.perTier.tier1')), findsOneWidget);
      expect(find.byKey(const ValueKey('count.perTier.tier2')), findsOneWidget);
      expect(find.byKey(const ValueKey('count.perTier.tier3')), findsOneWidget);

      // La rama "hostile" no tiene `field` — elegirla no debe pintar ningún
      // sub-campo (ni el de "single" ni el de "perTier").
      await tester.tap(find.text('Hostile characters'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('count.single')), findsNothing);
      expect(find.byKey(const ValueKey('count.perTier.tier1')), findsNothing);
      expect(controller.values['count.choice'], 'hostile');
    },
  );

  testWidgets(
    'un CatalogFieldSpec anidado dentro de un ListFieldSpec renderiza su sub-campo',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = GenericFormController();
      await tester.pumpWidget(
        wrapWithLocalization(
          Scaffold(
            body: SingleChildScrollView(
              child: GenericFormView(
                fields: buildWeaponFormSchema(),
                controller: controller,
                formKey: GlobalKey<FormState>(),
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

  testWidgets(
    'FieldSpec.helpText: pinta un botón de ayuda que abre un diálogo con el texto',
    (tester) async {
      await _pumpFields(tester, [
        const TextFieldSpec(
          key: 'source',
          label: 'Fabricante',
          helpText: 'Aquí va el ID del fabricante, no su nombre.',
        ),
      ]);

      expect(find.byIcon(Icons.help_outline), findsOneWidget);
      expect(
        find.text('Aquí va el ID del fabricante, no su nombre.'),
        findsNothing,
      );

      await tester.tap(find.byIcon(Icons.help_outline));
      await tester.pumpAndSettle();

      expect(
        find.text('Aquí va el ID del fabricante, no su nombre.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'TextFieldSpec.referenceEntityKey: pinta un botón "Crear X" que rellena '
    'el campo con el id devuelto por onCreateReference',
    (tester) async {
      final controller = await _pumpFields(
        tester,
        [
          const TextFieldSpec(
            key: 'source',
            label: 'Fabricante',
            referenceEntityKey: 'manufacturers',
            referenceLabel: 'fabricante',
          ),
        ],
        onCreateReference: (key) async {
          expect(key, 'manufacturers');
          return 'TEST_MFR';
        },
      );

      expect(find.text('Crear fabricante'), findsOneWidget);
      expect(controller.get('source'), isNull);

      await tester.tap(find.text('Crear fabricante'));
      await tester.pumpAndSettle();

      expect(controller.get('source'), 'TEST_MFR');
      // No solo el valor interno del controlador: el propio TextFormField
      // debe mostrar el id relleno "desde fuera" (regresión del bug de
      // `TextFormField.initialValue`, que solo se aplica en el primer
      // build — ver `_ControlledTextField` en `generic_form_view.dart`).
      expect(find.text('TEST_MFR'), findsOneWidget);
    },
  );

  testWidgets(
    'sin onCreateReference, un TextFieldSpec con referenceEntityKey no pinta '
    'el botón de creación',
    (tester) async {
      await _pumpFields(tester, [
        const TextFieldSpec(
          key: 'source',
          label: 'Fabricante',
          referenceEntityKey: 'manufacturers',
          referenceLabel: 'fabricante',
        ),
      ]);

      expect(find.text('Crear fabricante'), findsNothing);
    },
  );

  testWidgets(
    'locale en: traduce label/helpText del campo y el texto fijo del motor '
    '(Ayuda/Crear referencia), vía field_translations.dart',
    (tester) async {
      final controller = GenericFormController();
      await tester.pumpWidget(
        wrapWithLocalization(
          Scaffold(
            body: GenericFormView(
              fields: const [
                TextFieldSpec(
                  key: 'source',
                  label: 'Fabricante (source)',
                  helpText:
                      'El ID del fabricante (Manufacturer), no su nombre visible.',
                  referenceEntityKey: 'manufacturers',
                  referenceLabel: 'fabricante',
                ),
              ],
              controller: controller,
              formKey: GlobalKey<FormState>(),
              locale: const Locale('en'),
              onCreateReference: (_) async => 'X',
            ),
          ),
          locale: const Locale('en'),
        ),
      );

      expect(find.text('Manufacturer (source)'), findsOneWidget);
      expect(find.text('Create manufacturer'), findsOneWidget);
      expect(find.text('Fabricante (source)'), findsNothing);

      await tester.tap(find.byIcon(Icons.help_outline));
      await tester.pumpAndSettle();

      expect(
        find.text("The manufacturer's ID, not its display name."),
        findsOneWidget,
      );
      expect(find.text('Close'), findsOneWidget);
    },
  );
}
