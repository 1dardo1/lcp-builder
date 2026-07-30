/// Shared base field bundle for mech systems / weapon mods (domain section
/// 13.4).
library;

import '../../domain/domain.dart';
import 'field_spec.dart';
import 'field_help_texts.dart';
import 'field_mappers.dart';
import 'tag_fields.dart';
import 'action_fields.dart';
import 'bonus_fields.dart';
import 'synergy_fields.dart';
import 'deployable_fields.dart';
import 'counter_fields.dart';

// --- Sección 13.4 (IMechSystemData) — bundle base reutilizado por
// MechSystem y WeaponMod (WeaponMod extiende todos los campos de
// MechSystem, pero al ser clases de dominio distintas cada una necesita
// construir su propia instancia — no se puede "extender" un objeto ya
// construido). Mismo criterio que llevó a extraer el paquete de
// actions/bonuses/synergies/deployables a este módulo: un segundo
// consumidor real confirmando que merece la pena compartirlo. ---

List<FieldSpec> mechSystemBaseFields() => [
  const TextFieldSpec(
    key: 'id',
    label: 'ID',
    required: true,
    helpText:
        'Identificador único dentro del .lcp. Minúsculas, sin espacios — no '
        'es el nombre visible, eso va en "Nombre".',
  ),
  const TextFieldSpec(
    key: 'name',
    label: 'Nombre',
    required: true,
    helpText: 'El nombre que verá el jugador en COMP/CON.',
  ),
  const TextFieldSpec(
    key: 'source',
    label: 'Fabricante (source; opcional solo en License Collection)',
    helpText: manufacturerIdHelpText,
    referenceEntityKey: 'manufacturers',
    referenceLabel: 'fabricante',
  ),
  const TextFieldSpec(
    key: 'license',
    label: 'Licencia (opcional solo en License Collection)',
    helpText: 'Nombre visible de la licencia (normalmente el del frame).',
  ),
  const TextFieldSpec(
    key: 'licenseId',
    jsonKey: 'license_id',
    label: 'ID de la licencia (frame; opcional solo en License Collection)',
    helpText: 'El ID del frame al que pertenece, no su nombre visible.',
    referenceEntityKey: 'frames',
    referenceLabel: 'frame',
  ),
  const NumberFieldSpec(
    key: 'licenseLevel',
    jsonKey: 'license_level',
    label: 'Nivel de licencia (0-3)',
    required: true,
  ),
  EnumFieldSpec<SystemType>(
    key: 'type',
    label: 'Tipo (default: System)',
    options: SystemType.values,
    displayLabel: (t) => t.jsonValue,
    fromJsonValue: (s) => SystemType.values.firstWhere((t) => t.jsonValue == s),
  ),
  const TextFieldSpec(
    key: 'effect',
    label: 'Efecto',
    maxLines: 3,
    helpText: 'Texto de reglas del sistema — lo que hace mecánicamente.',
  ),
  const TextFieldSpec(
    key: 'description',
    label: 'Descripción',
    maxLines: 3,
    helpText: 'Texto de sabor/ambientación, sin efecto mecánico.',
  ),
  const NumberFieldSpec(key: 'sp', label: 'SP'),
  const ListFieldSpec(key: 'tags', label: 'Tags', itemFields: tagItemFields),
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
  const BoolFieldSpec(
    key: 'noBonus',
    jsonKey: 'no_bonus',
    label: 'Ignora bonuses',
  ),
  ListFieldSpec(
    key: 'synergies',
    label: 'Synergies',
    itemFields: synergyItemFields(),
  ),
  const BoolFieldSpec(
    key: 'noSynergy',
    jsonKey: 'no_synergy',
    label: 'Ignora synergies',
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
    label: 'Integrated (IDs, sin validar referencias circulares)',
    itemFields: [
      TextFieldSpec(
        key: 'id',
        label: 'ID',
        required: true,
        helpText:
            'El ID de otro sistema/equipo que viene incluido gratis '
            'con este, no su nombre visible.',
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

/// Valores comunes ya ensamblados desde `values` — cada entidad concreta
/// (`MechSystem`, `WeaponMod`) los pasa a su propio constructor de dominio
/// junto con sus campos específicos.
class MechSystemBaseValues {
  final String id;
  final String name;
  final String? source;
  final String? license;
  final String? licenseId;
  final int licenseLevel;
  final SystemType? type;
  final String? effect;
  final String? description;
  final int? sp;
  final List<ITagInstance>? tags;
  final List<IActionData>? actions;
  final List<IBonusData>? bonuses;
  final bool? noBonus;
  final List<ISynergyData>? synergies;
  final bool? noSynergy;
  final List<IDeployableData>? deployables;
  final List<ICounterData>? counters;
  final List<String>? integrated;
  final List<String>? specialEquipment;
  final List<IActiveEffectData>? activeEffects;

  const MechSystemBaseValues({
    required this.id,
    required this.name,
    this.source,
    this.license,
    this.licenseId,
    required this.licenseLevel,
    this.type,
    this.effect,
    this.description,
    this.sp,
    this.tags,
    this.actions,
    this.bonuses,
    this.noBonus,
    this.synergies,
    this.noSynergy,
    this.deployables,
    this.counters,
    this.integrated,
    this.specialEquipment,
    this.activeEffects,
  });
}

MechSystemBaseValues mechSystemBaseFromValues(Map<String, dynamic> values) =>
    MechSystemBaseValues(
      id: values['id'] as String,
      name: values['name'] as String,
      source: values['source'] as String?,
      license: values['license'] as String?,
      licenseId: values['licenseId'] as String?,
      licenseLevel: (values['licenseLevel'] as num?)?.toInt() ?? 0,
      type: values['type'] as SystemType?,
      effect: values['effect'] as String?,
      description: values['description'] as String?,
      sp: (values['sp'] as num?)?.toInt(),
      tags: mapItems(values['tags'], tagFromItem),
      actions: mapItems(values['actions'], actionFromItem),
      bonuses: mapItems(values['bonuses'], bonusFromItemValues),
      noBonus: values['noBonus'] as bool?,
      synergies: mapItems(values['synergies'], synergyFromItem),
      noSynergy: values['noSynergy'] as bool?,
      deployables: mapItems(values['deployables'], deployableFromItem),
      counters: mapItems(values['counters'], counterFromItem),
      integrated: mapStringIdItems(values['integrated']),
      specialEquipment: mapStringIdItems(values['specialEquipment']),
      activeEffects: mapItems(values['activeEffects'], activeEffectFromGroup),
    );
