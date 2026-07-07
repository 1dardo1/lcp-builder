import '../../domain/domain.dart';
import 'common_entity_fields.dart';
import 'entity_crear_config.dart';
import 'field_spec.dart';

/// Esquema de campos de [INpcTemplateData] (sección 15.1 del modelo de
/// dominio). Sin caso polimórfico propio — mismo patrón que las entidades
/// "trivial" de la primera tanda, campos planos + una lista de IDs.
List<FieldSpec> buildNpcTemplateFormSchema() => [
  const TextFieldSpec(key: 'id', label: 'ID', required: true),
  const TextFieldSpec(key: 'name', label: 'Nombre', required: true),
  const TextFieldSpec(
    key: 'description',
    label: 'Descripción',
    required: true,
    maxLines: 3,
  ),
  EnumFieldSpec<NpcForceTag>(
    key: 'forceTag',
    label: 'Force tag (bloquea el tag NPC, no editable por el usuario)',
    options: NpcForceTag.values,
    displayLabel: (t) => t.jsonValue,
  ),
  const ListFieldSpec(
    key: 'prohibitTemplates',
    label: 'Templates cuya aplicación conjunta se prohíbe (IDs)',
    itemFields: [TextFieldSpec(key: 'id', label: 'ID', required: true)],
  ),
  const NumberFieldSpec(key: 'optionalMin', label: 'Optional min (default 0)'),
  const NumberFieldSpec(key: 'optionalMax', label: 'Optional max'),
  const NumberFieldSpec(
    key: 'optionalPerTier',
    label: 'Optional per tier (cálculo aditivo, ver vault §15.1)',
  ),
  const NumberFieldSpec(key: 'optionalClassMin', label: 'Optional class min'),
  const NumberFieldSpec(key: 'optionalClassMax', label: 'Optional class max'),
  const NumberFieldSpec(
    key: 'optionalClassPerTier',
    label: 'Optional class per tier',
  ),
  const TextFieldSpec(
    key: 'caveat',
    label: 'Caveat (reglas especiales no trackeadas por COMP/CON)',
    maxLines: 2,
  ),
  ListFieldSpec(
    key: 'activeEffects',
    label: 'Active effects',
    itemFields: activeEffectFields(),
  ),
];

INpcTemplateData npcTemplateFromFormValues(Map<String, dynamic> values) =>
    INpcTemplateData(
      id: values['id'] as String,
      name: values['name'] as String,
      description: values['description'] as String,
      forceTag: values['forceTag'] as NpcForceTag?,
      prohibitTemplates: mapStringIdItems(values['prohibitTemplates']),
      optionalMin: (values['optionalMin'] as num?)?.toInt(),
      optionalMax: (values['optionalMax'] as num?)?.toInt(),
      optionalPerTier: (values['optionalPerTier'] as num?)?.toInt(),
      optionalClassMin: (values['optionalClassMin'] as num?)?.toInt(),
      optionalClassMax: (values['optionalClassMax'] as num?)?.toInt(),
      optionalClassPerTier: (values['optionalClassPerTier'] as num?)?.toInt(),
      caveat: values['caveat'] as String?,
      activeEffects: mapItems(values['activeEffects'], activeEffectFromGroup),
    );

final npcTemplateCrearConfig = EntityCrearConfig(
  title: 'Crear NPC template',
  contentKey: 'npc_templates',
  buildSchema: buildNpcTemplateFormSchema,
  fromFormValues: npcTemplateFromFormValues,
  idOf: (content) => (content as INpcTemplateData).id,
  nameOf: (content) => (content as INpcTemplateData).name,
);
