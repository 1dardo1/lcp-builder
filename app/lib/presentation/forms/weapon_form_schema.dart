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
  const TextFieldSpec(
    key: 'name',
    label: 'Nombre',
    required: true,
    helpText: 'El nombre visible de este tipo de munición.',
  ),
  const TextFieldSpec(
    key: 'description',
    label: 'Descripción',
    required: true,
    maxLines: 2,
    helpText: 'Texto de reglas de esta munición.',
  ),
  const NumberFieldSpec(key: 'cost', label: 'Coste'),
  MultiEnumFieldSpec<WeaponType>(
    key: 'allowedTypes',
    jsonKey: 'allowed_types',
    label: 'Tipos permitidos (vacío = todos)',
    options: WeaponType.values,
    displayLabel: (t) => t.jsonValue,
    fromJsonValue: (s) => WeaponType.values.firstWhere((t) => t.jsonValue == s),
  ),
  MultiEnumFieldSpec<WeaponSize>(
    key: 'allowedSizes',
    jsonKey: 'allowed_sizes',
    label: 'Tamaños permitidos (vacío = todos)',
    options: WeaponSize.values,
    displayLabel: (s) => s.jsonValue,
    fromJsonValue: (s) => WeaponSize.values.firstWhere((w) => w.jsonValue == s),
  ),
  MultiEnumFieldSpec<WeaponType>(
    key: 'restrictedTypes',
    jsonKey: 'restricted_types',
    label: 'Tipos restringidos',
    options: WeaponType.values,
    displayLabel: (t) => t.jsonValue,
    fromJsonValue: (s) => WeaponType.values.firstWhere((t) => t.jsonValue == s),
  ),
  MultiEnumFieldSpec<WeaponSize>(
    key: 'restrictedSizes',
    jsonKey: 'restricted_sizes',
    label: 'Tamaños restringidos',
    options: WeaponSize.values,
    displayLabel: (s) => s.jsonValue,
    fromJsonValue: (s) => WeaponSize.values.firstWhere((w) => w.jsonValue == s),
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
    jsonKey: 'active_effects',
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
  textOrActiveEffectField('onAttack', 'Al atacar'),
  textOrActiveEffectField('onHit', 'Al acertar'),
  textOrActiveEffectField('onCrit', 'Al crítico'),
  textOrActiveEffectField('onMiss', 'Al fallar'),
  const BoolFieldSpec(key: 'skirmish', label: 'Skirmish'),
  const BoolFieldSpec(key: 'barrage', label: 'Barrage'),
  const NumberFieldSpec(key: 'cost', label: 'Coste (si tiene tag limited)'),
];

List<FieldSpec> _profileItemFields() => [
  const TextFieldSpec(
    key: 'name',
    label: 'Nombre',
    required: true,
    helpText: 'El nombre visible de este perfil de disparo del arma.',
  ),
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
  branchFromJson: _weaponTypeBranchFromJson,
  options: [
    ShapeChoiceOption(
      value: 'A',
      label: 'Único',
      field: EnumFieldSpec<WeaponType>(
        key: 'type.a',
        jsonKey: 'type',
        label: 'Tipo',
        options: WeaponType.values,
        displayLabel: _weaponTypeLabel,
        fromJsonValue: _weaponTypeFromJson,
      ),
    ),
    ShapeChoiceOption(
      value: 'B',
      label: 'Varios',
      field: MultiEnumFieldSpec<WeaponType>(
        key: 'type.b',
        jsonKey: 'type',
        label: 'Tipos',
        options: WeaponType.values,
        displayLabel: _weaponTypeLabel,
        fromJsonValue: _weaponTypeFromJson,
      ),
    ),
  ],
);

String _weaponTypeLabel(WeaponType t) => t.jsonValue;

WeaponType _weaponTypeFromJson(dynamic v) =>
    WeaponType.values.firstWhere((t) => t.jsonValue == v);

/// `type` es un único `WeaponType` (string) o una lista — la propia forma
/// del valor crudo ya dice qué rama es, sin necesitar ningún campo
/// discriminador aparte.
String? _weaponTypeBranchFromJson(Map<String, dynamic> json) {
  final raw = json['type'];
  if (raw is List) return 'B';
  if (raw is String) return 'A';
  return null;
}

Object _weaponTypeFromValues(Map<String, dynamic> values) {
  final choice = values['type.choice'] as String? ?? 'A';
  if (choice == 'A') {
    return (values['type.a'] as WeaponType?) ?? WeaponType.rifle;
  }
  final list = (values['type.b'] as List?)?.cast<WeaponType>() ?? const [];
  return list.isEmpty ? WeaponType.rifle : list;
}

List<FieldSpec> buildWeaponFormSchema() => [
  const TextFieldSpec(
    key: 'id',
    label: 'ID',
    required: true,
    helpText:
        'Identificador único del arma dentro de todo el .lcp (y, en la '
        'práctica, dentro de todo COMP/CON). Minúsculas, sin espacios — ej. '
        '"mw_rifle_pesado". No es el nombre visible, eso va en "Nombre".',
  ),
  const TextFieldSpec(
    key: 'name',
    label: 'Nombre',
    required: true,
    helpText: 'El nombre que verá el jugador en COMP/CON, ej. "Rifle pesado".',
  ),
  TextFieldSpec(
    key: 'source',
    label: 'Fabricante (source)',
    required: true,
    helpText:
        'El ID del fabricante (Manufacturer), NO su nombre visible. Ej.: '
        'si el fabricante se llama "General Manufacturing Systems" pero su '
        'ID es "GMS", aquí va "GMS". Si el fabricante todavía no existe, '
        'usa el botón de abajo para crearlo sin salir de este formulario.',
    referenceEntityKey: 'manufacturers',
    referenceLabel: 'fabricante',
  ),
  const TextFieldSpec(
    key: 'license',
    label: 'Licencia (nombre de display)',
    required: true,
    helpText:
        'El nombre visible de la licencia (normalmente el nombre del frame '
        'al que pertenece el arma), ej. "GMS Everest". A diferencia de '
        '"ID de la licencia" de abajo, aquí va el nombre, no el id.',
  ),
  TextFieldSpec(
    key: 'licenseId',
    jsonKey: 'license_id',
    label: 'ID de la licencia (frame)',
    required: true,
    helpText:
        'El ID del frame (Frame) al que pertenece esta arma — no su '
        'nombre visible. Si el frame todavía no existe, créalo con el '
        'botón de abajo; el id que le pongas ahí es el que va aquí.',
    referenceEntityKey: 'frames',
    referenceLabel: 'frame',
  ),
  const NumberFieldSpec(
    key: 'licenseLevel',
    jsonKey: 'license_level',
    label: 'Nivel de licencia (0-3)',
    required: true,
    helpText:
        'Rango de la licencia del frame que el piloto necesita desbloqueado '
        'para poder usar esta arma. 0 = disponible desde el rango base.',
  ),
  const TextFieldSpec(
    key: 'effect',
    label: 'Efecto',
    required: true,
    maxLines: 3,
    helpText: 'Texto de reglas del arma — lo que hace mecánicamente.',
  ),
  const TextFieldSpec(
    key: 'description',
    label: 'Descripción',
    required: true,
    maxLines: 3,
    helpText: 'Texto de sabor/ambientación, sin efecto mecánico.',
  ),
  const NumberFieldSpec(
    key: 'sp',
    label: 'SP',
    helpText: 'Coste en System Points del arma. Si se omite, cuenta como 0.',
  ),
  EnumFieldSpec<MountType>(
    key: 'mount',
    label: 'Mount',
    required: true,
    options: MountType.values,
    displayLabel: (m) => m.jsonValue,
    fromJsonValue: (s) => MountType.values.firstWhere((m) => m.jsonValue == s),
    helpText:
        'El tipo de mount que ocupa el arma en el frame (Main, Heavy, '
        'Aux, Flex...). Determina en qué hueco del mech se puede instalar.',
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
  const BoolFieldSpec(
    key: 'noAttack',
    jsonKey: 'no_attack',
    label: 'No genera acciones de ataque',
  ),
  const BoolFieldSpec(
    key: 'noMods',
    jsonKey: 'no_mods',
    label: 'No admite mods',
  ),
  const BoolFieldSpec(
    key: 'noCoreBonus',
    jsonKey: 'no_core_bonus',
    label: 'Ignora core bonuses de mount',
  ),
  const BoolFieldSpec(
    key: 'noBonus',
    jsonKey: 'no_bonus',
    label: 'Ignora bonuses',
  ),
  const BoolFieldSpec(
    key: 'noSynergy',
    jsonKey: 'no_synergy',
    label: 'Ignora synergies',
  ),
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
