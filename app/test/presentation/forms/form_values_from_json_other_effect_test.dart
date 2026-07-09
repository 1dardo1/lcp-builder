import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/infrastructure/lcp/domain_json_mapper.dart';
import 'package:lcp_builder/presentation/forms/common_entity_fields.dart';
import 'package:lcp_builder/presentation/forms/form_values_from_json.dart';

/// Prueba de aceptación de `otherEffectCatalogField` (`CatalogFieldSpec`):
/// a diferencia del enum simple, aquí el id del catálogo se lee del campo
/// `type` del JSON, no de una clave con el nombre del catálogo — y el
/// mismo campo `val` sirve de valor sea cual sea la rama elegida.
void main() {
  test('CoverEffectData (rama enum) se hidrata vía otherEffect.value', () {
    const effect = CoverEffectData(val: CoverLevel.hard, target: TargetType.enemy);
    final json = otherEffectDataToJson(effect);

    final values = formValuesFromJson(otherEffectItemFields(), json);

    expect(values['otherEffect.id'], OtherEffectKind.cover);
    expect(values['otherEffect.value'], CoverLevel.hard);
    expect(values['target'], TargetType.enemy);
  });

  test('OvershieldEffectData (rama numérica) se hidrata vía otherEffect.value.a', () {
    const effect = OvershieldEffectData(val: NumericOrFormulaValue.number(3));
    final json = otherEffectDataToJson(effect);

    final values = formValuesFromJson(otherEffectItemFields(), json);

    expect(values['otherEffect.id'], OtherEffectKind.overshield);
    expect(values['otherEffect.value.choice'], 'A');
    expect(values['otherEffect.value.a'], 3);
  });
}
