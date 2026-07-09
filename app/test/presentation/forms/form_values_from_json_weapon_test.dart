import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/infrastructure/lcp/domain_json_mapper.dart';
import 'package:lcp_builder/presentation/forms/form_values_from_json.dart';
import 'package:lcp_builder/presentation/forms/weapon_form_schema.dart';

/// Prueba de aceptación de la auditoría de `fromJsonValue`: convierte un
/// arma real a JSON tal cual la escribiría `CrearContenidoUseCase` y
/// comprueba que `formValuesFromJson` la reconstruye lista para precargar
/// el formulario de Crear — no solo campos escalares, también los enum
/// simples/múltiples que se acaban de auditar en `weapon_form_schema.dart`.
void main() {
  test('hidrata mount y los enums de la munición de un arma real', () {
    const weapon = IWeaponData(
      id: 'mw_rifle',
      name: 'Rifle',
      source: 'GMS',
      license: 'GMS Everest',
      licenseId: 'mf_everest',
      licenseLevel: 2,
      effect: 'Efecto',
      description: 'Descripción',
      mount: MountType.heavy,
      type: WeaponType.rifle,
      ammo: [
        IAmmoData(
          name: 'AP rounds',
          description: 'd',
          allowedTypes: [WeaponType.rifle, WeaponType.cannon],
          allowedSizes: [WeaponSize.heavy],
        ),
      ],
      sp: 3,
    );

    final json = weaponDataToJson(weapon);
    final values = formValuesFromJson(buildWeaponFormSchema(), json);

    expect(values['mount'], MountType.heavy);
    expect(values['sp'], 3);
    expect(values['id'], 'mw_rifle');

    final ammoItems = values['ammo'] as List<Map<String, dynamic>>;
    expect(ammoItems, hasLength(1));
    expect(ammoItems.first['allowedTypes'], [
      WeaponType.rifle,
      WeaponType.cannon,
    ]);
    expect(ammoItems.first['allowedSizes'], [WeaponSize.heavy]);

    // `type` (ShapeChoiceFieldSpec, ver tarea pendiente) no se hidrata
    // todavía — comprobamos explícitamente que no rompe, en vez de dar
    // por hecho el resultado.
    expect(values.containsKey('type.a'), isFalse);
    expect(values.containsKey('type.b'), isFalse);
  });
}
