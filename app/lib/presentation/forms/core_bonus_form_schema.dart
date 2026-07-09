import '../../domain/domain.dart';
import 'common_entity_fields.dart';
import 'entity_crear_config.dart';
import 'field_spec.dart';

/// Esquema de campos de [ICoreBonusData] (sección 11.2 del modelo de
/// dominio). Riesgo conocido documentado en el dominio: COMP/CON no valida
/// referencias circulares en `integrated` — responsabilidad del formulario
/// evitarlo (no automatizado en este primer corte, ver vault MdD §11.2).
List<FieldSpec> buildCoreBonusFormSchema() => [
  const TextFieldSpec(
    key: 'id',
    label: 'ID',
    required: true,
    helpText: 'Identificador único del core bonus. Minúsculas, sin espacios.',
  ),
  const TextFieldSpec(
    key: 'name',
    label: 'Nombre',
    required: true,
    helpText: 'El nombre visible del core bonus.',
  ),
  const TextFieldSpec(
    key: 'source',
    label: 'Fabricante (debe coincidir con un Manufacturer ID)',
    required: true,
    helpText: 'El ID del fabricante (Manufacturer), no su nombre visible.',
    referenceEntityKey: 'manufacturers',
    referenceLabel: 'fabricante',
  ),
  const TextFieldSpec(
    key: 'effect',
    label: 'Efecto',
    required: true,
    maxLines: 3,
    helpText: 'Texto de reglas del core bonus.',
  ),
  const TextFieldSpec(
    key: 'description',
    label: 'Descripción',
    required: true,
    maxLines: 3,
    helpText: 'Texto de sabor/ambientación, sin efecto mecánico.',
  ),
  const TextFieldSpec(
    key: 'mountedEffect',
    jsonKey: 'mounted_effect',
    label: 'Efecto al instalar en un mount',
    maxLines: 2,
    helpText:
        'Texto de reglas adicional, solo si este core bonus hace algo '
        'especial al instalarse en un mount concreto.',
  ),
  ListFieldSpec(
    key: 'activeEffects',
    jsonKey: 'active_effects',
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
  ListFieldSpec(
    key: 'integrated',
    label: 'Integrated (IDs, instalado automáticamente)',
    itemFields: [
      TextFieldSpec(
        key: 'id',
        label: 'ID',
        required: true,
        helpText:
            'El ID de otro sistema/equipo que se instala automáticamente '
            'con este core bonus, no su nombre visible.',
      ),
    ],
  ),
  ListFieldSpec(
    key: 'specialEquipment',
    jsonKey: 'special_equipment',
    label: 'Special equipment (IDs, disponible en el selector)',
    itemFields: [
      TextFieldSpec(
        key: 'id',
        label: 'ID',
        required: true,
        helpText: 'El ID del equipo especial que se desbloquea, no su nombre.',
      ),
    ],
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
