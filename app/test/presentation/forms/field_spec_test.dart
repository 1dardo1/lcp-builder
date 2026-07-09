import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/presentation/forms/field_spec.dart';

/// `jsonKey` es la pieza que Mostrar necesita para saber, sin duplicar
/// los 24 esquemas de Crear, a qué clave real del JSON corresponde cada
/// campo — ver el comentario en `field_spec.dart`.
void main() {
  test('sin jsonKey explícito, usa key', () {
    const field = TextFieldSpec(key: 'licenseId', label: 'x');
    expect(field.jsonKey, 'licenseId');
  });

  test('con jsonKey explícito, lo respeta en vez de key', () {
    const field = TextFieldSpec(
      key: 'licenseId',
      label: 'x',
      jsonKey: 'license_id',
    );
    expect(field.jsonKey, 'license_id');
  });

  test('el default aplica igual en cualquier subtipo de FieldSpec', () {
    const shapeChoice = ShapeChoiceFieldSpec(
      key: 'type',
      label: 'x',
      options: [],
    );
    expect(shapeChoice.jsonKey, 'type');
  });
}
