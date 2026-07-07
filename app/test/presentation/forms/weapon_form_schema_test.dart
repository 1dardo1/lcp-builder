import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/presentation/forms/weapon_form_schema.dart';

void main() {
  group('weaponFromFormValues', () {
    test('ensambla los campos simples y una lista de daño', () {
      final weapon = weaponFromFormValues({
        'id': 'mw_test',
        'name': 'Test',
        'source': 'GMS',
        'license': 'GMS Everest',
        'licenseId': 'mf_everest',
        'licenseLevel': 0,
        'effect': 'e',
        'description': 'd',
        'mount': MountType.main,
        'type': WeaponType.rifle,
        'damage': [
          {'type': DamageType.kinetic, 'val': '2d6'},
        ],
      });

      expect(weapon.id, 'mw_test');
      expect(weapon.mount, MountType.main);
      expect(weapon.damage, hasLength(1));
      expect(weapon.damage!.first.type, DamageType.kinetic);
      expect(weapon.damage!.first.val.formula, '2d6');
    });

    test('ensambla una lista con un único bonus numérico (rama "número")', () {
      final weapon = weaponFromFormValues({
        'id': 'mw_test',
        'name': 'Test',
        'source': 'GMS',
        'license': 'GMS Everest',
        'licenseId': 'mf_everest',
        'licenseLevel': 0,
        'effect': 'e',
        'description': 'd',
        'mount': MountType.main,
        'type': WeaponType.rifle,
        'bonuses': [
          {
            'bonus.id': BonusId.accuracy,
            'bonus.value.choice': 'A',
            'bonus.value.a': 1,
          },
        ],
      });

      expect(weapon.bonuses, hasLength(1));
      expect(weapon.bonuses!.first.id, BonusId.accuracy);
      expect(
        (weapon.bonuses!.first.val as NumericOrFormulaValue).numberValue,
        1,
      );
    });

    test('ensambla varios bonuses (catálogo anidado dentro de una lista)', () {
      final weapon = weaponFromFormValues({
        'id': 'mw_test',
        'name': 'Test',
        'source': 'GMS',
        'license': 'GMS Everest',
        'licenseId': 'mf_everest',
        'licenseLevel': 0,
        'effect': 'e',
        'description': 'd',
        'mount': MountType.main,
        'type': WeaponType.rifle,
        'bonuses': [
          {
            'bonus.id': BonusId.accuracy,
            'bonus.value.choice': 'A',
            'bonus.value.a': 1,
          },
          {'bonus.id': BonusId.cheapStruct, 'bonus.value': true},
        ],
      });

      expect(weapon.bonuses, hasLength(2));
      expect(weapon.bonuses![0].id, BonusId.accuracy);
      expect(weapon.bonuses![1].id, BonusId.cheapStruct);
      expect(weapon.bonuses![1].val, true);
    });

    test('sin bonuses, el campo queda null', () {
      final weapon = weaponFromFormValues({
        'id': 'mw_test',
        'name': 'Test',
        'source': 'GMS',
        'license': 'GMS Everest',
        'licenseId': 'mf_everest',
        'licenseLevel': 0,
        'effect': 'e',
        'description': 'd',
        'mount': MountType.main,
        'type': WeaponType.rifle,
      });

      expect(weapon.bonuses, isNull);
    });
  });
}
