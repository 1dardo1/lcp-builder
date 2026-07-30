/// Active-effect and action field builders and assemblers, plus the
/// text-or-active-effect field (domain section 3).
library;

import '../../domain/domain.dart';
import 'field_spec.dart';
import 'shared_field_specs.dart';
import 'field_mappers.dart';
import 'damage_range_fields.dart';
import 'effect_fields.dart';

// --- Sección 3: IActiveEffectData / IActionData ---

List<FieldSpec> activeEffectFields() => [
  const TextFieldSpec(
    key: 'name',
    label: 'Nombre',
    required: true,
    helpText: 'El nombre visible de este efecto activo, ej. "Overcharged".',
  ),
  const TextFieldSpec(
    key: 'detail',
    label: 'Detalle',
    required: true,
    maxLines: 3,
    helpText: 'Texto de reglas — lo que hace mecánicamente este efecto.',
  ),
  const TextFieldSpec(
    key: 'condition',
    label: 'Condición',
    helpText: 'Cuándo se activa este efecto, si no es siempre (texto libre).',
  ),
  EnumFieldSpec<ActionFrequency>(
    key: 'frequency',
    label: 'Frecuencia',
    options: ActionFrequency.values,
    displayLabel: (f) => f.jsonValue,
    fromJsonValue: (s) =>
        ActionFrequency.values.firstWhere((f) => f.jsonValue == s),
  ),
  PatternTextFieldSpec(
    key: 'duration',
    label: 'Duración',
    pattern: effectDurationPattern,
    patternHint: 'ej. round_start_1, next_turn_start_self',
  ),
  PatternTextFieldSpec(
    key: 'bonusDamage',
    jsonKey: 'bonus_damage',
    label: 'Daño extra',
    pattern: diceExpressionPattern,
    patternHint: 'ej. 1d6',
  ),
  ListFieldSpec(key: 'damage', label: 'Daño', itemFields: damageItemFields()),
  ListFieldSpec(key: 'range', label: 'Alcance', itemFields: rangeItemFields()),
  ListFieldSpec(
    key: 'addStatus',
    jsonKey: 'add_status',
    label: 'Añade status/condition',
    itemFields: statusEffectItemFields(),
  ),
  ListFieldSpec(
    key: 'addResist',
    jsonKey: 'add_resist',
    label: 'Añade resist/vulnerability/immunity',
    itemFields: resistanceItemFields(),
  ),
  ListFieldSpec(
    key: 'addSpecial',
    jsonKey: 'add_special',
    label: 'Añade special status',
    itemFields: specialStatusItemFields(),
  ),
  const ListFieldSpec(
    key: 'removeSpecial',
    jsonKey: 'remove_special',
    label: 'Quita special status',
    itemFields: [
      TextFieldSpec(
        key: 'id',
        label: 'Atributo',
        required: true,
        helpText:
            'El nombre del atributo especial a quitar (debe coincidir '
            'exactamente con el que se añadió en otro sitio).',
      ),
    ],
  ),
  ListFieldSpec(
    key: 'addOther',
    jsonKey: 'add_other',
    label: 'Añade otro efecto',
    itemFields: otherEffectItemFields(),
  ),
  effectSaveGroupField('save'),
  EnumFieldSpec<AttackType>(
    key: 'attack',
    label: 'Tipo de ataque',
    options: AttackType.values,
    displayLabel: (a) => a.name,
    fromJsonValue: (s) => AttackType.values.byName(s),
  ),
  const BoolFieldSpec(key: 'pilot', label: 'Pilot'),
  const BoolFieldSpec(key: 'mech', label: 'Mech'),
  const NumberFieldSpec(key: 'accuracy', label: 'Accuracy'),
  const NumberFieldSpec(
    key: 'attackBonus',
    jsonKey: 'attack_bonus',
    label: 'Attack bonus',
  ),
];

IActiveEffectData activeEffectFromGroup(Map<String, dynamic> item) =>
    IActiveEffectData(
      name: item['name'] as String,
      detail: item['detail'] as String,
      condition: item['condition'] as String?,
      frequency: item['frequency'] as ActionFrequency?,
      duration: effectDurationFromInput(item['duration'] as String?),
      bonusDamage: (item['bonusDamage'] as String?)?.isNotEmpty == true
          ? diceExpressionFromInput(item['bonusDamage'] as String)
          : null,
      damage: mapItems(item['damage'], damageDataFromItem),
      range: mapItems(item['range'], rangeDataFromItem),
      addStatus: mapItems(item['addStatus'], statusEffectFromItem),
      addResist: mapItems(item['addResist'], resistanceFromItem),
      addSpecial: mapItems(item['addSpecial'], specialStatusFromItem),
      removeSpecial: mapStringIdItems(item['removeSpecial']),
      addOther: mapItems(item['addOther'], otherEffectFromItem),
      save: effectSaveFromGroup(item['save'] as Map<String, dynamic>?),
      attack: item['attack'] as AttackType?,
      pilot: item['pilot'] as bool?,
      mech: item['mech'] as bool?,
      accuracy: item['accuracy'] as num?,
      attackBonus: item['attackBonus'] as num?,
    );

/// Campo `IActiveEffectData?` suelto (no envuelto en `TextOrActiveEffect`,
/// a diferencia de `textOrActiveEffectField`) — ej. `on_attack`/`on_hit`/
/// `on_crit`/`on_miss` de `IWeaponModData`, que en la spec son siempre un
/// active effect estructurado, nunca texto libre.
FieldSpec activeEffectGroupField(String key, String label) => GroupFieldSpec(
  key: key,
  // La clave real en el `.lcp` es snake_case (`on_miss`, `on_attack`...),
  // no la camelCase del formulario (ver `domain_json_mapper.dart`). Sin
  // este `jsonKey`, Mostrar (`EntityDisplayCard`) y la hidratación de
  // Editar (`form_values_from_json.dart`) buscaban `json['onMiss']`, que no
  // existe — así que estos efectos se perdían al reabrir la entidad y, al
  // ser sus campos obligatorios, la validación bloqueaba el guardado
  // (bug real de Editar en weapon mod, encontrado por el test de
  // aceptación).
  jsonKey: _camelToSnake(key),
  label: label,
  fields: activeEffectFields(),
);

/// `onMiss` → `on_miss`. Los `jsonKey` de estos grupos deben coincidir con
/// la grafía snake_case que escribe el mapper (no se guardan a mano por
/// campo, se derivan de la key camelCase para no repetir la conversión en
/// cada uno de los ~8 sitios que llaman a [activeEffectGroupField]).
String _camelToSnake(String s) =>
    s.replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]!.toLowerCase()}');

IActiveEffectData? activeEffectFromGroupOrNull(
  Map<String, dynamic> item,
  String key,
) {
  final group = item[key] as Map<String, dynamic>?;
  if (group == null || group['name'] == null) return null;
  return activeEffectFromGroup(group);
}

List<FieldSpec> actionItemFields() => [
  const TextFieldSpec(
    key: 'name',
    label: 'Nombre',
    required: true,
    helpText: 'El nombre visible de la acción, ej. "Skirmish".',
  ),
  EnumFieldSpec<ActivationType>(
    key: 'activation',
    label: 'Activación',
    required: true,
    options: ActivationType.values,
    displayLabel: (a) => a.jsonValue,
    fromJsonValue: (s) =>
        ActivationType.values.firstWhere((a) => a.jsonValue == s),
  ),
  const TextFieldSpec(
    key: 'detail',
    label: 'Detalle',
    required: true,
    maxLines: 3,
    helpText: 'Texto de reglas — lo que hace mecánicamente esta acción.',
  ),
  EnumFieldSpec<ActionFrequency>(
    key: 'frequency',
    label: 'Frecuencia',
    options: ActionFrequency.values,
    displayLabel: (f) => f.jsonValue,
    fromJsonValue: (s) =>
        ActionFrequency.values.firstWhere((f) => f.jsonValue == s),
  ),
  const TextFieldSpec(
    key: 'trigger',
    label: 'Trigger (si es Reaction)',
    helpText:
        'Qué dispara esta acción cuando es de tipo Reaction, ej. "Cuando el '
        'piloto sea alcanzado por un ataque cuerpo a cuerpo".',
  ),
  const NumberFieldSpec(key: 'cost', label: 'Coste (si es limited)'),
  const BoolFieldSpec(key: 'pilot', label: 'Pilot'),
  const BoolFieldSpec(key: 'mech', label: 'Mech'),
  const BoolFieldSpec(
    key: 'hideActive',
    jsonKey: 'hide_active',
    label: 'Ocultar acción activa',
  ),
  PatternTextFieldSpec(
    key: 'bonusDamage',
    jsonKey: 'bonus_damage',
    label: 'Daño extra',
    pattern: diceExpressionPattern,
    patternHint: 'ej. 1d6',
  ),
  GroupFieldSpec(key: 'damage', label: 'Daño', fields: damageItemFields()),
  GroupFieldSpec(key: 'range', label: 'Alcance', fields: rangeItemFields()),
  ListFieldSpec(
    key: 'addStatus',
    jsonKey: 'add_status',
    label: 'Añade status/condition',
    itemFields: statusEffectItemFields(),
  ),
  ListFieldSpec(
    key: 'addResist',
    jsonKey: 'add_resist',
    label: 'Añade resist/vulnerability/immunity',
    itemFields: resistanceItemFields(),
  ),
  ListFieldSpec(
    key: 'addSpecial',
    jsonKey: 'add_special',
    label: 'Añade special status',
    itemFields: specialStatusItemFields(),
  ),
  const ListFieldSpec(
    key: 'removeSpecial',
    jsonKey: 'remove_special',
    label: 'Quita special status',
    itemFields: [
      TextFieldSpec(
        key: 'id',
        label: 'Atributo',
        required: true,
        helpText:
            'El nombre del atributo especial a quitar (debe coincidir '
            'exactamente con el que se añadió en otro sitio).',
      ),
    ],
  ),
  ListFieldSpec(
    key: 'addOther',
    jsonKey: 'add_other',
    label: 'Añade otro efecto',
    itemFields: otherEffectItemFields(),
  ),
  ListFieldSpec(
    key: 'activeEffects',
    jsonKey: 'active_effects',
    label: 'Active effects',
    itemFields: activeEffectFields(),
  ),
  effectSaveGroupField('save'),
];

IActionData actionFromItem(Map<String, dynamic> item) {
  final damageGroup = item['damage'] as Map<String, dynamic>?;
  final rangeGroup = item['range'] as Map<String, dynamic>?;
  return IActionData(
    name: item['name'] as String,
    activation: item['activation'] as ActivationType,
    detail: item['detail'] as String,
    frequency: item['frequency'] as ActionFrequency?,
    trigger: item['trigger'] as String?,
    cost: (item['cost'] as num?)?.toInt(),
    pilot: item['pilot'] as bool?,
    mech: item['mech'] as bool?,
    hideActive: item['hideActive'] as bool?,
    bonusDamage: (item['bonusDamage'] as String?)?.isNotEmpty == true
        ? diceExpressionFromInput(item['bonusDamage'] as String)
        : null,
    damage: damageGroup == null || damageGroup['type'] == null
        ? null
        : damageDataFromItem(damageGroup),
    range: rangeGroup == null || rangeGroup['type'] == null
        ? null
        : rangeDataFromItem(rangeGroup),
    addStatus: mapItems(item['addStatus'], statusEffectFromItem),
    addResist: mapItems(item['addResist'], resistanceFromItem),
    addSpecial: mapItems(item['addSpecial'], specialStatusFromItem),
    removeSpecial: mapStringIdItems(item['removeSpecial']),
    addOther: mapItems(item['addOther'], otherEffectFromItem),
    activeEffects: mapItems(item['activeEffects'], activeEffectFromGroup),
    save: effectSaveFromGroup(item['save'] as Map<String, dynamic>?),
  );
}
// --- Sección 3: TextOrActiveEffect ---

FieldSpec textOrActiveEffectField(String key, String label) =>
    ShapeChoiceFieldSpec(
      key: key,
      label: label,
      options: [
        ShapeChoiceOption(
          value: 'A',
          label: 'Texto',
          field: TextFieldSpec(
            key: '$key.a',
            label: '$label (texto)',
            helpText:
                'Texto de reglas libre, para cuando no hace falta la '
                'forma estructurada de "Active effect".',
          ),
        ),
        ShapeChoiceOption(
          value: 'B',
          label: 'Active effect',
          field: GroupFieldSpec(
            key: '$key.b',
            label: '$label (active effect)',
            fields: activeEffectFields(),
          ),
        ),
      ],
    );

TextOrActiveEffect? textOrActiveEffectFromItem(
  Map<String, dynamic> item,
  String key,
) {
  final choice = item['$key.choice'] as String? ?? 'A';
  if (choice == 'A') {
    final text = item['$key.a'] as String?;
    return (text == null || text.isEmpty)
        ? null
        : TextOrActiveEffect.text(text);
  }
  final group = item['$key.b'] as Map<String, dynamic>?;
  if (group == null || group['name'] == null) return null;
  return TextOrActiveEffect.effect(activeEffectFromGroup(group));
}
