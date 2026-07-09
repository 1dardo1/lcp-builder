import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/presentation/forms/field_spec.dart';
import 'package:lcp_builder/presentation/forms/form_values_from_json.dart';

enum _Mount { main, heavy }

void main() {
  group('formValuesFromJson', () {
    test('campos escalares se copian del jsonKey al key del formulario', () {
      final schema = [
        const TextFieldSpec(key: 'id', label: 'ID'),
        const NumberFieldSpec(key: 'sp', label: 'SP', jsonKey: 'sp_cost'),
        const BoolFieldSpec(key: 'hidden', label: 'Hidden'),
        PatternTextFieldSpec(
          key: 'damage',
          label: 'Damage',
          pattern: RegExp(r'.*'),
          patternHint: 'x',
        ),
      ];
      final values = formValuesFromJson(schema, {
        'id': 'mw_rifle',
        'sp_cost': 2,
        'hidden': true,
        'damage': '1d6',
      });

      expect(values, {
        'id': 'mw_rifle',
        'sp': 2,
        'hidden': true,
        'damage': '1d6',
      });
    });

    test('un campo ausente en el json no aparece en el resultado', () {
      const schema = [TextFieldSpec(key: 'quote', label: 'Cita')];
      final values = formValuesFromJson(schema, {});

      expect(values.containsKey('quote'), isFalse);
    });

    test('EnumFieldSpec usa fromJsonValue para reconstruir la instancia', () {
      final schema = [
        EnumFieldSpec<_Mount>(
          key: 'mount',
          label: 'Mount',
          options: _Mount.values,
          displayLabel: (m) => m.name,
          fromJsonValue: (s) => s == 'Heavy' ? _Mount.heavy : _Mount.main,
        ),
      ];
      final values = formValuesFromJson(schema, {'mount': 'Heavy'});

      expect(values['mount'], _Mount.heavy);
    });

    test('EnumFieldSpec sin fromJsonValue todavía (auditoría pendiente) no rompe, se omite', () {
      final schema = [
        EnumFieldSpec<_Mount>(
          key: 'mount',
          label: 'Mount',
          options: _Mount.values,
          displayLabel: (m) => m.name,
        ),
      ];
      final values = formValuesFromJson(schema, {'mount': 'Heavy'});

      expect(values.containsKey('mount'), isFalse);
    });

    test('MultiEnumFieldSpec reconstruye la lista completa vía fromJsonValue', () {
      final schema = [
        MultiEnumFieldSpec<_Mount>(
          key: 'mounts',
          label: 'Mounts',
          options: _Mount.values,
          displayLabel: (m) => m.name,
          fromJsonValue: (s) => s == 'Heavy' ? _Mount.heavy : _Mount.main,
        ),
      ];
      final values = formValuesFromJson(schema, {
        'mounts': ['Heavy', 'Main'],
      });

      expect(values['mounts'], [_Mount.heavy, _Mount.main]);
    });

    test('GroupFieldSpec recorre sus campos anidados en su propio mapa', () {
      const schema = [
        GroupFieldSpec(
          key: 'stats',
          label: 'Stats',
          fields: [NumberFieldSpec(key: 'hp', label: 'HP')],
        ),
      ];
      final values = formValuesFromJson(schema, {
        'stats': {'hp': 10},
      });

      expect(values['stats'], {'hp': 10});
    });

    test('ListFieldSpec produce una lista de mapas, uno por ítem', () {
      const schema = [
        ListFieldSpec(
          key: 'traits',
          label: 'Traits',
          itemFields: [TextFieldSpec(key: 'name', label: 'Nombre')],
        ),
      ];
      final values = formValuesFromJson(schema, {
        'traits': [
          {'name': 'a'},
          {'name': 'b'},
        ],
      });

      expect(values['traits'], [
        {'name': 'a'},
        {'name': 'b'},
      ]);
    });

    test('ShapeChoiceFieldSpec y CatalogFieldSpec se omiten sin lanzar (pendiente)', () {
      final schema = [
        const ShapeChoiceFieldSpec(
          key: 'value',
          label: 'Value',
          options: [ShapeChoiceOption(value: 'a', label: 'A')],
        ),
        CatalogFieldSpec<String>(
          key: 'bonus',
          label: 'Bonus',
          catalogIds: const ['x'],
          idLabel: (id) => id,
          valueFieldFor: (id) => const TextFieldSpec(key: 'bonus.value', label: 'Valor'),
        ),
      ];
      final values = formValuesFromJson(schema, {
        'value': 'a',
        'bonus': {'id': 'x', 'val': 1},
      });

      expect(values, isEmpty);
    });
  });
}
