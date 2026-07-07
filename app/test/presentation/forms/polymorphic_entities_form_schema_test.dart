import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/presentation/forms/eidolon_layer_form_schema.dart';
import 'package:lcp_builder/presentation/forms/frame_form_schema.dart';
import 'package:lcp_builder/presentation/forms/mech_system_form_schema.dart';
import 'package:lcp_builder/presentation/forms/npc_class_form_schema.dart';
import 'package:lcp_builder/presentation/forms/npc_feature_form_schema.dart';
import 'package:lcp_builder/presentation/forms/npc_template_form_schema.dart';
import 'package:lcp_builder/presentation/forms/pilot_gear_form_schema.dart';
import 'package:lcp_builder/presentation/forms/weapon_mod_form_schema.dart';

/// Ensambladores de las 8 entidades con casos polimórficos propios que
/// cierran "Crear": caso 1/2 (unión discriminada, `PilotGear`/`NpcFeature`)
/// y caso 6 (variabilidad por tier, `NpcClass`/`NpcFeature`/`EidolonLayer`)
/// resueltos sin `FieldSpec` nuevo — la prueba real de que la composición
/// `ShapeChoiceFieldSpec` (generalizado a N ramas) + `GroupFieldSpec`
/// decidida en el vault funciona igual de bien para ambos casos.
void main() {
  group('mechSystemFromFormValues', () {
    test('ensambla campos base y el paquete de bonuses/synergies', () {
      final system = mechSystemFromFormValues({
        'id': 'ms_test',
        'name': 'Test',
        'licenseLevel': 1,
        'type': SystemType.shield,
        'noBonus': true,
      });

      expect(system.type, SystemType.shield);
      expect(system.noBonus, isTrue);
    });
  });

  group('weaponModFromFormValues', () {
    test('ensambla los campos heredados de MechSystem y los propios', () {
      final mod = weaponModFromFormValues({
        'id': 'wm_test',
        'name': 'Test',
        'licenseLevel': 0,
        'allowedTypes': [WeaponType.rifle],
        'onAttack': {'name': 'On attack', 'detail': 'd'},
      });

      expect(mod.allowedTypes, [WeaponType.rifle]);
      expect(mod.onAttack?.name, 'On attack');
    });
  });

  group('pilotGearFromFormValues', () {
    test('kind=weapon ensambla IPilotWeaponData', () {
      final gear = pilotGearFromFormValues({
        'id': 'pg_test',
        'name': 'Test',
        'kind.choice': 'weapon',
        'kind.weapon': {
          'description': 'd',
          'damage': [
            {'type': DamageType.kinetic, 'val': '2'},
          ],
        },
      });

      expect(gear, isA<IPilotWeaponData>());
      expect((gear as IPilotWeaponData).damage, hasLength(1));
    });

    test('kind=armor ensambla IPilotArmorData', () {
      final gear = pilotGearFromFormValues({
        'id': 'pg_test_armor',
        'name': 'Test',
        'kind.choice': 'armor',
        'kind.armor': {'description': 'd'},
      });

      expect(gear, isA<IPilotArmorData>());
    });

    test('sin elección explícita, por defecto ensambla IPilotWeaponData', () {
      final gear = pilotGearFromFormValues({'id': 'pg_test2', 'name': 'Test'});

      expect(gear, isA<IPilotWeaponData>());
    });
  });

  group('frameFromFormValues', () {
    test('ensambla stats/coreSystem anidados y mounts', () {
      final frame = frameFromFormValues({
        'id': 'mf_test',
        'name': 'Test',
        'source': 'TEST_MFR',
        'licenseLevel': 2,
        'description': 'd',
        'mounts': [
          {'value': MountType.main},
        ],
        'stats': {
          'size': 1,
          'structure': 4,
          'stress': 4,
          'armor': 0,
          'hp': 8,
          'evasion': 8,
          'edef': 8,
          'heatcap': 5,
          'repcap': 5,
          'sensorRange': 10,
          'techAttack': 0,
          'save': 10,
          'speed': 5,
          'sp': 5,
        },
        'coreSystem': {
          'name': 'Core',
          'activeName': 'Active',
          'activeEffect': 'e',
          'activation': ActivationType.quick,
        },
        'specialty.choice': 'bool',
        'specialty.bool': true,
      });

      expect(frame.mounts, [MountType.main]);
      expect(frame.stats.sensorRange, 10);
      expect(frame.coreSystem.activeName, 'Active');
      expect(frame.specialty, true);
    });

    test(
      'specialty como IPrerequisite se ensambla desde el grupo estructurado',
      () {
        final frame = frameFromFormValues({
          'id': 'mf_test2',
          'name': 'Test',
          'source': 'TEST_MFR',
          'licenseLevel': 0,
          'description': 'd',
          'mounts': <Map<String, dynamic>>[],
          'stats': <String, dynamic>{},
          'coreSystem': {
            'name': 'Core',
            'activeName': 'Active',
            'activeEffect': 'e',
            'activation': ActivationType.quick,
          },
          'specialty.choice': 'prerequisite',
          'specialty.prerequisite': {'source': 'TEST_MFR', 'minRank': 2},
        });

        expect(frame.specialty, isA<IPrerequisite>());
        expect((frame.specialty as IPrerequisite).minRank, 2);
      },
    );
  });

  group('npcFeatureFromFormValues', () {
    test('kind=trait ensambla INpcTraitFeatureData', () {
      final feature = npcFeatureFromFormValues({
        'id': 'nf_test',
        'name': 'Test',
      });

      expect(feature, isA<INpcTraitFeatureData>());
    });

    test('kind=tech ensambla TierValue.perTier para attackBonus (caso 6)', () {
      final feature = npcFeatureFromFormValues({
        'id': 'nf_test_tech',
        'name': 'Test',
        'kind.choice': 'tech',
        'kind.tech': {
          'attackBonus.choice': 'perTier',
          'attackBonus.perTier': {'tier1': 1, 'tier2': 2, 'tier3': 3},
        },
      });

      expect(feature, isA<INpcTechFeatureData>());
      final tech = feature as INpcTechFeatureData;
      expect(tech.attackBonus?.perTier, [1, 2, 3]);
    });

    test('kind=weapon ensambla damage/range/attacks', () {
      final feature = npcFeatureFromFormValues({
        'id': 'nf_test_weapon',
        'name': 'Test',
        'kind.choice': 'weapon',
        'kind.weapon': {
          'weaponType': 'Main Rifle',
          'damage': [
            {
              'type': DamageType.kinetic,
              'damage': {'tier1': 2, 'tier2': 3, 'tier3': 4},
            },
          ],
          'attacks.choice': 'single',
          'attacks.single': 1,
        },
      });

      expect(feature, isA<INpcWeaponFeatureData>());
      final weapon = feature as INpcWeaponFeatureData;
      expect(weapon.weaponType, 'Main Rifle');
      expect(weapon.damage.first.damage, [2, 3, 4]);
      expect(weapon.attacks.single, 1);
    });
  });

  group('npcClassFromFormValues', () {
    test('ensambla info/stats con TierValue y NpcSize (caso 6)', () {
      final npcClass = npcClassFromFormValues({
        'id': 'npcc_test',
        'name': 'Test',
        'role': NpcRole.striker,
        'info': {'flavor': 'f', 'tactics': 't', 'terse': 'te'},
        'stats': {
          'armor.choice': 'single',
          'armor.single': 0,
          'hp.choice': 'perTier',
          'hp.perTier': {'tier1': 5, 'tier2': 10, 'tier3': 15},
          'size': {
            'tier1': [1],
            'tier2': [1],
            'tier3': [1, 2],
          },
        },
      });

      expect(npcClass.role, NpcRole.striker);
      expect(npcClass.info.flavor, 'f');
      expect(npcClass.stats.hp.perTier, [5, 10, 15]);
      expect(npcClass.stats.size.perTier[2], [1, 2]);
    });
  });

  group('npcTemplateFromFormValues', () {
    test('ensambla campos planos y prohibitTemplates como lista de IDs', () {
      final template = npcTemplateFromFormValues({
        'id': 'npct_test',
        'name': 'Test',
        'description': 'd',
        'forceTag': NpcForceTag.vehicle,
        'prohibitTemplates': [
          {'id': 'npct_other'},
        ],
      });

      expect(template.forceTag, NpcForceTag.vehicle);
      expect(template.prohibitTemplates, ['npct_other']);
    });
  });

  group('eidolonLayerFromFormValues', () {
    test('ensambla shards con count (caso 6, 3 ramas) y features anidadas', () {
      final layer = eidolonLayerFromFormValues({
        'id': 'el_test',
        'name': 'Test',
        'appearance': 'a',
        'hints': 'h',
        'rules': 'r',
        'shards': {
          'count.choice': 'hostile',
          'detail': 'd',
          'features': [
            {'id': 'nf_shard', 'name': 'Shard feature'},
          ],
        },
      });

      expect(layer.shards?.count.hostileCharacters, isTrue);
      expect(layer.shards?.features, hasLength(1));
      expect(layer.shards?.features.first, isA<INpcTraitFeatureData>());
    });
  });
}
