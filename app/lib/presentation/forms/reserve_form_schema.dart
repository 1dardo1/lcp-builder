import '../../domain/domain.dart';
import 'common_entity_fields.dart';
import 'entity_crear_config.dart';
import 'field_spec.dart';

/// Esquema de campos de [IReserveData] (sección 11.4 del modelo de
/// dominio). Reutiliza el mismo "paquete" de actions/bonuses/synergies/
/// deployables/counters/activeEffects que arma, extraído a
/// `common_entity_fields.dart` precisamente para esto.
List<FieldSpec> buildReserveFormSchema() => [
  const TextFieldSpec(key: 'id', label: 'ID', required: true),
  const TextFieldSpec(key: 'name', label: 'Nombre', required: true),
  EnumFieldSpec<ReserveType>(
    key: 'type',
    label: 'Tipo (solo agrupa en pestañas de UI)',
    required: true,
    options: ReserveType.values,
    displayLabel: (t) => t.name,
  ),
  const TextFieldSpec(key: 'label', label: 'Etiqueta (default: el nombre)'),
  const TextFieldSpec(key: 'description', label: 'Descripción', maxLines: 3),
  const BoolFieldSpec(key: 'consumable', label: 'Consumible'),
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

IReserveData reserveFromFormValues(Map<String, dynamic> values) => IReserveData(
  id: values['id'] as String,
  name: values['name'] as String,
  type: values['type'] as ReserveType,
  label: values['label'] as String?,
  description: values['description'] as String?,
  consumable: values['consumable'] as bool?,
  actions: mapItems(values['actions'], actionFromItem),
  bonuses: mapItems(values['bonuses'], bonusFromItemValues),
  synergies: mapItems(values['synergies'], synergyFromItem),
  deployables: mapItems(values['deployables'], deployableFromItem),
  counters: mapItems(values['counters'], counterFromItem),
  integrated: mapStringIdItems(values['integrated']),
  specialEquipment: mapStringIdItems(values['specialEquipment']),
  activeEffects: mapItems(values['activeEffects'], activeEffectFromGroup),
);

final reserveCrearConfig = EntityCrearConfig(
  title: 'Crear reserve',
  contentKey: 'reserves',
  buildSchema: buildReserveFormSchema,
  fromFormValues: reserveFromFormValues,
  idOf: (content) => (content as IReserveData).id,
  nameOf: (content) => (content as IReserveData).name,
);
