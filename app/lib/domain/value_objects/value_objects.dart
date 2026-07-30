/// LCP Builder domain value objects.
///
/// Barrel file: re-exports every value object so existing imports of
/// `value_objects.dart` keep working unchanged. The value objects are a
/// direct transcription of `vault/Modelo de Dominio/` (sections 1-17) and
/// were split out of this file, one file per cohesive group, in the same
/// order as the source document. On the structural equality omitted from the
/// value objects with many list fields, see "Principios y decisiones clave"
/// in the vault (a documented decision, not an oversight).
library;

export 'shared_value_types.dart';
export 'damage_and_range.dart';
export 'effects.dart';
export 'actions_and_active_effects.dart';
export 'bonuses.dart';
export 'synergies.dart';
export 'tags.dart';
export 'deployables.dart';
export 'ammo.dart';
export 'bonds.dart';
export 'talents.dart';
export 'frames.dart';
export 'weapons.dart';
export 'npcs.dart';
export 'eidolons.dart';
export 'manifest.dart';
export 'sitreps.dart';
