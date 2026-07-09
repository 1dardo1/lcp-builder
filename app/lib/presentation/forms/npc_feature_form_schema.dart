import '../../domain/domain.dart';
import 'common_entity_fields.dart';
import 'entity_crear_config.dart';
import 'field_spec.dart';

/// Esquema de campos de [INpcFeatureData] (sección 15.2 del modelo de
/// dominio). Caso 1 del catálogo (unión discriminada por `type`, 5
/// variantes: trait/system/reaction/tech/weapon), resuelto con la misma
/// composición `ShapeChoiceFieldSpec` + `GroupFieldSpec` que
/// [buildPilotGearFormSchema] — aquí las variantes comparten mucho más
/// (toda la base común), así que el selector solo envuelve lo que cada
/// variante añade encima, no todos los campos. `tech`/`weapon` usan
/// además `TierValue` (caso 6, `tierValueField`/`tierValueFromItem` de
/// `common_entity_fields.dart`).
///
/// Reutilizable por [buildEidolonLayerFormSchema] (`features`/`shards`
/// anidan `INpcFeatureData`), de ahí que el bundle de campos y el
/// ensamblador vivan en funciones públicas, no solo en `buildSchema`.

List<FieldSpec> npcFeatureBaseFields() => [
  const TextFieldSpec(
    key: 'id',
    label: 'ID',
    required: true,
    helpText: 'Identificador único de la feature. Minúsculas, sin espacios.',
  ),
  const TextFieldSpec(
    key: 'name',
    label: 'Nombre',
    required: true,
    helpText: 'El nombre visible de la feature.',
  ),
  const TextFieldSpec(
    key: 'origin',
    label: 'Origen (ID de NPC Class/Template)',
    helpText: 'El ID de la NPC Class o Template de la que viene esta feature.',
  ),
  const BoolFieldSpec(key: 'base', label: 'Asignada automáticamente'),
  const BoolFieldSpec(key: 'deprecated', label: 'Deprecated'),
  textOrActiveEffectField('effect', 'Efecto'),
  const BoolFieldSpec(
    key: 'hideActive',
    jsonKey: 'hide_active',
    label: 'Ocultar en Active Mode',
  ),
  const BoolFieldSpec(
    key: 'buildFeature',
    jsonKey: 'build_feature',
    label: 'Build feature (sin efecto en combate)',
  ),
  const TextFieldSpec(
    key: 'mod',
    label: 'Modifica a (ID de otra feature)',
    helpText: 'El ID de la feature que esta modifica, no su nombre visible.',
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
];

List<FieldSpec> _npcDamageItemFields() => [
  EnumFieldSpec<DamageType>(
    key: 'type',
    label: 'Tipo de daño',
    required: true,
    options: DamageType.values,
    displayLabel: (d) => d.jsonValue,
  ),
  const GroupFieldSpec(
    key: 'damage',
    label: 'Daño por tier (3 enteros)',
    fields: [
      NumberFieldSpec(key: 'tier1', label: 'Tier 1', required: true),
      NumberFieldSpec(key: 'tier2', label: 'Tier 2', required: true),
      NumberFieldSpec(key: 'tier3', label: 'Tier 3', required: true),
    ],
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
  ),
];

INpcDamageData _npcDamageFromItem(Map<String, dynamic> item) {
  final group = (item['damage'] as Map<String, dynamic>?) ?? const {};
  return INpcDamageData(
    type: item['type'] as DamageType,
    damage: [
      (group['tier1'] as num?) ?? 0,
      (group['tier2'] as num?) ?? 0,
      (group['tier3'] as num?) ?? 0,
    ],
    aoe: stringOrBoolFromItem(item, 'aoe'),
    save: damageSaveFromItem(item),
    saveHalf: item['saveHalf'] as bool?,
    ap: item['ap'] as bool?,
    target: item['target'] as TargetType?,
  );
}

FieldSpec _npcFeatureKindField() => ShapeChoiceFieldSpec(
  key: 'kind',
  jsonKey: 'type',
  label: 'Tipo de feature',
  required: true,
  options: [
    const ShapeChoiceOption(value: 'trait', label: 'Trait'),
    const ShapeChoiceOption(value: 'system', label: 'System'),
    ShapeChoiceOption(
      value: 'reaction',
      label: 'Reaction',
      field: GroupFieldSpec(
        key: 'kind.reaction',
        label: 'Datos de reaction',
        fields: [
          TextFieldSpec(
            key: 'trigger',
            label: 'Trigger',
            helpText: 'Qué dispara esta reaction, en texto libre.',
          ),
        ],
      ),
    ),
    ShapeChoiceOption(
      value: 'tech',
      label: 'Tech',
      field: GroupFieldSpec(
        key: 'kind.tech',
        label: 'Datos de tech',
        fields: [
          tierValueField('attackBonus', 'Attack bonus'),
          tierValueField('accuracy', 'Accuracy'),
        ],
      ),
    ),
    ShapeChoiceOption(
      value: 'weapon',
      label: 'Weapon',
      field: GroupFieldSpec(
        key: 'kind.weapon',
        label: 'Datos de weapon',
        fields: [
          const TextFieldSpec(
            key: 'weaponType',
            jsonKey: 'weapon_type',
            label: 'Tipo de arma ("{Size} {Type}", ej. "Superheavy Rifle")',
            required: true,
            helpText:
                'Texto libre combinando tamaño y tipo, tal como se muestra '
                'en la tarjeta del NPC, ej. "Heavy Cannon".',
          ),
          ListFieldSpec(
            key: 'damage',
            label: 'Daño',
            itemFields: _npcDamageItemFields(),
          ),
          ListFieldSpec(
            key: 'range',
            label: 'Alcance',
            itemFields: rangeItemFields(),
          ),
          tierValueField('attacks', 'Nº de ataques'),
          tierValueField('attackBonus', 'Attack bonus'),
          tierValueField('accuracy', 'Accuracy'),
          activeEffectGroupField('onAttack', 'Al atacar'),
          activeEffectGroupField('onHit', 'Al acertar'),
          activeEffectGroupField('onCrit', 'Al crítico'),
          activeEffectGroupField('onMiss', 'Al fallar'),
        ],
      ),
    ),
  ],
);

/// Campos completos de una `INpcFeatureData` (base + selector de variante)
/// — expuesto aparte de `buildNpcFeatureFormSchema` para que
/// `buildEidolonLayerFormSchema` pueda reutilizarlo tal cual como
/// `itemFields` de sus listas anidadas de features (`IEidolonLayerData
/// .features`, `IEidolonShardData.features`), sin duplicar el esquema.
List<FieldSpec> npcFeatureItemFields() => [
  ...npcFeatureBaseFields(),
  _npcFeatureKindField(),
];

List<FieldSpec> buildNpcFeatureFormSchema() => npcFeatureItemFields();

class _NpcFeatureBaseValues {
  final String id;
  final String name;
  final String? origin;
  final bool? base;
  final bool? deprecated;
  final TextOrActiveEffect? effect;
  final bool? hideActive;
  final bool? buildFeature;
  final String? mod;
  final List<ITagInstance>? tags;
  final List<IActionData>? actions;
  final List<IBonusData>? bonuses;
  final List<ISynergyData>? synergies;
  final List<IDeployableData>? deployables;

  const _NpcFeatureBaseValues({
    required this.id,
    required this.name,
    this.origin,
    this.base,
    this.deprecated,
    this.effect,
    this.hideActive,
    this.buildFeature,
    this.mod,
    this.tags,
    this.actions,
    this.bonuses,
    this.synergies,
    this.deployables,
  });
}

_NpcFeatureBaseValues _npcFeatureBaseFromValues(Map<String, dynamic> values) =>
    _NpcFeatureBaseValues(
      id: values['id'] as String,
      name: values['name'] as String,
      origin: values['origin'] as String?,
      base: values['base'] as bool?,
      deprecated: values['deprecated'] as bool?,
      effect: textOrActiveEffectFromItem(values, 'effect'),
      hideActive: values['hideActive'] as bool?,
      buildFeature: values['buildFeature'] as bool?,
      mod: values['mod'] as String?,
      tags: mapItems(values['tags'], tagFromItem),
      actions: mapItems(values['actions'], actionFromItem),
      bonuses: mapItems(values['bonuses'], bonusFromItemValues),
      synergies: mapItems(values['synergies'], synergyFromItem),
      deployables: mapItems(values['deployables'], deployableFromItem),
    );

/// Ensamblador reutilizable — usado tanto por `buildNpcFeatureFormSchema`
/// (nivel superior) como por `IEidolonLayerData.features`/`IEidolonShardData
/// .features`, que anidan `INpcFeatureData` dentro de otra entidad.
INpcFeatureData npcFeatureFromFormValues(Map<String, dynamic> values) {
  final base = _npcFeatureBaseFromValues(values);
  final choice = values['kind.choice'] as String? ?? 'trait';

  switch (choice) {
    case 'system':
      return INpcSystemFeatureData(
        id: base.id,
        name: base.name,
        origin: base.origin,
        base: base.base,
        deprecated: base.deprecated,
        effect: base.effect,
        hideActive: base.hideActive,
        buildFeature: base.buildFeature,
        mod: base.mod,
        tags: base.tags,
        actions: base.actions,
        bonuses: base.bonuses,
        synergies: base.synergies,
        deployables: base.deployables,
      );
    case 'reaction':
      final group =
          (values['kind.reaction'] as Map<String, dynamic>?) ?? const {};
      return INpcReactionFeatureData(
        id: base.id,
        name: base.name,
        origin: base.origin,
        base: base.base,
        deprecated: base.deprecated,
        effect: base.effect,
        hideActive: base.hideActive,
        buildFeature: base.buildFeature,
        mod: base.mod,
        tags: base.tags,
        actions: base.actions,
        bonuses: base.bonuses,
        synergies: base.synergies,
        deployables: base.deployables,
        trigger: group['trigger'] as String?,
      );
    case 'tech':
      final group = (values['kind.tech'] as Map<String, dynamic>?) ?? const {};
      return INpcTechFeatureData(
        id: base.id,
        name: base.name,
        origin: base.origin,
        base: base.base,
        deprecated: base.deprecated,
        effect: base.effect,
        hideActive: base.hideActive,
        buildFeature: base.buildFeature,
        mod: base.mod,
        tags: base.tags,
        actions: base.actions,
        bonuses: base.bonuses,
        synergies: base.synergies,
        deployables: base.deployables,
        attackBonus: tierValueFromItem(group, 'attackBonus'),
        accuracy: tierValueFromItem(group, 'accuracy'),
      );
    case 'weapon':
      final group =
          (values['kind.weapon'] as Map<String, dynamic>?) ?? const {};
      return INpcWeaponFeatureData(
        id: base.id,
        name: base.name,
        origin: base.origin,
        base: base.base,
        deprecated: base.deprecated,
        effect: base.effect,
        hideActive: base.hideActive,
        buildFeature: base.buildFeature,
        mod: base.mod,
        tags: base.tags,
        actions: base.actions,
        bonuses: base.bonuses,
        synergies: base.synergies,
        deployables: base.deployables,
        weaponType: group['weaponType'] as String? ?? '',
        damage: mapItems(group['damage'], _npcDamageFromItem) ?? const [],
        range: mapItems(group['range'], rangeDataFromItem) ?? const [],
        attacks: tierValueFromItem(group, 'attacks') ?? TierValue.single(1),
        attackBonus: tierValueFromItem(group, 'attackBonus'),
        accuracy: tierValueFromItem(group, 'accuracy'),
        onAttack: activeEffectFromGroupOrNull(group, 'onAttack'),
        onHit: activeEffectFromGroupOrNull(group, 'onHit'),
        onCrit: activeEffectFromGroupOrNull(group, 'onCrit'),
        onMiss: activeEffectFromGroupOrNull(group, 'onMiss'),
      );
    default:
      return INpcTraitFeatureData(
        id: base.id,
        name: base.name,
        origin: base.origin,
        base: base.base,
        deprecated: base.deprecated,
        effect: base.effect,
        hideActive: base.hideActive,
        buildFeature: base.buildFeature,
        mod: base.mod,
        tags: base.tags,
        actions: base.actions,
        bonuses: base.bonuses,
        synergies: base.synergies,
        deployables: base.deployables,
      );
  }
}

final npcFeatureCrearConfig = EntityCrearConfig(
  title: 'Crear NPC feature',
  contentKey: 'npc_features',
  buildSchema: buildNpcFeatureFormSchema,
  fromFormValues: npcFeatureFromFormValues,
  idOf: (content) => (content as INpcFeatureData).id,
  nameOf: (content) => (content as INpcFeatureData).name,
);
