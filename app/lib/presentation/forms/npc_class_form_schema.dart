import '../../domain/domain.dart';
import 'common_entity_fields.dart';
import 'entity_crear_config.dart';
import 'field_spec.dart';

/// Esquema de campos de [INpcClassData] (sección 15.1 del modelo de
/// dominio). El uso más denso de caso 6 del catálogo: `stats` tiene 13
/// campos `TierValue` y 1 `NpcSize`, todos resueltos con las mismas piezas
/// ya usadas en [buildNpcFeatureFormSchema] (`tierValueField`/
/// `npcSizeField` de `common_entity_fields.dart`) — ninguna pieza nueva.

List<FieldSpec> _npcClassInfoFields() => const [
  TextFieldSpec(key: 'flavor', label: 'Flavor (texto de Compendium)'),
  TextFieldSpec(key: 'tactics', label: 'Tactics (nota para el GM)'),
  TextFieldSpec(key: 'terse', label: 'Terse (resumen ultra-corto)'),
];

INpcClassInfo _npcClassInfoFromGroup(Map<String, dynamic> group) =>
    INpcClassInfo(
      flavor: group['flavor'] as String? ?? '',
      tactics: group['tactics'] as String? ?? '',
      terse: group['terse'] as String? ?? '',
    );

List<FieldSpec> _npcClassStatsFields() => [
  tierValueField('armor', 'Armor'),
  tierValueField('hp', 'HP'),
  tierValueField('evade', 'Evade'),
  tierValueField('edef', 'E-Defense'),
  tierValueField('heatcap', 'Heat cap'),
  tierValueField('speed', 'Speed'),
  tierValueField('sensor', 'Sensor'),
  tierValueField('save', 'Save'),
  tierValueField('hull', 'Hull'),
  tierValueField('agility', 'Agility'),
  tierValueField('systems', 'Systems'),
  tierValueField('engineering', 'Engineering'),
  npcSizeField(),
  tierValueField('activations', 'Activations'),
];

INpcClassStats _npcClassStatsFromGroup(
  Map<String, dynamic> group,
) => INpcClassStats(
  armor: tierValueFromItem(group, 'armor') ?? TierValue.single(0),
  hp: tierValueFromItem(group, 'hp') ?? TierValue.single(0),
  evade: tierValueFromItem(group, 'evade') ?? TierValue.single(0),
  edef: tierValueFromItem(group, 'edef') ?? TierValue.single(0),
  heatcap: tierValueFromItem(group, 'heatcap') ?? TierValue.single(0),
  speed: tierValueFromItem(group, 'speed') ?? TierValue.single(0),
  sensor: tierValueFromItem(group, 'sensor') ?? TierValue.single(0),
  save: tierValueFromItem(group, 'save') ?? TierValue.single(0),
  hull: tierValueFromItem(group, 'hull') ?? TierValue.single(0),
  agility: tierValueFromItem(group, 'agility') ?? TierValue.single(0),
  systems: tierValueFromItem(group, 'systems') ?? TierValue.single(0),
  engineering: tierValueFromItem(group, 'engineering') ?? TierValue.single(0),
  size:
      npcSizeFromItem(group) ??
      NpcSize(const [
        [1],
        [1],
        [1],
      ]),
  activations: tierValueFromItem(group, 'activations') ?? TierValue.single(1),
);

List<FieldSpec> buildNpcClassFormSchema() => [
  const TextFieldSpec(key: 'id', label: 'ID', required: true),
  const TextFieldSpec(key: 'name', label: 'Nombre', required: true),
  EnumFieldSpec<NpcRole>(
    key: 'role',
    label: 'Rol',
    required: true,
    options: NpcRole.values,
    displayLabel: (r) => r.name,
  ),
  GroupFieldSpec(key: 'info', label: 'Info', fields: _npcClassInfoFields()),
  GroupFieldSpec(key: 'stats', label: 'Stats', fields: _npcClassStatsFields()),
  const NumberFieldSpec(
    key: 'optionalClassMin',
    label: 'Optional class min (default 0)',
  ),
  const NumberFieldSpec(key: 'optionalClassMax', label: 'Optional class max'),
  const NumberFieldSpec(
    key: 'optionalClassPerTier',
    label: 'Optional class per tier (cálculo aditivo, ver vault §15.1)',
  ),
  ListFieldSpec(
    key: 'activeEffects',
    label: 'Active effects',
    itemFields: activeEffectFields(),
  ),
];

INpcClassData npcClassFromFormValues(Map<String, dynamic> values) {
  final infoGroup = (values['info'] as Map<String, dynamic>?) ?? const {};
  final statsGroup = (values['stats'] as Map<String, dynamic>?) ?? const {};
  return INpcClassData(
    id: values['id'] as String,
    name: values['name'] as String,
    role: values['role'] as NpcRole,
    info: _npcClassInfoFromGroup(infoGroup),
    stats: _npcClassStatsFromGroup(statsGroup),
    optionalClassMin: (values['optionalClassMin'] as num?)?.toInt(),
    optionalClassMax: (values['optionalClassMax'] as num?)?.toInt(),
    optionalClassPerTier: (values['optionalClassPerTier'] as num?)?.toInt(),
    activeEffects: mapItems(values['activeEffects'], activeEffectFromGroup),
  );
}

final npcClassCrearConfig = EntityCrearConfig(
  title: 'Crear NPC class',
  contentKey: 'npc_classes',
  buildSchema: buildNpcClassFormSchema,
  fromFormValues: npcClassFromFormValues,
  idOf: (content) => (content as INpcClassData).id,
  nameOf: (content) => (content as INpcClassData).name,
);
