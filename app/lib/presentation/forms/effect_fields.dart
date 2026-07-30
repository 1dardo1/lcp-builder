/// Effect field builders and assemblers: statuses, resistances, special/other
/// statuses and effect saves (domain section 2).
library;

import '../../domain/domain.dart';
import 'field_spec.dart';
import 'shared_field_specs.dart';

// --- Catálogos de UI locales (uniones cerradas discriminadas, no un
// catálogo externo grande como BonusId — mismo mecanismo, menos entradas).
// Públicos para poder construirlos directamente en tests, igual que se
// hace con BonusId. ---

enum ResistanceKind { resist, vulnerability, immunity }

enum OtherEffectKind { overshield, hp, repair, cover }
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

ResistanceValue resistanceValueFromJson(String v) =>
    ResistanceValue.values.byName(v);

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
