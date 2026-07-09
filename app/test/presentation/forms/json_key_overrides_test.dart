import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/presentation/forms/field_spec.dart';
import 'package:lcp_builder/presentation/forms/frame_form_schema.dart';
import 'package:lcp_builder/presentation/forms/npc_feature_form_schema.dart';
import 'package:lcp_builder/presentation/forms/pilot_gear_form_schema.dart';
import 'package:lcp_builder/presentation/forms/weapon_form_schema.dart';

/// Busca un [FieldSpec] por `key` en cualquier profundidad del árbol
/// (campos propios de un [GroupFieldSpec], ítems de un [ListFieldSpec]) —
/// no desciende en las ramas de un [ShapeChoiceFieldSpec]/[CatalogFieldSpec]
/// a propósito: esas son sintéticas, nunca tienen un `jsonKey` propio real
/// (ver comentario de `FieldSpec.jsonKey`).
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

/// Comprueba una muestra de los `jsonKey` que se auditaron a mano contra
/// `domain_json_mapper.dart` (ver el commit que introdujo este archivo) —
/// no exhaustivo (auditar los 24 esquemas campo a campo cada vez que se
/// toca uno sería frágil), pero cubre los casos con más riesgo real si
/// alguien los revierte sin darse cuenta: renombres simples
/// (`licenseId`/`license_id`) y los dos casos semánticos que el propio
/// nombre no delata (`kind` → `type`, el discriminador de una unión).
void main() {
  test('weapon: licenseId/licenseLevel usan jsonKey en snake_case', () {
    final fields = buildWeaponFormSchema();
    expect(_findByKey(fields, 'licenseId').jsonKey, 'license_id');
    expect(_findByKey(fields, 'licenseLevel').jsonKey, 'license_level');
  });

  test('frame: campos top-level y anidados (dentro de "stats") con jsonKey '
      'distinto de key', () {
    final fields = buildFrameFormSchema();
    expect(_findByKey(fields, 'coreSystem').jsonKey, 'core_system');
    expect(_findByKey(fields, 'imageUrl').jsonKey, 'image_url');
    // Anidado dentro del GroupFieldSpec 'stats'.
    expect(_findByKey(fields, 'sensorRange').jsonKey, 'sensor_range');
  });

  test('pilotGear: "kind" (discriminador de la unión) usa jsonKey "type", '
      'no una simple conversión snake_case', () {
    final fields = buildPilotGearFormSchema();
    expect(_findByKey(fields, 'kind').jsonKey, 'type');
  });

  test('npcFeature: "kind" también usa jsonKey "type"', () {
    final fields = buildNpcFeatureFormSchema();
    expect(_findByKey(fields, 'kind').jsonKey, 'type');
  });
}
