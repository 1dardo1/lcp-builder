import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/infrastructure/lcp/domain_json_mapper.dart';
import 'package:lcp_builder/presentation/forms/crear_entidad_configs.dart';
import 'package:lcp_builder/presentation/forms/form_values_from_json.dart';

import '../../support/minimal_valid_values.dart';

/// Regresión del error del banner rojo al Guardar: `type 'int' is not a
/// subtype of type 'String?' in type cast`. Es la gemela por el lado de
/// GUARDAR del bug de la "pantalla gris" (#59): un `.lcp` cuyo `damage.val`
/// (un campo de texto de dado) viene como número (`1`) hidrataba el
/// controlador con un `int`, y al ensamblar la entidad para guardar
/// (`item['val'] as String?`) reventaba. #59 solo arregló el lado de mostrar
/// (el campo pinta "1"); esto arregla el de guardar, coaccionando a texto en
/// la hidratación.
void main() {
  test('un campo de texto con valor numérico en el .lcp (damage.val: int) se '
      'hidrata y se ensambla al Guardar sin reventar', () {
    final config = crearEntidadConfigsByContentKey['weapons']!;
    final schema = config.buildSchema();

    // Un weapon válido cuyo `damage.val` es un número, como el .lcp real de
    // la captura (el propio Crear serializa el dado plano como int).
    final raw =
        entityDataToJson(config.fromFormValues(minimalValidValues(schema)))
          ..['damage'] = [
            {'type': 'Kinetic', 'val': 1},
          ];

    final values = formValuesFromJson(schema, raw);

    // El campo de texto quedó como texto, no como int.
    expect(values['damage'], isA<List>());
    final damageItem = (values['damage'] as List).first as Map;
    expect(damageItem['val'], '1');

    // Y ensamblar para guardar ya no lanza el TypeError.
    final content = config.fromFormValues(values);
    final json = entityDataToJson(content);
    expect(json['damage'], isNotEmpty);
  });
}
