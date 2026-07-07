/// Traduce el dominio (Dart) a la forma JSON exacta del formato `.lcp`
/// (snake_case, mismos nombres de campo que `vault/Modelo de Dominio/`).
/// Vive en `infrastructure/` a propósito: el dominio no sabe nada de JSON
/// ni de `.lcp` — esa es la frontera hexagonal (ver ADR-001).
///
/// Cubre por ahora el grafo completo de [IWeaponData] y [ILcpManifestData]
/// (primer caso de uso: Crear arma). Los tipos compartidos (`IDamageData`,
/// `IActionData`, `IBonusData`, etc.) se reutilizarán al mapear el resto de
/// entidades — no son específicos de arma.
library;

import '../../domain/domain.dart';

Map<String, dynamic> _clean(Map<String, dynamic> map) {
  final result = <String, dynamic>{};
  for (final entry in map.entries) {
    if (entry.value != null) result[entry.key] = entry.value;
  }
  return result;
}

List<dynamic>? _list<T>(List<T>? items, Object Function(T) toJson) {
  if (items == null) return null;
  return items.map(toJson).toList();
}

// --- Sección 1 ---

Object diceExpressionToJson(DiceExpression v) => v.numberValue ?? v.formula!;

Object stringOrBoolToJson(StringOrBool v) => v.text ?? v.flag!;

Map<String, dynamic> damageSaveToJson(IDamageSaveData v) =>
    _clean({'stat': v.stat, 'aoe': v.aoe});

Object? _damageSaveObjectToJson(Object? v) {
  if (v == null) return null;
  if (v is String) return v;
  if (v is IDamageSaveData) return damageSaveToJson(v);
  throw ArgumentError('save no reconocido: $v');
}

Map<String, dynamic> damageDataToJson(IDamageData v) => _clean({
  'type': v.type.jsonValue,
  'val': diceExpressionToJson(v.val),
  'aoe': v.aoe == null ? null : stringOrBoolToJson(v.aoe!),
  'save': _damageSaveObjectToJson(v.save),
  'save_half': v.saveHalf,
  'ap': v.ap,
  'target': v.target?.name,
});

Map<String, dynamic> rangeDataToJson(IRangeData v) => _clean({
  'type': v.type.jsonValue,
  'val': diceExpressionToJson(v.val),
  'min': v.min == null ? null : diceExpressionToJson(v.min!),
});

// --- Sección 2 ---

Map<String, dynamic> statusEffectDataToJson(IStatusEffectData v) => _clean({
  'id': v.id,
  'duration': v.duration?.value,
  'save': v.save?.name,
  'aoe': v.aoe == null ? null : stringOrBoolToJson(v.aoe!),
  'target': v.target?.name,
});

Object immunityValueToJson(ImmunityValue v) =>
    v.knownValue?.name ?? v.conditionId!;

Map<String, dynamic> resistanceDataToJson(IResistanceData v) {
  final target = v.target?.name;
  return switch (v) {
    ResistEffectData(:final resist) => _clean({
      'resist': resist.name,
      'target': target,
    }),
    VulnerabilityEffectData(:final vulnerability) => _clean({
      'vulnerability': vulnerability.name,
      'target': target,
    }),
    ImmunityEffectData(:final immunity) => _clean({
      'immunity': immunityValueToJson(immunity),
      'target': target,
    }),
  };
}

Map<String, dynamic> specialStatusDataToJson(ISpecialStatusData v) => _clean({
  'attribute': v.attribute,
  'detail': v.detail,
  'target': v.target?.name,
  'duration': v.duration?.value,
});

Object numericOrFormulaValueToJson(NumericOrFormulaValue v) =>
    v.numberValue ?? v.formula!;

Map<String, dynamic> otherEffectDataToJson(IOtherEffectData v) {
  final target = v.target?.name;
  final aoe = v.aoe == null ? null : stringOrBoolToJson(v.aoe!);
  return switch (v) {
    OvershieldEffectData(:final val) => _clean({
      'type': 'overshield',
      'val': numericOrFormulaValueToJson(val),
      'target': target,
      'aoe': aoe,
    }),
    HpEffectData(:final val) => _clean({
      'type': 'hp',
      'val': numericOrFormulaValueToJson(val),
      'target': target,
      'aoe': aoe,
    }),
    RepairEffectData(:final val) => _clean({
      'type': 'repair',
      'val': numericOrFormulaValueToJson(val),
      'target': target,
      'aoe': aoe,
    }),
    CoverEffectData(:final val) => _clean({
      'type': 'cover',
      'val': val.name,
      'target': target,
      'aoe': aoe,
    }),
  };
}

Map<String, dynamic> effectSaveDataToJson(IEffectSaveData v) =>
    _clean({'stat': v.stat.name, 'aoe': v.aoe});

// --- Sección 3 ---

Object textOrActiveEffectToJson(TextOrActiveEffect v) =>
    v.text ?? activeEffectDataToJson(v.effect!);

Map<String, dynamic> activeEffectDataToJson(IActiveEffectData v) => _clean({
  'name': v.name,
  'detail': v.detail,
  'condition': v.condition,
  'frequency': v.frequency?.jsonValue,
  'duration': v.duration?.value,
  'bonus_damage': v.bonusDamage == null
      ? null
      : diceExpressionToJson(v.bonusDamage!),
  'damage': _list(v.damage, damageDataToJson),
  'range': _list(v.range, rangeDataToJson),
  'add_status': _list(v.addStatus, statusEffectDataToJson),
  'add_resist': _list(v.addResist, resistanceDataToJson),
  'add_special': _list(v.addSpecial, specialStatusDataToJson),
  'remove_special': v.removeSpecial,
  'add_other': _list(v.addOther, otherEffectDataToJson),
  'save': v.save == null ? null : effectSaveDataToJson(v.save!),
  'attack': v.attack?.name,
  'pilot': v.pilot,
  'mech': v.mech,
  'accuracy': v.accuracy,
  'attack_bonus': v.attackBonus,
});

Map<String, dynamic> actionDataToJson(IActionData v) => _clean({
  'name': v.name,
  'activation': v.activation.jsonValue,
  'detail': v.detail,
  'frequency': v.frequency?.jsonValue,
  'trigger': v.trigger,
  'cost': v.cost,
  'pilot': v.pilot,
  'mech': v.mech,
  'hide_active': v.hideActive,
  'bonus_damage': v.bonusDamage == null
      ? null
      : diceExpressionToJson(v.bonusDamage!),
  'damage': v.damage == null ? null : damageDataToJson(v.damage!),
  'range': v.range == null ? null : rangeDataToJson(v.range!),
  'add_status': _list(v.addStatus, statusEffectDataToJson),
  'add_resist': _list(v.addResist, resistanceDataToJson),
  'add_special': _list(v.addSpecial, specialStatusDataToJson),
  'remove_special': v.removeSpecial,
  'add_other': _list(v.addOther, otherEffectDataToJson),
  'active_effects': _list(v.activeEffects, activeEffectDataToJson),
  'save': v.save == null ? null : effectSaveDataToJson(v.save!),
});

// --- Sección 4 ---

Object dieRollToJson(DieRoll v) => v.value;

Map<String, dynamic> mountAssignmentToJson(MountAssignment v) => {
  'mount_type': v.mountType.jsonValue,
  'max_mounts': v.maxMounts,
};

Object bonusValToJson(Object val) => switch (val) {
  NumericOrFormulaValue v => numericOrFormulaValueToJson(v),
  bool v => v,
  List<DieRoll> v => v.map(dieRollToJson).toList(),
  MountAssignment v => mountAssignmentToJson(v),
  _ => throw ArgumentError('IBonusData.val no reconocido: $val'),
};

Map<String, dynamic> bonusDataToJson(IBonusData v) => _clean({
  'id': v.id.jsonValue,
  'val': bonusValToJson(v.val),
  'accuracy': v.accuracy,
  'damage_types': v.damageTypes?.map((e) => e.jsonValue).toList(),
  'range_types': v.rangeTypes?.map((e) => e.jsonValue).toList(),
  'weapon_types': v.weaponTypes?.map((e) => e.jsonValue).toList(),
  'weapon_sizes': v.weaponSizes?.map((e) => e.jsonValue).toList(),
  'overwrite': v.overwrite,
  'replace': v.replace,
});

// --- Sección 5 ---

Map<String, dynamic> synergyDataToJson(ISynergyData v) => _clean({
  'locations': v.locations.map((e) => e.value).toList(),
  'detail': v.detail,
  'weapon_types': v.weaponTypes?.map((e) => e.jsonValue).toList(),
  'weapon_sizes': v.weaponSizes?.map((e) => e.jsonValue).toList(),
  'system_types': v.systemTypes?.map((e) => e.jsonValue).toList(),
});

// --- Sección 6 ---

Map<String, dynamic> tagInstanceToJson(ITagInstance v) =>
    _clean({'id': v.id, 'val': v.val});

// --- Sección 7 ---

Map<String, dynamic> counterDataToJson(ICounterData v) => _clean({
  'id': v.id,
  'name': v.name,
  'default_value': v.defaultValue,
  'min': v.min,
  'max': v.max,
});

// --- Sección 8 ---

Object? _numOrFormulaObjectToJson(Object? v) {
  if (v == null) return null;
  if (v is num) return v;
  if (v is NumericOrFormulaValue) return numericOrFormulaValueToJson(v);
  throw ArgumentError('campo number|NumericOrFormulaValue no reconocido: $v');
}

Map<String, dynamic> deployableDataToJson(IDeployableData v) => _clean({
  'name': v.name,
  'type': v.type?.value,
  'detail': v.detail,
  'activation': v.activation?.jsonValue,
  'deactivation': v.deactivation?.jsonValue,
  'recall': v.recall?.jsonValue,
  'redeploy': v.redeploy?.jsonValue,
  'instances': v.instances,
  'cost': v.cost,
  'size': v.size,
  'size_special': v.sizeSpecial,
  'armor': _numOrFormulaObjectToJson(v.armor),
  'hp': _numOrFormulaObjectToJson(v.hp),
  'evasion': _numOrFormulaObjectToJson(v.evasion),
  'edef': _numOrFormulaObjectToJson(v.edef),
  'heatcap': _numOrFormulaObjectToJson(v.heatcap),
  'repcap': _numOrFormulaObjectToJson(v.repcap),
  'sensor_range': _numOrFormulaObjectToJson(v.sensorRange),
  'tech_attack': _numOrFormulaObjectToJson(v.techAttack),
  'save': _numOrFormulaObjectToJson(v.save),
  'speed': _numOrFormulaObjectToJson(v.speed),
  'grapple': _numOrFormulaObjectToJson(v.grapple),
  'attack_bonus': _numOrFormulaObjectToJson(v.attackBonus),
  'damage': _list(v.damage, damageDataToJson),
  'range': _list(v.range, rangeDataToJson),
  'actions': _list(v.actions, actionDataToJson),
  'bonuses': _list(v.bonuses, bonusDataToJson),
  'synergies': _list(v.synergies, synergyDataToJson),
  'deployables': _list(v.deployables, deployableDataToJson),
  'counters': _list(v.counters, counterDataToJson),
  'active_effects': _list(v.activeEffects, activeEffectDataToJson),
  'add_status': _list(v.addStatus, statusEffectDataToJson),
  'add_special': _list(v.addSpecial, specialStatusDataToJson),
  'remove_special': v.removeSpecial,
  'add_other': _list(v.addOther, otherEffectDataToJson),
  'add_resist': _list(v.addResist, resistanceDataToJson),
  'tags': _list(v.tags, tagInstanceToJson),
  'pilot': v.pilot,
  'mech': v.mech,
});

// --- Sección 9 ---

Map<String, dynamic> ammoDataToJson(IAmmoData v) => _clean({
  'name': v.name,
  'description': v.description,
  'cost': v.cost,
  'allowed_types': v.allowedTypes?.map((e) => e.jsonValue).toList(),
  'allowed_sizes': v.allowedSizes?.map((e) => e.jsonValue).toList(),
  'restricted_types': v.restrictedTypes?.map((e) => e.jsonValue).toList(),
  'restricted_sizes': v.restrictedSizes?.map((e) => e.jsonValue).toList(),
});

// --- Sección 13.3 (Weapons) ---

Map<String, dynamic> weaponProfileToJson(IWeaponProfile v) => _clean({
  'name': v.name,
  'effect': v.effect == null ? null : textOrActiveEffectToJson(v.effect!),
  'skirmish': v.skirmish,
  'barrage': v.barrage,
  'cost': v.cost,
  'on_attack': v.onAttack == null
      ? null
      : textOrActiveEffectToJson(v.onAttack!),
  'on_hit': v.onHit == null ? null : textOrActiveEffectToJson(v.onHit!),
  'on_crit': v.onCrit == null ? null : textOrActiveEffectToJson(v.onCrit!),
  'on_miss': v.onMiss == null ? null : textOrActiveEffectToJson(v.onMiss!),
  'active_effects': _list(v.activeEffects, activeEffectDataToJson),
  'damage': _list(v.damage, damageDataToJson),
  'range': _list(v.range, rangeDataToJson),
  'actions': _list(v.actions, actionDataToJson),
  'bonuses': _list(v.bonuses, bonusDataToJson),
  'synergies': _list(v.synergies, synergyDataToJson),
  'deployables': _list(v.deployables, deployableDataToJson),
  'counters': _list(v.counters, counterDataToJson),
  'integrated': v.integrated,
  'special_equipment': v.specialEquipment,
});

Object _weaponTypeFieldToJson(Object type) => switch (type) {
  WeaponType t => t.jsonValue,
  List<WeaponType> t => t.map((e) => e.jsonValue).toList(),
  _ => throw ArgumentError('IWeaponData.type no reconocido: $type'),
};

/// Mapea [IWeaponData] completo — todos los campos de la entidad, sin
/// recorte (incluye `bonuses`, `profiles`; ver decisión de alcance ya
/// tomada de no trimear la entidad).
Map<String, dynamic> weaponDataToJson(IWeaponData v) => _clean({
  'id': v.id,
  'name': v.name,
  'source': v.source,
  'license': v.license,
  'license_id': v.licenseId,
  'license_level': v.licenseLevel,
  'effect': v.effect,
  'description': v.description,
  'mount': v.mount.jsonValue,
  'type': _weaponTypeFieldToJson(v.type),
  'ammo': _list(v.ammo, ammoDataToJson),
  'cost': v.cost,
  'barrage': v.barrage,
  'skirmish': v.skirmish,
  'no_attack': v.noAttack,
  'no_mods': v.noMods,
  'no_core_bonus': v.noCoreBonus,
  'damage': _list(v.damage, damageDataToJson),
  'range': _list(v.range, rangeDataToJson),
  'tags': _list(v.tags, tagInstanceToJson),
  'sp': v.sp,
  'on_attack': v.onAttack == null
      ? null
      : textOrActiveEffectToJson(v.onAttack!),
  'on_hit': v.onHit == null ? null : textOrActiveEffectToJson(v.onHit!),
  'on_crit': v.onCrit == null ? null : textOrActiveEffectToJson(v.onCrit!),
  'on_miss': v.onMiss == null ? null : textOrActiveEffectToJson(v.onMiss!),
  'active_effects': _list(v.activeEffects, activeEffectDataToJson),
  'actions': _list(v.actions, actionDataToJson),
  'bonuses': _list(v.bonuses, bonusDataToJson),
  'no_bonus': v.noBonus,
  'synergies': _list(v.synergies, synergyDataToJson),
  'no_synergy': v.noSynergy,
  'deployables': _list(v.deployables, deployableDataToJson),
  'counters': _list(v.counters, counterDataToJson),
  'integrated': v.integrated,
  'special_equipment': v.specialEquipment,
  'profiles': _list(v.profiles, weaponProfileToJson),
});

// --- Sección 17.1 (Manifest) ---

Map<String, dynamic> changelogItemToJson(IChangelogItem v) => {
  'version': v.version,
  'date': v.date,
  'changes': v.changes,
};

Map<String, dynamic> lcpDependencyToJson(ILcpDependency v) =>
    _clean({'name': v.name, 'version': v.version.value, 'link': v.link});

Map<String, dynamic> lcpManifestDataToJson(ILcpManifestData v) => _clean({
  'name': v.name,
  'author': v.author,
  'description': v.description,
  'version': v.version,
  'image_url': v.imageUrl,
  'website': v.website,
  'dependencies': _list(v.dependencies, lcpDependencyToJson),
  'v3': v.v3,
  'version_history': _list(v.versionHistory, changelogItemToJson),
});
