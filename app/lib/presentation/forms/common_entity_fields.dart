/// Reusable form field builders and domain assemblers shared by the entity
/// form schemas.
///
/// Barrel file: re-exports every field module so the schema files that import
/// `common_entity_fields.dart` keep working unchanged. Split out of a single
/// ~2000-line file, one module per responsibility / domain section.
library;

export 'field_help_texts.dart';
export 'field_mappers.dart';
export 'shared_field_specs.dart';
export 'damage_range_fields.dart';
export 'effect_fields.dart';
export 'action_fields.dart';
export 'bonus_fields.dart';
export 'synergy_fields.dart';
export 'tag_fields.dart';
export 'counter_fields.dart';
export 'deployable_fields.dart';
export 'npc_data_fields.dart';
export 'mech_system_base_fields.dart';
