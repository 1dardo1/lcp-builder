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
        'type.a': WeaponType.rifle,
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
        'type.a': WeaponType.rifle,
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
        'type.a': WeaponType.rifle,
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
        'type.a': WeaponType.rifle,
      });

      expect(weapon.bonuses, isNull);
    });

    test('type: por defecto (rama "único") ensambla un WeaponType simple', () {
      final weapon = weaponFromFormValues(_baseValues());
      expect(weapon.type, WeaponType.rifle);
    });

    test('type: rama "varios" ensambla una List<WeaponType>', () {
      final weapon = weaponFromFormValues({
        ..._baseValues(),
        'type.choice': 'B',
        'type.b': [WeaponType.rifle, WeaponType.melee],
      });
      expect(weapon.type, [WeaponType.rifle, WeaponType.melee]);
    });

    test('onAttack: rama "texto" ensambla un TextOrActiveEffect.text', () {
      final weapon = weaponFromFormValues({
        ..._baseValues(),
        'onAttack.a': 'Zas.',
      });
      expect(weapon.onAttack!.text, 'Zas.');
      expect(weapon.onAttack!.effect, isNull);
    });

    test('onAttack: rama "active effect" ensambla un TextOrActiveEffect.effect '
        'anidado (GroupFieldSpec)', () {
      final weapon = weaponFromFormValues({
        ..._baseValues(),
        'onAttack.choice': 'B',
        'onAttack.b': {'name': 'Descarga', 'detail': 'detalle'},
      });
      expect(weapon.onAttack!.text, isNull);
      expect(weapon.onAttack!.effect!.name, 'Descarga');
      expect(weapon.onAttack!.effect!.detail, 'detalle');
    });

    test('addResist: catálogo cerrado de 3 vías (resist)', () {
      final weapon = weaponFromFormValues({
        ..._baseValues(),
        'activeEffects': [
          {
            'name': 'Blindaje',
            'detail': 'd',
            'addResist': [
              {
                'resistance.id': ResistanceKind.resist,
                'resistance.value': ResistanceValue.kinetic,
              },
            ],
          },
        ],
      });
      final effect = weapon.activeEffects!.single;
      final resist = effect.addResist!.single as ResistEffectData;
      expect(resist.resist, ResistanceValue.kinetic);
    });

    test('addOther: catálogo cerrado de 4 vías (cover)', () {
      final weapon = weaponFromFormValues({
        ..._baseValues(),
        'actions': [
          {
            'name': 'Cobertura',
            'activation': ActivationType.quick,
            'detail': 'd',
            'addOther': [
              {
                'otherEffect.id': OtherEffectKind.cover,
                'otherEffect.value': CoverLevel.hard,
              },
            ],
          },
        ],
      });
      final action = weapon.actions!.single;
      final other = action.addOther!.single as CoverEffectData;
      expect(other.val, CoverLevel.hard);
    });

    test('deployables: campos numéricos num|NumericOrFormulaValue', () {
      final weapon = weaponFromFormValues({
        ..._baseValues(),
        'deployables': [
          {
            'name': 'Drone',
            'detail': 'd',
            'hp.a': 5,
            'armor.choice': 'B',
            'armor.b': '{grit}',
          },
        ],
      });
      final deployable = weapon.deployables!.single;
      expect((deployable.hp as NumericOrFormulaValue).numberValue, 5);
      expect((deployable.armor as NumericOrFormulaValue).formula, '{grit}');
      expect(deployable.deployables, isNull);
    });

    test('profiles: reutiliza el mismo bundle de campos que el arma', () {
      final weapon = weaponFromFormValues({
        ..._baseValues(),
        'profiles': [
          {
            'name': 'Modo ráfaga',
            'effect.a': 'Dispara 3 veces.',
            'damage': [
              {'type': DamageType.kinetic, 'val': '1d6'},
            ],
          },
        ],
      });
      final profile = weapon.profiles!.single;
      expect(profile.name, 'Modo ráfaga');
      expect(profile.effect!.text, 'Dispara 3 veces.');
      expect(profile.damage!.single.type, DamageType.kinetic);
    });

    test('synergies: location preset y location action_X personalizada', () {
      final weapon = weaponFromFormValues({
        ..._baseValues(),
        'synergies': [
          {
            'locations': [
              {'value': 'weapon'},
              {'value': 'action_custom_id'},
            ],
            'detail': 'd',
          },
        ],
      });
      final synergy = weapon.synergies!.single;
      expect(synergy.locations, [
        SynergyLocation.weapon,
        SynergyLocation.actionX('custom_id'),
      ]);
    });
  });
}

Map<String, dynamic> _baseValues() => {
  'id': 'mw_test',
  'name': 'Test',
  'source': 'GMS',
  'license': 'GMS Everest',
  'licenseId': 'mf_everest',
  'licenseLevel': 0,
  'effect': 'e',
  'description': 'd',
  'mount': MountType.main,
  'type.a': WeaponType.rifle,
};
