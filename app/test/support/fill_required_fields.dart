import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/presentation/forms/field_spec.dart';

import 'robust_interactions.dart';

/// Simula la interacción real de un usuario rellenando los campos
/// obligatorios de un esquema con los valores producidos por
/// `minimalValidValues` (mismo criterio de alcance: nivel superior +
/// [GroupFieldSpec] anidado, nunca dentro de un [ListFieldSpec]).
///
/// Deliberadamente NO existe un atajo para inyectar los valores
/// directamente en el [GenericFormController] desde fuera (`CrearEntidadScreen`
/// no expone ningún `initialValues`) — un test de *aceptación* debe ejercitar
/// la interacción real (`enterText`/tocar un desplegable), igual que lo
/// haría la persona usuaria, no solo la lógica de ensamblado.
Future<void> fillRequiredFields(
  WidgetTester tester,
  List<FieldSpec> fields,
  Map<String, dynamic> values, {
  String keyPrefix = '',
}) async {
  for (final f in fields) {
    switch (f) {
      case TextFieldSpec(:final key):
      case PatternTextFieldSpec(:final key):
        if (values.containsKey(key)) {
          await focusAndEnterText(
            tester,
            find.byKey(ValueKey('$keyPrefix$key')),
            values[key] as String,
          );
        }
      case NumberFieldSpec(:final key):
        if (values.containsKey(key)) {
          await focusAndEnterText(
            tester,
            find.byKey(ValueKey('$keyPrefix$key')),
            values[key].toString(),
          );
        }
      case EnumFieldSpec(:final key):
        if (values.containsKey(key)) {
          await tester.tap(find.byKey(ValueKey('$keyPrefix$key')));
          await tester.pumpAndSettle();
          await tester.tap(find.text(f.labelFor(values[key])).last);
          await tester.pumpAndSettle();
        }
      case GroupFieldSpec(:final key, :final fields):
        final nested = values[key] as Map<String, dynamic>?;
        if (nested != null) {
          await fillRequiredFields(
            tester,
            fields,
            nested,
            keyPrefix: '$keyPrefix$key.',
          );
        }
      case BoolFieldSpec():
      case MultiEnumFieldSpec():
      case ListFieldSpec():
      case ShapeChoiceFieldSpec():
      case CatalogFieldSpec():
        break;
    }
  }
}
