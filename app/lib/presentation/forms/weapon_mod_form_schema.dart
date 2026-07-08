import '../../domain/domain.dart';
import 'common_entity_fields.dart';
import 'entity_crear_config.dart';
import 'field_spec.dart';

/// Esquema de campos de [IWeaponModData] (sección 13.5 del modelo de
/// dominio). Extiende todos los campos de [IMechSystemData]
/// (`mechSystemBaseFields()`/`mechSystemBaseFromValues()` en
/// `common_entity_fields.dart`) más los específicos de mod.
///
/// `addedDamage`/`addedRange` no implementan aquí la regla de fusión por
/// tipo (ver vault MdD §13.5) — eso es lógica del caso de uso que *aplica*
/// un mod a un arma, no de la creación/exportación del mod en sí, que solo
/// necesita transportar los datos. `restrictedTypes`/`restrictedSizes`
/// (deprecados en este contexto, vigentes en Ammo) se exponen igualmente
/// por completitud de la entidad, con la etiqueta avisando del estado.
List<FieldSpec> buildWeaponModFormSchema() => [
  ...mechSystemBaseFields(),
  activeEffectGroupField('onMiss', 'Al fallar'),
  activeEffectGroupField('onAttack', 'Al atacar'),
  activeEffectGroupField('onHit', 'Al acertar'),
  activeEffectGroupField('onCrit', 'Al crítico'),
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
  const ListFieldSpec(
    key: 'addedTags',
    label: 'Tags añadidos (se quitan si el mod se quita)',
    itemFields: [TextFieldSpec(
        key: 'id',
        label: 'ID del tag',
        required: true,
        helpText: 'El ID del tag (Tag), no su nombre visible. Si el tag '
            'todavía no existe, usa el botón de crear tag desde el menú.',
      )],
  ),
  ListFieldSpec(
    key: 'addedDamage',
    label: 'Daño añadido (regla de fusión por tipo, ver vault §13.5)',
    itemFields: damageItemFields(),
  ),
  ListFieldSpec(
    key: 'addedRange',
    label: 'Alcance añadido',
    itemFields: rangeItemFields(),
  ),
  MultiEnumFieldSpec<WeaponType>(
    key: 'restrictedTypes',
    label: 'Tipos restringidos (DEPRECADO)',
    options: WeaponType.values,
    displayLabel: (t) => t.jsonValue,
  ),
  MultiEnumFieldSpec<WeaponSize>(
    key: 'restrictedSizes',
    label: 'Tamaños restringidos (DEPRECADO)',
    options: WeaponSize.values,
    displayLabel: (s) => s.jsonValue,
  ),
];

IWeaponModData weaponModFromFormValues(Map<String, dynamic> values) {
  final base = mechSystemBaseFromValues(values);
  return IWeaponModData(
    id: base.id,
    name: base.name,
    source: base.source,
    license: base.license,
    licenseId: base.licenseId,
    licenseLevel: base.licenseLevel,
    type: base.type,
    effect: base.effect,
    description: base.description,
    sp: base.sp,
    tags: base.tags,
    actions: base.actions,
    bonuses: base.bonuses,
    noBonus: base.noBonus,
    synergies: base.synergies,
    noSynergy: base.noSynergy,
    deployables: base.deployables,
    counters: base.counters,
    integrated: base.integrated,
    specialEquipment: base.specialEquipment,
    activeEffects: base.activeEffects,
    onMiss: activeEffectFromGroupOrNull(values, 'onMiss'),
    onAttack: activeEffectFromGroupOrNull(values, 'onAttack'),
    onHit: activeEffectFromGroupOrNull(values, 'onHit'),
    onCrit: activeEffectFromGroupOrNull(values, 'onCrit'),
    allowedTypes: emptyToNull(
      values['allowedTypes'] as List?,
    )?.cast<WeaponType>(),
    allowedSizes: emptyToNull(
      values['allowedSizes'] as List?,
    )?.cast<WeaponSize>(),
    addedTags: mapItems(values['addedTags'], tagFromItem),
    addedDamage: mapItems(values['addedDamage'], damageDataFromItem),
    addedRange: mapItems(values['addedRange'], rangeDataFromItem),
    restrictedTypes: emptyToNull(
      values['restrictedTypes'] as List?,
    )?.cast<WeaponType>(),
    restrictedSizes: emptyToNull(
      values['restrictedSizes'] as List?,
    )?.cast<WeaponSize>(),
  );
}

final weaponModCrearConfig = EntityCrearConfig(
  title: 'Crear weapon mod',
  contentKey: 'mods',
  buildSchema: buildWeaponModFormSchema,
  fromFormValues: weaponModFromFormValues,
  idOf: (content) => (content as IWeaponModData).id,
  nameOf: (content) => (content as IWeaponModData).name,
);
