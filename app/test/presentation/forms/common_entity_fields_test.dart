import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/presentation/forms/common_entity_fields.dart';
import 'package:lcp_builder/presentation/forms/core_bonus_form_schema.dart';
import 'package:lcp_builder/presentation/forms/field_spec.dart';
import 'package:lcp_builder/presentation/forms/frame_form_schema.dart';
import 'package:lcp_builder/presentation/forms/weapon_form_schema.dart';

/// Busca un [FieldSpec] por `key` en cualquier profundidad del árbol
/// (mismo criterio que `json_key_overrides_test.dart`).
FieldSpec _findByKey(List<FieldSpec> fields, String key) {
  for (final f in fields) {
    if (f.key == key) return f;
    final nested = switch (f) {
      GroupFieldSpec(:final fields) => fields,
      ListFieldSpec(:final itemFields) => itemFields,
      _ => null,
    };
    if (nested != null) {
      try {
        return _findByKey(nested, key);
      } on StateError {
        continue;
      }
    }
  }
  throw StateError('No se encontró key="$key"');
}

/// Comprueba la referencia de tags/fabricantes del Core de Lancer que se
/// añadió al `helpText` de los campos que referencian su `id` — verificada
/// contra `lib/manufacturers.json`/`lib/tags.json` en
/// `massif-press/lancer-data` (no exhaustivo: comprobación de una muestra,
/// no de las 67 entradas de tags una por una).
void main() {
  group('manufacturerIdHelpText', () {
    test('incluye los 5 fabricantes reales del Core, id y nombre', () {
      for (final entry in const {
        'GMS': 'General Massive Systems',
        'IPS-N': 'IPS-Northstar',
        'SSC': 'Smith-Shimano Corpro',
        'HORUS': 'Horus',
        'HA': 'Harrison Armory',
      }.entries) {
        expect(manufacturerIdHelpText, contains(entry.key));
        expect(manufacturerIdHelpText, contains(entry.value));
      }
    });

    test('se usa de verdad en los esquemas que referencian un fabricante', () {
      final weaponSource = buildWeaponFormSchema().firstWhere(
        (f) => f.key == 'source',
      );
      expect(weaponSource.helpText, manufacturerIdHelpText);

      final frameSource = buildFrameFormSchema().firstWhere(
        (f) => f.key == 'source',
      );
      expect(frameSource.helpText, manufacturerIdHelpText);

      final coreBonusSource = buildCoreBonusFormSchema().firstWhere(
        (f) => f.key == 'source',
      );
      expect(coreBonusSource.helpText, manufacturerIdHelpText);
    });
  });

  group('tagIdHelpText', () {
    test('incluye una muestra de tags reales del Core, id y nombre', () {
      for (final entry in const {
        'tg_accurate': 'Accurate',
        'tg_ap': 'Armor-Piercing (AP)',
        'tg_limited': 'Limited',
        'tg_ai': 'AI',
        'tg_npc_weapon': 'NPC Weapon',
      }.entries) {
        expect(tagIdHelpText, contains(entry.key));
        expect(tagIdHelpText, contains(entry.value));
      }
    });

    test('se usa de verdad en el campo "tags" del esquema de arma', () {
      final tagsField =
          _findByKey(buildWeaponFormSchema(), 'tags') as ListFieldSpec;
      final idField = tagsField.itemFields.firstWhere((f) => f.key == 'id');
      expect(idField.helpText, tagIdHelpText);
    });
  });
}
