import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/domain/domain.dart';

/// Tests directos de las invariantes y la lógica de los value objects del
/// dominio — la pieza prioritaria del proyecto, que hasta ahora solo se
/// ejercitaba de forma indirecta (esquemas de formulario + roundtrips).
///
/// Cubre lo que tiene lógica real: validación por `assert`/regex
/// (rechazar input inválido), factories que construyen el `value` correcto,
/// constructores posicionales con invariante de longitud, y la semántica de
/// igualdad (`==`/`hashCode`) de los enums abiertos.
///
/// Nota: los `assert` solo corren con asserts activados (debug/tests), que
/// es justo el modo de `flutter test` — por eso aquí sí se puede verificar
/// que rechazan lo inválido.
void main() {
  group('DiceExpression', () {
    test('.formula acepta una expresión válida', () {
      expect(DiceExpression.formula('1d6+2').formula, '1d6+2');
    });

    test('.formula rechaza caracteres fuera de la gramática', () {
      expect(() => DiceExpression.formula('@@@'), throwsAssertionError);
      expect(() => DiceExpression.formula(''), throwsAssertionError);
    });

    test('.number guarda el valor numérico sin fórmula', () {
      final d = DiceExpression.number(3);
      expect(d.numberValue, 3);
      expect(d.formula, isNull);
    });
  });

  group('EffectDuration', () {
    test('las factories construyen el value con el número de ronda', () {
      expect(EffectDuration.roundStart(2).value, 'round_start_2');
      expect(EffectDuration.roundEnd(3).value, 'round_end_3');
    });

    test('las constantes tienen su value literal', () {
      expect(EffectDuration.nextTurnStartSelf.value, 'next_turn_start_self');
    });

    test('== y hashCode se basan en value (deduplican en un Set)', () {
      expect(EffectDuration.roundStart(2), EffectDuration.roundStart(2));
      expect(
        EffectDuration.roundStart(2).hashCode,
        EffectDuration.roundStart(2).hashCode,
      );
      expect({
        EffectDuration.roundStart(2),
        EffectDuration.roundStart(2),
        EffectDuration.roundEnd(2),
      }, hasLength(2));
    });
  });

  group('ReactionFrequency', () {
    test('las factories construyen el value esperado', () {
      expect(ReactionFrequency.perRound(2).value, '2/round');
      expect(ReactionFrequency.perScene(1).value, '1/scene');
      expect(ReactionFrequency.perMission(4).value, '4/mission');
      expect(ReactionFrequency.unlimited.value, 'Unlimited');
    });

    test('perEncounter es un alias de perScene', () {
      expect(ReactionFrequency.perEncounter(3), ReactionFrequency.perScene(3));
      expect(ReactionFrequency.perEncounter(3).value, '3/scene');
    });
  });

  group('IEffectSaveData.shortForm', () {
    test('fija aoe a false y conserva el stat', () {
      final s = IEffectSaveData.shortForm(MechStat.hull);
      expect(s.stat, MechStat.hull);
      expect(s.aoe, false);
    });
  });

  group('DieRoll', () {
    test('acepta expresiones de tirada válidas', () {
      expect(DieRoll('2d6+1').value, '2d6+1');
      expect(DieRoll('10').value, '10');
      expect(DieRoll('1d20').value, '1d20');
    });

    test('rechaza expresiones inválidas', () {
      expect(() => DieRoll('abc'), throwsAssertionError);
      expect(() => DieRoll(''), throwsAssertionError);
    });
  });

  group('SynergyLocation', () {
    test('las constantes exponen su value', () {
      expect(SynergyLocation.weapon.value, 'weapon');
      expect(SynergyLocation.corePower.value, 'core_power');
    });

    test('actionX construye action_<id>', () {
      expect(SynergyLocation.actionX('foo').value, 'action_foo');
    });

    test('== se basa en value', () {
      expect(SynergyLocation.actionX('x'), SynergyLocation.actionX('x'));
      expect(
        SynergyLocation.actionX('x') == SynergyLocation.actionX('y'),
        isFalse,
      );
    });
  });

  group('DeployableType', () {
    test('constantes y custom', () {
      expect(DeployableType.drone.value, 'Drone');
      expect(DeployableType.custom('Turret').value, 'Turret');
    });

    test('== se basa en value (custom == constante equivalente)', () {
      expect(DeployableType.custom('Drone'), DeployableType.drone);
    });
  });

  group('TierValue', () {
    test('single devuelve el mismo valor para cualquier tier', () {
      final t = TierValue.single(5);
      expect(t.forTier(1), 5);
      expect(t.forTier(3), 5);
    });

    test('perTier devuelve el valor por índice de tier', () {
      final t = TierValue.perTier([10, 20, 30]);
      expect(t.forTier(1), 10);
      expect(t.forTier(2), 20);
      expect(t.forTier(3), 30);
    });

    test('perTier exige exactamente 3 valores', () {
      expect(() => TierValue.perTier([1, 2]), throwsAssertionError);
      expect(() => TierValue.perTier([1, 2, 3, 4]), throwsAssertionError);
    });

    test('forTier exige un tier entre 1 y 3', () {
      final t = TierValue.perTier([1, 2, 3]);
      expect(() => t.forTier(0), throwsAssertionError);
      expect(() => t.forTier(4), throwsAssertionError);
    });
  });

  group('NpcSize', () {
    test('acepta exactamente 3 sub-arrays', () {
      expect(
        NpcSize(const [
          [1],
          [1, 2],
          [2],
        ]).perTier,
        hasLength(3),
      );
    });

    test('rechaza un número de sub-arrays distinto de 3', () {
      expect(
        () => NpcSize(const [
          [1],
          [1],
        ]),
        throwsAssertionError,
      );
    });
  });

  group('INpcDamageData', () {
    test('exige exactamente 3 valores de daño (uno por tier)', () {
      expect(
        INpcDamageData(type: DamageType.kinetic, damage: const [1, 2, 3]).damage,
        hasLength(3),
      );
      expect(
        () => INpcDamageData(type: DamageType.kinetic, damage: const [1, 2]),
        throwsAssertionError,
      );
    });
  });

  group('EidolonShardCount', () {
    test('single / perTier / hostileCharacters', () {
      expect(EidolonShardCount.single(2).single, 2);
      expect(EidolonShardCount.perTier([1, 2, 3]).perTier, [1, 2, 3]);
      expect(const EidolonShardCount.hostileCharacters().hostileCharacters,
          isTrue);
    });

    test('perTier exige exactamente 3 valores', () {
      expect(() => EidolonShardCount.perTier([1, 2]), throwsAssertionError);
    });
  });

  group('SemverConstraint', () {
    test('acepta las tres formas válidas', () {
      expect(SemverConstraint('1.0.0').value, '1.0.0');
      expect(SemverConstraint('*').value, '*');
      expect(SemverConstraint('=2.3.4').value, '=2.3.4');
    });

    test('rechaza formas inválidas', () {
      expect(() => SemverConstraint('1.0'), throwsAssertionError);
      expect(() => SemverConstraint('v1.0.0'), throwsAssertionError);
      expect(() => SemverConstraint('1.0.0-beta'), throwsAssertionError);
      expect(() => SemverConstraint(''), throwsAssertionError);
    });
  });
}
