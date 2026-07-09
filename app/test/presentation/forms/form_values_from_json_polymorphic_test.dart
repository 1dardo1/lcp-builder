import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/infrastructure/lcp/domain_json_mapper.dart';
import 'package:lcp_builder/presentation/forms/common_entity_fields.dart';
import 'package:lcp_builder/presentation/forms/frame_form_schema.dart';
import 'package:lcp_builder/presentation/forms/form_values_from_json.dart';
import 'package:lcp_builder/presentation/forms/npc_feature_form_schema.dart';
import 'package:lcp_builder/presentation/forms/pilot_gear_form_schema.dart';

/// Prueba de aceptación de la auditoría de `branchFromJson`/`idFromJson`
/// en los campos polimórficos "difíciles" (más allá de `weapon.type` y
/// `otherEffect`, ya cubiertos en otro test): `aoe`, `save`, `resistance`
/// (con su propia rama anidada `immunity`) y `specialty`.
void main() {
  group('aoe (StringOrBool)', () {
    test('texto', () {
      final damage = IDamageData(
        type: DamageType.kinetic,
        val: DiceExpression.formula('1d6'),
        aoe: StringOrBool.text('3-cone'),
      );
      final values = formValuesFromJson(damageItemFields(), damageDataToJson(damage));

      expect(values['aoe.choice'], 'A');
      expect(values['aoe.a'], '3-cone');
    });

    test('bool', () {
      final damage = IDamageData(
        type: DamageType.kinetic,
        val: DiceExpression.formula('1d6'),
        aoe: StringOrBool.flag(true),
      );
      final values = formValuesFromJson(damageItemFields(), damageDataToJson(damage));

      expect(values['aoe.choice'], 'B');
      expect(values['aoe.b'], true);
    });
  });

  group('save (string | IDamageSaveData)', () {
    test('texto libre', () {
      final damage = IDamageData(
        type: DamageType.kinetic,
        val: DiceExpression.formula('1d6'),
        save: 'HULL save',
      );
      final values = formValuesFromJson(damageItemFields(), damageDataToJson(damage));

      expect(values['save.choice'], 'A');
      expect(values['save.a'], 'HULL save');
    });

    test('estructurado', () {
      final damage = IDamageData(
        type: DamageType.kinetic,
        val: DiceExpression.formula('1d6'),
        save: IDamageSaveData(stat: 'hull', aoe: true),
      );
      final values = formValuesFromJson(damageItemFields(), damageDataToJson(damage));

      expect(values['save.choice'], 'B');
      expect(values['save.b'], {'stat': 'hull', 'aoe': true});
    });
  });

  group('resistance (CatalogFieldSpec<ResistanceKind>)', () {
    test('resist', () {
      const effect = ResistEffectData(resist: ResistanceValue.kinetic);
      final values = formValuesFromJson(
        resistanceItemFields(),
        resistanceDataToJson(effect),
      );

      expect(values['resistance.id'], ResistanceKind.resist);
      expect(values['resistance.value'], ResistanceValue.kinetic);
    });

    test('vulnerability', () {
      const effect = VulnerabilityEffectData(vulnerability: ResistanceValue.heat);
      final values = formValuesFromJson(
        resistanceItemFields(),
        resistanceDataToJson(effect),
      );

      expect(values['resistance.id'], ResistanceKind.vulnerability);
      expect(values['resistance.value'], ResistanceValue.heat);
    });

    test('immunity con valor conocido', () {
      const effect = ImmunityEffectData(
        immunity: ImmunityValue.known(ResistanceValue.burn),
      );
      final values = formValuesFromJson(
        resistanceItemFields(),
        resistanceDataToJson(effect),
      );

      expect(values['resistance.id'], ResistanceKind.immunity);
      expect(values['resistance.value.choice'], 'A');
      expect(values['resistance.value.a'], ResistanceValue.burn);
    });

    test('immunity con id de status/condition', () {
      const effect = ImmunityEffectData(
        immunity: ImmunityValue.conditionId('stunned'),
      );
      final values = formValuesFromJson(
        resistanceItemFields(),
        resistanceDataToJson(effect),
      );

      expect(values['resistance.id'], ResistanceKind.immunity);
      expect(values['resistance.value.choice'], 'B');
      expect(values['resistance.value.b'], 'stunned');
    });
  });

  group('specialty (bool | IPrerequisite)', () {
    const frameBase = (
      id: 'fr_test',
      name: 'Test',
      source: 'GMS',
      description: 'd',
      stats: IFrameStats(
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
      coreSystem: ICoreSystemData(
        name: 'Core',
        activeName: 'Active',
        activeEffect: 'Effect',
        activation: ActivationType.quick,
      ),
    );

    test('bool', () {
      final frame = IFrameData(
        id: frameBase.id,
        name: frameBase.name,
        source: frameBase.source,
        licenseId: null,
        licenseLevel: 2,
        description: frameBase.description,
        mechtype: const [],
        mounts: const [],
        traits: const [],
        stats: frameBase.stats,
        coreSystem: frameBase.coreSystem,
        specialty: true,
      );
      final values = formValuesFromJson(buildFrameFormSchema(), frameDataToJson(frame));

      expect(values['specialty.choice'], 'bool');
      expect(values['specialty.bool'], true);
    });

    test('IPrerequisite', () {
      final frame = IFrameData(
        id: frameBase.id,
        name: frameBase.name,
        source: frameBase.source,
        licenseId: null,
        licenseLevel: 2,
        description: frameBase.description,
        mechtype: const [],
        mounts: const [],
        traits: const [],
        stats: frameBase.stats,
        coreSystem: frameBase.coreSystem,
        specialty: const IPrerequisite(source: 'GMS', minRank: 1, cumulative: true),
      );
      final values = formValuesFromJson(buildFrameFormSchema(), frameDataToJson(frame));

      expect(values['specialty.choice'], 'prerequisite');
      expect(values['specialty.prerequisite'], {
        'source': 'GMS',
        'minRank': 1,
        'cumulative': true,
      });
    });
  });

  group('bonus (CatalogFieldSpec<BonusId>, catálogo grande con id real)', () {
    test('numericOrFormula', () {
      final bonus = IBonusData(
        id: BonusId.accuracy,
        val: const NumericOrFormulaValue.number(2),
      );
      final values = formValuesFromJson(bonusItemFields(), bonusDataToJson(bonus));

      expect(values['bonus.id'], BonusId.accuracy);
      expect(values['bonus.value.choice'], 'A');
      expect(values['bonus.value.a'], 2);
    });

    test('boolean', () {
      final bonus = IBonusData(id: BonusId.cheapStruct, val: true);
      final values = formValuesFromJson(bonusItemFields(), bonusDataToJson(bonus));

      expect(values['bonus.id'], BonusId.cheapStruct);
      expect(values['bonus.value'], true);
    });

    test('dieRollList (sin resolver a propósito, no rompe)', () {
      final bonus = IBonusData(
        id: BonusId.overcharge,
        val: [DieRoll('1d6'), DieRoll('1d6+1d8')],
      );
      final values = formValuesFromJson(bonusItemFields(), bonusDataToJson(bonus));

      expect(values['bonus.id'], BonusId.overcharge);
      expect(values.containsKey('bonus.value'), isFalse);
    });
  });

  group('kind → type (GroupFieldSpec.inline: campos hermanos, no anidados)', () {
    test('IPilotWeaponData', () {
      const gear = IPilotWeaponData(
        id: 'pg_rifle',
        name: 'Sidearm',
        effect: 'Efecto',
      );
      final values = formValuesFromJson(
        buildPilotGearFormSchema(),
        pilotGearDataToJson(gear),
      );

      expect(values['kind.choice'], 'weapon');
      expect(values['kind.weapon'], isA<Map<String, dynamic>>());
      expect((values['kind.weapon'] as Map)['effect'], 'Efecto');
      expect(values.containsKey('kind.armor'), isFalse);
    });

    test('IPilotArmorData', () {
      const gear = IPilotArmorData(id: 'pg_armor', name: 'Vest', description: 'd');
      final values = formValuesFromJson(
        buildPilotGearFormSchema(),
        pilotGearDataToJson(gear),
      );

      expect(values['kind.choice'], 'armor');
      expect((values['kind.armor'] as Map)['description'], 'd');
    });

    test('INpcReactionFeatureData', () {
      const feature = INpcReactionFeatureData(
        id: 'nf_react',
        name: 'React',
        trigger: 'Al fallar un ataque',
      );
      final values = formValuesFromJson(
        buildNpcFeatureFormSchema(),
        npcFeatureDataToJson(feature),
      );

      expect(values['kind.choice'], 'reaction');
      expect((values['kind.reaction'] as Map)['trigger'], 'Al fallar un ataque');
    });

    test('INpcTraitFeatureData (rama sin sub-campo)', () {
      const feature = INpcTraitFeatureData(id: 'nf_trait', name: 'Trait');
      final values = formValuesFromJson(
        buildNpcFeatureFormSchema(),
        npcFeatureDataToJson(feature),
      );

      expect(values['kind.choice'], 'trait');
      expect(values.containsKey('kind.reaction'), isFalse);
    });
  });
}
