import '../../domain/domain.dart';
import 'common_entity_fields.dart';
import 'entity_crear_config.dart';
import 'field_spec.dart';

/// Esquema de campos de [IPilotGearData] (sección 11.3 del modelo de
/// dominio). Primera entidad de esta tanda con caso 1/2 del catálogo
/// (unión discriminada por tag `type` — `Weapon`/`Armor`/`Gear`, con el
/// discriminador viviendo en el tipo Dart como `sealed class`, no como
/// campo). Se resuelve con la misma composición que el caso 6
/// (`ShapeChoiceFieldSpec` + `GroupFieldSpec`, ver vault "Decisión -
/// variabilidad por tier de NPC"): el usuario elige qué variante construir
/// con un selector de N ramas, y cada rama es un `GroupFieldSpec` con los
/// campos propios de esa variante — no hace falta un `FieldSpec` nuevo
/// tampoco para este caso.
List<FieldSpec> _pilotWeaponFields() => [
  const TextFieldSpec(
    key: 'description',
    label: 'Descripción',
    maxLines: 3,
    helpText: 'Texto de sabor/ambientación, sin efecto mecánico.',
  ),
  const TextFieldSpec(
    key: 'effect',
    label: 'Efecto',
    maxLines: 3,
    helpText:
        'Texto de reglas — lo que hace mecánicamente esta arma de piloto.',
  ),
  ListFieldSpec(key: 'range', label: 'Alcance', itemFields: rangeItemFields()),
  ListFieldSpec(key: 'damage', label: 'Daño', itemFields: damageItemFields()),
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
    label: 'Actions (solo disponibles con el piloto UNMOUNTED)',
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
    label: 'Deployables (solo disponibles con el piloto UNMOUNTED)',
    itemFields: deployableItemFields(),
  ),
  ListFieldSpec(
    key: 'counters',
    label: 'Counters',
    itemFields: counterItemFields(),
  ),
  ListFieldSpec(
    key: 'activeEffects',
    jsonKey: 'active_effects',
    label: 'Active effects (se aplican al piloto, no al mech)',
    itemFields: activeEffectFields(),
  ),
];

List<FieldSpec> _pilotArmorOrGearFields() => [
  const TextFieldSpec(
    key: 'description',
    label: 'Descripción',
    maxLines: 3,
    helpText: 'Texto de reglas y/o sabor de este equipo de piloto.',
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
  ListFieldSpec(
    key: 'counters',
    label: 'Counters',
    itemFields: counterItemFields(),
  ),
];

List<FieldSpec> buildPilotGearFormSchema() => [
  const TextFieldSpec(
    key: 'id',
    label: 'ID',
    required: true,
    helpText: 'Identificador único del pilot gear. Minúsculas, sin espacios.',
  ),
  const TextFieldSpec(
    key: 'name',
    label: 'Nombre',
    required: true,
    helpText: 'El nombre visible del pilot gear.',
  ),
  ShapeChoiceFieldSpec(
    key: 'kind',
    jsonKey: 'type',
    label: 'Tipo de gear',
    required: true,
    options: [
      ShapeChoiceOption(
        value: 'weapon',
        label: 'Weapon',
        field: GroupFieldSpec(
          key: 'kind.weapon',
          label: 'Datos del arma de piloto',
          fields: _pilotWeaponFields(),
        ),
      ),
      ShapeChoiceOption(
        value: 'armor',
        label: 'Armor',
        field: GroupFieldSpec(
          key: 'kind.armor',
          label: 'Datos de la armadura de piloto',
          fields: _pilotArmorOrGearFields(),
        ),
      ),
      ShapeChoiceOption(
        value: 'gear',
        label: 'Gear',
        field: GroupFieldSpec(
          key: 'kind.gear',
          label: 'Datos del gear de piloto',
          fields: _pilotArmorOrGearFields(),
        ),
      ),
    ],
  ),
];

IPilotGearData pilotGearFromFormValues(Map<String, dynamic> values) {
  final id = values['id'] as String;
  final name = values['name'] as String;
  final choice = values['kind.choice'] as String? ?? 'weapon';
  final group = (values['kind.$choice'] as Map<String, dynamic>?) ?? const {};

  switch (choice) {
    case 'weapon':
      return IPilotWeaponData(
        id: id,
        name: name,
        description: group['description'] as String?,
        effect: group['effect'] as String?,
        range: mapItems(group['range'], rangeDataFromItem),
        damage: mapItems(group['damage'], damageDataFromItem),
        tags: mapItems(group['tags'], tagFromItem),
        actions: mapItems(group['actions'], actionFromItem),
        bonuses: mapItems(group['bonuses'], bonusFromItemValues),
        synergies: mapItems(group['synergies'], synergyFromItem),
        deployables: mapItems(group['deployables'], deployableFromItem),
        counters: mapItems(group['counters'], counterFromItem),
        activeEffects: mapItems(group['activeEffects'], activeEffectFromGroup),
      );
    case 'armor':
      return IPilotArmorData(
        id: id,
        name: name,
        description: group['description'] as String?,
        tags: mapItems(group['tags'], tagFromItem),
        actions: mapItems(group['actions'], actionFromItem),
        bonuses: mapItems(group['bonuses'], bonusFromItemValues),
        synergies: mapItems(group['synergies'], synergyFromItem),
        deployables: mapItems(group['deployables'], deployableFromItem),
        counters: mapItems(group['counters'], counterFromItem),
      );
    default:
      return IPilotGearItemData(
        id: id,
        name: name,
        description: group['description'] as String?,
        tags: mapItems(group['tags'], tagFromItem),
        actions: mapItems(group['actions'], actionFromItem),
        bonuses: mapItems(group['bonuses'], bonusFromItemValues),
        synergies: mapItems(group['synergies'], synergyFromItem),
        deployables: mapItems(group['deployables'], deployableFromItem),
        counters: mapItems(group['counters'], counterFromItem),
      );
  }
}

final pilotGearCrearConfig = EntityCrearConfig(
  title: 'Crear pilot gear',
  contentKey: 'pilot_gear',
  buildSchema: buildPilotGearFormSchema,
  fromFormValues: pilotGearFromFormValues,
  idOf: (content) => (content as IPilotGearData).id,
  nameOf: (content) => (content as IPilotGearData).name,
);
