import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/infrastructure/lcp/domain_json_mapper.dart';

void main() {
  group('damageDataToJson', () {
    test('usa la grafía real de la spec para el tipo (mayúscula inicial)', () {
      final json = damageDataToJson(
        IDamageData(type: DamageType.kinetic, val: DiceExpression.number(5)),
      );

      expect(json['type'], 'Kinetic');
      expect(json['val'], 5);
    });

    test('omite campos ausentes en vez de escribirlos como null', () {
      final json = damageDataToJson(
        IDamageData(type: DamageType.energy, val: DiceExpression.number(1)),
      );

      expect(json.containsKey('aoe'), isFalse);
      expect(json.containsKey('save'), isFalse);
    });
  });

  group('rangeDataToJson', () {
    test('usa la grafía real de la spec para el tipo', () {
      final json = rangeDataToJson(
        IRangeData(type: RangeType.range, val: DiceExpression.number(10)),
      );

      expect(json['type'], 'Range');
    });
  });

  group('bonusDataToJson', () {
    test('serializa id.jsonValue y el val según su valueKind', () {
      final json = bonusDataToJson(
        IBonusData(id: BonusId.accuracy, val: NumericOrFormulaValue.number(1)),
      );

      expect(json['id'], 'accuracy');
      expect(json['val'], 1);
    });
  });

  group('weaponDataToJson', () {
    test('mapea un arma mínima con la grafía snake_case de la spec', () {
      final weapon = IWeaponData(
        id: 'mw_test',
        name: 'Test Rifle',
        source: 'GMS',
        license: 'GMS Everest',
        licenseId: 'mf_everest',
        licenseLevel: 0,
        effect: 'efecto',
        description: 'descripcion',
        mount: MountType.main,
        type: WeaponType.rifle,
      );

      final json = weaponDataToJson(weapon);

      expect(json['license_id'], 'mf_everest');
      expect(json['license_level'], 0);
      expect(json['mount'], 'Main');
      expect(json['type'], 'Rifle');
      expect(json.containsKey('profiles'), isFalse);
    });

    test('type acepta tanto un único WeaponType como una lista', () {
      final weapon = IWeaponData(
        id: 'mw_test',
        name: 'Test',
        source: 'GMS',
        license: 'GMS Everest',
        licenseId: 'mf_everest',
        licenseLevel: 0,
        effect: 'e',
        description: 'd',
        mount: MountType.main,
        type: [WeaponType.rifle, WeaponType.cqb],
      );

      final json = weaponDataToJson(weapon);

      expect(json['type'], ['Rifle', 'CQB']);
    });
  });

  group('lcpManifestDataToJson', () {
    test('mapea los campos requeridos', () {
      final json = lcpManifestDataToJson(
        ILcpManifestData(
          name: 'Paquete',
          author: 'Autor',
          description: 'desc',
          version: '1.0.0',
        ),
      );

      expect(json['name'], 'Paquete');
      expect(json['version'], '1.0.0');
      expect(json.containsKey('dependencies'), isFalse);
    });
  });

  group('manufacturerDataToJson', () {
    test('mapea id/name y omite campos opcionales ausentes', () {
      final json = manufacturerDataToJson(
        const IManufacturerData(
          id: 'GMS',
          name: 'General Manufacturing Systems',
          description: 'd',
          quote: 'q',
          light: '#FFFFFF',
          dark: '#000000',
        ),
      );

      expect(json['id'], 'GMS');
      expect(json['light'], '#FFFFFF');
      expect(json.containsKey('icon_svg'), isFalse);
    });
  });

  group('tagDataToJson', () {
    test('mapea filter_ignore en snake_case', () {
      final json = tagDataToJson(
        const ITagData(
          id: 'tg_accurate',
          name: 'Accurate',
          description: 'd',
          filterIgnore: true,
        ),
      );

      expect(json['filter_ignore'], true);
      expect(json.containsKey('hidden'), isFalse);
    });
  });

  group('skillDataToJson', () {
    test('mapea family.jsonValue', () {
      final json = skillDataToJson(
        const ISkillData(
          id: 'sk_test',
          name: 'Test',
          description: 'd',
          detail: 'det',
          family: SkillFamily.intFamily,
        ),
      );

      expect(json['family'], 'int');
    });
  });

  group('statusConditionDataToJson', () {
    test('mapea type y exclusive por .name', () {
      final json = statusConditionDataToJson(
        const IStatusConditionData(
          id: 'st_shredded',
          name: 'Shredded',
          type: StatusConditionType.status,
          effects: 'e',
          exclusive: ExclusiveTarget.mech,
        ),
      );

      expect(json['type'], 'status');
      expect(json['exclusive'], 'mech');
    });
  });

  group('sitrepDataToJson', () {
    test('mapea conditions como lista de title/condition', () {
      final json = sitrepDataToJson(
        const ISitrepData(
          id: 'sitrep_test',
          name: 'Test',
          description: 'd',
          conditions: [ISitrepCondition(title: 't', condition: 'c')],
        ),
      );

      expect(json['conditions'], [
        {'title': 't', 'condition': 'c'},
      ]);
    });
  });

  group('environmentDataToJson', () {
    test('mapea los 3 campos', () {
      final json = environmentDataToJson(
        const IEnvironmentData(id: 'env_test', name: 'Test', description: 'd'),
      );

      expect(json, {'id': 'env_test', 'name': 'Test', 'description': 'd'});
    });
  });

  group('backgroundDataToJson', () {
    test('mapea skills como lista de strings, sin transformar', () {
      final json = backgroundDataToJson(
        const IBackgroundData(
          id: 'bg_test',
          name: 'Test',
          description: 'd',
          skills: ['sk_a', 'sk_b'],
        ),
      );

      expect(json['skills'], ['sk_a', 'sk_b']);
    });
  });

  group('bondDataToJson', () {
    test('mapea major_ideals/minor_ideals y questions/powers anidados', () {
      final json = bondDataToJson(
        const IBondData(
          id: 'bond_test',
          name: 'Test',
          majorIdeals: ['Honor'],
          minorIdeals: ['Cunning'],
          questions: [
            IQuestionData(question: '¿Por qué?', options: ['a', 'b']),
          ],
          powers: [IBondPowerData(name: 'Power', description: 'd')],
        ),
      );

      expect(json['major_ideals'], ['Honor']);
      expect(json['questions'], [
        {
          'question': '¿Por qué?',
          'options': ['a', 'b'],
        },
      ]);
      expect(json['powers'], [
        {'name': 'Power', 'description': 'd'},
      ]);
    });
  });

  group('reserveDataToJson', () {
    test('mapea type.name y el paquete de actions/bonuses/etc.', () {
      final json = reserveDataToJson(
        IReserveData(
          id: 'reserve_test',
          name: 'Test',
          type: ReserveType.tactical,
          consumable: true,
          bonuses: [
            IBonusData(
              id: BonusId.accuracy,
              val: NumericOrFormulaValue.number(1),
            ),
          ],
        ),
      );

      expect(json['type'], 'tactical');
      expect(json['consumable'], true);
      expect((json['bonuses'] as List).first['id'], 'accuracy');
      expect(json.containsKey('label'), isFalse);
    });
  });

  group('coreBonusDataToJson', () {
    test('mapea mounted_effect en snake_case', () {
      final json = coreBonusDataToJson(
        const ICoreBonusData(
          id: 'cb_test',
          name: 'Test',
          source: 'GMS',
          effect: 'e',
          description: 'd',
          mountedEffect: 'me',
        ),
      );

      expect(json['mounted_effect'], 'me');
      expect(json['source'], 'GMS');
    });
  });

  group('talentDataToJson', () {
    test('mapea ranks anidados con su propio paquete', () {
      final json = talentDataToJson(
        ITalentData(
          id: 'tal_test',
          name: 'Test',
          description: 'd',
          ranks: [
            IRankData(
              name: 'Rank 1',
              description: 'd',
              exclusive: true,
              bonuses: [
                IBonusData(
                  id: BonusId.accuracy,
                  val: NumericOrFormulaValue.number(1),
                ),
              ],
            ),
          ],
        ),
      );

      final ranks = json['ranks'] as List;
      expect(ranks, hasLength(1));
      expect(ranks.first['name'], 'Rank 1');
      expect(ranks.first['exclusive'], true);
      expect((ranks.first['bonuses'] as List).first['id'], 'accuracy');
    });
  });
}
