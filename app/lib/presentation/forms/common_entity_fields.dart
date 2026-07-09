import '../../domain/domain.dart';
import 'field_spec.dart';

/// Piezas de esquema/ensamblador reutilizadas por varias entidades (no
/// solo arma): tipos compartidos del dominio como `IActionData`,
/// `IBonusData`, `ISynergyData`, `IDeployableData`, `ICounterData`,
/// `IActiveEffectData`, y sus propios anidados (`IDamageData`,
/// `IRangeData`, `IStatusEffectData`, `IResistanceData`,
/// `ISpecialStatusData`, `IOtherEffectData`, `IEffectSaveData`).
///
/// Extraído de `weapon_form_schema.dart` cuando se completaron Reserve/
/// CoreBonus/Talent, que repiten literalmente el mismo "paquete" de
/// actions/bonuses/synergies/deployables/counters/activeEffects que ya
/// existía para arma — ver "Principios y decisiones clave" en el vault.
final diceExpressionPattern = RegExp(r'^[0-9dD+\-*/(){}A-Za-z_ ]+$');
final effectDurationPattern = RegExp(
  r'^(next_turn_(start|end)_(self|target)|round_(start|end)_\d+)$',
);

// --- Catálogos de UI locales (uniones cerradas discriminadas, no un
// catálogo externo grande como BonusId — mismo mecanismo, menos entradas).
// Públicos para poder construirlos directamente en tests, igual que se
// hace con BonusId. ---

enum ResistanceKind { resist, vulnerability, immunity }

enum OtherEffectKind { overshield, hp, repair, cover }

/// `num | NumericOrFormulaValue` — patrón repetido en `IDeployableData`
/// (armor/hp/evasion/edef/heatcap/repcap/sensorRange/techAttack/save/speed/
/// grapple/attackBonus). Se resuelve siempre como `NumericOrFormulaValue`
/// (miembro válido de la unión) para no añadir un tercer camino de
/// ensamblado — mismo mecanismo ya usado en `IBonusData.val` con
/// `numericOrFormula`.
/// [jsonKey]: la clave real del `.lcp`, si difiere de [key] (ej.
/// `otherEffect.value` en el formulario, `val` en el JSON — ver
/// `otherEffectCatalogField`). Por defecto igual a [key], como en
/// [FieldSpec.jsonKey].
FieldSpec numericOrFormulaField(String key, String label, {String? jsonKey}) {
  final realKey = jsonKey ?? key;
  return ShapeChoiceFieldSpec(
    key: key,
    jsonKey: realKey,
    label: label,
    // El propio valor crudo ya dice qué rama es: un número o un string.
    branchFromJson: (json) {
      final raw = json[realKey];
      if (raw is num) return 'A';
      if (raw is String) return 'B';
      return null;
    },
    options: [
      ShapeChoiceOption(
        value: 'A',
        label: 'Número',
        field: NumberFieldSpec(
          key: '$key.a',
          jsonKey: realKey,
          label: label,
          allowDecimal: true,
        ),
      ),
      ShapeChoiceOption(
        value: 'B',
        label: 'Fórmula',
        field: TextFieldSpec(
          key: '$key.b',
          jsonKey: realKey,
          label: 'Fórmula (ej. {grit}+2)',
          helpText:
              'Fórmula en vez de número fijo — usa llaves para referirte a '
              'un stat del piloto/mech, ej. "{grit}+2" o "{level}".',
        ),
      ),
    ],
  );
}

NumericOrFormulaValue? numericOrFormulaFromItem(
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
FieldSpec damageSaveField() => const ShapeChoiceFieldSpec(
  key: 'save',
  label: 'Save',
  branchFromJson: _damageSaveBranchFromJson,
  options: [
    ShapeChoiceOption(
      value: 'A',
      label: 'Texto',
      field: TextFieldSpec(
        key: 'save.a',
        jsonKey: 'save',
        label: 'Save (texto libre)',
        helpText:
            'Texto de reglas tal cual aparece en la tarjeta, ej. "On a hit, '
            'target must succeed a HULL save or take 5 heat."',
      ),
    ),
    ShapeChoiceOption(
      value: 'B',
      label: 'Estructurado',
      field: GroupFieldSpec(
        key: 'save.b',
        jsonKey: 'save',
        label: 'Save estructurado',
        fields: [
          TextFieldSpec(
            key: 'stat',
            label: 'Stat',
            required: true,
            helpText:
                'El stat contra el que tira el objetivo, en minúsculas '
                '(ej. "hull", "agility", "systems", "engineering").',
          ),
          BoolFieldSpec(key: 'aoe', label: 'AoE'),
        ],
      ),
    ),
  ],
);

/// `save` es un string suelto o un objeto `{stat, aoe}` — la forma del
/// propio valor ya dice qué rama es.
String? _damageSaveBranchFromJson(Map<String, dynamic> json) {
  final raw = json['save'];
  if (raw is String) return 'A';
  if (raw is Map) return 'B';
  return null;
}

Object? damageSaveFromItem(Map<String, dynamic> item) {
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

/// `StringOrBool` para `aoe` — repetido literalmente en `IDamageData`,
/// `IStatusEffectData` e `IOtherEffectData` (y también en `INpcDamageData`,
/// que restringe `damage` pero no `aoe`), de ahí la extracción.
FieldSpec aoeField() => const ShapeChoiceFieldSpec(
  key: 'aoe',
  label: 'AoE',
  branchFromJson: _aoeBranchFromJson,
  options: [
    ShapeChoiceOption(
      value: 'A',
      label: 'Texto',
      field: TextFieldSpec(
        key: 'aoe.a',
        jsonKey: 'aoe',
        label: 'AoE (texto)',
        helpText:
            'Forma del área de efecto, como aparece en la tarjeta — ej. '
            '"3-cone", "1-line", "burst 1".',
      ),
    ),
    ShapeChoiceOption(
      value: 'B',
      label: 'Sí/No',
      field: BoolFieldSpec(key: 'aoe.b', jsonKey: 'aoe', label: 'AoE'),
    ),
  ],
);

/// `aoe` es un string o un bool directamente (`stringOrBoolToJson`) — la
/// forma del propio valor ya dice qué rama es.
String? _aoeBranchFromJson(Map<String, dynamic> json) {
  final raw = json['aoe'];
  if (raw is String) return 'A';
  if (raw is bool) return 'B';
  return null;
}

List<FieldSpec> damageItemFields() => [
  EnumFieldSpec<DamageType>(
    key: 'type',
    label: 'Tipo de daño',
    required: true,
    options: DamageType.values,
    displayLabel: (d) => d.jsonValue,
    fromJsonValue: (s) => DamageType.values.firstWhere((d) => d.jsonValue == s),
  ),
  PatternTextFieldSpec(
    key: 'val',
    label: 'Valor (número o dados)',
    required: true,
    pattern: diceExpressionPattern,
    patternHint: 'ej. 2d6, 10, 1d6+{grit}',
  ),
  aoeField(),
  damageSaveField(),
  const BoolFieldSpec(
    key: 'saveHalf',
    jsonKey: 'save_half',
    label: 'Mitad de daño con save',
  ),
  const BoolFieldSpec(key: 'ap', label: 'AP (ignora armadura)'),
  EnumFieldSpec<TargetType>(
    key: 'target',
    label: 'Target',
    options: TargetType.values,
    displayLabel: (t) => t.name,
    fromJsonValue: (s) => TargetType.values.byName(s),
  ),
];

StringOrBool? stringOrBoolFromItem(Map<String, dynamic> item, String key) {
  final choice = item['$key.choice'] as String? ?? 'A';
  if (choice == 'A') {
    final text = item['$key.a'] as String?;
    return (text == null || text.isEmpty) ? null : StringOrBool.text(text);
  }
  final flag = item['$key.b'] as bool?;
  return flag == null ? null : StringOrBool.flag(flag);
}

IDamageData damageDataFromItem(Map<String, dynamic> item) => IDamageData(
  type: item['type'] as DamageType,
  val: diceExpressionFromInput(item['val'] as String? ?? '0'),
  aoe: stringOrBoolFromItem(item, 'aoe'),
  save: damageSaveFromItem(item),
  saveHalf: item['saveHalf'] as bool?,
  ap: item['ap'] as bool?,
  target: item['target'] as TargetType?,
);

List<FieldSpec> rangeItemFields() => [
  EnumFieldSpec<RangeType>(
    key: 'type',
    label: 'Tipo de alcance',
    required: true,
    options: RangeType.values,
    displayLabel: (r) => r.jsonValue,
    fromJsonValue: (s) => RangeType.values.firstWhere((r) => r.jsonValue == s),
  ),
  PatternTextFieldSpec(
    key: 'val',
    label: 'Valor',
    required: true,
    pattern: diceExpressionPattern,
    patternHint: 'ej. 10, 1d6',
  ),
  PatternTextFieldSpec(
    key: 'min',
    label: 'Mínimo (opcional)',
    pattern: diceExpressionPattern,
    patternHint: 'ej. 5',
  ),
];

IRangeData rangeDataFromItem(Map<String, dynamic> item) => IRangeData(
  type: item['type'] as RangeType,
  val: diceExpressionFromInput(item['val'] as String? ?? '0'),
  min: (item['min'] as String?)?.isNotEmpty == true
      ? diceExpressionFromInput(item['min'] as String)
      : null,
);

DiceExpression diceExpressionFromInput(String raw) {
  final n = num.tryParse(raw);
  return n != null ? DiceExpression.number(n) : DiceExpression.formula(raw);
}

// --- Sección 2: IStatusEffectData / IResistanceData / ISpecialStatusData /
// IOtherEffectData / IEffectSaveData ---

List<FieldSpec> statusEffectItemFields() => [
  const TextFieldSpec(
    key: 'id',
    label: 'ID de status/condition',
    required: true,
    helpText:
        'El ID del status o condition (ej. "immobilized", "stunned"), no su '
        'nombre visible. Si todavía no existe, créalo primero desde "Crear '
        'status/condition" en el menú.',
  ),
  PatternTextFieldSpec(
    key: 'duration',
    label: 'Duración',
    pattern: effectDurationPattern,
    patternHint:
        'next_turn_start_self, next_turn_end_self, next_turn_start_target, '
        'next_turn_end_target, round_start_N, round_end_N',
  ),
  EnumFieldSpec<MechStat>(
    key: 'save',
    label: 'Save (stat)',
    options: MechStat.values,
    displayLabel: (s) => s.name,
    fromJsonValue: (s) => MechStat.values.byName(s),
  ),
  aoeField(),
  EnumFieldSpec<TargetType>(
    key: 'target',
    label: 'Target',
    options: TargetType.values,
    displayLabel: (t) => t.name,
    fromJsonValue: (s) => TargetType.values.byName(s),
  ),
];

EffectDuration? effectDurationFromInput(String? raw) {
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

IStatusEffectData statusEffectFromItem(Map<String, dynamic> item) =>
    IStatusEffectData(
      id: item['id'] as String,
      duration: effectDurationFromInput(item['duration'] as String?),
      save: item['save'] as MechStat?,
      aoe: stringOrBoolFromItem(item, 'aoe'),
      target: item['target'] as TargetType?,
    );

FieldSpec resistanceCatalogField() => CatalogFieldSpec<ResistanceKind>(
  key: 'resistance',
  label: 'Tipo',
  catalogIds: ResistanceKind.values,
  idLabel: (k) => k.name,
  // El JSON no envuelve nada bajo una clave `resistance` — el id del
  // catálogo es directamente la clave presente (`resist`/`vulnerability`/
  // `immunity`, ver `resistanceDataToJson`), no un campo `id` aparte.
  idFromJson: (json) {
    for (final kind in ResistanceKind.values) {
      if (json.containsKey(kind.name)) return kind;
    }
    return null;
  },
  valueFieldFor: (k) => switch (k) {
    ResistanceKind.resist => EnumFieldSpec<ResistanceValue>(
      key: 'resistance.value',
      jsonKey: 'resist',
      label: 'Resist',
      required: true,
      options: ResistanceValue.values,
      displayLabel: (v) => v.name,
      fromJsonValue: (s) => ResistanceValue.values.byName(s),
    ),
    ResistanceKind.vulnerability => EnumFieldSpec<ResistanceValue>(
      key: 'resistance.value',
      jsonKey: 'vulnerability',
      label: 'Vulnerability',
      required: true,
      options: ResistanceValue.values,
      displayLabel: (v) => v.name,
      fromJsonValue: (s) => ResistanceValue.values.byName(s),
    ),
    ResistanceKind.immunity => const ShapeChoiceFieldSpec(
      key: 'resistance.value',
      jsonKey: 'immunity',
      label: 'Immunity',
      required: true,
      branchFromJson: _immunityBranchFromJson,
      options: [
        ShapeChoiceOption(
          value: 'A',
          label: 'Valor conocido',
          field: EnumFieldSpec<ResistanceValue>(
            key: 'resistance.value.a',
            jsonKey: 'immunity',
            label: 'Valor',
            options: ResistanceValue.values,
            displayLabel: resistanceValueLabel,
            fromJsonValue: resistanceValueFromJson,
          ),
        ),
        ShapeChoiceOption(
          value: 'B',
          label: 'ID de status/condition',
          field: TextFieldSpec(
            key: 'resistance.value.b',
            jsonKey: 'immunity',
            label: 'ID',
            helpText:
                'El ID del status/condition al que es inmune, no su nombre.',
          ),
        ),
      ],
    ),
  },
);

String resistanceValueLabel(ResistanceValue v) => v.name;

ResistanceValue resistanceValueFromJson(String v) => ResistanceValue.values.byName(v);

/// `immunity` es el nombre de un `ResistanceValue` conocido o un id de
/// status/condition arbitrario — ambos son strings, así que a diferencia
/// de `aoe`/`save` la forma no basta: hay que comprobar si el valor
/// coincide con uno de los nombres conocidos (ver `immunityValueToJson`).
String? _immunityBranchFromJson(Map<String, dynamic> json) {
  final raw = json['immunity'] as String?;
  if (raw == null) return null;
  return ResistanceValue.values.asNameMap().containsKey(raw) ? 'A' : 'B';
}

List<FieldSpec> resistanceItemFields() => [
  resistanceCatalogField(),
  EnumFieldSpec<TargetType>(
    key: 'target',
    label: 'Target',
    options: TargetType.values,
    displayLabel: (t) => t.name,
    fromJsonValue: (s) => TargetType.values.byName(s),
  ),
];

IResistanceData? resistanceFromItem(Map<String, dynamic> item) {
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

List<FieldSpec> specialStatusItemFields() => [
  const TextFieldSpec(
    key: 'attribute',
    label: 'Atributo',
    required: true,
    helpText:
        'Nombre corto del efecto especial que no encaja en las categorías '
        'normales de resist/vulnerability/immunity, ej. "Shredded".',
  ),
  const TextFieldSpec(
    key: 'detail',
    label: 'Detalle',
    maxLines: 2,
    helpText:
        'Texto de reglas de ese efecto especial, si hace falta explicarlo.',
  ),
  EnumFieldSpec<TargetType>(
    key: 'target',
    label: 'Target',
    options: TargetType.values,
    displayLabel: (t) => t.name,
    fromJsonValue: (s) => TargetType.values.byName(s),
  ),
  PatternTextFieldSpec(
    key: 'duration',
    label: 'Duración',
    pattern: effectDurationPattern,
    patternHint: 'ej. round_start_1, next_turn_start_self',
  ),
];

ISpecialStatusData specialStatusFromItem(Map<String, dynamic> item) =>
    ISpecialStatusData(
      attribute: item['attribute'] as String,
      detail: item['detail'] as String?,
      target: item['target'] as TargetType?,
      duration: effectDurationFromInput(item['duration'] as String?),
    );

FieldSpec otherEffectCatalogField() => CatalogFieldSpec<OtherEffectKind>(
  key: 'otherEffect',
  label: 'Tipo',
  catalogIds: OtherEffectKind.values,
  idLabel: (k) => k.name,
  // El JSON no envuelve nada bajo una clave `otherEffect` — es un objeto
  // plano con `type`/`val`/`target`/`aoe` como hermanos (ver
  // `otherEffectDataToJson`), así que el id del catálogo se lee del campo
  // `type`, no de una clave con el nombre del catálogo.
  idFromJson: (json) {
    final type = json['type'] as String?;
    if (type == null) return null;
    return OtherEffectKind.values.asNameMap()[type];
  },
  valueFieldFor: (k) => switch (k) {
    OtherEffectKind.overshield => numericOrFormulaField(
      'otherEffect.value',
      'Overshield',
      jsonKey: 'val',
    ),
    OtherEffectKind.hp => numericOrFormulaField(
      'otherEffect.value',
      'HP',
      jsonKey: 'val',
    ),
    OtherEffectKind.repair => numericOrFormulaField(
      'otherEffect.value',
      'Repair',
      jsonKey: 'val',
    ),
    OtherEffectKind.cover => EnumFieldSpec<CoverLevel>(
      key: 'otherEffect.value',
      jsonKey: 'val',
      label: 'Cover',
      required: true,
      options: CoverLevel.values,
      displayLabel: (c) => c.name,
      fromJsonValue: (s) => CoverLevel.values.byName(s),
    ),
  },
);

List<FieldSpec> otherEffectItemFields() => [
  otherEffectCatalogField(),
  EnumFieldSpec<TargetType>(
    key: 'target',
    label: 'Target',
    options: TargetType.values,
    displayLabel: (t) => t.name,
    fromJsonValue: (s) => TargetType.values.byName(s),
  ),
  aoeField(),
];

IOtherEffectData? otherEffectFromItem(Map<String, dynamic> item) {
  final kind = item['otherEffect.id'] as OtherEffectKind?;
  if (kind == null) return null;
  final target = item['target'] as TargetType?;
  final aoe = stringOrBoolFromItem(item, 'aoe');
  switch (kind) {
    case OtherEffectKind.overshield:
      final v = numericOrFormulaFromItem(item, 'otherEffect.value');
      return v == null
          ? null
          : OvershieldEffectData(val: v, target: target, aoe: aoe);
    case OtherEffectKind.hp:
      final v = numericOrFormulaFromItem(item, 'otherEffect.value');
      return v == null ? null : HpEffectData(val: v, target: target, aoe: aoe);
    case OtherEffectKind.repair:
      final v = numericOrFormulaFromItem(item, 'otherEffect.value');
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

FieldSpec effectSaveGroupField(String key) => GroupFieldSpec(
  key: key,
  label: 'Save',
  fields: [
    EnumFieldSpec<MechStat>(
      key: 'stat',
      label: 'Stat',
      required: true,
      options: MechStat.values,
      displayLabel: (s) => s.name,
      fromJsonValue: (s) => MechStat.values.byName(s),
    ),
    const BoolFieldSpec(key: 'aoe', label: 'AoE'),
  ],
);

IEffectSaveData? effectSaveFromGroup(Map<String, dynamic>? group) {
  final stat = group?['stat'] as MechStat?;
  if (stat == null) return null;
  return IEffectSaveData(stat: stat, aoe: group?['aoe'] as bool?);
}

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
FieldSpec activeEffectGroupField(String key, String label) =>
    GroupFieldSpec(key: key, label: label, fields: activeEffectFields());

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

// --- Sección 4: IBonusData (con todos sus filtros, no solo id/val) ---

final _bonusIdByJsonValue = {
  for (final id in BonusId.values) id.jsonValue: id,
};

FieldSpec bonusCatalogField() => CatalogFieldSpec<BonusId>(
  key: 'bonus',
  label: 'Bonus',
  catalogIds: BonusId.values,
  idLabel: (id) => id.jsonValue,
  // A diferencia de `resistance`/`otherEffect`, aquí sí hay un campo `id`
  // real (ver `bonusDataToJson`) — no hay que adivinar la clave presente.
  idFromJson: (json) => _bonusIdByJsonValue[json['id']],
  valueFieldFor: (id) => switch (id.valueKind) {
    BonusValueKind.numericOrFormula => ShapeChoiceFieldSpec(
      key: 'bonus.value',
      jsonKey: 'val',
      label: 'Valor',
      required: true,
      branchFromJson: (json) {
        final raw = json['val'];
        if (raw is num) return 'A';
        if (raw is String) return 'B';
        return null;
      },
      options: const [
        ShapeChoiceOption(
          value: 'A',
          label: 'Número',
          field: NumberFieldSpec(
            key: 'bonus.value.a',
            jsonKey: 'val',
            label: 'Número',
            allowDecimal: true,
          ),
        ),
        ShapeChoiceOption(
          value: 'B',
          label: 'Fórmula',
          field: TextFieldSpec(
            key: 'bonus.value.b',
            jsonKey: 'val',
            label: 'Fórmula (ej. {grit}+2)',
            helpText:
                'Fórmula en vez de número fijo — usa llaves para referirte a '
                'un stat del piloto/mech, ej. "{grit}+2" o "{level}".',
          ),
        ),
      ],
    ),
    BonusValueKind.boolean => const BoolFieldSpec(
      key: 'bonus.value',
      jsonKey: 'val',
      label: 'Activo',
    ),
    // dieRollList/mountAssignment/unverified quedan sin jsonKey a
    // propósito: el formulario los representa como un único string (una
    // progresión separada por comas, o "tipo:max"), pero el JSON real es
    // una lista (`dieRollToJson`) o un objeto `{mount_type, max_mounts}`
    // (`mountAssignmentToJson`) — asignárselo tal cual a un TextFieldSpec
    // rompería el campo en vez de precargarlo. Necesitan una conversión
    // de forma que el hydrator genérico todavía no sabe hacer (ver
    // conversación pendiente).
    BonusValueKind.dieRollList => const TextFieldSpec(
      key: 'bonus.value',
      label: 'Progresión, separada por comas (ej. 1d6, 1d6+1d8, 2d6+1d10)',
      helpText:
          'Un valor de dados por cada rango del bonus, separados por comas — '
          'el primero para el rango 1, el segundo para el rango 2, etc.',
    ),
    BonusValueKind.mountAssignment => const TextFieldSpec(
      key: 'bonus.value',
      label: 'mount_type:max_mounts (ej. main:3)',
      helpText:
          'Tipo de mount seguido de dos puntos y el número máximo de mounts '
          'de ese tipo, ej. "main:3" o "flex:1".',
    ),
    BonusValueKind.unverified => const TextFieldSpec(
      key: 'bonus.value',
      label: 'Valor (sin confirmar, ver vault MdD §4)',
      helpText:
          'Este bonus todavía no tiene forma confirmada en el modelo de '
          'dominio — escribe el valor tal cual aparece en la spec oficial.',
    ),
  },
);

List<FieldSpec> bonusItemFields() => [
  bonusCatalogField(),
  const NumberFieldSpec(key: 'accuracy', label: 'Accuracy asociado'),
  MultiEnumFieldSpec<DamageType>(
    key: 'damageTypes',
    jsonKey: 'damage_types',
    label: 'Tipos de daño (vacío = todos)',
    options: DamageType.values,
    displayLabel: (d) => d.jsonValue,
    fromJsonValue: (s) => DamageType.values.firstWhere((d) => d.jsonValue == s),
  ),
  MultiEnumFieldSpec<BonusRangeTypeFilter>(
    key: 'rangeTypes',
    jsonKey: 'range_types',
    label: 'Tipos de alcance (vacío = todos)',
    options: BonusRangeTypeFilter.values,
    displayLabel: (r) => r.jsonValue,
    fromJsonValue: (s) =>
        BonusRangeTypeFilter.values.firstWhere((r) => r.jsonValue == s),
  ),
  MultiEnumFieldSpec<BonusWeaponTypeFilter>(
    key: 'weaponTypes',
    jsonKey: 'weapon_types',
    label: 'Tipos de arma (vacío = any)',
    options: BonusWeaponTypeFilter.values,
    displayLabel: (t) => t.jsonValue,
    fromJsonValue: (s) =>
        BonusWeaponTypeFilter.values.firstWhere((t) => t.jsonValue == s),
  ),
  MultiEnumFieldSpec<BonusWeaponSizeFilter>(
    key: 'weaponSizes',
    jsonKey: 'weapon_sizes',
    label: 'Tamaños de arma (vacío = any)',
    options: BonusWeaponSizeFilter.values,
    displayLabel: (s) => s.jsonValue,
    fromJsonValue: (s) =>
        BonusWeaponSizeFilter.values.firstWhere((f) => f.jsonValue == s),
  ),
  const BoolFieldSpec(key: 'overwrite', label: 'Overwrite'),
  const BoolFieldSpec(key: 'replace', label: 'Replace'),
];

/// Ensambla un `IBonusData` a partir de los valores de un ítem de la lista
/// `bonuses` (ver [bonusCatalogField]).
IBonusData? bonusFromItemValues(Map<String, dynamic> item) {
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
    damageTypes: emptyToNull(item['damageTypes'] as List?)?.cast<DamageType>(),
    rangeTypes: emptyToNull(
      item['rangeTypes'] as List?,
    )?.cast<BonusRangeTypeFilter>(),
    weaponTypes: emptyToNull(
      item['weaponTypes'] as List?,
    )?.cast<BonusWeaponTypeFilter>(),
    weaponSizes: emptyToNull(
      item['weaponSizes'] as List?,
    )?.cast<BonusWeaponSizeFilter>(),
    overwrite: item['overwrite'] as bool?,
    replace: item['replace'] as bool?,
  );
}

List<T>? emptyToNull<T>(List<T>? list) =>
    (list == null || list.isEmpty) ? null : list;

// --- Sección 5: ISynergyData ---

/// `locations`: conjunto cerrado (`rest`, `weapon`, ...) más la forma
/// variable `action_<id>` — mismo criterio de proporcionalidad que
/// `DiceExpression`/`MountAssignment`: se valida el patrón con texto libre
/// en vez de construir un selector dedicado para un mecanismo que el
/// propio dominio ya marca como "de último recurso" (vault MdD §5).
final synergyLocationPattern = RegExp(
  r'^(rest|weapon|system|deployable|drone|move|boost|structure|armor|hp|'
  r'overshield|stress|heat|repair|core_power|overcharge|hull|agility|'
  r'systems|engineering|pilot_weapon|cascade|action_[A-Za-z0-9_]+)$',
);

List<FieldSpec> synergyItemFields() => [
  ListFieldSpec(
    key: 'locations',
    label: 'Locations (al menos una)',
    itemFields: [
      PatternTextFieldSpec(
        key: 'value',
        label: 'Location',
        required: true,
        pattern: synergyLocationPattern,
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
    helpText: 'Texto de reglas de la synergy — qué gana el piloto/mech.',
  ),
  MultiEnumFieldSpec<WeaponType>(
    key: 'weaponTypes',
    jsonKey: 'weapon_types',
    label: 'Tipos de arma (vacío = todos)',
    options: WeaponType.values,
    displayLabel: (t) => t.jsonValue,
    fromJsonValue: (s) => WeaponType.values.firstWhere((t) => t.jsonValue == s),
  ),
  MultiEnumFieldSpec<WeaponSize>(
    key: 'weaponSizes',
    jsonKey: 'weapon_sizes',
    label: 'Tamaños de arma (vacío = todos)',
    options: WeaponSize.values,
    displayLabel: (s) => s.jsonValue,
    fromJsonValue: (s) => WeaponSize.values.firstWhere((w) => w.jsonValue == s),
  ),
  MultiEnumFieldSpec<SystemType>(
    key: 'systemTypes',
    jsonKey: 'system_types',
    label: 'Tipos de sistema (vacío = todos)',
    options: SystemType.values,
    displayLabel: (s) => s.jsonValue,
    fromJsonValue: (s) => SystemType.values.firstWhere((t) => t.jsonValue == s),
  ),
];

ISynergyData? synergyFromItem(Map<String, dynamic> item) {
  final locationItems =
      (item['locations'] as List<Map<String, dynamic>>?) ?? const [];
  final locations = locationItems
      .map((l) => l['value'] as String?)
      .whereType<String>()
      .map(synergyLocationFromValue)
      .toList();
  if (locations.isEmpty) return null;
  return ISynergyData(
    locations: locations,
    detail: item['detail'] as String? ?? '',
    weaponTypes: emptyToNull(item['weaponTypes'] as List?)?.cast<WeaponType>(),
    weaponSizes: emptyToNull(item['weaponSizes'] as List?)?.cast<WeaponSize>(),
    systemTypes: emptyToNull(item['systemTypes'] as List?)?.cast<SystemType>(),
  );
}

SynergyLocation synergyLocationFromValue(String value) {
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

/// Sin campo `deployables` propio — recursión acotada a 1 nivel, ver
/// `weapon_form_schema.dart` (decisión documentada allí, aplica igual
/// para cualquier entidad que anide deployables).
List<FieldSpec> deployableItemFields() => [
  const TextFieldSpec(
    key: 'name',
    label: 'Nombre',
    required: true,
    helpText: 'El nombre visible del deployable, ej. "Recon Drone".',
  ),
  const TextFieldSpec(
    key: 'type',
    label: 'Tipo (Drone | Mine | Deployable | personalizado)',
    helpText:
        'Escribe exactamente "Drone", "Mine" o "Deployable" para los tipos '
        'estándar, o cualquier otro texto para un tipo personalizado.',
  ),
  const TextFieldSpec(
    key: 'detail',
    label: 'Detalle',
    required: true,
    maxLines: 3,
    helpText: 'Texto de reglas de este deployable.',
  ),
  EnumFieldSpec<ActivationType>(
    key: 'activation',
    label: 'Activación',
    options: ActivationType.values,
    displayLabel: (a) => a.jsonValue,
    fromJsonValue: (s) =>
        ActivationType.values.firstWhere((a) => a.jsonValue == s),
  ),
  EnumFieldSpec<ActivationType>(
    key: 'deactivation',
    label: 'Desactivación',
    options: ActivationType.values,
    displayLabel: (a) => a.jsonValue,
    fromJsonValue: (s) =>
        ActivationType.values.firstWhere((a) => a.jsonValue == s),
  ),
  EnumFieldSpec<ActivationType>(
    key: 'recall',
    label: 'Recall',
    options: ActivationType.values,
    displayLabel: (a) => a.jsonValue,
    fromJsonValue: (s) =>
        ActivationType.values.firstWhere((a) => a.jsonValue == s),
  ),
  EnumFieldSpec<ActivationType>(
    key: 'redeploy',
    label: 'Redeploy',
    options: ActivationType.values,
    displayLabel: (a) => a.jsonValue,
    fromJsonValue: (s) =>
        ActivationType.values.firstWhere((a) => a.jsonValue == s),
  ),
  const NumberFieldSpec(key: 'instances', label: 'Instancias'),
  const NumberFieldSpec(key: 'cost', label: 'Coste (si el padre es limited)'),
  const NumberFieldSpec(key: 'size', label: 'Tamaño', allowDecimal: true),
  const TextFieldSpec(
    key: 'sizeSpecial',
    jsonKey: 'size_special',
    label: 'Tamaño especial',
    helpText:
        'Solo si el tamaño no es un número fijo (ej. "1 por punto de '
        'estructura perdido"). Si el tamaño es un número normal, usa el '
        'campo "Tamaño" de arriba y deja este vacío.',
  ),
  numericOrFormulaField('armor', 'Armor'),
  numericOrFormulaField('hp', 'HP'),
  numericOrFormulaField('evasion', 'Evasion'),
  numericOrFormulaField('edef', 'E-Defense'),
  numericOrFormulaField('heatcap', 'Heat cap'),
  numericOrFormulaField('repcap', 'Repair cap'),
  numericOrFormulaField('sensorRange', 'Sensor range', jsonKey: 'sensor_range'),
  numericOrFormulaField('techAttack', 'Tech attack', jsonKey: 'tech_attack'),
  numericOrFormulaField('save', 'Save'),
  numericOrFormulaField('speed', 'Speed'),
  numericOrFormulaField('grapple', 'Grapple'),
  numericOrFormulaField('attackBonus', 'Attack bonus', jsonKey: 'attack_bonus'),
  ListFieldSpec(key: 'damage', label: 'Daño', itemFields: damageItemFields()),
  ListFieldSpec(key: 'range', label: 'Alcance', itemFields: rangeItemFields()),
  ListFieldSpec(
    key: 'actions',
    label: 'Actions (mientras esté activo)',
    itemFields: actionItemFields(),
  ),
  ListFieldSpec(
    key: 'bonuses',
    label: 'Bonuses',
    itemFields: bonusItemFields(),
  ),
  ListFieldSpec(
    key: 'synergies',
    label: 'Synergies',
    itemFields: synergyItemFields(),
  ),
  ListFieldSpec(
    key: 'counters',
    label: 'Counters',
    itemFields: counterItemFields(),
  ),
  ListFieldSpec(
    key: 'activeEffects',
    jsonKey: 'active_effects',
    label: 'Active effects',
    itemFields: activeEffectFields(),
  ),
  ListFieldSpec(
    key: 'addStatus',
    jsonKey: 'add_status',
    label: 'Añade status/condition',
    itemFields: statusEffectItemFields(),
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
    key: 'addResist',
    jsonKey: 'add_resist',
    label: 'Añade resist/vulnerability/immunity',
    itemFields: resistanceItemFields(),
  ),
  const ListFieldSpec(
    key: 'tags',
    label: 'Tags',
    itemFields: [
      TextFieldSpec(
        key: 'id',
        label: 'ID del tag',
        required: true,
        helpText:
            'El ID del tag (Tag), no su nombre visible. Si el tag '
            'todavía no existe, usa el botón de crear tag desde el menú.',
      ),
    ],
  ),
  const BoolFieldSpec(
    key: 'pilot',
    label: 'Pilot (default true si el padre es Pilot Equipment)',
  ),
  const BoolFieldSpec(key: 'mech', label: 'Mech'),
];

DeployableType? deployableTypeFromInput(String? raw) {
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

IDeployableData deployableFromItem(Map<String, dynamic> item) =>
    IDeployableData(
      name: item['name'] as String,
      type: deployableTypeFromInput(item['type'] as String?),
      detail: item['detail'] as String,
      activation: item['activation'] as ActivationType?,
      deactivation: item['deactivation'] as ActivationType?,
      recall: item['recall'] as ActivationType?,
      redeploy: item['redeploy'] as ActivationType?,
      instances: (item['instances'] as num?)?.toInt(),
      cost: (item['cost'] as num?)?.toInt(),
      size: item['size'] as num?,
      sizeSpecial: item['sizeSpecial'] as String?,
      armor: numericOrFormulaFromItem(item, 'armor'),
      hp: numericOrFormulaFromItem(item, 'hp'),
      evasion: numericOrFormulaFromItem(item, 'evasion'),
      edef: numericOrFormulaFromItem(item, 'edef'),
      heatcap: numericOrFormulaFromItem(item, 'heatcap'),
      repcap: numericOrFormulaFromItem(item, 'repcap'),
      sensorRange: numericOrFormulaFromItem(item, 'sensorRange'),
      techAttack: numericOrFormulaFromItem(item, 'techAttack'),
      save: numericOrFormulaFromItem(item, 'save'),
      speed: numericOrFormulaFromItem(item, 'speed'),
      grapple: numericOrFormulaFromItem(item, 'grapple'),
      attackBonus: numericOrFormulaFromItem(item, 'attackBonus'),
      damage: mapItems(item['damage'], damageDataFromItem),
      range: mapItems(item['range'], rangeDataFromItem),
      actions: mapItems(item['actions'], actionFromItem),
      bonuses: mapItems(item['bonuses'], bonusFromItemValues),
      synergies: mapItems(item['synergies'], synergyFromItem),
      counters: mapItems(item['counters'], counterFromItem),
      activeEffects: mapItems(item['activeEffects'], activeEffectFromGroup),
      addStatus: mapItems(item['addStatus'], statusEffectFromItem),
      addSpecial: mapItems(item['addSpecial'], specialStatusFromItem),
      removeSpecial: mapStringIdItems(item['removeSpecial']),
      addOther: mapItems(item['addOther'], otherEffectFromItem),
      addResist: mapItems(item['addResist'], resistanceFromItem),
      tags: mapItems(item['tags'], tagFromItem),
      pilot: item['pilot'] as bool?,
      mech: item['mech'] as bool?,
    );

// --- Sección 7: ICounterData ---

List<FieldSpec> counterItemFields() => [
  const TextFieldSpec(
    key: 'id',
    label: 'ID',
    required: true,
    helpText:
        'Identificador interno de este contador. Minúsculas, sin espacios.',
  ),
  const TextFieldSpec(
    key: 'name',
    label: 'Nombre',
    required: true,
    helpText: 'El nombre visible del contador, ej. "Cargas de granada".',
  ),
  const NumberFieldSpec(
    key: 'defaultValue',
    jsonKey: 'default_value',
    label: 'Valor por defecto',
  ),
  const NumberFieldSpec(key: 'min', label: 'Mínimo'),
  const NumberFieldSpec(key: 'max', label: 'Máximo'),
];

ICounterData counterFromItem(Map<String, dynamic> item) => ICounterData(
  id: item['id'] as String,
  name: item['name'] as String,
  defaultValue: item['defaultValue'] as num?,
  min: item['min'] as num?,
  max: item['max'] as num?,
);

// --- Sección 6: ITagInstance ---

ITagInstance tagFromItem(Map<String, dynamic> item) =>
    ITagInstance(id: item['id'] as String);

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

// --- Helpers genéricos de listas ---

List<T>? mapItems<T>(
  dynamic rawItems,
  T? Function(Map<String, dynamic>) fromItem,
) {
  final items = (rawItems as List<Map<String, dynamic>>?) ?? const [];
  if (items.isEmpty) return null;
  final mapped = items.map(fromItem).whereType<T>().toList();
  return mapped.isEmpty ? null : mapped;
}

List<String>? mapStringIdItems(dynamic rawItems) {
  final items = (rawItems as List<Map<String, dynamic>>?) ?? const [];
  if (items.isEmpty) return null;
  final ids = items.map((i) => i['id'] as String?).whereType<String>().toList();
  return ids.isEmpty ? null : ids;
}

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

// --- Sección 13.4 (IMechSystemData) — bundle base reutilizado por
// MechSystem y WeaponMod (WeaponMod extiende todos los campos de
// MechSystem, pero al ser clases de dominio distintas cada una necesita
// construir su propia instancia — no se puede "extender" un objeto ya
// construido). Mismo criterio que llevó a extraer el paquete de
// actions/bonuses/synergies/deployables a este módulo: un segundo
// consumidor real confirmando que merece la pena compartirlo. ---

List<FieldSpec> mechSystemBaseFields() => [
  const TextFieldSpec(
    key: 'id',
    label: 'ID',
    required: true,
    helpText:
        'Identificador único dentro del .lcp. Minúsculas, sin espacios — no '
        'es el nombre visible, eso va en "Nombre".',
  ),
  const TextFieldSpec(
    key: 'name',
    label: 'Nombre',
    required: true,
    helpText: 'El nombre que verá el jugador en COMP/CON.',
  ),
  const TextFieldSpec(
    key: 'source',
    label: 'Fabricante (source; opcional solo en License Collection)',
    helpText: 'El ID del fabricante (Manufacturer), no su nombre visible.',
    referenceEntityKey: 'manufacturers',
    referenceLabel: 'fabricante',
  ),
  const TextFieldSpec(
    key: 'license',
    label: 'Licencia (opcional solo en License Collection)',
    helpText: 'Nombre visible de la licencia (normalmente el del frame).',
  ),
  const TextFieldSpec(
    key: 'licenseId',
    jsonKey: 'license_id',
    label: 'ID de la licencia (frame; opcional solo en License Collection)',
    helpText: 'El ID del frame al que pertenece, no su nombre visible.',
    referenceEntityKey: 'frames',
    referenceLabel: 'frame',
  ),
  const NumberFieldSpec(
    key: 'licenseLevel',
    jsonKey: 'license_level',
    label: 'Nivel de licencia (0-3)',
    required: true,
  ),
  EnumFieldSpec<SystemType>(
    key: 'type',
    label: 'Tipo (default: System)',
    options: SystemType.values,
    displayLabel: (t) => t.jsonValue,
    fromJsonValue: (s) => SystemType.values.firstWhere((t) => t.jsonValue == s),
  ),
  const TextFieldSpec(
    key: 'effect',
    label: 'Efecto',
    maxLines: 3,
    helpText: 'Texto de reglas del sistema — lo que hace mecánicamente.',
  ),
  const TextFieldSpec(
    key: 'description',
    label: 'Descripción',
    maxLines: 3,
    helpText: 'Texto de sabor/ambientación, sin efecto mecánico.',
  ),
  const NumberFieldSpec(key: 'sp', label: 'SP'),
  const ListFieldSpec(
    key: 'tags',
    label: 'Tags',
    itemFields: [
      TextFieldSpec(
        key: 'id',
        label: 'ID del tag',
        required: true,
        helpText:
            'El ID del tag (Tag), no su nombre visible. Si el tag '
            'todavía no existe, usa el botón de crear tag desde el menú.',
      ),
    ],
  ),
  ListFieldSpec(
    key: 'actions',
    label: 'Actions',
    itemFields: actionItemFields(),
  ),
  ListFieldSpec(
    key: 'bonuses',
    label: 'Bonuses',
    itemFields: bonusItemFields(),
  ),
  const BoolFieldSpec(
    key: 'noBonus',
    jsonKey: 'no_bonus',
    label: 'Ignora bonuses',
  ),
  ListFieldSpec(
    key: 'synergies',
    label: 'Synergies',
    itemFields: synergyItemFields(),
  ),
  const BoolFieldSpec(
    key: 'noSynergy',
    jsonKey: 'no_synergy',
    label: 'Ignora synergies',
  ),
  ListFieldSpec(
    key: 'deployables',
    label: 'Deployables',
    itemFields: deployableItemFields(),
  ),
  ListFieldSpec(
    key: 'counters',
    label: 'Counters',
    itemFields: counterItemFields(),
  ),
  ListFieldSpec(
    key: 'integrated',
    label: 'Integrated (IDs, sin validar referencias circulares)',
    itemFields: [
      TextFieldSpec(
        key: 'id',
        label: 'ID',
        required: true,
        helpText:
            'El ID de otro sistema/equipo que viene incluido gratis '
            'con este, no su nombre visible.',
      ),
    ],
  ),
  ListFieldSpec(
    key: 'specialEquipment',
    jsonKey: 'special_equipment',
    label: 'Special equipment (IDs)',
    itemFields: [
      TextFieldSpec(
        key: 'id',
        label: 'ID',
        required: true,
        helpText: 'El ID del equipo especial asociado, no su nombre visible.',
      ),
    ],
  ),
  ListFieldSpec(
    key: 'activeEffects',
    jsonKey: 'active_effects',
    label: 'Active effects',
    itemFields: activeEffectFields(),
  ),
];

/// Valores comunes ya ensamblados desde `values` — cada entidad concreta
/// (`MechSystem`, `WeaponMod`) los pasa a su propio constructor de dominio
/// junto con sus campos específicos.
class MechSystemBaseValues {
  final String id;
  final String name;
  final String? source;
  final String? license;
  final String? licenseId;
  final int licenseLevel;
  final SystemType? type;
  final String? effect;
  final String? description;
  final int? sp;
  final List<ITagInstance>? tags;
  final List<IActionData>? actions;
  final List<IBonusData>? bonuses;
  final bool? noBonus;
  final List<ISynergyData>? synergies;
  final bool? noSynergy;
  final List<IDeployableData>? deployables;
  final List<ICounterData>? counters;
  final List<String>? integrated;
  final List<String>? specialEquipment;
  final List<IActiveEffectData>? activeEffects;

  const MechSystemBaseValues({
    required this.id,
    required this.name,
    this.source,
    this.license,
    this.licenseId,
    required this.licenseLevel,
    this.type,
    this.effect,
    this.description,
    this.sp,
    this.tags,
    this.actions,
    this.bonuses,
    this.noBonus,
    this.synergies,
    this.noSynergy,
    this.deployables,
    this.counters,
    this.integrated,
    this.specialEquipment,
    this.activeEffects,
  });
}

MechSystemBaseValues mechSystemBaseFromValues(Map<String, dynamic> values) =>
    MechSystemBaseValues(
      id: values['id'] as String,
      name: values['name'] as String,
      source: values['source'] as String?,
      license: values['license'] as String?,
      licenseId: values['licenseId'] as String?,
      licenseLevel: (values['licenseLevel'] as num?)?.toInt() ?? 0,
      type: values['type'] as SystemType?,
      effect: values['effect'] as String?,
      description: values['description'] as String?,
      sp: (values['sp'] as num?)?.toInt(),
      tags: mapItems(values['tags'], tagFromItem),
      actions: mapItems(values['actions'], actionFromItem),
      bonuses: mapItems(values['bonuses'], bonusFromItemValues),
      noBonus: values['noBonus'] as bool?,
      synergies: mapItems(values['synergies'], synergyFromItem),
      noSynergy: values['noSynergy'] as bool?,
      deployables: mapItems(values['deployables'], deployableFromItem),
      counters: mapItems(values['counters'], counterFromItem),
      integrated: mapStringIdItems(values['integrated']),
      specialEquipment: mapStringIdItems(values['specialEquipment']),
      activeEffects: mapItems(values['activeEffects'], activeEffectFromGroup),
    );
