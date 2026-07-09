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

    // `type` es un ShapeChoiceFieldSpec (único WeaponType vs. lista) — el
    // JSON trae un único string, así que la rama detectada debe ser "A" y
    // `type.a` debe traer la instancia ya reconstruida.
    expect(values['type.choice'], 'A');
    expect(values['type.a'], WeaponType.rifle);
    expect(values.containsKey('type.b'), isFalse);
  });

  test('type como lista hidrata la rama "B" en vez de "A"', () {
    const weapon = IWeaponData(
      id: 'mw_multi',
      name: 'Multi',
      source: 'GMS',
      license: 'GMS Everest',
      licenseId: 'mf_everest',
      licenseLevel: 0,
      effect: 'Efecto',
      description: 'Descripción',
      mount: MountType.main,
      type: [WeaponType.rifle, WeaponType.melee],
    );

    final json = weaponDataToJson(weapon);
    final values = formValuesFromJson(buildWeaponFormSchema(), json);

    expect(values['type.choice'], 'B');
    expect(values['type.b'], [WeaponType.rifle, WeaponType.melee]);
    expect(values.containsKey('type.a'), isFalse);
  });
}
