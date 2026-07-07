import '../../domain/domain.dart';
import 'entity_crear_config.dart';
import 'field_spec.dart';

/// Esquema de campos de [IWeaponData] para el motor genérico — cobertura
/// completa de la entidad (todos los campos de `IWeaponData`), con una
/// única excepción documentada por decisión consciente: `IDeployableData`
/// no expone su propio campo `deployables` (recursión de deployable dentro
/// de deployable) — el propio dominio ya anota que en la práctica "no crea
/// jerarquías reales" (mismo patrón que Action/ActiveEffect); se prioriza
/// no añadir profundidad de anidación ilimitada al formulario por un caso
/// que no ocurre en contenido real.
///
/// Organización: funciones `_xFields`/`_xField` de abajo arriba, en el
/// mismo orden topológico que `vault/Modelo de Dominio/` — cada una
/// construye los `FieldSpec` de un tipo del dominio y se reutiliza en todos
/// los puntos donde ese tipo aparece anidado (ej. `_damageItemFields` sirve
/// tanto para `IWeaponData.damage` como para el `damage` singular de
/// `IActiveEffectData`, vía [ListFieldSpec]/[GroupFieldSpec] según toque).
final _diceExpressionPattern = RegExp(r'^[0-9dD+\-*/(){}A-Za-z_ ]+$');
final _effectDurationPattern = RegExp(
  r'^(next_turn_(start|end)_(self|target)|round_(start|end)_\d+)$',
);

// --- Catálogos de UI locales (uniones cerradas discriminadas, no un
// catálogo externo grande como BonusId — mismo mecanismo, menos entradas).
// Públicos (no privados del archivo) para poder construirlos directamente
// en tests, igual que se hace con BonusId. ---

enum ResistanceKind { resist, vulnerability, immunity }

enum OtherEffectKind { overshield, hp, repair, cover }

/// `num | NumericOrFormulaValue` — patrón repetido en `IDeployableData`
/// (armor/hp/evasion/edef/heatcap/repcap/sensorRange/techAttack/save/speed/
/// grapple/attackBonus). Se resuelve siempre como `NumericOrFormulaValue`
/// (miembro válido de la unión) para no añadir un tercer camino de
/// ensamblado — mismo mecanismo ya usado en `IBonusData.val` con
/// `numericOrFormula`.
FieldSpec _numericOrFormulaField(String key, String label) =>
    ShapeChoiceFieldSpec(
      key: key,
      label: label,
      optionALabel: 'Número',
      optionA: NumberFieldSpec(key: '$key.a', label: label, allowDecimal: true),
      optionBLabel: 'Fórmula',
      optionB: TextFieldSpec(key: '$key.b', label: 'Fórmula (ej. {grit}+2)'),
    );

NumericOrFormulaValue? _numericOrFormulaFromItem(
  Map<String, dynamic> item,
  String key,
) {
  final choice = item['$key.choice'] as String? ?? 'A';
  if (choice == 'A') {
    final a = item['$key.a'] as num?;
    return a == null ? null : NumericOrFormulaValue.number(a);
  }
  final b = item['$key.b'] as String?;
  return (b == null || b.isEmpty) ? null : NumericOrFormulaValue.formula(b);
}

// --- Sección 1: IDamageData / IRangeData ---

/// `save`: `String | IDamageSaveData`. `IDamageSaveData.stat` es string
/// libre (no el enum `MechStat`) — ver vault MdD §1.
FieldSpec _damageSaveField() => const ShapeChoiceFieldSpec(
  key: 'save',
  label: 'Save',
  optionALabel: 'Texto',
  optionA: TextFieldSpec(key: 'save.a', label: 'Save (texto libre)'),
  optionBLabel: 'Estructurado',
  optionB: GroupFieldSpec(
    key: 'save.b',
    label: 'Save estructurado',
    fields: [
      TextFieldSpec(key: 'stat', label: 'Stat', required: true),
      BoolFieldSpec(key: 'aoe', label: 'AoE'),
    ],
  ),
);

Object? _damageSaveFromItem(Map<String, dynamic> item) {
  final choice = item['save.choice'] as String? ?? 'A';
  if (choice == 'A') {
    final text = item['save.a'] as String?;
    return (text == null || text.isEmpty) ? null : text;
  }
  final group = item['save.b'] as Map<String, dynamic>?;
  final stat = group?['stat'] as String?;
  if (stat == null || stat.isEmpty) return null;
  return IDamageSaveData(stat: stat, aoe: group?['aoe'] as bool?);
}

List<FieldSpec> _damageItemFields() => [
  EnumFieldSpec<DamageType>(
    key: 'type',
    label: 'Tipo de daño',
    required: true,
    options: DamageType.values,
    displayLabel: (d) => d.jsonValue,
  ),
  PatternTextFieldSpec(
    key: 'val',
    label: 'Valor (número o dados)',
    required: true,
    pattern: _diceExpressionPattern,
    patternHint: 'ej. 2d6, 10, 1d6+{grit}',
  ),
  const ShapeChoiceFieldSpec(
    key: 'aoe',
    label: 'AoE',
    optionALabel: 'Texto',
    optionA: TextFieldSpec(key: 'aoe.a', label: 'AoE (texto)'),
    optionBLabel: 'Sí/No',
    optionB: BoolFieldSpec(key: 'aoe.b', label: 'AoE'),
  ),
  _damageSaveField(),
  const BoolFieldSpec(key: 'saveHalf', label: 'Mitad de daño con save'),
  const BoolFieldSpec(key: 'ap', label: 'AP (ignora armadura)'),
  EnumFieldSpec<TargetType>(
    key: 'target',
    label: 'Target',
    options: TargetType.values,
    displayLabel: (t) => t.name,
  ),
];

StringOrBool? _stringOrBoolFromItem(Map<String, dynamic> item, String key) {
  final choice = item['$key.choice'] as String? ?? 'A';
  if (choice == 'A') {
    final text = item['$key.a'] as String?;
    return (text == null || text.isEmpty) ? null : StringOrBool.text(text);
  }
  final flag = item['$key.b'] as bool?;
  return flag == null ? null : StringOrBool.flag(flag);
}

IDamageData _damageDataFromItem(Map<String, dynamic> item) => IDamageData(
  type: item['type'] as DamageType,
  val: _diceExpressionFromInput(item['val'] as String? ?? '0'),
  aoe: _stringOrBoolFromItem(item, 'aoe'),
  save: _damageSaveFromItem(item),
  saveHalf: item['saveHalf'] as bool?,
  ap: item['ap'] as bool?,
  target: item['target'] as TargetType?,
);

List<FieldSpec> _rangeItemFields() => [
  EnumFieldSpec<RangeType>(
    key: 'type',
    label: 'Tipo de alcance',
    required: true,
    options: RangeType.values,
    displayLabel: (r) => r.jsonValue,
  ),
  PatternTextFieldSpec(
    key: 'val',
    label: 'Valor',
    required: true,
    pattern: _diceExpressionPattern,
    patternHint: 'ej. 10, 1d6',
  ),
  PatternTextFieldSpec(
    key: 'min',
    label: 'Mínimo (opcional)',
    pattern: _diceExpressionPattern,
    patternHint: 'ej. 5',
  ),
];

IRangeData _rangeDataFromItem(Map<String, dynamic> item) => IRangeData(
  type: item['type'] as RangeType,
  val: _diceExpressionFromInput(item['val'] as String? ?? '0'),
  min: (item['min'] as String?)?.isNotEmpty == true
      ? _diceExpressionFromInput(item['min'] as String)
      : null,
);

DiceExpression _diceExpressionFromInput(String raw) {
  final n = num.tryParse(raw);
  return n != null ? DiceExpression.number(n) : DiceExpression.formula(raw);
}

// --- Sección 2: IStatusEffectData / IResistanceData / ISpecialStatusData /
// IOtherEffectData / IEffectSaveData ---

List<FieldSpec> _statusEffectItemFields() => [
  const TextFieldSpec(
    key: 'id',
    label: 'ID de status/condition',
    required: true,
  ),
  PatternTextFieldSpec(
    key: 'duration',
    label: 'Duración',
    pattern: _effectDurationPattern,
    patternHint:
        'next_turn_start_self, next_turn_end_self, next_turn_start_target, '
        'next_turn_end_target, round_start_N, round_end_N',
  ),
  EnumFieldSpec<MechStat>(
    key: 'save',
    label: 'Save (stat)',
    options: MechStat.values,
    displayLabel: (s) => s.name,
  ),
  const ShapeChoiceFieldSpec(
    key: 'aoe',
    label: 'AoE',
    optionALabel: 'Texto',
    optionA: TextFieldSpec(key: 'aoe.a', label: 'AoE (texto)'),
    optionBLabel: 'Sí/No',
    optionB: BoolFieldSpec(key: 'aoe.b', label: 'AoE'),
  ),
  EnumFieldSpec<TargetType>(
    key: 'target',
    label: 'Target',
    options: TargetType.values,
    displayLabel: (t) => t.name,
  ),
];

EffectDuration? _effectDurationFromInput(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  switch (raw) {
    case 'next_turn_start_self':
      return EffectDuration.nextTurnStartSelf;
    case 'next_turn_end_self':
      return EffectDuration.nextTurnEndSelf;
    case 'next_turn_start_target':
      return EffectDuration.nextTurnStartTarget;
    case 'next_turn_end_target':
      return EffectDuration.nextTurnEndTarget;
  }
  final roundStart = RegExp(r'^round_start_(\d+)$').firstMatch(raw);
  if (roundStart != null) {
    return EffectDuration.roundStart(int.parse(roundStart.group(1)!));
  }
  final roundEnd = RegExp(r'^round_end_(\d+)$').firstMatch(raw);
  if (roundEnd != null) {
    return EffectDuration.roundEnd(int.parse(roundEnd.group(1)!));
  }
  return null;
}

IStatusEffectData _statusEffectFromItem(Map<String, dynamic> item) =>
    IStatusEffectData(
      id: item['id'] as String,
      duration: _effectDurationFromInput(item['duration'] as String?),
      save: item['save'] as MechStat?,
      aoe: _stringOrBoolFromItem(item, 'aoe'),
      target: item['target'] as TargetType?,
    );

FieldSpec _resistanceCatalogField() => CatalogFieldSpec<ResistanceKind>(
  key: 'resistance',
  label: 'Tipo',
  catalogIds: ResistanceKind.values,
  idLabel: (k) => k.name,
  valueFieldFor: (k) => switch (k) {
    ResistanceKind.resist => EnumFieldSpec<ResistanceValue>(
      key: 'resistance.value',
      label: 'Resist',
      required: true,
      options: ResistanceValue.values,
      displayLabel: (v) => v.name,
    ),
    ResistanceKind.vulnerability => EnumFieldSpec<ResistanceValue>(
      key: 'resistance.value',
      label: 'Vulnerability',
      required: true,
      options: ResistanceValue.values,
      displayLabel: (v) => v.name,
    ),
    ResistanceKind.immunity => const ShapeChoiceFieldSpec(
      key: 'resistance.value',
      label: 'Immunity',
      required: true,
      optionALabel: 'Valor conocido',
      optionA: EnumFieldSpec<ResistanceValue>(
        key: 'resistance.value.a',
        label: 'Valor',
        options: ResistanceValue.values,
        displayLabel: _resistanceValueLabel,
      ),
      optionBLabel: 'ID de status/condition',
      optionB: TextFieldSpec(key: 'resistance.value.b', label: 'ID'),
    ),
  },
);

String _resistanceValueLabel(ResistanceValue v) => v.name;

List<FieldSpec> _resistanceItemFields() => [
  _resistanceCatalogField(),
  EnumFieldSpec<TargetType>(
    key: 'target',
    label: 'Target',
    options: TargetType.values,
    displayLabel: (t) => t.name,
  ),
];

IResistanceData? _resistanceFromItem(Map<String, dynamic> item) {
  final kind = item['resistance.id'] as ResistanceKind?;
  if (kind == null) return null;
  final target = item['target'] as TargetType?;
  switch (kind) {
    case ResistanceKind.resist:
      final v = item['resistance.value'] as ResistanceValue?;
      return v == null ? null : ResistEffectData(resist: v, target: target);
    case ResistanceKind.vulnerability:
      final v = item['resistance.value'] as ResistanceValue?;
      return v == null
          ? null
          : VulnerabilityEffectData(vulnerability: v, target: target);
    case ResistanceKind.immunity:
      final choice = item['resistance.value.choice'] as String? ?? 'A';
      final ImmunityValue immunity;
      if (choice == 'A') {
        final v = item['resistance.value.a'] as ResistanceValue?;
        if (v == null) return null;
        immunity = ImmunityValue.known(v);
      } else {
        final id = item['resistance.value.b'] as String?;
        if (id == null || id.isEmpty) return null;
        immunity = ImmunityValue.conditionId(id);
      }
      return ImmunityEffectData(immunity: immunity, target: target);
  }
}

List<FieldSpec> _specialStatusItemFields() => [
  const TextFieldSpec(key: 'attribute', label: 'Atributo', required: true),
  const TextFieldSpec(key: 'detail', label: 'Detalle', maxLines: 2),
  EnumFieldSpec<TargetType>(
    key: 'target',
    label: 'Target',
    options: TargetType.values,
    displayLabel: (t) => t.name,
  ),
  PatternTextFieldSpec(
    key: 'duration',
    label: 'Duración',
    pattern: _effectDurationPattern,
    patternHint: 'ej. round_start_1, next_turn_start_self',
  ),
];

ISpecialStatusData _specialStatusFromItem(Map<String, dynamic> item) =>
    ISpecialStatusData(
      attribute: item['attribute'] as String,
      detail: item['detail'] as String?,
      target: item['target'] as TargetType?,
      duration: _effectDurationFromInput(item['duration'] as String?),
    );

FieldSpec _otherEffectCatalogField() => CatalogFieldSpec<OtherEffectKind>(
  key: 'otherEffect',
  label: 'Tipo',
  catalogIds: OtherEffectKind.values,
  idLabel: (k) => k.name,
  valueFieldFor: (k) => switch (k) {
    OtherEffectKind.overshield => _numericOrFormulaField(
      'otherEffect.value',
      'Overshield',
    ),
    OtherEffectKind.hp => _numericOrFormulaField('otherEffect.value', 'HP'),
    OtherEffectKind.repair => _numericOrFormulaField(
      'otherEffect.value',
      'Repair',
    ),
    OtherEffectKind.cover => EnumFieldSpec<CoverLevel>(
      key: 'otherEffect.value',
      label: 'Cover',
      required: true,
      options: CoverLevel.values,
      displayLabel: (c) => c.name,
    ),
  },
);

List<FieldSpec> _otherEffectItemFields() => [
  _otherEffectCatalogField(),
  EnumFieldSpec<TargetType>(
    key: 'target',
    label: 'Target',
    options: TargetType.values,
    displayLabel: (t) => t.name,
  ),
  const ShapeChoiceFieldSpec(
    key: 'aoe',
    label: 'AoE',
    optionALabel: 'Texto',
    optionA: TextFieldSpec(key: 'aoe.a', label: 'AoE (texto)'),
    optionBLabel: 'Sí/No',
    optionB: BoolFieldSpec(key: 'aoe.b', label: 'AoE'),
  ),
];

IOtherEffectData? _otherEffectFromItem(Map<String, dynamic> item) {
  final kind = item['otherEffect.id'] as OtherEffectKind?;
  if (kind == null) return null;
  final target = item['target'] as TargetType?;
  final aoe = _stringOrBoolFromItem(item, 'aoe');
  switch (kind) {
    case OtherEffectKind.overshield:
      final v = _numericOrFormulaFromItem(item, 'otherEffect.value');
      return v == null
          ? null
          : OvershieldEffectData(val: v, target: target, aoe: aoe);
    case OtherEffectKind.hp:
      final v = _numericOrFormulaFromItem(item, 'otherEffect.value');
      return v == null ? null : HpEffectData(val: v, target: target, aoe: aoe);
    case OtherEffectKind.repair:
      final v = _numericOrFormulaFromItem(item, 'otherEffect.value');
      return v == null
          ? null
          : RepairEffectData(val: v, target: target, aoe: aoe);
    case OtherEffectKind.cover:
      final v = item['otherEffect.value'] as CoverLevel?;
      return v == null
          ? null
          : CoverEffectData(val: v, target: target, aoe: aoe);
  }
}

FieldSpec _effectSaveGroupField(String key) => GroupFieldSpec(
  key: key,
  label: 'Save',
  fields: [
    EnumFieldSpec<MechStat>(
      key: 'stat',
      label: 'Stat',
      required: true,
      options: MechStat.values,
      displayLabel: (s) => s.name,
    ),
    const BoolFieldSpec(key: 'aoe', label: 'AoE'),
  ],
);

IEffectSaveData? _effectSaveFromGroup(Map<String, dynamic>? group) {
  final stat = group?['stat'] as MechStat?;
  if (stat == null) return null;
  return IEffectSaveData(stat: stat, aoe: group?['aoe'] as bool?);
}

// --- Sección 3: IActiveEffectData / IActionData ---

List<FieldSpec> _activeEffectFields() => [
  const TextFieldSpec(key: 'name', label: 'Nombre', required: true),
  const TextFieldSpec(
    key: 'detail',
    label: 'Detalle',
    required: true,
    maxLines: 3,
  ),
  const TextFieldSpec(key: 'condition', label: 'Condición'),
  EnumFieldSpec<ActionFrequency>(
    key: 'frequency',
    label: 'Frecuencia',
    options: ActionFrequency.values,
    displayLabel: (f) => f.jsonValue,
  ),
  PatternTextFieldSpec(
    key: 'duration',
    label: 'Duración',
    pattern: _effectDurationPattern,
    patternHint: 'ej. round_start_1, next_turn_start_self',
  ),
  PatternTextFieldSpec(
    key: 'bonusDamage',
    label: 'Daño extra',
    pattern: _diceExpressionPattern,
    patternHint: 'ej. 1d6',
  ),
  ListFieldSpec(key: 'damage', label: 'Daño', itemFields: _damageItemFields()),
  ListFieldSpec(key: 'range', label: 'Alcance', itemFields: _rangeItemFields()),
  ListFieldSpec(
    key: 'addStatus',
    label: 'Añade status/condition',
    itemFields: _statusEffectItemFields(),
  ),
  ListFieldSpec(
    key: 'addResist',
    label: 'Añade resist/vulnerability/immunity',
    itemFields: _resistanceItemFields(),
  ),
  ListFieldSpec(
    key: 'addSpecial',
    label: 'Añade special status',
    itemFields: _specialStatusItemFields(),
  ),
  const ListFieldSpec(
    key: 'removeSpecial',
    label: 'Quita special status',
    itemFields: [TextFieldSpec(key: 'id', label: 'Atributo', required: true)],
  ),
  ListFieldSpec(
    key: 'addOther',
    label: 'Añade otro efecto',
    itemFields: _otherEffectItemFields(),
  ),
  _effectSaveGroupField('save'),
  EnumFieldSpec<AttackType>(
    key: 'attack',
    label: 'Tipo de ataque',
    options: AttackType.values,
    displayLabel: (a) => a.name,
  ),
  const BoolFieldSpec(key: 'pilot', label: 'Pilot'),
  const BoolFieldSpec(key: 'mech', label: 'Mech'),
  const NumberFieldSpec(key: 'accuracy', label: 'Accuracy'),
  const NumberFieldSpec(key: 'attackBonus', label: 'Attack bonus'),
];

IActiveEffectData _activeEffectFromGroup(Map<String, dynamic> item) =>
    IActiveEffectData(
      name: item['name'] as String,
      detail: item['detail'] as String,
      condition: item['condition'] as String?,
      frequency: item['frequency'] as ActionFrequency?,
      duration: _effectDurationFromInput(item['duration'] as String?),
      bonusDamage: (item['bonusDamage'] as String?)?.isNotEmpty == true
          ? _diceExpressionFromInput(item['bonusDamage'] as String)
          : null,
      damage: _mapItems(item['damage'], _damageDataFromItem),
      range: _mapItems(item['range'], _rangeDataFromItem),
      addStatus: _mapItems(item['addStatus'], _statusEffectFromItem),
      addResist: _mapItems(item['addResist'], _resistanceFromItem),
      addSpecial: _mapItems(item['addSpecial'], _specialStatusFromItem),
      removeSpecial: _mapStringItems(item['removeSpecial']),
      addOther: _mapItems(item['addOther'], _otherEffectFromItem),
      save: _effectSaveFromGroup(item['save'] as Map<String, dynamic>?),
      attack: item['attack'] as AttackType?,
      pilot: item['pilot'] as bool?,
      mech: item['mech'] as bool?,
      accuracy: item['accuracy'] as num?,
      attackBonus: item['attackBonus'] as num?,
    );

List<FieldSpec> _actionItemFields() => [
  const TextFieldSpec(key: 'name', label: 'Nombre', required: true),
  EnumFieldSpec<ActivationType>(
    key: 'activation',
    label: 'Activación',
    required: true,
    options: ActivationType.values,
    displayLabel: (a) => a.jsonValue,
  ),
  const TextFieldSpec(
    key: 'detail',
    label: 'Detalle',
    required: true,
    maxLines: 3,
  ),
  EnumFieldSpec<ActionFrequency>(
    key: 'frequency',
    label: 'Frecuencia',
    options: ActionFrequency.values,
    displayLabel: (f) => f.jsonValue,
  ),
  const TextFieldSpec(key: 'trigger', label: 'Trigger (si es Reaction)'),
  const NumberFieldSpec(key: 'cost', label: 'Coste (si es limited)'),
  const BoolFieldSpec(key: 'pilot', label: 'Pilot'),
  const BoolFieldSpec(key: 'mech', label: 'Mech'),
  const BoolFieldSpec(key: 'hideActive', label: 'Ocultar acción activa'),
  PatternTextFieldSpec(
    key: 'bonusDamage',
    label: 'Daño extra',
    pattern: _diceExpressionPattern,
    patternHint: 'ej. 1d6',
  ),
  GroupFieldSpec(key: 'damage', label: 'Daño', fields: _damageItemFields()),
  GroupFieldSpec(key: 'range', label: 'Alcance', fields: _rangeItemFields()),
  ListFieldSpec(
    key: 'addStatus',
    label: 'Añade status/condition',
    itemFields: _statusEffectItemFields(),
  ),
  ListFieldSpec(
    key: 'addResist',
    label: 'Añade resist/vulnerability/immunity',
    itemFields: _resistanceItemFields(),
  ),
  ListFieldSpec(
    key: 'addSpecial',
    label: 'Añade special status',
    itemFields: _specialStatusItemFields(),
  ),
  const ListFieldSpec(
    key: 'removeSpecial',
    label: 'Quita special status',
    itemFields: [TextFieldSpec(key: 'id', label: 'Atributo', required: true)],
  ),
  ListFieldSpec(
    key: 'addOther',
    label: 'Añade otro efecto',
    itemFields: _otherEffectItemFields(),
  ),
  ListFieldSpec(
    key: 'activeEffects',
    label: 'Active effects',
    itemFields: _activeEffectFields(),
  ),
  _effectSaveGroupField('save'),
];

IActionData _actionFromItem(Map<String, dynamic> item) {
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
        ? _diceExpressionFromInput(item['bonusDamage'] as String)
        : null,
    damage: damageGroup == null || damageGroup['type'] == null
        ? null
        : _damageDataFromItem(damageGroup),
    range: rangeGroup == null || rangeGroup['type'] == null
        ? null
        : _rangeDataFromItem(rangeGroup),
    addStatus: _mapItems(item['addStatus'], _statusEffectFromItem),
    addResist: _mapItems(item['addResist'], _resistanceFromItem),
    addSpecial: _mapItems(item['addSpecial'], _specialStatusFromItem),
    removeSpecial: _mapStringItems(item['removeSpecial']),
    addOther: _mapItems(item['addOther'], _otherEffectFromItem),
    activeEffects: _mapItems(item['activeEffects'], _activeEffectFromGroup),
    save: _effectSaveFromGroup(item['save'] as Map<String, dynamic>?),
  );
}

// --- Sección 4: IBonusData (con todos sus filtros, no solo id/val) ---

FieldSpec _bonusCatalogField() => CatalogFieldSpec<BonusId>(
  key: 'bonus',
  label: 'Bonus',
  catalogIds: BonusId.values,
  idLabel: (id) => id.jsonValue,
  valueFieldFor: (id) => switch (id.valueKind) {
    BonusValueKind.numericOrFormula => const ShapeChoiceFieldSpec(
      key: 'bonus.value',
      label: 'Valor',
      required: true,
      optionALabel: 'Número',
      optionA: NumberFieldSpec(
        key: 'bonus.value.a',
        label: 'Número',
        allowDecimal: true,
      ),
      optionBLabel: 'Fórmula',
      optionB: TextFieldSpec(
        key: 'bonus.value.b',
        label: 'Fórmula (ej. {grit}+2)',
      ),
    ),
    BonusValueKind.boolean => const BoolFieldSpec(
      key: 'bonus.value',
      label: 'Activo',
    ),
    BonusValueKind.dieRollList => const TextFieldSpec(
      key: 'bonus.value',
      label: 'Progresión, separada por comas (ej. 1d6, 1d6+1d8, 2d6+1d10)',
    ),
    BonusValueKind.mountAssignment => const TextFieldSpec(
      key: 'bonus.value',
      label: 'mount_type:max_mounts (ej. main:3)',
    ),
    BonusValueKind.unverified => const TextFieldSpec(
      key: 'bonus.value',
      label: 'Valor (sin confirmar, ver vault MdD §4)',
    ),
  },
);

List<FieldSpec> _bonusItemFields() => [
  _bonusCatalogField(),
  const NumberFieldSpec(key: 'accuracy', label: 'Accuracy asociado'),
  MultiEnumFieldSpec<DamageType>(
    key: 'damageTypes',
    label: 'Tipos de daño (vacío = todos)',
    options: DamageType.values,
    displayLabel: (d) => d.jsonValue,
  ),
  MultiEnumFieldSpec<BonusRangeTypeFilter>(
    key: 'rangeTypes',
    label: 'Tipos de alcance (vacío = todos)',
    options: BonusRangeTypeFilter.values,
    displayLabel: (r) => r.jsonValue,
  ),
  MultiEnumFieldSpec<BonusWeaponTypeFilter>(
    key: 'weaponTypes',
    label: 'Tipos de arma (vacío = any)',
    options: BonusWeaponTypeFilter.values,
    displayLabel: (t) => t.jsonValue,
  ),
  MultiEnumFieldSpec<BonusWeaponSizeFilter>(
    key: 'weaponSizes',
    label: 'Tamaños de arma (vacío = any)',
    options: BonusWeaponSizeFilter.values,
    displayLabel: (s) => s.jsonValue,
  ),
  const BoolFieldSpec(key: 'overwrite', label: 'Overwrite'),
  const BoolFieldSpec(key: 'replace', label: 'Replace'),
];

/// Ensambla un `IBonusData` a partir de los valores de un ítem de la lista
/// `bonuses` (ver [_bonusCatalogField]).
IBonusData? _bonusFromItemValues(Map<String, dynamic> item) {
  final bonusId = item['bonus.id'] as BonusId?;
  if (bonusId == null) return null;

  final Object val = switch (bonusId.valueKind) {
    BonusValueKind.numericOrFormula =>
      (item['bonus.value.choice'] as String? ?? 'A') == 'A'
          ? NumericOrFormulaValue.number((item['bonus.value.a'] as num?) ?? 0)
          : NumericOrFormulaValue.formula(
              (item['bonus.value.b'] as String?) ?? '',
            ),
    BonusValueKind.boolean => (item['bonus.value'] as bool?) ?? false,
    // Cada elemento de la lista es ya una cadena DieRoll completa (ej. la
    // progresión de overcharge: "1d6", "1d6+1d8", "2d6+1d10"...) — se
    // separan por comas, no se trocea una sola cadena por sus +/-.
    BonusValueKind.dieRollList =>
      (item['bonus.value'] as String? ?? '')
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .map(DieRoll.new)
          .toList(),
    BonusValueKind.mountAssignment => () {
      final raw = (item['bonus.value'] as String? ?? 'main:1').split(':');
      final type = MountAssignmentType.values.firstWhere(
        (t) => t.jsonValue.toLowerCase() == raw[0].toLowerCase(),
        orElse: () => MountAssignmentType.main,
      );
      return MountAssignment(
        mountType: type,
        maxMounts: int.tryParse(raw.length > 1 ? raw[1] : '1') ?? 1,
      );
    }(),
    BonusValueKind.unverified => item['bonus.value'] as String? ?? '',
  };
  return IBonusData(
    id: bonusId,
    val: val,
    accuracy: item['accuracy'] as num?,
    damageTypes: _emptyToNull(item['damageTypes'] as List?)?.cast<DamageType>(),
    rangeTypes: _emptyToNull(
      item['rangeTypes'] as List?,
    )?.cast<BonusRangeTypeFilter>(),
    weaponTypes: _emptyToNull(
      item['weaponTypes'] as List?,
    )?.cast<BonusWeaponTypeFilter>(),
    weaponSizes: _emptyToNull(
      item['weaponSizes'] as List?,
    )?.cast<BonusWeaponSizeFilter>(),
    overwrite: item['overwrite'] as bool?,
    replace: item['replace'] as bool?,
  );
}

List<T>? _emptyToNull<T>(List<T>? list) =>
    (list == null || list.isEmpty) ? null : list;

// --- Sección 5: ISynergyData ---

/// `locations`: conjunto cerrado (`rest`, `weapon`, ...) más la forma
/// variable `action_<id>` — mismo criterio de proporcionalidad que
/// `DiceExpression`/`MountAssignment`: se valida el patrón con texto libre
/// en vez de construir un selector dedicado para un mecanismo que el
/// propio dominio ya marca como "de último recurso" (vault MdD §5).
final _synergyLocationPattern = RegExp(
  r'^(rest|weapon|system|deployable|drone|move|boost|structure|armor|hp|'
  r'overshield|stress|heat|repair|core_power|overcharge|hull|agility|'
  r'systems|engineering|pilot_weapon|cascade|action_[A-Za-z0-9_]+)$',
);

List<FieldSpec> _synergyItemFields() => [
  ListFieldSpec(
    key: 'locations',
    label: 'Locations (al menos una)',
    itemFields: [
      PatternTextFieldSpec(
        key: 'value',
        label: 'Location',
        required: true,
        pattern: _synergyLocationPattern,
        patternHint:
            'rest, weapon, system, deployable, drone, move, boost, '
            'structure, armor, hp, overshield, stress, heat, repair, '
            'core_power, overcharge, hull, agility, systems, engineering, '
            'pilot_weapon, cascade, o action_<id>',
      ),
    ],
  ),
  const TextFieldSpec(
    key: 'detail',
    label: 'Detalle',
    required: true,
    maxLines: 3,
  ),
  MultiEnumFieldSpec<WeaponType>(
    key: 'weaponTypes',
    label: 'Tipos de arma (vacío = todos)',
    options: WeaponType.values,
    displayLabel: (t) => t.jsonValue,
  ),
  MultiEnumFieldSpec<WeaponSize>(
    key: 'weaponSizes',
    label: 'Tamaños de arma (vacío = todos)',
    options: WeaponSize.values,
    displayLabel: (s) => s.jsonValue,
  ),
  MultiEnumFieldSpec<SystemType>(
    key: 'systemTypes',
    label: 'Tipos de sistema (vacío = todos)',
    options: SystemType.values,
    displayLabel: (s) => s.jsonValue,
  ),
];

ISynergyData? _synergyFromItem(Map<String, dynamic> item) {
  final locationItems =
      (item['locations'] as List<Map<String, dynamic>>?) ?? const [];
  final locations = locationItems
      .map((l) => l['value'] as String?)
      .whereType<String>()
      .map(_synergyLocationFromValue)
      .toList();
  if (locations.isEmpty) return null;
  return ISynergyData(
    locations: locations,
    detail: item['detail'] as String? ?? '',
    weaponTypes: _emptyToNull(item['weaponTypes'] as List?)?.cast<WeaponType>(),
    weaponSizes: _emptyToNull(item['weaponSizes'] as List?)?.cast<WeaponSize>(),
    systemTypes: _emptyToNull(item['systemTypes'] as List?)?.cast<SystemType>(),
  );
}

SynergyLocation _synergyLocationFromValue(String value) {
  const presets = {
    'rest': SynergyLocation.rest,
    'weapon': SynergyLocation.weapon,
    'system': SynergyLocation.system,
    'deployable': SynergyLocation.deployable,
    'drone': SynergyLocation.drone,
    'move': SynergyLocation.move,
    'boost': SynergyLocation.boost,
    'structure': SynergyLocation.structure,
    'armor': SynergyLocation.armor,
    'hp': SynergyLocation.hp,
    'overshield': SynergyLocation.overshield,
    'stress': SynergyLocation.stress,
    'heat': SynergyLocation.heat,
    'repair': SynergyLocation.repair,
    'core_power': SynergyLocation.corePower,
    'overcharge': SynergyLocation.overcharge,
    'hull': SynergyLocation.hull,
    'agility': SynergyLocation.agility,
    'systems': SynergyLocation.systems,
    'engineering': SynergyLocation.engineering,
    'pilot_weapon': SynergyLocation.pilotWeapon,
    'cascade': SynergyLocation.cascade,
  };
  final preset = presets[value];
  if (preset != null) return preset;
  final actionId = RegExp(r'^action_(.+)$').firstMatch(value)?.group(1);
  return SynergyLocation.actionX(actionId ?? value);
}

// --- Sección 8: IDeployableData ---

/// Sin campo `deployables` propio — ver nota de alcance al inicio del
/// archivo (recursión acotada a 1 nivel).
List<FieldSpec> _deployableItemFields() => [
  const TextFieldSpec(key: 'name', label: 'Nombre', required: true),
  const TextFieldSpec(
    key: 'type',
    label: 'Tipo (Drone | Mine | Deployable | personalizado)',
  ),
  const TextFieldSpec(
    key: 'detail',
    label: 'Detalle',
    required: true,
    maxLines: 3,
  ),
  EnumFieldSpec<ActivationType>(
    key: 'activation',
    label: 'Activación',
    options: ActivationType.values,
    displayLabel: (a) => a.jsonValue,
  ),
  EnumFieldSpec<ActivationType>(
    key: 'deactivation',
    label: 'Desactivación',
    options: ActivationType.values,
    displayLabel: (a) => a.jsonValue,
  ),
  EnumFieldSpec<ActivationType>(
    key: 'recall',
    label: 'Recall',
    options: ActivationType.values,
    displayLabel: (a) => a.jsonValue,
  ),
  EnumFieldSpec<ActivationType>(
    key: 'redeploy',
    label: 'Redeploy',
    options: ActivationType.values,
    displayLabel: (a) => a.jsonValue,
  ),
  const NumberFieldSpec(key: 'instances', label: 'Instancias'),
  const NumberFieldSpec(key: 'cost', label: 'Coste (si el padre es limited)'),
  const NumberFieldSpec(key: 'size', label: 'Tamaño', allowDecimal: true),
  const TextFieldSpec(key: 'sizeSpecial', label: 'Tamaño especial'),
  _numericOrFormulaField('armor', 'Armor'),
  _numericOrFormulaField('hp', 'HP'),
  _numericOrFormulaField('evasion', 'Evasion'),
  _numericOrFormulaField('edef', 'E-Defense'),
  _numericOrFormulaField('heatcap', 'Heat cap'),
  _numericOrFormulaField('repcap', 'Repair cap'),
  _numericOrFormulaField('sensorRange', 'Sensor range'),
  _numericOrFormulaField('techAttack', 'Tech attack'),
  _numericOrFormulaField('save', 'Save'),
  _numericOrFormulaField('speed', 'Speed'),
  _numericOrFormulaField('grapple', 'Grapple'),
  _numericOrFormulaField('attackBonus', 'Attack bonus'),
  ListFieldSpec(key: 'damage', label: 'Daño', itemFields: _damageItemFields()),
  ListFieldSpec(key: 'range', label: 'Alcance', itemFields: _rangeItemFields()),
  ListFieldSpec(
    key: 'actions',
    label: 'Actions (mientras esté activo)',
    itemFields: _actionItemFields(),
  ),
  ListFieldSpec(
    key: 'bonuses',
    label: 'Bonuses',
    itemFields: _bonusItemFields(),
  ),
  ListFieldSpec(
    key: 'synergies',
    label: 'Synergies',
    itemFields: _synergyItemFields(),
  ),
  ListFieldSpec(
    key: 'counters',
    label: 'Counters',
    itemFields: _counterItemFields(),
  ),
  ListFieldSpec(
    key: 'activeEffects',
    label: 'Active effects',
    itemFields: _activeEffectFields(),
  ),
  ListFieldSpec(
    key: 'addStatus',
    label: 'Añade status/condition',
    itemFields: _statusEffectItemFields(),
  ),
  ListFieldSpec(
    key: 'addSpecial',
    label: 'Añade special status',
    itemFields: _specialStatusItemFields(),
  ),
  const ListFieldSpec(
    key: 'removeSpecial',
    label: 'Quita special status',
    itemFields: [TextFieldSpec(key: 'id', label: 'Atributo', required: true)],
  ),
  ListFieldSpec(
    key: 'addOther',
    label: 'Añade otro efecto',
    itemFields: _otherEffectItemFields(),
  ),
  ListFieldSpec(
    key: 'addResist',
    label: 'Añade resist/vulnerability/immunity',
    itemFields: _resistanceItemFields(),
  ),
  const ListFieldSpec(
    key: 'tags',
    label: 'Tags',
    itemFields: [TextFieldSpec(key: 'id', label: 'ID del tag', required: true)],
  ),
  const BoolFieldSpec(
    key: 'pilot',
    label: 'Pilot (default true si el padre es Pilot Equipment)',
  ),
  const BoolFieldSpec(key: 'mech', label: 'Mech'),
];

DeployableType? _deployableTypeFromInput(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  switch (raw) {
    case 'Drone':
      return DeployableType.drone;
    case 'Mine':
      return DeployableType.mine;
    case 'Deployable':
      return DeployableType.deployable;
    default:
      return DeployableType.custom(raw);
  }
}

IDeployableData _deployableFromItem(Map<String, dynamic> item) =>
    IDeployableData(
      name: item['name'] as String,
      type: _deployableTypeFromInput(item['type'] as String?),
      detail: item['detail'] as String,
      activation: item['activation'] as ActivationType?,
      deactivation: item['deactivation'] as ActivationType?,
      recall: item['recall'] as ActivationType?,
      redeploy: item['redeploy'] as ActivationType?,
      instances: (item['instances'] as num?)?.toInt(),
      cost: (item['cost'] as num?)?.toInt(),
      size: item['size'] as num?,
      sizeSpecial: item['sizeSpecial'] as String?,
      armor: _numericOrFormulaFromItem(item, 'armor'),
      hp: _numericOrFormulaFromItem(item, 'hp'),
      evasion: _numericOrFormulaFromItem(item, 'evasion'),
      edef: _numericOrFormulaFromItem(item, 'edef'),
      heatcap: _numericOrFormulaFromItem(item, 'heatcap'),
      repcap: _numericOrFormulaFromItem(item, 'repcap'),
      sensorRange: _numericOrFormulaFromItem(item, 'sensorRange'),
      techAttack: _numericOrFormulaFromItem(item, 'techAttack'),
      save: _numericOrFormulaFromItem(item, 'save'),
      speed: _numericOrFormulaFromItem(item, 'speed'),
      grapple: _numericOrFormulaFromItem(item, 'grapple'),
      attackBonus: _numericOrFormulaFromItem(item, 'attackBonus'),
      damage: _mapItems(item['damage'], _damageDataFromItem),
      range: _mapItems(item['range'], _rangeDataFromItem),
      actions: _mapItems(item['actions'], _actionFromItem),
      bonuses: _mapItems(item['bonuses'], _bonusFromItemValues),
      synergies: _mapItems(item['synergies'], _synergyFromItem),
      counters: _mapItems(item['counters'], _counterFromItem),
      activeEffects: _mapItems(item['activeEffects'], _activeEffectFromGroup),
      addStatus: _mapItems(item['addStatus'], _statusEffectFromItem),
      addSpecial: _mapItems(item['addSpecial'], _specialStatusFromItem),
      removeSpecial: _mapStringItems(item['removeSpecial']),
      addOther: _mapItems(item['addOther'], _otherEffectFromItem),
      addResist: _mapItems(item['addResist'], _resistanceFromItem),
      tags: _mapItems(item['tags'], _tagFromItem),
      pilot: item['pilot'] as bool?,
      mech: item['mech'] as bool?,
    );

// --- Sección 9: IAmmoData ---

List<FieldSpec> _ammoItemFields() => [
  const TextFieldSpec(key: 'name', label: 'Nombre', required: true),
  const TextFieldSpec(
    key: 'description',
    label: 'Descripción',
    required: true,
    maxLines: 2,
  ),
  const NumberFieldSpec(key: 'cost', label: 'Coste'),
  MultiEnumFieldSpec<WeaponType>(
    key: 'allowedTypes',
    label: 'Tipos permitidos (vacío = todos)',
    options: WeaponType.values,
    displayLabel: (t) => t.jsonValue,
  ),
  MultiEnumFieldSpec<WeaponSize>(
    key: 'allowedSizes',
    label: 'Tamaños permitidos (vacío = todos)',
    options: WeaponSize.values,
    displayLabel: (s) => s.jsonValue,
  ),
  MultiEnumFieldSpec<WeaponType>(
    key: 'restrictedTypes',
    label: 'Tipos restringidos',
    options: WeaponType.values,
    displayLabel: (t) => t.jsonValue,
  ),
  MultiEnumFieldSpec<WeaponSize>(
    key: 'restrictedSizes',
    label: 'Tamaños restringidos',
    options: WeaponSize.values,
    displayLabel: (s) => s.jsonValue,
  ),
];

IAmmoData _ammoFromItem(Map<String, dynamic> item) => IAmmoData(
  name: item['name'] as String,
  description: item['description'] as String,
  cost: (item['cost'] as num?)?.toInt(),
  allowedTypes: _emptyToNull(item['allowedTypes'] as List?)?.cast<WeaponType>(),
  allowedSizes: _emptyToNull(item['allowedSizes'] as List?)?.cast<WeaponSize>(),
  restrictedTypes: _emptyToNull(
    item['restrictedTypes'] as List?,
  )?.cast<WeaponType>(),
  restrictedSizes: _emptyToNull(
    item['restrictedSizes'] as List?,
  )?.cast<WeaponSize>(),
);

// --- Sección 7: ICounterData ---

List<FieldSpec> _counterItemFields() => [
  const TextFieldSpec(key: 'id', label: 'ID', required: true),
  const TextFieldSpec(key: 'name', label: 'Nombre', required: true),
  const NumberFieldSpec(key: 'defaultValue', label: 'Valor por defecto'),
  const NumberFieldSpec(key: 'min', label: 'Mínimo'),
  const NumberFieldSpec(key: 'max', label: 'Máximo'),
];

ICounterData _counterFromItem(Map<String, dynamic> item) => ICounterData(
  id: item['id'] as String,
  name: item['name'] as String,
  defaultValue: item['defaultValue'] as num?,
  min: item['min'] as num?,
  max: item['max'] as num?,
);

// --- Sección 6: ITagInstance ---

ITagInstance _tagFromItem(Map<String, dynamic> item) =>
    ITagInstance(id: item['id'] as String);

// --- Sección 3: TextOrActiveEffect ---

FieldSpec _textOrActiveEffectField(String key, String label) =>
    ShapeChoiceFieldSpec(
      key: key,
      label: label,
      optionALabel: 'Texto',
      optionA: TextFieldSpec(key: '$key.a', label: '$label (texto)'),
      optionBLabel: 'Active effect',
      optionB: GroupFieldSpec(
        key: '$key.b',
        label: '$label (active effect)',
        fields: _activeEffectFields(),
      ),
    );

TextOrActiveEffect? _textOrActiveEffectFromItem(
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
  return TextOrActiveEffect.effect(_activeEffectFromGroup(group));
}

// --- Sección 13.3: IWeaponProfile / IWeaponData ---

/// Campos compartidos entre `IWeaponData` (nivel superior) y cada ítem de
/// `profiles` (`IWeaponProfile`) — ambos tipos del dominio repiten
/// literalmente estos campos (mismo nombre, mismo tipo). Se reutiliza la
/// misma lista de [FieldSpec] en ambos puntos: las keys son relativas al
/// [_FieldContext] activo (controlador global vs. mapa del ítem de
/// `profiles`), así que no colisionan.
List<FieldSpec> _weaponEffectFields() => [
  ListFieldSpec(
    key: 'activeEffects',
    label: 'Active effects',
    itemFields: _activeEffectFields(),
  ),
  ListFieldSpec(key: 'damage', label: 'Daño', itemFields: _damageItemFields()),
  ListFieldSpec(key: 'range', label: 'Alcance', itemFields: _rangeItemFields()),
  ListFieldSpec(
    key: 'actions',
    label: 'Actions',
    itemFields: _actionItemFields(),
  ),
  ListFieldSpec(
    key: 'bonuses',
    label: 'Bonuses',
    itemFields: _bonusItemFields(),
  ),
  ListFieldSpec(
    key: 'synergies',
    label: 'Synergies',
    itemFields: _synergyItemFields(),
  ),
  ListFieldSpec(
    key: 'deployables',
    label: 'Deployables',
    itemFields: _deployableItemFields(),
  ),
  ListFieldSpec(
    key: 'counters',
    label: 'Counters',
    itemFields: _counterItemFields(),
  ),
  const ListFieldSpec(
    key: 'integrated',
    label: 'Integrated (IDs)',
    itemFields: [TextFieldSpec(key: 'id', label: 'ID', required: true)],
  ),
  const ListFieldSpec(
    key: 'specialEquipment',
    label: 'Special equipment (IDs)',
    itemFields: [TextFieldSpec(key: 'id', label: 'ID', required: true)],
  ),
  _textOrActiveEffectField('onAttack', 'Al atacar'),
  _textOrActiveEffectField('onHit', 'Al acertar'),
  _textOrActiveEffectField('onCrit', 'Al crítico'),
  _textOrActiveEffectField('onMiss', 'Al fallar'),
  const BoolFieldSpec(key: 'skirmish', label: 'Skirmish'),
  const BoolFieldSpec(key: 'barrage', label: 'Barrage'),
  const NumberFieldSpec(key: 'cost', label: 'Coste (si tiene tag limited)'),
];

List<FieldSpec> _profileItemFields() => [
  const TextFieldSpec(key: 'name', label: 'Nombre', required: true),
  _textOrActiveEffectField('effect', 'Efecto'),
  ..._weaponEffectFields(),
];

IWeaponProfile _profileFromItem(Map<String, dynamic> item) => IWeaponProfile(
  name: item['name'] as String,
  effect: _textOrActiveEffectFromItem(item, 'effect'),
  skirmish: item['skirmish'] as bool?,
  barrage: item['barrage'] as bool?,
  cost: (item['cost'] as num?)?.toInt(),
  onAttack: _textOrActiveEffectFromItem(item, 'onAttack'),
  onHit: _textOrActiveEffectFromItem(item, 'onHit'),
  onCrit: _textOrActiveEffectFromItem(item, 'onCrit'),
  onMiss: _textOrActiveEffectFromItem(item, 'onMiss'),
  activeEffects: _mapItems(item['activeEffects'], _activeEffectFromGroup),
  damage: _mapItems(item['damage'], _damageDataFromItem),
  range: _mapItems(item['range'], _rangeDataFromItem),
  actions: _mapItems(item['actions'], _actionFromItem),
  bonuses: _mapItems(item['bonuses'], _bonusFromItemValues),
  synergies: _mapItems(item['synergies'], _synergyFromItem),
  deployables: _mapItems(item['deployables'], _deployableFromItem),
  counters: _mapItems(item['counters'], _counterFromItem),
  integrated: _mapStringIdItems(item['integrated']),
  specialEquipment: _mapStringIdItems(item['specialEquipment']),
);

/// `type`: `WeaponType | List<WeaponType>` — elección entre un único tipo
/// (lo habitual) o varios (armas que pertenecen a más de un `WeaponType`).
const _weaponTypeField = ShapeChoiceFieldSpec(
  key: 'type',
  label: 'Tipo de arma',
  required: true,
  optionALabel: 'Único',
  optionA: EnumFieldSpec<WeaponType>(
    key: 'type.a',
    label: 'Tipo',
    options: WeaponType.values,
    displayLabel: _weaponTypeLabel,
  ),
  optionBLabel: 'Varios',
  optionB: MultiEnumFieldSpec<WeaponType>(
    key: 'type.b',
    label: 'Tipos',
    options: WeaponType.values,
    displayLabel: _weaponTypeLabel,
  ),
);

String _weaponTypeLabel(WeaponType t) => t.jsonValue;

Object _weaponTypeFromValues(Map<String, dynamic> values) {
  final choice = values['type.choice'] as String? ?? 'A';
  if (choice == 'A') {
    return (values['type.a'] as WeaponType?) ?? WeaponType.rifle;
  }
  final list = (values['type.b'] as List?)?.cast<WeaponType>() ?? const [];
  return list.isEmpty ? WeaponType.rifle : list;
}

List<FieldSpec> buildWeaponFormSchema() => [
  const TextFieldSpec(key: 'id', label: 'ID', required: true),
  const TextFieldSpec(key: 'name', label: 'Nombre', required: true),
  const TextFieldSpec(
    key: 'source',
    label: 'Fabricante (source)',
    required: true,
  ),
  const TextFieldSpec(
    key: 'license',
    label: 'Licencia (nombre de display)',
    required: true,
  ),
  const TextFieldSpec(
    key: 'licenseId',
    label: 'ID de la licencia (frame)',
    required: true,
  ),
  const NumberFieldSpec(
    key: 'licenseLevel',
    label: 'Nivel de licencia (0-3)',
    required: true,
  ),
  const TextFieldSpec(
    key: 'effect',
    label: 'Efecto',
    required: true,
    maxLines: 3,
  ),
  const TextFieldSpec(
    key: 'description',
    label: 'Descripción',
    required: true,
    maxLines: 3,
  ),
  const NumberFieldSpec(key: 'sp', label: 'SP'),
  EnumFieldSpec<MountType>(
    key: 'mount',
    label: 'Mount',
    required: true,
    options: MountType.values,
    displayLabel: (m) => m.jsonValue,
  ),
  _weaponTypeField,
  ListFieldSpec(key: 'ammo', label: 'Ammo', itemFields: _ammoItemFields()),
  const ListFieldSpec(
    key: 'tags',
    label: 'Tags',
    itemFields: [
      TextFieldSpec(
        key: 'id',
        label: 'ID del tag (ej. tg_accurate)',
        required: true,
      ),
    ],
  ),
  const BoolFieldSpec(key: 'noAttack', label: 'No genera acciones de ataque'),
  const BoolFieldSpec(key: 'noMods', label: 'No admite mods'),
  const BoolFieldSpec(
    key: 'noCoreBonus',
    label: 'Ignora core bonuses de mount',
  ),
  const BoolFieldSpec(key: 'noBonus', label: 'Ignora bonuses'),
  const BoolFieldSpec(key: 'noSynergy', label: 'Ignora synergies'),
  ..._weaponEffectFields(),
  ListFieldSpec(
    key: 'profiles',
    label: 'Profiles',
    itemFields: _profileItemFields(),
  ),
];

List<T>? _mapItems<T>(
  dynamic rawItems,
  T? Function(Map<String, dynamic>) fromItem,
) {
  final items = (rawItems as List<Map<String, dynamic>>?) ?? const [];
  if (items.isEmpty) return null;
  final mapped = items.map(fromItem).whereType<T>().toList();
  return mapped.isEmpty ? null : mapped;
}

List<String>? _mapStringItems(dynamic rawItems) {
  final items = (rawItems as List<String>?) ?? const [];
  return items.isEmpty ? null : items;
}

List<String>? _mapStringIdItems(dynamic rawItems) {
  final items = (rawItems as List<Map<String, dynamic>>?) ?? const [];
  if (items.isEmpty) return null;
  final ids = items.map((i) => i['id'] as String?).whereType<String>().toList();
  return ids.isEmpty ? null : ids;
}

/// Ensambla los valores crudos del formulario en un [IWeaponData] real.
/// Este paso es intrínsecamente específico de la entidad — el motor
/// genérico no puede (ni debe) saber cómo construir un `IWeaponData`.
IWeaponData weaponFromFormValues(Map<String, dynamic> values) {
  return IWeaponData(
    id: values['id'] as String,
    name: values['name'] as String,
    source: values['source'] as String,
    license: values['license'] as String,
    licenseId: values['licenseId'] as String,
    licenseLevel: (values['licenseLevel'] as num?)?.toInt() ?? 0,
    effect: values['effect'] as String,
    description: values['description'] as String,
    mount: values['mount'] as MountType,
    type: _weaponTypeFromValues(values),
    ammo: _mapItems(values['ammo'], _ammoFromItem),
    cost: (values['cost'] as num?)?.toInt(),
    barrage: values['barrage'] as bool?,
    skirmish: values['skirmish'] as bool?,
    noAttack: values['noAttack'] as bool?,
    noMods: values['noMods'] as bool?,
    noCoreBonus: values['noCoreBonus'] as bool?,
    damage: _mapItems(values['damage'], _damageDataFromItem),
    range: _mapItems(values['range'], _rangeDataFromItem),
    tags: _mapItems(values['tags'], _tagFromItem),
    sp: (values['sp'] as num?)?.toInt(),
    onAttack: _textOrActiveEffectFromItem(values, 'onAttack'),
    onHit: _textOrActiveEffectFromItem(values, 'onHit'),
    onCrit: _textOrActiveEffectFromItem(values, 'onCrit'),
    onMiss: _textOrActiveEffectFromItem(values, 'onMiss'),
    activeEffects: _mapItems(values['activeEffects'], _activeEffectFromGroup),
    actions: _mapItems(values['actions'], _actionFromItem),
    bonuses: _mapItems(values['bonuses'], _bonusFromItemValues),
    noBonus: values['noBonus'] as bool?,
    synergies: _mapItems(values['synergies'], _synergyFromItem),
    noSynergy: values['noSynergy'] as bool?,
    deployables: _mapItems(values['deployables'], _deployableFromItem),
    counters: _mapItems(values['counters'], _counterFromItem),
    integrated: _mapStringIdItems(values['integrated']),
    specialEquipment: _mapStringIdItems(values['specialEquipment']),
    profiles: _mapItems(values['profiles'], _profileFromItem),
  );
}

final weaponCrearConfig = EntityCrearConfig(
  title: 'Crear arma',
  contentKey: 'weapons',
  buildSchema: buildWeaponFormSchema,
  fromFormValues: weaponFromFormValues,
  idOf: (content) => (content as IWeaponData).id,
  nameOf: (content) => (content as IWeaponData).name,
);
