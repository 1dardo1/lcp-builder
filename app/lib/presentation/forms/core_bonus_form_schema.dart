import '../../domain/domain.dart';
import 'common_entity_fields.dart';
import 'entity_crear_config.dart';
import 'field_spec.dart';

/// Esquema de campos de [ICoreBonusData] (sección 11.2 del modelo de
/// dominio). Riesgo conocido documentado en el dominio: COMP/CON no valida
/// referencias circulares en `integrated` — responsabilidad del formulario
/// evitarlo (no automatizado en este primer corte, ver vault MdD §11.2).
List<FieldSpec> buildCoreBonusFormSchema() => [
  const TextFieldSpec(key: 'id', label: 'ID', required: true),
  const TextFieldSpec(key: 'name', label: 'Nombre', required: true),
  const TextFieldSpec(
    key: 'source',
    label: 'Fabricante (debe coincidir con un Manufacturer ID)',
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
  const TextFieldSpec(
    key: 'mountedEffect',
    label: 'Efecto al instalar en un mount',
    maxLines: 2,
  ),
  ListFieldSpec(
    key: 'activeEffects',
    label: 'Active effects',
    itemFields: activeEffectFields(),
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
    label: 'Integrated (IDs, instalado automáticamente)',
    itemFields: [TextFieldSpec(key: 'id', label: 'ID', required: true)],
  ),
  const ListFieldSpec(
    key: 'specialEquipment',
    label: 'Special equipment (IDs, disponible en el selector)',
    itemFields: [TextFieldSpec(key: 'id', label: 'ID', required: true)],
  ),
];

ICoreBonusData coreBonusFromFormValues(Map<String, dynamic> values) =>
    ICoreBonusData(
      id: values['id'] as String,
      name: values['name'] as String,
      source: values['source'] as String,
      effect: values['effect'] as String,
      description: values['description'] as String,
      mountedEffect: values['mountedEffect'] as String?,
      activeEffects: mapItems(values['activeEffects'], activeEffectFromGroup),
      actions: mapItems(values['actions'], actionFromItem),
      bonuses: mapItems(values['bonuses'], bonusFromItemValues),
      synergies: mapItems(values['synergies'], synergyFromItem),
      deployables: mapItems(values['deployables'], deployableFromItem),
      counters: mapItems(values['counters'], counterFromItem),
      integrated: mapStringIdItems(values['integrated']),
      specialEquipment: mapStringIdItems(values['specialEquipment']),
    );

final coreBonusCrearConfig = EntityCrearConfig(
  title: 'Crear core bonus',
  contentKey: 'core_bonuses',
  buildSchema: buildCoreBonusFormSchema,
  fromFormValues: coreBonusFromFormValues,
  idOf: (content) => (content as ICoreBonusData).id,
  nameOf: (content) => (content as ICoreBonusData).name,
);
