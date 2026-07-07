import '../../domain/domain.dart';
import 'common_entity_fields.dart';
import 'entity_crear_config.dart';
import 'field_spec.dart';

/// Esquema de campos de [IFrameData] (sección 13.2 del modelo de dominio).
/// La entidad más grande de esta tanda: `stats` es un `GroupFieldSpec` de
/// forma fija (14 campos numéricos requeridos), `traits` una lista de
/// `IFrameTraitData` (reutiliza el paquete común), `coreSystem` un único
/// `GroupFieldSpec` (`ICoreSystemData`, con mitad activa/mitad pasiva), y
/// `specialty` es caso 3 del catálogo (`bool | IPrerequisite`, sin campo
/// discriminador — se resuelve con `ShapeChoiceFieldSpec`).

List<FieldSpec> _frameStatsFields() => const [
  NumberFieldSpec(key: 'size', label: 'Tamaño (entero o 0.5)', required: true),
  NumberFieldSpec(key: 'structure', label: 'Structure', required: true),
  NumberFieldSpec(key: 'stress', label: 'Stress', required: true),
  NumberFieldSpec(key: 'armor', label: 'Armor', required: true),
  NumberFieldSpec(key: 'hp', label: 'HP', required: true),
  NumberFieldSpec(key: 'evasion', label: 'Evasion', required: true),
  NumberFieldSpec(key: 'edef', label: 'E-Defense', required: true),
  NumberFieldSpec(key: 'heatcap', label: 'Heat cap', required: true),
  NumberFieldSpec(key: 'repcap', label: 'Repair cap', required: true),
  NumberFieldSpec(key: 'sensorRange', label: 'Sensor range', required: true),
  NumberFieldSpec(key: 'techAttack', label: 'Tech attack', required: true),
  NumberFieldSpec(key: 'save', label: 'Save', required: true),
  NumberFieldSpec(key: 'speed', label: 'Speed', required: true),
  NumberFieldSpec(key: 'sp', label: 'SP', required: true),
];

IFrameStats _frameStatsFromGroup(Map<String, dynamic> group) => IFrameStats(
  size: (group['size'] as num?) ?? 0,
  structure: (group['structure'] as num?) ?? 0,
  stress: (group['stress'] as num?) ?? 0,
  armor: (group['armor'] as num?) ?? 0,
  hp: (group['hp'] as num?) ?? 0,
  evasion: (group['evasion'] as num?) ?? 0,
  edef: (group['edef'] as num?) ?? 0,
  heatcap: (group['heatcap'] as num?) ?? 0,
  repcap: (group['repcap'] as num?) ?? 0,
  sensorRange: (group['sensorRange'] as num?) ?? 0,
  techAttack: (group['techAttack'] as num?) ?? 0,
  save: (group['save'] as num?) ?? 0,
  speed: (group['speed'] as num?) ?? 0,
  sp: (group['sp'] as num?) ?? 0,
);

List<FieldSpec> _frameTraitItemFields() => [
  const TextFieldSpec(key: 'name', label: 'Nombre', required: true),
  const TextFieldSpec(
    key: 'description',
    label: 'Descripción',
    required: true,
    maxLines: 3,
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
  ListFieldSpec(
    key: 'synergies',
    label: 'Synergies',
    itemFields: synergyItemFields(),
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
  ListFieldSpec(
    key: 'activeEffects',
    label: 'Active effects',
    itemFields: activeEffectFields(),
  ),
];

IFrameTraitData _frameTraitFromItem(Map<String, dynamic> item) =>
    IFrameTraitData(
      name: item['name'] as String,
      description: item['description'] as String,
      actions: mapItems(item['actions'], actionFromItem),
      bonuses: mapItems(item['bonuses'], bonusFromItemValues),
      synergies: mapItems(item['synergies'], synergyFromItem),
      deployables: mapItems(item['deployables'], deployableFromItem),
      counters: mapItems(item['counters'], counterFromItem),
      integrated: mapStringIdItems(item['integrated']),
      specialEquipment: mapStringIdItems(item['specialEquipment']),
      activeEffects: mapItems(item['activeEffects'], activeEffectFromGroup),
    );

List<FieldSpec> _coreSystemFields() => [
  const TextFieldSpec(key: 'name', label: 'Nombre', required: true),
  const TextFieldSpec(key: 'description', label: 'Descripción', maxLines: 3),
  const TextFieldSpec(
    key: 'activeName',
    label: 'Nombre (activo)',
    required: true,
  ),
  const TextFieldSpec(
    key: 'activeEffect',
    label: 'Efecto (activo)',
    required: true,
    maxLines: 3,
  ),
  EnumFieldSpec<ActivationType>(
    key: 'activation',
    label: 'Activación',
    required: true,
    options: ActivationType.values,
    displayLabel: (a) => a.jsonValue,
  ),
  EnumFieldSpec<ActivationType>(
    key: 'deactivation',
    label: 'Desactivación',
    options: ActivationType.values,
    displayLabel: (a) => a.jsonValue,
  ),
  EnumFieldSpec<CoreSystemUse>(
    key: 'use',
    label: 'Duración de uso',
    options: CoreSystemUse.values,
    displayLabel: (u) => u.jsonValue,
  ),
  ListFieldSpec(
    key: 'activeEffects',
    label: 'Active effects (al activar)',
    itemFields: activeEffectFields(),
  ),
  ListFieldSpec(
    key: 'activeActions',
    label: 'Actions (activo)',
    itemFields: actionItemFields(),
  ),
  ListFieldSpec(
    key: 'activeBonuses',
    label: 'Bonuses (activo)',
    itemFields: bonusItemFields(),
  ),
  ListFieldSpec(
    key: 'activeSynergies',
    label: 'Synergies (activo)',
    itemFields: synergyItemFields(),
  ),
  const TextFieldSpec(key: 'passiveName', label: 'Nombre (pasivo)'),
  const TextFieldSpec(
    key: 'passiveEffect',
    label: 'Efecto (pasivo)',
    maxLines: 3,
  ),
  ListFieldSpec(
    key: 'passiveActions',
    label: 'Actions (siempre disponibles)',
    itemFields: actionItemFields(),
  ),
  ListFieldSpec(
    key: 'passiveBonuses',
    label: 'Bonuses (siempre activos)',
    itemFields: bonusItemFields(),
  ),
  ListFieldSpec(
    key: 'passiveSynergies',
    label: 'Synergies (siempre activas)',
    itemFields: synergyItemFields(),
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
  const ListFieldSpec(
    key: 'tags',
    label: 'Tags',
    itemFields: [TextFieldSpec(key: 'id', label: 'ID del tag', required: true)],
  ),
];

ICoreSystemData _coreSystemFromGroup(Map<String, dynamic> group) =>
    ICoreSystemData(
      name: group['name'] as String? ?? '',
      description: group['description'] as String?,
      activeName: group['activeName'] as String? ?? '',
      activeEffect: group['activeEffect'] as String? ?? '',
      activation:
          group['activation'] as ActivationType? ?? ActivationType.quick,
      deactivation: group['deactivation'] as ActivationType?,
      use: group['use'] as CoreSystemUse?,
      activeEffects: mapItems(group['activeEffects'], activeEffectFromGroup),
      activeActions: mapItems(group['activeActions'], actionFromItem),
      activeBonuses: mapItems(group['activeBonuses'], bonusFromItemValues),
      activeSynergies: mapItems(group['activeSynergies'], synergyFromItem),
      passiveName: group['passiveName'] as String?,
      passiveEffect: group['passiveEffect'] as String?,
      passiveActions: mapItems(group['passiveActions'], actionFromItem),
      passiveBonuses: mapItems(group['passiveBonuses'], bonusFromItemValues),
      passiveSynergies: mapItems(group['passiveSynergies'], synergyFromItem),
      deployables: mapItems(group['deployables'], deployableFromItem),
      counters: mapItems(group['counters'], counterFromItem),
      integrated: mapStringIdItems(group['integrated']),
      specialEquipment: mapStringIdItems(group['specialEquipment']),
      tags: mapItems(group['tags'], tagFromItem),
    );

/// `specialty?: boolean | IPrerequisite` — caso 3 (forma decidida por el
/// valor, no por un campo discriminador). Mismo mecanismo que
/// `ShapeChoiceFieldSpec` ya usa en otros campos `A | B`.
FieldSpec _specialtyField() => const ShapeChoiceFieldSpec(
  key: 'specialty',
  label: 'Specialty',
  options: [
    ShapeChoiceOption(
      value: 'bool',
      label: 'Oculta la licencia base',
      field: BoolFieldSpec(key: 'specialty.bool', label: 'Specialty'),
    ),
    ShapeChoiceOption(
      value: 'prerequisite',
      label: 'Condición de gating',
      field: GroupFieldSpec(
        key: 'specialty.prerequisite',
        label: 'Prerequisite',
        fields: [
          TextFieldSpec(
            key: 'source',
            label: 'Fabricante (Manufacturer ID)',
            required: true,
          ),
          NumberFieldSpec(
            key: 'minRank',
            label: 'Rango mínimo',
            required: true,
          ),
          BoolFieldSpec(key: 'cumulative', label: 'Acumulativo'),
        ],
      ),
    ),
  ],
);

Object? _specialtyFromValues(Map<String, dynamic> values) {
  final choice = values['specialty.choice'] as String?;
  if (choice == null) return null;
  if (choice == 'bool') return values['specialty.bool'] as bool?;
  final group = values['specialty.prerequisite'] as Map<String, dynamic>?;
  final source = group?['source'] as String?;
  if (source == null || source.isEmpty) return null;
  return IPrerequisite(
    source: source,
    minRank: (group?['minRank'] as num?)?.toInt() ?? 0,
    cumulative: (group?['cumulative'] as bool?) ?? false,
  );
}

List<FieldSpec> buildFrameFormSchema() => [
  const TextFieldSpec(key: 'id', label: 'ID', required: true),
  const TextFieldSpec(key: 'name', label: 'Nombre', required: true),
  const TextFieldSpec(
    key: 'source',
    label: 'Fabricante (debe coincidir con un Manufacturer ID)',
    required: true,
  ),
  const TextFieldSpec(
    key: 'licenseId',
    label: 'ID de la licencia principal (requerido si es variante)',
  ),
  const NumberFieldSpec(
    key: 'licenseLevel',
    label: 'Nivel de licencia (0-3)',
    required: true,
  ),
  const ListFieldSpec(
    key: 'mechtype',
    label: 'Mechtype (al menos uno, solo hint de UI)',
    itemFields: [TextFieldSpec(key: 'id', label: 'Mechtype', required: true)],
  ),
  const TextFieldSpec(
    key: 'description',
    label: 'Descripción',
    required: true,
    maxLines: 3,
  ),
  const ListFieldSpec(
    key: 'mounts',
    label: 'Mounts (al menos uno)',
    itemFields: [
      EnumFieldSpec<MountType>(
        key: 'value',
        label: 'Mount',
        required: true,
        options: MountType.values,
        displayLabel: _mountLabel,
      ),
    ],
  ),
  GroupFieldSpec(key: 'stats', label: 'Stats', fields: _frameStatsFields()),
  ListFieldSpec(
    key: 'traits',
    label: 'Traits',
    itemFields: _frameTraitItemFields(),
  ),
  GroupFieldSpec(
    key: 'coreSystem',
    label: 'Core system',
    fields: _coreSystemFields(),
  ),
  _specialtyField(),
  const TextFieldSpec(
    key: 'variant',
    label: 'Variant (id o nombre del frame del que es variante)',
  ),
  const TextFieldSpec(key: 'imageUrl', label: 'Imagen (URL)'),
  const NumberFieldSpec(key: 'yPos', label: 'Alineación vertical (banner UI)'),
];

String _mountLabel(MountType m) => m.jsonValue;

IFrameData frameFromFormValues(Map<String, dynamic> values) {
  final statsGroup = (values['stats'] as Map<String, dynamic>?) ?? const {};
  final coreSystemGroup =
      (values['coreSystem'] as Map<String, dynamic>?) ?? const {};
  final mountItems =
      (values['mounts'] as List<Map<String, dynamic>>?) ?? const [];

  return IFrameData(
    id: values['id'] as String,
    name: values['name'] as String,
    source: values['source'] as String,
    licenseId: values['licenseId'] as String?,
    licenseLevel: (values['licenseLevel'] as num?)?.toInt() ?? 0,
    mechtype: mapStringIdItems(values['mechtype']) ?? const [],
    description: values['description'] as String,
    mounts: [
      for (final item in mountItems)
        if (item['value'] != null) item['value'] as MountType,
    ],
    stats: _frameStatsFromGroup(statsGroup),
    traits: mapItems(values['traits'], _frameTraitFromItem) ?? const [],
    coreSystem: _coreSystemFromGroup(coreSystemGroup),
    specialty: _specialtyFromValues(values),
    variant: values['variant'] as String?,
    imageUrl: values['imageUrl'] as String?,
    yPos: values['yPos'] as num?,
  );
}

final frameCrearConfig = EntityCrearConfig(
  title: 'Crear frame',
  contentKey: 'frames',
  buildSchema: buildFrameFormSchema,
  fromFormValues: frameFromFormValues,
  idOf: (content) => (content as IFrameData).id,
  nameOf: (content) => (content as IFrameData).name,
);
