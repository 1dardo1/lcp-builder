import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/presentation/forms/crear_entidad_configs.dart';

import '../../support/minimal_valid_values.dart';

/// Verificación rápida, sin emulador, de que [minimalValidValues] produce
/// datos que de verdad ensamblan para las 20 entidades del registro
/// (`crearEntidadConfigs`) — pensada como paso previo, barato de correr,
/// antes de reutilizar el mismo helper en los tests de aceptación reales
/// de Android (lentos, uno por uno en un emulador, y que aquí no se
/// pueden ejecutar ni depurar). Si `fromFormValues` lanza para alguna
/// entidad, este test señala cuál sin necesidad de tocar un emulador.
void main() {
  for (final config in crearEntidadConfigs) {
    test('${config.title}: minimalValidValues() ensambla sin lanzar', () {
      final values = minimalValidValues(config.buildSchema());
      final content = config.fromFormValues(values);
      expect(config.idOf(content), isNotEmpty);
      expect(config.nameOf(content), isNotEmpty);
    });
  }
}
