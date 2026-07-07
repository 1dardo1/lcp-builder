import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/presentation/forms/background_form_schema.dart';
import 'package:lcp_builder/presentation/forms/bond_form_schema.dart';
import 'package:lcp_builder/presentation/forms/environment_form_schema.dart';
import 'package:lcp_builder/presentation/forms/manufacturer_form_schema.dart';
import 'package:lcp_builder/presentation/forms/sitrep_form_schema.dart';
import 'package:lcp_builder/presentation/forms/skill_form_schema.dart';
import 'package:lcp_builder/presentation/forms/status_condition_form_schema.dart';
import 'package:lcp_builder/presentation/forms/tag_form_schema.dart';

/// Ensambladores de las entidades "simples" (sin casos polimórficos
/// propios) — un archivo compartido, a diferencia de `weapon_form_schema`,
/// porque cada una es pequeña y no lo justifica un archivo propio.
void main() {
  group('manufacturerFromFormValues', () {
    test('ensambla los campos requeridos y opcionales', () {
      final manufacturer = manufacturerFromFormValues({
        'id': 'GMS',
        'name': 'General Manufacturing Systems',
        'description': 'd',
        'quote': 'q',
        'light': '#FFFFFF',
        'dark': '#000000',
        'iconSvg': '<svg/>',
      });

      expect(manufacturer.id, 'GMS');
      expect(manufacturer.iconSvg, '<svg/>');
      expect(manufacturer.iconUrl, isNull);
    });
  });

  group('tagFromFormValues', () {
    test('ensambla hidden/filterIgnore', () {
      final tag = tagFromFormValues({
        'id': 'tg_accurate',
        'name': 'Accurate',
        'description': 'd',
        'hidden': true,
      });

      expect(tag.hidden, isTrue);
      expect(tag.filterIgnore, isNull);
    });
  });

  group('skillFromFormValues', () {
    test('ensambla family', () {
      final skill = skillFromFormValues({
        'id': 'sk_test',
        'name': 'Test',
        'description': 'd',
        'detail': 'det',
        'family': SkillFamily.dex,
      });

      expect(skill.family, SkillFamily.dex);
    });
  });

  group('statusConditionFromFormValues', () {
    test('ensambla type y exclusive', () {
      final status = statusConditionFromFormValues({
        'id': 'st_shredded',
        'name': 'Shredded',
        'type': StatusConditionType.status,
        'effects': 'e',
        'exclusive': ExclusiveTarget.mech,
      });

      expect(status.type, StatusConditionType.status);
      expect(status.exclusive, ExclusiveTarget.mech);
    });
  });

  group('sitrepFromFormValues', () {
    test('ensambla conditions desde la lista de ítems', () {
      final sitrep = sitrepFromFormValues({
        'id': 'sitrep_test',
        'name': 'Test',
        'description': 'd',
        'conditions': [
          {'title': 't', 'condition': 'c'},
        ],
      });

      expect(sitrep.conditions, hasLength(1));
      expect(sitrep.conditions!.first.title, 't');
    });

    test('sin conditions, el campo queda null', () {
      final sitrep = sitrepFromFormValues({
        'id': 'sitrep_test',
        'name': 'Test',
        'description': 'd',
      });

      expect(sitrep.conditions, isNull);
    });
  });

  group('environmentFromFormValues', () {
    test('ensambla los 3 campos', () {
      final environment = environmentFromFormValues({
        'id': 'env_test',
        'name': 'Test',
        'description': 'd',
      });

      expect(environment.id, 'env_test');
      expect(environment.name, 'Test');
      expect(environment.description, 'd');
    });
  });

  group('backgroundFromFormValues', () {
    test('ensambla skills desde la lista de ítems', () {
      final background = backgroundFromFormValues({
        'id': 'bg_test',
        'name': 'Test',
        'description': 'd',
        'skills': [
          {'id': 'sk_a'},
          {'id': 'sk_b'},
        ],
      });

      expect(background.skills, ['sk_a', 'sk_b']);
    });

    test('sin skills, el campo queda null', () {
      final background = backgroundFromFormValues({
        'id': 'bg_test',
        'name': 'Test',
        'description': 'd',
      });

      expect(background.skills, isNull);
    });
  });

  group('bondFromFormValues', () {
    test('ensambla ideals, questions (con options anidadas) y powers', () {
      final bond = bondFromFormValues({
        'id': 'bond_test',
        'name': 'Test',
        'majorIdeals': [
          {'value': 'Honor'},
        ],
        'minorIdeals': [
          {'value': 'Cunning'},
        ],
        'questions': [
          {
            'question': '¿Por qué?',
            'options': [
              {'value': 'a'},
              {'value': 'b'},
            ],
          },
        ],
        'powers': [
          {
            'name': 'Power',
            'description': 'd',
            'frequency': ActionFrequency.perScene,
            'veteran': true,
          },
        ],
      });

      expect(bond.majorIdeals, ['Honor']);
      expect(bond.minorIdeals, ['Cunning']);
      expect(bond.questions, hasLength(1));
      expect(bond.questions.first.question, '¿Por qué?');
      expect(bond.questions.first.options, ['a', 'b']);
      expect(bond.powers, hasLength(1));
      expect(bond.powers.first.veteran, isTrue);
      expect(bond.powers.first.frequency, ActionFrequency.perScene);
    });

    test('sin questions ni powers, ambas listas quedan vacías, no null', () {
      final bond = bondFromFormValues({'id': 'bond_test', 'name': 'Test'});

      expect(bond.questions, isEmpty);
      expect(bond.powers, isEmpty);
    });
  });
}
