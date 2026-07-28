import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/infrastructure/lcp/domain_json_mapper.dart';
import 'package:lcp_builder/presentation/forms/crear_entidad_configs.dart';
import 'package:lcp_builder/presentation/forms/form_values_from_json.dart';

import '../../support/minimal_valid_values.dart';

/// Regresión del hueco encontrado al crear un cuchillo arrojadizo: el
/// formulario de tags solo tenía el campo `id`, así que no se podía dar el
/// valor de un tag numérico (Thrown 5, Reliable 2, Limited 3...). El dominio
/// (`ITagInstance.val`) y el `.lcp` (`{"id":"tg_reliable","val":2}`) sí lo
/// soportaban; faltaba exponerlo en el formulario y leerlo en `tagFromItem`.
void main() {
  test('un tag con valor (Thrown 5) se ensambla, serializa y relee conservando '
      'el val', () {
    final config = crearEntidadConfigsByContentKey['weapons']!;
    final schema = config.buildSchema();

    final values = minimalValidValues(schema)
      ..['tags'] = [
        {'id': 'tg_thrown', 'val': 5},
      ];

    final json = entityDataToJson(config.fromFormValues(values));
    final tags = json['tags'] as List;
    expect(tags, hasLength(1));
    // `equals` sobre el Map literal compara en profundidad (a diferencia de
    // `contains`, que usa `==` y en Dart dos Map distintos nunca son iguales).
    expect(tags.first, {'id': 'tg_thrown', 'val': 5});

    // Y al reabrir en Editar (hidratación) el valor sigue ahí.
    final rehydrated = formValuesFromJson(schema, json);
    final tag = (rehydrated['tags'] as List).first as Map;
    expect(tag['id'], 'tg_thrown');
    expect(tag['val'], 5);
  });
}
