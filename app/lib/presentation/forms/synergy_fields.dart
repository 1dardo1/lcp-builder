/// Synergy field builder and assembler (domain section 5).
library;

import '../../domain/domain.dart';
import 'field_spec.dart';
import 'field_mappers.dart';

// --- Sección 5: ISynergyData ---

/// `locations`: conjunto cerrado (`rest`, `weapon`, ...) más la forma
/// variable `action_<id>` — mismo criterio de proporcionalidad que
/// `DiceExpression`/`MountAssignment`: se valida el patrón con texto libre
/// en vez de construir un selector dedicado para un mecanismo que el
/// propio dominio ya marca como "de último recurso" (vault MdD §5).
final synergyLocationPattern = RegExp(
  r'^(rest|weapon|system|deployable|drone|move|boost|structure|armor|hp|'
  r'overshield|stress|heat|repair|core_power|overcharge|hull|agility|'
  r'systems|engineering|pilot_weapon|cascade|action_[A-Za-z0-9_]+)$',
);

List<FieldSpec> synergyItemFields() => [
  ListFieldSpec(
    key: 'locations',
    label: 'Locations (al menos una)',
    itemFields: [
      PatternTextFieldSpec(
        key: 'value',
        label: 'Location',
        required: true,
        pattern: synergyLocationPattern,
        patternHint:
            'rest, weapon, system, deployable, drone, move, boost, '
            'structure, armor, hp, overshield, stress, heat, repair, '
            'core_power, overcharge, hull, agility, systems, engineering, '
            'pilot_weapon, cascade, o action_<id>',
      ),
    ],
  ),
  const TextFieldSpec(
    key: 'detail',
    label: 'Detalle',
    required: true,
    maxLines: 3,
    helpText: 'Texto de reglas de la synergy — qué gana el piloto/mech.',
  ),
  MultiEnumFieldSpec<WeaponType>(
    key: 'weaponTypes',
    jsonKey: 'weapon_types',
    label: 'Tipos de arma (vacío = todos)',
    options: WeaponType.values,
    displayLabel: (t) => t.jsonValue,
    fromJsonValue: (s) => WeaponType.values.firstWhere((t) => t.jsonValue == s),
  ),
  MultiEnumFieldSpec<WeaponSize>(
    key: 'weaponSizes',
    jsonKey: 'weapon_sizes',
    label: 'Tamaños de arma (vacío = todos)',
    options: WeaponSize.values,
    displayLabel: (s) => s.jsonValue,
    fromJsonValue: (s) => WeaponSize.values.firstWhere((w) => w.jsonValue == s),
  ),
  MultiEnumFieldSpec<SystemType>(
    key: 'systemTypes',
    jsonKey: 'system_types',
    label: 'Tipos de sistema (vacío = todos)',
    options: SystemType.values,
    displayLabel: (s) => s.jsonValue,
    fromJsonValue: (s) => SystemType.values.firstWhere((t) => t.jsonValue == s),
  ),
];

ISynergyData? synergyFromItem(Map<String, dynamic> item) {
  final locationItems =
      (item['locations'] as List<Map<String, dynamic>>?) ?? const [];
  final locations = locationItems
      .map((l) => l['value'] as String?)
      .whereType<String>()
      .map(synergyLocationFromValue)
      .toList();
  if (locations.isEmpty) return null;
  return ISynergyData(
    locations: locations,
    detail: item['detail'] as String? ?? '',
    weaponTypes: emptyToNull(item['weaponTypes'] as List?)?.cast<WeaponType>(),
    weaponSizes: emptyToNull(item['weaponSizes'] as List?)?.cast<WeaponSize>(),
    systemTypes: emptyToNull(item['systemTypes'] as List?)?.cast<SystemType>(),
  );
}

SynergyLocation synergyLocationFromValue(String value) {
  const presets = {
    'rest': SynergyLocation.rest,
    'weapon': SynergyLocation.weapon,
    'system': SynergyLocation.system,
    'deployable': SynergyLocation.deployable,
    'drone': SynergyLocation.drone,
    'move': SynergyLocation.move,
    'boost': SynergyLocation.boost,
    'structure': SynergyLocation.structure,
    'armor': SynergyLocation.armor,
    'hp': SynergyLocation.hp,
    'overshield': SynergyLocation.overshield,
    'stress': SynergyLocation.stress,
    'heat': SynergyLocation.heat,
    'repair': SynergyLocation.repair,
    'core_power': SynergyLocation.corePower,
    'overcharge': SynergyLocation.overcharge,
    'hull': SynergyLocation.hull,
    'agility': SynergyLocation.agility,
    'systems': SynergyLocation.systems,
    'engineering': SynergyLocation.engineering,
    'pilot_weapon': SynergyLocation.pilotWeapon,
    'cascade': SynergyLocation.cascade,
  };
  final preset = presets[value];
  if (preset != null) return preset;
  final actionId = RegExp(r'^action_(.+)$').firstMatch(value)?.group(1);
  return SynergyLocation.actionX(actionId ?? value);
}
