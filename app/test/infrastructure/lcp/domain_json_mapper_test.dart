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

  group('lcpManifestDataFromJson', () {
    test('lee los campos requeridos y deja los opcionales en null si no '
        'están', () {
      final manifest = lcpManifestDataFromJson({
        'name': 'Paquete',
        'author': 'Autor',
        'description': 'desc',
        'version': '1.0.0',
      });

      expect(manifest.name, 'Paquete');
      expect(manifest.version, '1.0.0');
      expect(manifest.dependencies, isNull);
      expect(manifest.versionHistory, isNull);
    });

    test('roundtrip: toJson -> fromJson conserva todos los campos, '
        'incluidos dependencies/version_history anidados', () {
      final original = ILcpManifestData(
        name: 'Paquete',
        author: 'Autor',
        description: 'desc',
        version: '1.0.0',
        imageUrl: 'https://example.com/img.png',
        website: 'https://example.com',
        v3: true,
        dependencies: [
          ILcpDependency(name: 'otro-paquete', version: SemverConstraint('1.2.3')),
        ],
        versionHistory: const [
          IChangelogItem(version: '1.0.0', date: '2026-01-01', changes: ['Primera versión']),
        ],
      );

      final roundtripped = lcpManifestDataFromJson(lcpManifestDataToJson(original));

      expect(roundtripped.name, original.name);
      expect(roundtripped.imageUrl, original.imageUrl);
      expect(roundtripped.v3, isTrue);
      expect(roundtripped.dependencies, hasLength(1));
      expect(roundtripped.dependencies!.first.name, 'otro-paquete');
      expect(roundtripped.dependencies!.first.version.value, '1.2.3');
      expect(roundtripped.versionHistory, hasLength(1));
      expect(roundtripped.versionHistory!.first.changes, ['Primera versión']);
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
      expect(json.containsKey('svg'), isFalse);
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

  group('tierValueToJson / npcSizeToJson / eidolonShardCountToJson', () {
    test('TierValue.single se serializa como el número suelto', () {
      expect(tierValueToJson(TierValue.single(4)), 4);
    });

    test('TierValue.perTier se serializa como array de 3', () {
      expect(tierValueToJson(TierValue.perTier([1, 2, 3])), [1, 2, 3]);
    });

    test('NpcSize se serializa como array de 3 sub-arrays', () {
      expect(
        npcSizeToJson(
          NpcSize(const [
            [1],
            [2],
            [0.5, 1],
          ]),
        ),
        [
          [1],
          [2],
          [0.5, 1],
        ],
      );
    });

    test(
      'EidolonShardCount.hostileCharacters se serializa como el string literal',
      () {
        expect(
          eidolonShardCountToJson(const EidolonShardCount.hostileCharacters()),
          'hostile_characters',
        );
      },
    );
  });

  group('mechSystemDataToJson', () {
    test(
      'mapea license_id/no_bonus en snake_case y omite opcionales ausentes',
      () {
        final json = mechSystemDataToJson(
          IMechSystemData(
            id: 'ms_test',
            name: 'Test',
            source: 'TEST_MFR',
            license: 'TEST License',
            licenseId: 'mf_test',
            licenseLevel: 2,
            type: SystemType.tech,
            noBonus: true,
          ),
        );

        expect(json['license_id'], 'mf_test');
        expect(json['license_level'], 2);
        expect(json['type'], 'Tech');
        expect(json['no_bonus'], true);
        expect(json.containsKey('sp'), isFalse);
      },
    );
  });

  group('weaponModDataToJson', () {
    test('incluye los campos heredados de MechSystem y los propios de mod', () {
      final json = weaponModDataToJson(
        IWeaponModData(
          id: 'wm_test',
          name: 'Test',
          licenseLevel: 1,
          allowedTypes: const [WeaponType.rifle],
          onAttack: const IActiveEffectData(name: 'On attack', detail: 'd'),
        ),
      );

      expect(json['id'], 'wm_test');
      expect(json['allowed_types'], ['Rifle']);
      expect((json['on_attack'] as Map)['name'], 'On attack');
      expect(json.containsKey('added_damage'), isFalse);
    });
  });

  group('pilotGearDataToJson', () {
    test('IPilotWeaponData mapea type: Weapon (case-sensitive)', () {
      final json = pilotGearDataToJson(
        const IPilotWeaponData(id: 'pg_test', name: 'Test'),
      );

      expect(json['type'], 'Weapon');
    });

    test('IPilotArmorData mapea type: Armor y omite campos de weapon', () {
      final json = pilotGearDataToJson(
        const IPilotArmorData(id: 'pg_test_armor', name: 'Test'),
      );

      expect(json['type'], 'Armor');
      expect(json.containsKey('damage'), isFalse);
    });

    test('IPilotGearItemData mapea type: Gear', () {
      final json = pilotGearDataToJson(
        const IPilotGearItemData(id: 'pg_test_gear', name: 'Test'),
      );

      expect(json['type'], 'Gear');
    });
  });

  group('frameDataToJson', () {
    test('mapea stats/core_system anidados y specialty como bool', () {
      final json = frameDataToJson(
        IFrameData(
          id: 'mf_test',
          name: 'Test',
          source: 'TEST_MFR',
          licenseLevel: 2,
          mechtype: const ['Striker'],
          description: 'd',
          mounts: const [MountType.main],
          stats: const IFrameStats(
            size: 1,
            structure: 4,
            stress: 4,
            armor: 0,
            hp: 8,
            evasion: 8,
            edef: 8,
            heatcap: 5,
            repcap: 5,
            sensorRange: 10,
            techAttack: 0,
            save: 10,
            speed: 5,
            sp: 5,
          ),
          traits: const [],
          coreSystem: const ICoreSystemData(
            name: 'Core',
            activeName: 'Active',
            activeEffect: 'e',
            activation: ActivationType.quick,
          ),
          specialty: true,
        ),
      );

      expect(json['license_level'], 2);
      expect((json['stats'] as Map)['sensor_range'], 10);
      expect((json['core_system'] as Map)['active_name'], 'Active');
      expect(json['specialty'], true);
    });

    test('specialty como IPrerequisite mapea min_rank en snake_case', () {
      final json = frameDataToJson(
        IFrameData(
          id: 'mf_test2',
          name: 'Test',
          source: 'TEST_MFR',
          licenseLevel: 0,
          mechtype: const ['Striker'],
          description: 'd',
          mounts: const [MountType.main],
          stats: const IFrameStats(
            size: 1,
            structure: 4,
            stress: 4,
            armor: 0,
            hp: 8,
            evasion: 8,
            edef: 8,
            heatcap: 5,
            repcap: 5,
            sensorRange: 10,
            techAttack: 0,
            save: 10,
            speed: 5,
            sp: 5,
          ),
          traits: const [],
          coreSystem: const ICoreSystemData(
            name: 'Core',
            activeName: 'Active',
            activeEffect: 'e',
            activation: ActivationType.quick,
          ),
          specialty: const IPrerequisite(source: 'TEST_MFR', minRank: 2),
        ),
      );

      expect((json['specialty'] as Map)['min_rank'], 2);
    });
  });

  group('npcFeatureDataToJson', () {
    test('INpcTraitFeatureData mapea type: trait', () {
      final json = npcFeatureDataToJson(
        const INpcTraitFeatureData(id: 'nf_test', name: 'Test'),
      );

      expect(json['type'], 'trait');
    });

    test('INpcTechFeatureData mapea attack_bonus/accuracy como TierValue', () {
      final json = npcFeatureDataToJson(
        INpcTechFeatureData(
          id: 'nf_test_tech',
          name: 'Test',
          attackBonus: TierValue.perTier([1, 2, 3]),
        ),
      );

      expect(json['type'], 'tech');
      expect(json['attack_bonus'], [1, 2, 3]);
    });

    test(
      'INpcWeaponFeatureData mapea weapon_type y damage restringido a 3 enteros',
      () {
        final json = npcFeatureDataToJson(
          INpcWeaponFeatureData(
            id: 'nf_test_weapon',
            name: 'Test',
            weaponType: 'Main Rifle',
            damage: [
              INpcDamageData(type: DamageType.kinetic, damage: const [2, 3, 4]),
            ],
            range: const [],
            attacks: TierValue.single(1),
          ),
        );

        expect(json['type'], 'weapon');
        expect(json['weapon_type'], 'Main Rifle');
        expect((json['damage'] as List).first['damage'], [2, 3, 4]);
        expect(json['attacks'], 1);
      },
    );
  });

  group('npcClassDataToJson', () {
    test('mapea info/stats anidados, con TierValue y NpcSize', () {
      final json = npcClassDataToJson(
        INpcClassData(
          id: 'npcc_test',
          name: 'Test',
          role: NpcRole.striker,
          info: const INpcClassInfo(flavor: 'f', tactics: 't', terse: 'te'),
          stats: INpcClassStats(
            armor: TierValue.single(0),
            hp: TierValue.perTier([5, 10, 15]),
            evade: TierValue.single(5),
            edef: TierValue.single(5),
            heatcap: TierValue.single(5),
            speed: TierValue.single(5),
            sensor: TierValue.single(5),
            save: TierValue.single(5),
            hull: TierValue.single(0),
            agility: TierValue.single(0),
            systems: TierValue.single(0),
            engineering: TierValue.single(0),
            size: NpcSize(const [
              [1],
              [1],
              [1],
            ]),
            activations: TierValue.single(1),
          ),
        ),
      );

      expect(json['role'], 'striker');
      expect((json['info'] as Map)['flavor'], 'f');
      expect((json['stats'] as Map)['hp'], [5, 10, 15]);
      expect((json['stats'] as Map)['size'], [
        [1],
        [1],
        [1],
      ]);
    });
  });

  group('npcTemplateDataToJson', () {
    test('mapea forceTag.jsonValue y template literal true', () {
      final json = npcTemplateDataToJson(
        const INpcTemplateData(
          id: 'npct_test',
          name: 'Test',
          description: 'd',
          forceTag: NpcForceTag.vehicle,
        ),
      );

      expect(json['template'], true);
      expect(json['forceTag'], 'Vehicle');
    });
  });

  group('eidolonLayerDataToJson', () {
    test('mapea shards con count/features anidados', () {
      final json = eidolonLayerDataToJson(
        IEidolonLayerData(
          id: 'el_test',
          name: 'Test',
          appearance: 'a',
          hints: 'h',
          rules: 'r {1/2/3}',
          shards: IEidolonShardData(
            count: const EidolonShardCount.hostileCharacters(),
            detail: 'd',
            features: const [
              INpcTraitFeatureData(id: 'nf_shard', name: 'Shard feature'),
            ],
          ),
        ),
      );

      final shards = json['shards'] as Map;
      expect(shards['count'], 'hostile_characters');
      expect((shards['features'] as List).first['type'], 'trait');
    });
  });
}
