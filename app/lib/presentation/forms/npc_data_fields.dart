/// NPC tier-value and size field builders and assemblers (domain section 15).
library;

import '../../domain/domain.dart';
import 'field_spec.dart';

// --- Sección 15 (NPC Data): TierValue / NpcSize — caso 6 del catálogo de
// casos polimórficos (variabilidad por tier de NPC). Resuelto sin
// FieldSpec nuevo: ShapeChoiceFieldSpec (generalizado a N ramas) +
// GroupFieldSpec, ver vault "Decisión - variabilidad por tier de NPC". ---

/// `TierValue = number | [number, number, number]`. La rama "por tier" pide
/// 3 campos fijos (`tier1`/`tier2`/`tier3`), mismo criterio que descartó
/// `ListFieldSpec` en otros grupos de tamaño fijo (ej. `IEffectSaveData`).
/// [jsonKey]: la clave real del `.lcp`, si difiere de [key] (ej.
/// `attackBonus` en el formulario, `attack_bonus` en el JSON). Por
/// defecto igual a [key], como en [FieldSpec.jsonKey].
FieldSpec tierValueField(String key, String label, {String? jsonKey}) {
  final realKey = jsonKey ?? key;
  return ShapeChoiceFieldSpec(
    key: key,
    jsonKey: realKey,
    label: label,
    // `tierValueToJson` escribe un número suelto o un array de 3 — la
    // forma del propio valor ya dice la rama.
    branchFromJson: (json) {
      final raw = json[realKey];
      if (raw is List) return 'perTier';
      if (raw is num) return 'single';
      return null;
    },
    options: [
      ShapeChoiceOption(
        value: 'single',
        label: 'Único (los 3 tiers)',
        field: NumberFieldSpec(
          key: '$key.single',
          jsonKey: realKey,
          label: label,
        ),
      ),
      ShapeChoiceOption(
        value: 'perTier',
        label: 'Por tier',
        field: GroupFieldSpec(
          key: '$key.perTier',
          jsonKey: realKey,
          label: '$label por tier',
          fields: const [
            NumberFieldSpec(key: 'tier1', label: 'Tier 1', required: true),
            NumberFieldSpec(key: 'tier2', label: 'Tier 2', required: true),
            NumberFieldSpec(key: 'tier3', label: 'Tier 3', required: true),
          ],
        ),
      ),
    ],
  );
}

TierValue? tierValueFromItem(Map<String, dynamic> item, String key) {
  final choice = item['$key.choice'] as String? ?? 'single';
  if (choice == 'single') {
    final v = item['$key.single'] as num?;
    return v == null ? null : TierValue.single(v);
  }
  final group = item['$key.perTier'] as Map<String, dynamic>?;
  final t1 = group?['tier1'] as num?;
  final t2 = group?['tier2'] as num?;
  final t3 = group?['tier3'] as num?;
  if (t1 == null || t2 == null || t3 == null) return null;
  return TierValue.perTier([t1, t2, t3]);
}

/// `NpcSize` no ofrece elección (el dominio solo tiene un constructor,
/// siempre 3 sub-arrays) — a diferencia de [tierValueField], va directo al
/// `GroupFieldSpec` sin envolverlo en un `ShapeChoiceFieldSpec`. Cada tier
/// admite varios tamaños válidos a la vez, de ahí `MultiEnumFieldSpec`.
const _npcSizeValues = [0.5, 1, 2, 3];

FieldSpec npcSizeField() => GroupFieldSpec(
  key: 'size',
  label: 'Tamaño (uno o más valores válidos por tier: 0.5, 1, 2, 3)',
  fields: [
    for (final n in [1, 2, 3])
      // NpcSize se serializa como un array de 3 sub-arrays sueltos (ver
      // `npcSizeToJson`) — el hydrator (`form_values_from_json.dart`)
      // reparte ese array por posición sobre `tier1`/`tier2`/`tier3`, no
      // por nombre de clave. Los elementos del sub-array ya son números
      // crudos, no strings — `fromJsonValue` solo hace de identidad.
      MultiEnumFieldSpec<num>(
        key: 'tier$n',
        label: 'Tier $n',
        options: _npcSizeValues,
        displayLabel: (v) => v.toString(),
        fromJsonValue: (v) => v as num,
      ),
  ],
);

NpcSize? npcSizeFromItem(Map<String, dynamic> item) {
  final group = item['size'] as Map<String, dynamic>?;
  if (group == null) return null;
  final t1 = (group['tier1'] as List?)?.cast<num>() ?? const [];
  final t2 = (group['tier2'] as List?)?.cast<num>() ?? const [];
  final t3 = (group['tier3'] as List?)?.cast<num>() ?? const [];
  if (t1.isEmpty || t2.isEmpty || t3.isEmpty) return null;
  return NpcSize([t1, t2, t3]);
}
