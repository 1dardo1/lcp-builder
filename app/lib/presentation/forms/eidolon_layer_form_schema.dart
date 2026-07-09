import '../../domain/domain.dart';
import 'common_entity_fields.dart';
import 'entity_crear_config.dart';
import 'field_spec.dart';
import 'npc_feature_form_schema.dart';

/// Esquema de campos de [IEidolonLayerData] (sección 15.3 del modelo de
/// dominio). Última entidad de esta tanda — cierra los 3 usos de caso 6
/// del catálogo: reutiliza [npcFeatureItemFields]/[npcFeatureFromFormValues]
/// para `features` (anidando la unión discriminada de caso 1 dentro de
/// otra entidad), y resuelve `EidolonShardCount` (3 formas: número único,
/// por tier, o el literal `'hostile_characters'`) con el mismo mecanismo
/// `ShapeChoiceFieldSpec`/`GroupFieldSpec` que `TierValue`/`NpcSize` — sin
/// generalizar a `common_entity_fields.dart` porque, a diferencia de
/// `TierValue`, `EidolonShardCount` solo tiene este único consumidor
/// (mismo criterio ya aplicado: extraer solo con un segundo consumidor
/// real, no por especulación).
///
/// `contentKey`: la spec no confirma el nombre de archivo para esta
/// entidad (a diferencia de `weapons.json`/`systems.json`/`mods.json`/
/// `npc_classes.json`/`npc_features.json`/`npc_templates.json`, todos
/// citados explícitamente en el vault) — `eidolons` es una suposición
/// razonable pendiente de verificar contra un LCP real si el cliente usa
/// el suplemento de Eidolons (contenido condicionado, ver vault MdD §15.3).

/// `eidolonShardCountToJson`: el literal `'hostile_characters'`, un
/// número suelto, o un array de 3 — la forma del propio valor ya dice la
/// rama.
String? _shardCountBranchFromJson(Map<String, dynamic> json) {
  final raw = json['count'];
  if (raw == 'hostile_characters') return 'hostile';
  if (raw is List) return 'perTier';
  if (raw is num) return 'single';
  return null;
}

FieldSpec _shardCountField() => const ShapeChoiceFieldSpec(
  key: 'count',
  label: 'Shard count',
  required: true,
  branchFromJson: _shardCountBranchFromJson,
  options: [
    ShapeChoiceOption(
      value: 'single',
      label: 'Único (los 3 tiers)',
      field: NumberFieldSpec(
        key: 'count.single',
        jsonKey: 'count',
        label: 'Nº de shards',
      ),
    ),
    ShapeChoiceOption(
      value: 'perTier',
      label: 'Por tier',
      field: GroupFieldSpec(
        key: 'count.perTier',
        jsonKey: 'count',
        label: 'Nº de shards por tier',
        fields: [
          NumberFieldSpec(key: 'tier1', label: 'Tier 1', required: true),
          NumberFieldSpec(key: 'tier2', label: 'Tier 2', required: true),
          NumberFieldSpec(key: 'tier3', label: 'Tier 3', required: true),
        ],
      ),
    ),
    ShapeChoiceOption(
      value: 'hostile',
      label: 'Hostile characters (dinámico, resuelto por COMP/CON)',
    ),
  ],
);

EidolonShardCount _shardCountFromGroup(Map<String, dynamic> group) {
  final choice = group['count.choice'] as String? ?? 'single';
  if (choice == 'hostile') {
    return const EidolonShardCount.hostileCharacters();
  }
  if (choice == 'perTier') {
    final g = (group['count.perTier'] as Map<String, dynamic>?) ?? const {};
    return EidolonShardCount.perTier([
      (g['tier1'] as num?) ?? 0,
      (g['tier2'] as num?) ?? 0,
      (g['tier3'] as num?) ?? 0,
    ]);
  }
  return EidolonShardCount.single((group['count.single'] as num?) ?? 0);
}

List<FieldSpec> _shardFields() => [
  _shardCountField(),
  const TextFieldSpec(
    key: 'detail',
    label: 'Detalle',
    required: true,
    maxLines: 3,
    helpText: 'Texto de reglas/sabor de este shard.',
  ),
  ListFieldSpec(
    key: 'features',
    label: 'Features',
    itemFields: npcFeatureItemFields(),
  ),
  const NumberFieldSpec(
    key: 'tier',
    label: 'Tier (si se omite, usa el del layer)',
  ),
];

IEidolonShardData? _shardFromGroup(Map<String, dynamic>? group) {
  if (group == null) return null;
  final detail = group['detail'] as String?;
  if (detail == null || detail.isEmpty) return null;
  return IEidolonShardData(
    count: _shardCountFromGroup(group),
    detail: detail,
    features: mapItems(group['features'], npcFeatureFromFormValues) ?? const [],
    tier: (group['tier'] as num?)?.toInt(),
  );
}

List<FieldSpec> buildEidolonLayerFormSchema() => [
  const TextFieldSpec(
    key: 'id',
    label: 'ID',
    required: true,
    helpText:
        'Identificador único del eidolon layer. Minúsculas, sin espacios.',
  ),
  const TextFieldSpec(
    key: 'name',
    label: 'Nombre',
    required: true,
    helpText: 'El nombre visible de esta capa del eidolon.',
  ),
  const TextFieldSpec(
    key: 'appearance',
    label: 'Apariencia',
    required: true,
    maxLines: 3,
    helpText: 'Cómo cambia visualmente el eidolon en esta capa.',
  ),
  const TextFieldSpec(
    key: 'hints',
    label: 'Hints (dirigido a jugadores)',
    required: true,
    maxLines: 3,
    helpText: 'Pistas narrativas para los jugadores sobre esta capa.',
  ),
  const TextFieldSpec(
    key: 'rules',
    label: 'Rules (admite sintaxis {X/Y/Z} sensible a tier)',
    required: true,
    maxLines: 4,
    helpText:
        'Texto de reglas de esta capa. Si un número cambia según el tier '
        'del NPC, escribe "{valor_tier1/valor_tier2/valor_tier3}".',
  ),
  ListFieldSpec(
    key: 'features',
    label: 'Features',
    itemFields: npcFeatureItemFields(),
  ),
  GroupFieldSpec(key: 'shards', label: 'Shards', fields: _shardFields()),
  ListFieldSpec(
    key: 'activeEffects',
    jsonKey: 'active_effects',
    label: 'Active effects',
    itemFields: activeEffectFields(),
  ),
];

IEidolonLayerData eidolonLayerFromFormValues(Map<String, dynamic> values) =>
    IEidolonLayerData(
      id: values['id'] as String,
      name: values['name'] as String,
      appearance: values['appearance'] as String,
      hints: values['hints'] as String,
      rules: values['rules'] as String,
      features: mapItems(values['features'], npcFeatureFromFormValues),
      shards: _shardFromGroup(values['shards'] as Map<String, dynamic>?),
      activeEffects: mapItems(values['activeEffects'], activeEffectFromGroup),
    );

final eidolonLayerCrearConfig = EntityCrearConfig(
  title: 'Crear eidolon layer',
  contentKey: 'eidolons',
  buildSchema: buildEidolonLayerFormSchema,
  fromFormValues: eidolonLayerFromFormValues,
  idOf: (content) => (content as IEidolonLayerData).id,
  nameOf: (content) => (content as IEidolonLayerData).name,
);
