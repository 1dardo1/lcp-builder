import '../../domain/domain.dart';
import 'common_entity_fields.dart';
import 'entity_crear_config.dart';
import 'field_spec.dart';

/// Esquema de campos de [ITalentData] (sección 11.6 del modelo de
/// dominio). `ranks` es una lista de `IRankData`, que repite el mismo
/// "paquete" de actions/bonuses/synergies/deployables/counters/
/// activeEffects que arma/reserve/core bonus — aquí anidado dentro de
/// cada rank, no al nivel superior del talento (el talento en sí no tiene
/// ese paquete, solo sus ranks lo tienen).
List<FieldSpec> _rankItemFields() => [
  const TextFieldSpec(
    key: 'name',
    label: 'Nombre',
    required: true,
    helpText: 'El nombre visible de este rank del talento.',
  ),
  const TextFieldSpec(
    key: 'description',
    label: 'Descripción',
    required: true,
    maxLines: 3,
    helpText: 'Texto de reglas de este rank.',
  ),
  const BoolFieldSpec(
    key: 'exclusive',
    label: 'Exclusivo (relacional entre los ranks de este talento)',
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
    label: 'Integrated (IDs)',
    itemFields: [
      TextFieldSpec(
        key: 'id',
        label: 'ID',
        required: true,
        helpText: 'El ID de otro sistema/equipo incluido gratis, no su nombre.',
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

IRankData _rankFromItem(Map<String, dynamic> item) => IRankData(
  name: item['name'] as String,
  description: item['description'] as String,
  exclusive: item['exclusive'] as bool?,
  actions: mapItems(item['actions'], actionFromItem),
  bonuses: mapItems(item['bonuses'], bonusFromItemValues),
  synergies: mapItems(item['synergies'], synergyFromItem),
  deployables: mapItems(item['deployables'], deployableFromItem),
  counters: mapItems(item['counters'], counterFromItem),
  integrated: mapStringIdItems(item['integrated']),
  specialEquipment: mapStringIdItems(item['specialEquipment']),
  activeEffects: mapItems(item['activeEffects'], activeEffectFromGroup),
);

List<FieldSpec> buildTalentFormSchema() => [
  const TextFieldSpec(
    key: 'id',
    label: 'ID',
    required: true,
    helpText: 'Identificador único del talento. Minúsculas, sin espacios.',
  ),
  const TextFieldSpec(
    key: 'name',
    label: 'Nombre',
    required: true,
    helpText: 'El nombre visible del talento, ej. "Gunslinger".',
  ),
  const TextFieldSpec(
    key: 'description',
    label: 'Descripción',
    required: true,
    maxLines: 3,
    helpText: 'Texto de ambientación sobre este talento.',
  ),
  ListFieldSpec(
    key: 'ranks',
    label: 'Ranks (3 en la práctica de COMP/CON)',
    itemFields: _rankItemFields(),
  ),
  const TextFieldSpec(
    key: 'iconSvg',
    jsonKey: 'icon_svg',
    label: 'Icono (SVG)',
    helpText: 'Contenido SVG del icono. Opcional.',
  ),
  const TextFieldSpec(
    key: 'iconUrl',
    jsonKey: 'icon_url',
    label: 'Icono (URL, si no hay SVG)',
    helpText: 'URL a una imagen de icono, solo si no hay SVG. Opcional.',
  ),
  const TextFieldSpec(
    key: 'terse',
    label: 'Descripción corta',
    helpText: 'Resumen de una línea del talento, si hace falta.',
  ),
];

ITalentData talentFromFormValues(Map<String, dynamic> values) {
  final rankItems =
      (values['ranks'] as List<Map<String, dynamic>>?) ?? const [];
  return ITalentData(
    id: values['id'] as String,
    name: values['name'] as String,
    description: values['description'] as String,
    ranks: [for (final item in rankItems) _rankFromItem(item)],
    iconSvg: values['iconSvg'] as String?,
    iconUrl: values['iconUrl'] as String?,
    terse: values['terse'] as String?,
  );
}

final talentCrearConfig = EntityCrearConfig(
  title: 'Crear talent',
  contentKey: 'talents',
  buildSchema: buildTalentFormSchema,
  fromFormValues: talentFromFormValues,
  idOf: (content) => (content as ITalentData).id,
  nameOf: (content) => (content as ITalentData).name,
);
