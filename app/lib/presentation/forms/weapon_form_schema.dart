import '../../domain/domain.dart';
import 'common_entity_fields.dart';
import 'entity_crear_config.dart';
import 'field_spec.dart';

/// Esquema de campos de [IWeaponData] para el motor genérico — cobertura
/// completa de la entidad (todos los campos de `IWeaponData`), con una
/// única excepción documentada por decisión consciente: `IDeployableData`
/// no expone su propio campo `deployables` (recursión de deployable dentro
/// de deployable) — el propio dominio ya anota que en la práctica "no crea
/// jerarquías reales" (mismo patrón que Action/ActiveEffect); se prioriza
/// no añadir profundidad de anidación ilimitada al formulario por un caso
/// que no ocurre en contenido real.
///
/// Las piezas reutilizadas por otras entidades (Reserve/CoreBonus/Talent)
/// viven en `common_entity_fields.dart` — este archivo solo tiene lo
/// específico de arma: `ammo`, el bundle `weaponEffectFields`/`profiles`
/// (con `onAttack`/`onHit`/`onCrit`/`onMiss`/`skirmish`/`barrage`/`cost`,
/// que ninguna otra entidad tiene), el campo `type` (único o lista), y el
/// ensamblador final.

// --- Sección 9: IAmmoData (solo la usa arma) ---

List<FieldSpec> _ammoItemFields() => [
  const TextFieldSpec(key: 'name', label: 'Nombre', required: true),
  const TextFieldSpec(
    key: 'description',
    label: 'Descripción',
    required: true,
    maxLines: 2,
  ),
  const NumberFieldSpec(key: 'cost', label: 'Coste'),
  MultiEnumFieldSpec<WeaponType>(
    key: 'allowedTypes',
    label: 'Tipos permitidos (vacío = todos)',
    options: WeaponType.values,
    displayLabel: (t) => t.jsonValue,
  ),
  MultiEnumFieldSpec<WeaponSize>(
    key: 'allowedSizes',
    label: 'Tamaños permitidos (vacío = todos)',
    options: WeaponSize.values,
    displayLabel: (s) => s.jsonValue,
  ),
  MultiEnumFieldSpec<WeaponType>(
    key: 'restrictedTypes',
    label: 'Tipos restringidos',
    options: WeaponType.values,
    displayLabel: (t) => t.jsonValue,
  ),
  MultiEnumFieldSpec<WeaponSize>(
    key: 'restrictedSizes',
    label: 'Tamaños restringidos',
    options: WeaponSize.values,
    displayLabel: (s) => s.jsonValue,
  ),
];

IAmmoData _ammoFromItem(Map<String, dynamic> item) => IAmmoData(
  name: item['name'] as String,
  description: item['description'] as String,
  cost: (item['cost'] as num?)?.toInt(),
  allowedTypes: emptyToNull(item['allowedTypes'] as List?)?.cast<WeaponType>(),
  allowedSizes: emptyToNull(item['allowedSizes'] as List?)?.cast<WeaponSize>(),
  restrictedTypes: emptyToNull(
    item['restrictedTypes'] as List?,
  )?.cast<WeaponType>(),
  restrictedSizes: emptyToNull(
    item['restrictedSizes'] as List?,
  )?.cast<WeaponSize>(),
);

// --- Sección 13.3: IWeaponProfile / IWeaponData ---

/// Campos compartidos entre `IWeaponData` (nivel superior) y cada ítem de
/// `profiles` (`IWeaponProfile`) — ambos tipos del dominio repiten
/// literalmente estos campos (mismo nombre, mismo tipo). Se reutiliza la
/// misma lista de [FieldSpec] en ambos puntos: las keys son relativas al
/// contexto de lectura/escritura activo, así que no colisionan.
List<FieldSpec> _weaponEffectFields() => [
  ListFieldSpec(
    key: 'activeEffects',
    label: 'Active effects',
    itemFields: activeEffectFields(),
  ),
  ListFieldSpec(key: 'damage', label: 'Daño', itemFields: damageItemFields()),
  ListFieldSpec(key: 'range', label: 'Alcance', itemFields: rangeItemFields()),
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
  textOrActiveEffectField('onAttack', 'Al atacar'),
  textOrActiveEffectField('onHit', 'Al acertar'),
  textOrActiveEffectField('onCrit', 'Al crítico'),
  textOrActiveEffectField('onMiss', 'Al fallar'),
  const BoolFieldSpec(key: 'skirmish', label: 'Skirmish'),
  const BoolFieldSpec(key: 'barrage', label: 'Barrage'),
  const NumberFieldSpec(key: 'cost', label: 'Coste (si tiene tag limited)'),
];

List<FieldSpec> _profileItemFields() => [
  const TextFieldSpec(key: 'name', label: 'Nombre', required: true),
  textOrActiveEffectField('effect', 'Efecto'),
  ..._weaponEffectFields(),
];

IWeaponProfile _profileFromItem(Map<String, dynamic> item) => IWeaponProfile(
  name: item['name'] as String,
  effect: textOrActiveEffectFromItem(item, 'effect'),
  skirmish: item['skirmish'] as bool?,
  barrage: item['barrage'] as bool?,
  cost: (item['cost'] as num?)?.toInt(),
  onAttack: textOrActiveEffectFromItem(item, 'onAttack'),
  onHit: textOrActiveEffectFromItem(item, 'onHit'),
  onCrit: textOrActiveEffectFromItem(item, 'onCrit'),
  onMiss: textOrActiveEffectFromItem(item, 'onMiss'),
  activeEffects: mapItems(item['activeEffects'], activeEffectFromGroup),
  damage: mapItems(item['damage'], damageDataFromItem),
  range: mapItems(item['range'], rangeDataFromItem),
  actions: mapItems(item['actions'], actionFromItem),
  bonuses: mapItems(item['bonuses'], bonusFromItemValues),
  synergies: mapItems(item['synergies'], synergyFromItem),
  deployables: mapItems(item['deployables'], deployableFromItem),
  counters: mapItems(item['counters'], counterFromItem),
  integrated: mapStringIdItems(item['integrated']),
  specialEquipment: mapStringIdItems(item['specialEquipment']),
);

/// `type`: `WeaponType | List<WeaponType>` — elección entre un único tipo
/// (lo habitual) o varios (armas que pertenecen a más de un `WeaponType`).
const _weaponTypeField = ShapeChoiceFieldSpec(
  key: 'type',
  label: 'Tipo de arma',
  required: true,
  optionALabel: 'Único',
  optionA: EnumFieldSpec<WeaponType>(
    key: 'type.a',
    label: 'Tipo',
    options: WeaponType.values,
    displayLabel: _weaponTypeLabel,
  ),
  optionBLabel: 'Varios',
  optionB: MultiEnumFieldSpec<WeaponType>(
    key: 'type.b',
    label: 'Tipos',
    options: WeaponType.values,
    displayLabel: _weaponTypeLabel,
  ),
);

String _weaponTypeLabel(WeaponType t) => t.jsonValue;

Object _weaponTypeFromValues(Map<String, dynamic> values) {
  final choice = values['type.choice'] as String? ?? 'A';
  if (choice == 'A') {
    return (values['type.a'] as WeaponType?) ?? WeaponType.rifle;
  }
  final list = (values['type.b'] as List?)?.cast<WeaponType>() ?? const [];
  return list.isEmpty ? WeaponType.rifle : list;
}

List<FieldSpec> buildWeaponFormSchema() => [
  const TextFieldSpec(key: 'id', label: 'ID', required: true),
  const TextFieldSpec(key: 'name', label: 'Nombre', required: true),
  const TextFieldSpec(
    key: 'source',
    label: 'Fabricante (source)',
    required: true,
  ),
  const TextFieldSpec(
    key: 'license',
    label: 'Licencia (nombre de display)',
    required: true,
  ),
  const TextFieldSpec(
    key: 'licenseId',
    label: 'ID de la licencia (frame)',
    required: true,
  ),
  const NumberFieldSpec(
    key: 'licenseLevel',
    label: 'Nivel de licencia (0-3)',
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
  const NumberFieldSpec(key: 'sp', label: 'SP'),
  EnumFieldSpec<MountType>(
    key: 'mount',
    label: 'Mount',
    required: true,
    options: MountType.values,
    displayLabel: (m) => m.jsonValue,
  ),
  _weaponTypeField,
  ListFieldSpec(key: 'ammo', label: 'Ammo', itemFields: _ammoItemFields()),
  const ListFieldSpec(
    key: 'tags',
    label: 'Tags',
    itemFields: [
      TextFieldSpec(
        key: 'id',
        label: 'ID del tag (ej. tg_accurate)',
        required: true,
      ),
    ],
  ),
  const BoolFieldSpec(key: 'noAttack', label: 'No genera acciones de ataque'),
  const BoolFieldSpec(key: 'noMods', label: 'No admite mods'),
  const BoolFieldSpec(
    key: 'noCoreBonus',
    label: 'Ignora core bonuses de mount',
  ),
  const BoolFieldSpec(key: 'noBonus', label: 'Ignora bonuses'),
  const BoolFieldSpec(key: 'noSynergy', label: 'Ignora synergies'),
  ..._weaponEffectFields(),
  ListFieldSpec(
    key: 'profiles',
    label: 'Profiles',
    itemFields: _profileItemFields(),
  ),
];

/// Ensambla los valores crudos del formulario en un [IWeaponData] real.
/// Este paso es intrínsecamente específico de la entidad — el motor
/// genérico no puede (ni debe) saber cómo construir un `IWeaponData`.
IWeaponData weaponFromFormValues(Map<String, dynamic> values) {
  return IWeaponData(
    id: values['id'] as String,
    name: values['name'] as String,
    source: values['source'] as String,
    license: values['license'] as String,
    licenseId: values['licenseId'] as String,
    licenseLevel: (values['licenseLevel'] as num?)?.toInt() ?? 0,
    effect: values['effect'] as String,
    description: values['description'] as String,
    mount: values['mount'] as MountType,
    type: _weaponTypeFromValues(values),
    ammo: mapItems(values['ammo'], _ammoFromItem),
    cost: (values['cost'] as num?)?.toInt(),
    barrage: values['barrage'] as bool?,
    skirmish: values['skirmish'] as bool?,
    noAttack: values['noAttack'] as bool?,
    noMods: values['noMods'] as bool?,
    noCoreBonus: values['noCoreBonus'] as bool?,
    damage: mapItems(values['damage'], damageDataFromItem),
    range: mapItems(values['range'], rangeDataFromItem),
    tags: mapItems(values['tags'], tagFromItem),
    sp: (values['sp'] as num?)?.toInt(),
    onAttack: textOrActiveEffectFromItem(values, 'onAttack'),
    onHit: textOrActiveEffectFromItem(values, 'onHit'),
    onCrit: textOrActiveEffectFromItem(values, 'onCrit'),
    onMiss: textOrActiveEffectFromItem(values, 'onMiss'),
    activeEffects: mapItems(values['activeEffects'], activeEffectFromGroup),
    actions: mapItems(values['actions'], actionFromItem),
    bonuses: mapItems(values['bonuses'], bonusFromItemValues),
    noBonus: values['noBonus'] as bool?,
    synergies: mapItems(values['synergies'], synergyFromItem),
    noSynergy: values['noSynergy'] as bool?,
    deployables: mapItems(values['deployables'], deployableFromItem),
    counters: mapItems(values['counters'], counterFromItem),
    integrated: mapStringIdItems(values['integrated']),
    specialEquipment: mapStringIdItems(values['specialEquipment']),
    profiles: mapItems(values['profiles'], _profileFromItem),
  );
}

final weaponCrearConfig = EntityCrearConfig(
  title: 'Crear arma',
  contentKey: 'weapons',
  buildSchema: buildWeaponFormSchema,
  fromFormValues: weaponFromFormValues,
  idOf: (content) => (content as IWeaponData).id,
  nameOf: (content) => (content as IWeaponData).name,
);
