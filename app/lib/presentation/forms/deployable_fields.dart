/// Deployable field builder and assembler (domain section 8).
library;

import '../../domain/domain.dart';
import 'field_spec.dart';
import 'shared_field_specs.dart';
import 'field_mappers.dart';
import 'damage_range_fields.dart';
import 'effect_fields.dart';
import 'action_fields.dart';
import 'bonus_fields.dart';
import 'synergy_fields.dart';
import 'counter_fields.dart';
import 'tag_fields.dart';

// --- Sección 8: IDeployableData ---

/// Sin campo `deployables` propio — recursión acotada a 1 nivel, ver
/// `weapon_form_schema.dart` (decisión documentada allí, aplica igual
/// para cualquier entidad que anide deployables).
List<FieldSpec> deployableItemFields() => [
  const TextFieldSpec(
    key: 'name',
    label: 'Nombre',
    required: true,
    helpText: 'El nombre visible del deployable, ej. "Recon Drone".',
  ),
  const TextFieldSpec(
    key: 'type',
    label: 'Tipo (Drone | Mine | Deployable | personalizado)',
    helpText:
        'Escribe exactamente "Drone", "Mine" o "Deployable" para los tipos '
        'estándar, o cualquier otro texto para un tipo personalizado.',
  ),
  const TextFieldSpec(
    key: 'detail',
    label: 'Detalle',
    required: true,
    maxLines: 3,
    helpText: 'Texto de reglas de este deployable.',
  ),
  EnumFieldSpec<ActivationType>(
    key: 'activation',
    label: 'Activación',
    options: ActivationType.values,
    displayLabel: (a) => a.jsonValue,
    fromJsonValue: (s) =>
        ActivationType.values.firstWhere((a) => a.jsonValue == s),
  ),
  EnumFieldSpec<ActivationType>(
    key: 'deactivation',
    label: 'Desactivación',
    options: ActivationType.values,
    displayLabel: (a) => a.jsonValue,
    fromJsonValue: (s) =>
        ActivationType.values.firstWhere((a) => a.jsonValue == s),
  ),
  EnumFieldSpec<ActivationType>(
    key: 'recall',
    label: 'Recall',
    options: ActivationType.values,
    displayLabel: (a) => a.jsonValue,
    fromJsonValue: (s) =>
        ActivationType.values.firstWhere((a) => a.jsonValue == s),
  ),
  EnumFieldSpec<ActivationType>(
    key: 'redeploy',
    label: 'Redeploy',
    options: ActivationType.values,
    displayLabel: (a) => a.jsonValue,
    fromJsonValue: (s) =>
        ActivationType.values.firstWhere((a) => a.jsonValue == s),
  ),
  const NumberFieldSpec(key: 'instances', label: 'Instancias'),
  const NumberFieldSpec(key: 'cost', label: 'Coste (si el padre es limited)'),
  const NumberFieldSpec(key: 'size', label: 'Tamaño', allowDecimal: true),
  const TextFieldSpec(
    key: 'sizeSpecial',
    jsonKey: 'size_special',
    label: 'Tamaño especial',
    helpText:
        'Solo si el tamaño no es un número fijo (ej. "1 por punto de '
        'estructura perdido"). Si el tamaño es un número normal, usa el '
        'campo "Tamaño" de arriba y deja este vacío.',
  ),
  numericOrFormulaField('armor', 'Armor'),
  numericOrFormulaField('hp', 'HP'),
  numericOrFormulaField('evasion', 'Evasion'),
  numericOrFormulaField('edef', 'E-Defense'),
  numericOrFormulaField('heatcap', 'Heat cap'),
  numericOrFormulaField('repcap', 'Repair cap'),
  numericOrFormulaField('sensorRange', 'Sensor range', jsonKey: 'sensor_range'),
  numericOrFormulaField('techAttack', 'Tech attack', jsonKey: 'tech_attack'),
  numericOrFormulaField('save', 'Save'),
  numericOrFormulaField('speed', 'Speed'),
  numericOrFormulaField('grapple', 'Grapple'),
  numericOrFormulaField('attackBonus', 'Attack bonus', jsonKey: 'attack_bonus'),
  ListFieldSpec(key: 'damage', label: 'Daño', itemFields: damageItemFields()),
  ListFieldSpec(key: 'range', label: 'Alcance', itemFields: rangeItemFields()),
  ListFieldSpec(
    key: 'actions',
    label: 'Actions (mientras esté activo)',
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
    key: 'counters',
    label: 'Counters',
    itemFields: counterItemFields(),
  ),
  ListFieldSpec(
    key: 'activeEffects',
    jsonKey: 'active_effects',
    label: 'Active effects',
    itemFields: activeEffectFields(),
  ),
  ListFieldSpec(
    key: 'addStatus',
    jsonKey: 'add_status',
    label: 'Añade status/condition',
    itemFields: statusEffectItemFields(),
  ),
  ListFieldSpec(
    key: 'addSpecial',
    jsonKey: 'add_special',
    label: 'Añade special status',
    itemFields: specialStatusItemFields(),
  ),
  const ListFieldSpec(
    key: 'removeSpecial',
    jsonKey: 'remove_special',
    label: 'Quita special status',
    itemFields: [
      TextFieldSpec(
        key: 'id',
        label: 'Atributo',
        required: true,
        helpText:
            'El nombre del atributo especial a quitar (debe coincidir '
            'exactamente con el que se añadió en otro sitio).',
      ),
    ],
  ),
  ListFieldSpec(
    key: 'addOther',
    jsonKey: 'add_other',
    label: 'Añade otro efecto',
    itemFields: otherEffectItemFields(),
  ),
  ListFieldSpec(
    key: 'addResist',
    jsonKey: 'add_resist',
    label: 'Añade resist/vulnerability/immunity',
    itemFields: resistanceItemFields(),
  ),
  const ListFieldSpec(key: 'tags', label: 'Tags', itemFields: tagItemFields),
  const BoolFieldSpec(
    key: 'pilot',
    label: 'Pilot (default true si el padre es Pilot Equipment)',
  ),
  const BoolFieldSpec(key: 'mech', label: 'Mech'),
];

DeployableType? deployableTypeFromInput(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  switch (raw) {
    case 'Drone':
      return DeployableType.drone;
    case 'Mine':
      return DeployableType.mine;
    case 'Deployable':
      return DeployableType.deployable;
    default:
      return DeployableType.custom(raw);
  }
}

IDeployableData deployableFromItem(Map<String, dynamic> item) =>
    IDeployableData(
      name: item['name'] as String,
      type: deployableTypeFromInput(item['type'] as String?),
      detail: item['detail'] as String,
      activation: item['activation'] as ActivationType?,
      deactivation: item['deactivation'] as ActivationType?,
      recall: item['recall'] as ActivationType?,
      redeploy: item['redeploy'] as ActivationType?,
      instances: (item['instances'] as num?)?.toInt(),
      cost: (item['cost'] as num?)?.toInt(),
      size: item['size'] as num?,
      sizeSpecial: item['sizeSpecial'] as String?,
      armor: numericOrFormulaFromItem(item, 'armor'),
      hp: numericOrFormulaFromItem(item, 'hp'),
      evasion: numericOrFormulaFromItem(item, 'evasion'),
      edef: numericOrFormulaFromItem(item, 'edef'),
      heatcap: numericOrFormulaFromItem(item, 'heatcap'),
      repcap: numericOrFormulaFromItem(item, 'repcap'),
      sensorRange: numericOrFormulaFromItem(item, 'sensorRange'),
      techAttack: numericOrFormulaFromItem(item, 'techAttack'),
      save: numericOrFormulaFromItem(item, 'save'),
      speed: numericOrFormulaFromItem(item, 'speed'),
      grapple: numericOrFormulaFromItem(item, 'grapple'),
      attackBonus: numericOrFormulaFromItem(item, 'attackBonus'),
      damage: mapItems(item['damage'], damageDataFromItem),
      range: mapItems(item['range'], rangeDataFromItem),
      actions: mapItems(item['actions'], actionFromItem),
      bonuses: mapItems(item['bonuses'], bonusFromItemValues),
      synergies: mapItems(item['synergies'], synergyFromItem),
      counters: mapItems(item['counters'], counterFromItem),
      activeEffects: mapItems(item['activeEffects'], activeEffectFromGroup),
      addStatus: mapItems(item['addStatus'], statusEffectFromItem),
      addSpecial: mapItems(item['addSpecial'], specialStatusFromItem),
      removeSpecial: mapStringIdItems(item['removeSpecial']),
      addOther: mapItems(item['addOther'], otherEffectFromItem),
      addResist: mapItems(item['addResist'], resistanceFromItem),
      tags: mapItems(item['tags'], tagFromItem),
      pilot: item['pilot'] as bool?,
      mech: item['mech'] as bool?,
    );
