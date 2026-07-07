import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/presentation/forms/core_bonus_form_schema.dart';
import 'package:lcp_builder/presentation/forms/reserve_form_schema.dart';
import 'package:lcp_builder/presentation/forms/talent_form_schema.dart';

/// Ensambladores de las 3 entidades que reutilizan el paquete de
/// actions/bonuses/synergies/deployables/counters/activeEffects extraído
/// a `common_entity_fields.dart` — la prueba real de que la extracción
/// funciona igual de bien fuera de arma.
void main() {
  group('reserveFromFormValues', () {
    test('ensambla type, consumable y bonuses', () {
      final reserve = reserveFromFormValues({
        'id': 'reserve_test',
        'name': 'Test',
        'type': ReserveType.tactical,
        'consumable': true,
        'bonuses': [
          {
            'bonus.id': BonusId.accuracy,
            'bonus.value.choice': 'A',
            'bonus.value.a': 1,
          },
        ],
      });

      expect(reserve.type, ReserveType.tactical);
      expect(reserve.consumable, isTrue);
      expect(reserve.bonuses, hasLength(1));
      expect(reserve.bonuses!.first.id, BonusId.accuracy);
    });
  });

  group('coreBonusFromFormValues', () {
    test('ensambla source/effect y actions', () {
      final coreBonus = coreBonusFromFormValues({
        'id': 'cb_test',
        'name': 'Test',
        'source': 'GMS',
        'effect': 'e',
        'description': 'd',
        'actions': [
          {'name': 'Acción', 'activation': ActivationType.quick, 'detail': 'd'},
        ],
      });

      expect(coreBonus.source, 'GMS');
      expect(coreBonus.actions, hasLength(1));
      expect(coreBonus.actions!.first.name, 'Acción');
    });
  });

  group('talentFromFormValues', () {
    test('ensambla ranks anidados, cada uno con su propio paquete', () {
      final talent = talentFromFormValues({
        'id': 'tal_test',
        'name': 'Test',
        'description': 'd',
        'ranks': [
          {
            'name': 'Rank 1',
            'description': 'd',
            'exclusive': true,
            'bonuses': [
              {
                'bonus.id': BonusId.accuracy,
                'bonus.value.choice': 'A',
                'bonus.value.a': 1,
              },
            ],
          },
          {'name': 'Rank 2', 'description': 'd'},
        ],
      });

      expect(talent.ranks, hasLength(2));
      expect(talent.ranks[0].exclusive, isTrue);
      expect(talent.ranks[0].bonuses, hasLength(1));
      expect(talent.ranks[1].exclusive, isNull);
      expect(talent.ranks[1].bonuses, isNull);
    });

    test('sin ranks, la lista queda vacía, no null (campo requerido)', () {
      final talent = talentFromFormValues({
        'id': 'tal_test',
        'name': 'Test',
        'description': 'd',
      });

      expect(talent.ranks, isEmpty);
    });
  });
}
