import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/infrastructure/lcp/domain_json_mapper.dart';
import 'package:lcp_builder/presentation/forms/create_entity_configs.dart';
import 'package:lcp_builder/presentation/forms/generic_form_controller.dart';

import '../../support/minimal_valid_values.dart';

/// Al Guardar, `GenericFormController.trimTextValues` recorta los espacios
/// sobrantes de TODOS los textos (no solo de un campo suelto) antes de
/// ensamblar el dominio — generalización del arreglo puntual de #73 (el
/// `tg_thrown ` con espacio que COMP/CON no reconocía).
void main() {
  test('recorta id/nombre de nivel superior y el id de un tag anidado en una '
      'lista, y el ensamblado sigue funcionando', () {
    final config = createEntityConfigsByContentKey['weapons']!;
    final schema = config.buildSchema();

    final values = minimalValidValues(schema)
      ..['id'] = '  wpn_test '
      ..['name'] = ' Cuchillo arrojadizo '
      // La lista se declara con el tipo de runtime real (List<Map<String,
      // dynamic>>), el mismo que producen la hidratación y el onChanged del
      // motor — así el test cubre que el recorte in situ lo conserva.
      ..['tags'] = <Map<String, dynamic>>[
        {'id': ' tg_thrown ', 'val': 5},
      ];

    final controller = GenericFormController(initialValues: values);
    controller.trimTextValues();

    // La lista sigue siendo List<Map<String, dynamic>> (si el recorte la
    // hubiera rehecho como List<dynamic>, el cast del ensamblador reventaría).
    expect(controller.values['tags'], isA<List<Map<String, dynamic>>>());

    final json = entityDataToJson(config.fromFormValues(controller.values));
    expect(json['id'], 'wpn_test');
    expect(json['name'], 'Cuchillo arrojadizo');
    expect((json['tags'] as List).first, {'id': 'tg_thrown', 'val': 5});
  });

  test('recorta también dentro de un GroupFieldSpec (mapa anidado)', () {
    // `damage` es un GroupFieldSpec dentro de las actions de un arma; aquí se
    // prueba el recorte de un mapa anidado de forma directa sobre el árbol.
    final controller = GenericFormController(
      initialValues: {
        'id': ' x ',
        'grupo': <String, dynamic>{'sub': '  y  '},
        'lista': <Map<String, dynamic>>[
          {'campo': ' z '},
        ],
        // Los no-texto se dejan intactos.
        'numero': 3,
        'bool': true,
      },
    );

    controller.trimTextValues();
    final v = controller.values;

    expect(v['id'], 'x');
    expect((v['grupo'] as Map)['sub'], 'y');
    expect(((v['lista'] as List).first as Map)['campo'], 'z');
    expect(v['numero'], 3);
    expect(v['bool'], true);
  });
}
