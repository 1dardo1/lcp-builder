import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/infrastructure/lcp/domain_json_mapper.dart';
import 'package:lcp_builder/presentation/forms/eidolon_layer_form_schema.dart';
import 'package:lcp_builder/presentation/forms/form_values_from_json.dart';
import 'package:lcp_builder/presentation/forms/npc_class_form_schema.dart';

/// Prueba de aceptación del caso 6 del catálogo (variabilidad por tier de
/// NPC): `TierValue`/`NpcSize`/`EidolonShardCount` se serializan como
/// números o arrays sueltos, no como objetos con nombre de clave — el
/// hydrator reparte esos arrays por posición (`_hydratePositionalGroup`
/// en `form_values_from_json.dart`), no por clave.
void main() {
  INpcClassData classWith(INpcClassStats stats) => INpcClassData(
    id: 'npcc_test',
    name: 'Test',
    role: NpcRole.tank,
    info: const INpcClassInfo(flavor: 'f', tactics: 't', terse: 's'),
    stats: stats,
  );

  group('TierValue', () {
    test('single', () {
      final npcClass = classWith(
        INpcClassStats(
          armor: TierValue.single(2),
          hp: TierValue.single(10),
          evade: TierValue.single(10),
          edef: TierValue.single(10),
          heatcap: TierValue.single(5),
          speed: TierValue.single(4),
          sensor: TierValue.single(10),
          save: TierValue.single(10),
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
      );
      final values = formValuesFromJson(
        buildNpcClassFormSchema(),
        npcClassDataToJson(npcClass),
      );
      final stats = values['stats'] as Map<String, dynamic>;

      expect(stats['armor.choice'], 'single');
      expect(stats['armor.single'], 2);
      expect(stats.containsKey('armor.perTier'), isFalse);
    });

    test('perTier', () {
      final npcClass = classWith(
        INpcClassStats(
          armor: TierValue.perTier([2, 3, 4]),
          hp: TierValue.single(10),
          evade: TierValue.single(10),
          edef: TierValue.single(10),
          heatcap: TierValue.single(5),
          speed: TierValue.single(4),
          sensor: TierValue.single(10),
          save: TierValue.single(10),
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
      );
      final values = formValuesFromJson(
        buildNpcClassFormSchema(),
        npcClassDataToJson(npcClass),
      );
      final stats = values['stats'] as Map<String, dynamic>;

      expect(stats['armor.choice'], 'perTier');
      expect(stats['armor.perTier'], {'tier1': 2, 'tier2': 3, 'tier3': 4});
    });
  });

  test('NpcSize: reparte el array de 3 sub-arrays por posición sobre tier1/2/3', () {
    final npcClass = classWith(
      INpcClassStats(
        armor: TierValue.single(0),
        hp: TierValue.single(0),
        evade: TierValue.single(0),
        edef: TierValue.single(0),
        heatcap: TierValue.single(0),
        speed: TierValue.single(0),
        sensor: TierValue.single(0),
        save: TierValue.single(0),
        hull: TierValue.single(0),
        agility: TierValue.single(0),
        systems: TierValue.single(0),
        engineering: TierValue.single(0),
        size: NpcSize(const [
          [1],
          [1, 2],
          [2, 3],
        ]),
        activations: TierValue.single(1),
      ),
    );
    final values = formValuesFromJson(
      buildNpcClassFormSchema(),
      npcClassDataToJson(npcClass),
    );
    final stats = values['stats'] as Map<String, dynamic>;
    final size = stats['size'] as Map<String, dynamic>;

    expect(size['tier1'], [1]);
    expect(size['tier2'], [1, 2]);
    expect(size['tier3'], [2, 3]);
  });

  group('EidolonShardCount', () {
    IEidolonLayerData layerWith(EidolonShardCount count) => IEidolonLayerData(
      id: 'eid_test',
      name: 'Test',
      appearance: 'a',
      hints: 'h',
      rules: 'r',
      features: const [],
      shards: IEidolonShardData(count: count, detail: 'd', features: const []),
    );

    test('single', () {
      final layer = layerWith(const EidolonShardCount.single(2));
      final values = formValuesFromJson(
        buildEidolonLayerFormSchema(),
        eidolonLayerDataToJson(layer),
      );
      final shards = values['shards'] as Map<String, dynamic>;

      expect(shards['count.choice'], 'single');
      expect(shards['count.single'], 2);
    });

    test('perTier', () {
      final layer = layerWith(EidolonShardCount.perTier([1, 2, 3]));
      final values = formValuesFromJson(
        buildEidolonLayerFormSchema(),
        eidolonLayerDataToJson(layer),
      );
      final shards = values['shards'] as Map<String, dynamic>;

      expect(shards['count.choice'], 'perTier');
      expect(shards['count.perTier'], {'tier1': 1, 'tier2': 2, 'tier3': 3});
    });

    test('hostileCharacters', () {
      final layer = layerWith(const EidolonShardCount.hostileCharacters());
      final values = formValuesFromJson(
        buildEidolonLayerFormSchema(),
        eidolonLayerDataToJson(layer),
      );
      final shards = values['shards'] as Map<String, dynamic>;

      expect(shards['count.choice'], 'hostile');
      expect(shards.containsKey('count.single'), isFalse);
      expect(shards.containsKey('count.perTier'), isFalse);
    });
  });
}
