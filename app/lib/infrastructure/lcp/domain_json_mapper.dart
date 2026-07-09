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

// --- Lectura (Mostrar) ---
//
// Único `fromJson` de todo este archivo por ahora: Mostrar necesita el
// manifest tipado (nombre del paquete, autor...) para las pantallas de
// listado, pero el contenido por tipo de entidad (armas, frames...) se
// queda en JSON crudo — no hace falta reconstruir los 24 tipos de
// dominio solo para pintarlos en pantalla, ver
// `infrastructure/lcp/zip_content_pack_reader.dart`.

IChangelogItem changelogItemFromJson(Map<String, dynamic> json) =>
    IChangelogItem(
      version: json['version'] as String,
      date: json['date'] as String,
      changes: (json['changes'] as List).cast<String>(),
    );

ILcpDependency lcpDependencyFromJson(Map<String, dynamic> json) =>
    ILcpDependency(
      name: json['name'] as String,
      version: SemverConstraint(json['version'] as String),
      link: json['link'] as String?,
    );

ILcpManifestData lcpManifestDataFromJson(Map<String, dynamic> json) =>
    ILcpManifestData(
      name: json['name'] as String,
      author: json['author'] as String,
      description: json['description'] as String,
      version: json['version'] as String,
      imageUrl: json['image_url'] as String?,
      website: json['website'] as String?,
      dependencies: (json['dependencies'] as List?)
          ?.cast<Map<String, dynamic>>()
          .map(lcpDependencyFromJson)
          .toList(),
      v3: json['v3'] as bool?,
      versionHistory: (json['version_history'] as List?)
          ?.cast<Map<String, dynamic>>()
          .map(changelogItemFromJson)
          .toList(),
    );

// --- Sección 13.1 (Manufacturers) ---

Map<String, dynamic> manufacturerDataToJson(IManufacturerData v) => _clean({
  'id': v.id,
  'name': v.name,
  'description': v.description,
  'quote': v.quote,
  'light': v.light,
  'dark': v.dark,
  'icon_svg': v.iconSvg,
  'icon_url': v.iconUrl,
});

// --- Sección 6 (Tags, catálogo) ---

Map<String, dynamic> tagDataToJson(ITagData v) => _clean({
  'id': v.id,
  'name': v.name,
  'description': v.description,
  'hidden': v.hidden,
  'filter_ignore': v.filterIgnore,
});

// --- Sección 11.5 (Skills) ---

Map<String, dynamic> skillDataToJson(ISkillData v) => _clean({
  'id': v.id,
  'name': v.name,
  'description': v.description,
  'detail': v.detail,
  'family': v.family.jsonValue,
});

// --- Sección 17.4 (Statuses/Conditions) ---

Map<String, dynamic> statusConditionDataToJson(IStatusConditionData v) =>
    _clean({
      'id': v.id,
      'name': v.name,
      'type': v.type.name,
      'effects': v.effects,
      'terse': v.terse,
      'icon_svg': v.iconSvg,
      'icon_url': v.iconUrl,
      'exclusive': v.exclusive?.name,
    });

// --- Sección 17.3 (SITREPs) ---

Map<String, dynamic> sitrepConditionToJson(ISitrepCondition v) => {
  'title': v.title,
  'condition': v.condition,
};

Map<String, dynamic> sitrepDataToJson(ISitrepData v) => _clean({
  'id': v.id,
  'name': v.name,
  'description': v.description,
  'deployment': v.deployment,
  'objective': v.objective,
  'extraction': v.extraction,
  'conditions': _list(v.conditions, sitrepConditionToJson),
  'pc_victory': v.pcVictory,
  'enemy_victory': v.enemyVictory,
  'no_victory': v.noVictory,
});

// --- Sección 17.2 (Environments) ---

Map<String, dynamic> environmentDataToJson(IEnvironmentData v) =>
    _clean({'id': v.id, 'name': v.name, 'description': v.description});

// --- Sección 11.1 (Backgrounds) ---

Map<String, dynamic> backgroundDataToJson(IBackgroundData v) => _clean({
  'id': v.id,
  'name': v.name,
  'description': v.description,
  'skills': v.skills,
});

// --- Sección 11.7 (Bonds) ---

Map<String, dynamic> questionDataToJson(IQuestionData v) => {
  'question': v.question,
  'options': v.options,
};

Map<String, dynamic> bondPowerDataToJson(IBondPowerData v) => _clean({
  'name': v.name,
  'description': v.description,
  'frequency': v.frequency?.jsonValue,
  'prerequisite': v.prerequisite,
  'veteran': v.veteran,
  'master': v.master,
  'origin': v.origin,
});

Map<String, dynamic> bondDataToJson(IBondData v) => _clean({
  'id': v.id,
  'name': v.name,
  'major_ideals': v.majorIdeals,
  'minor_ideals': v.minorIdeals,
  'questions': _list(v.questions, questionDataToJson),
  'powers': _list(v.powers, bondPowerDataToJson),
});

// --- Sección 11.4 (Reserves) ---

Map<String, dynamic> reserveDataToJson(IReserveData v) => _clean({
  'id': v.id,
  'name': v.name,
  'type': v.type.name,
  'label': v.label,
  'description': v.description,
  'consumable': v.consumable,
  'actions': _list(v.actions, actionDataToJson),
  'bonuses': _list(v.bonuses, bonusDataToJson),
  'synergies': _list(v.synergies, synergyDataToJson),
  'deployables': _list(v.deployables, deployableDataToJson),
  'counters': _list(v.counters, counterDataToJson),
  'integrated': v.integrated,
  'special_equipment': v.specialEquipment,
  'active_effects': _list(v.activeEffects, activeEffectDataToJson),
});

// --- Sección 11.2 (Core Bonuses) ---

Map<String, dynamic> coreBonusDataToJson(ICoreBonusData v) => _clean({
  'id': v.id,
  'name': v.name,
  'source': v.source,
  'effect': v.effect,
  'description': v.description,
  'mounted_effect': v.mountedEffect,
  'active_effects': _list(v.activeEffects, activeEffectDataToJson),
  'actions': _list(v.actions, actionDataToJson),
  'bonuses': _list(v.bonuses, bonusDataToJson),
  'synergies': _list(v.synergies, synergyDataToJson),
  'deployables': _list(v.deployables, deployableDataToJson),
  'counters': _list(v.counters, counterDataToJson),
  'integrated': v.integrated,
  'special_equipment': v.specialEquipment,
});

// --- Sección 11.6 (Talents) ---

Map<String, dynamic> rankDataToJson(IRankData v) => _clean({
  'name': v.name,
  'description': v.description,
  'exclusive': v.exclusive,
  'actions': _list(v.actions, actionDataToJson),
  'bonuses': _list(v.bonuses, bonusDataToJson),
  'synergies': _list(v.synergies, synergyDataToJson),
  'deployables': _list(v.deployables, deployableDataToJson),
  'counters': _list(v.counters, counterDataToJson),
  'integrated': v.integrated,
  'special_equipment': v.specialEquipment,
  'active_effects': _list(v.activeEffects, activeEffectDataToJson),
});

Map<String, dynamic> talentDataToJson(ITalentData v) => _clean({
  'id': v.id,
  'name': v.name,
  'description': v.description,
  'ranks': _list(v.ranks, rankDataToJson),
  'icon_svg': v.iconSvg,
  'icon_url': v.iconUrl,
  'terse': v.terse,
});

// --- Sección 15 (NPC Data): TierValue / NpcSize / EidolonShardCount ---
// (caso 6 del catálogo de casos polimórficos, variabilidad por tier).

Object tierValueToJson(TierValue v) => v.single ?? v.perTier!;

Object npcSizeToJson(NpcSize v) => v.perTier;

Object eidolonShardCountToJson(EidolonShardCount v) {
  if (v.hostileCharacters) return 'hostile_characters';
  return v.single ?? v.perTier!;
}

// --- Sección 13.4 (Mech Systems) ---

Map<String, dynamic> mechSystemDataToJson(IMechSystemData v) => _clean({
  'id': v.id,
  'name': v.name,
  'source': v.source,
  'license': v.license,
  'license_id': v.licenseId,
  'license_level': v.licenseLevel,
  'type': v.type?.jsonValue,
  'effect': v.effect,
  'description': v.description,
  'sp': v.sp,
  'tags': _list(v.tags, tagInstanceToJson),
  'actions': _list(v.actions, actionDataToJson),
  'bonuses': _list(v.bonuses, bonusDataToJson),
  'no_bonus': v.noBonus,
  'synergies': _list(v.synergies, synergyDataToJson),
  'no_synergy': v.noSynergy,
  'deployables': _list(v.deployables, deployableDataToJson),
  'counters': _list(v.counters, counterDataToJson),
  'integrated': v.integrated,
  'special_equipment': v.specialEquipment,
  'active_effects': _list(v.activeEffects, activeEffectDataToJson),
});

// --- Sección 13.5 (Mech Weapon Mods) ---

Map<String, dynamic> weaponModDataToJson(IWeaponModData v) => _clean({
  ...mechSystemDataToJson(v),
  'on_miss': v.onMiss == null ? null : activeEffectDataToJson(v.onMiss!),
  'on_attack': v.onAttack == null ? null : activeEffectDataToJson(v.onAttack!),
  'on_hit': v.onHit == null ? null : activeEffectDataToJson(v.onHit!),
  'on_crit': v.onCrit == null ? null : activeEffectDataToJson(v.onCrit!),
  'allowed_types': v.allowedTypes?.map((e) => e.jsonValue).toList(),
  'allowed_sizes': v.allowedSizes?.map((e) => e.jsonValue).toList(),
  'added_tags': _list(v.addedTags, tagInstanceToJson),
  'added_damage': _list(v.addedDamage, damageDataToJson),
  'added_range': _list(v.addedRange, rangeDataToJson),
  'restricted_types': v.restrictedTypes?.map((e) => e.jsonValue).toList(),
  'restricted_sizes': v.restrictedSizes?.map((e) => e.jsonValue).toList(),
});

// --- Sección 11.3 (Pilot Gear) ---

Map<String, dynamic> pilotGearDataToJson(IPilotGearData v) => switch (v) {
  IPilotWeaponData v => _clean({
    'id': v.id,
    'name': v.name,
    'type': 'Weapon',
    'description': v.description,
    'effect': v.effect,
    'range': _list(v.range, rangeDataToJson),
    'damage': _list(v.damage, damageDataToJson),
    'tags': _list(v.tags, tagInstanceToJson),
    'actions': _list(v.actions, actionDataToJson),
    'bonuses': _list(v.bonuses, bonusDataToJson),
    'synergies': _list(v.synergies, synergyDataToJson),
    'deployables': _list(v.deployables, deployableDataToJson),
    'counters': _list(v.counters, counterDataToJson),
    'active_effects': _list(v.activeEffects, activeEffectDataToJson),
  }),
  IPilotArmorData v => _clean({
    'id': v.id,
    'name': v.name,
    'type': 'Armor',
    'description': v.description,
    'tags': _list(v.tags, tagInstanceToJson),
    'actions': _list(v.actions, actionDataToJson),
    'bonuses': _list(v.bonuses, bonusDataToJson),
    'synergies': _list(v.synergies, synergyDataToJson),
    'deployables': _list(v.deployables, deployableDataToJson),
    'counters': _list(v.counters, counterDataToJson),
  }),
  IPilotGearItemData v => _clean({
    'id': v.id,
    'name': v.name,
    'type': 'Gear',
    'description': v.description,
    'tags': _list(v.tags, tagInstanceToJson),
    'actions': _list(v.actions, actionDataToJson),
    'bonuses': _list(v.bonuses, bonusDataToJson),
    'synergies': _list(v.synergies, synergyDataToJson),
    'deployables': _list(v.deployables, deployableDataToJson),
    'counters': _list(v.counters, counterDataToJson),
  }),
};

// --- Sección 13.2 (Frames) ---

Map<String, dynamic> frameTraitDataToJson(IFrameTraitData v) => _clean({
  'name': v.name,
  'description': v.description,
  'actions': _list(v.actions, actionDataToJson),
  'bonuses': _list(v.bonuses, bonusDataToJson),
  'synergies': _list(v.synergies, synergyDataToJson),
  'deployables': _list(v.deployables, deployableDataToJson),
  'counters': _list(v.counters, counterDataToJson),
  'integrated': v.integrated,
  'special_equipment': v.specialEquipment,
  'active_effects': _list(v.activeEffects, activeEffectDataToJson),
});

Map<String, dynamic> coreSystemDataToJson(ICoreSystemData v) => _clean({
  'name': v.name,
  'description': v.description,
  'active_name': v.activeName,
  'active_effect': v.activeEffect,
  'activation': v.activation.jsonValue,
  'deactivation': v.deactivation?.jsonValue,
  'use': v.use?.jsonValue,
  'active_effects': _list(v.activeEffects, activeEffectDataToJson),
  'active_actions': _list(v.activeActions, actionDataToJson),
  'active_bonuses': _list(v.activeBonuses, bonusDataToJson),
  'active_synergies': _list(v.activeSynergies, synergyDataToJson),
  'passive_name': v.passiveName,
  'passive_effect': v.passiveEffect,
  'passive_actions': _list(v.passiveActions, actionDataToJson),
  'passive_bonuses': _list(v.passiveBonuses, bonusDataToJson),
  'passive_synergies': _list(v.passiveSynergies, synergyDataToJson),
  'deployables': _list(v.deployables, deployableDataToJson),
  'counters': _list(v.counters, counterDataToJson),
  'integrated': v.integrated,
  'special_equipment': v.specialEquipment,
  'tags': _list(v.tags, tagInstanceToJson),
});

Map<String, dynamic> prerequisiteToJson(IPrerequisite v) => _clean({
  'source': v.source,
  'min_rank': v.minRank,
  'cumulative': v.cumulative,
});

Map<String, dynamic> frameStatsToJson(IFrameStats v) => {
  'size': v.size,
  'structure': v.structure,
  'stress': v.stress,
  'armor': v.armor,
  'hp': v.hp,
  'evasion': v.evasion,
  'edef': v.edef,
  'heatcap': v.heatcap,
  'repcap': v.repcap,
  'sensor_range': v.sensorRange,
  'tech_attack': v.techAttack,
  'save': v.save,
  'speed': v.speed,
  'sp': v.sp,
};

Object? _frameSpecialtyToJson(Object? v) {
  if (v == null) return null;
  if (v is bool) return v;
  if (v is IPrerequisite) return prerequisiteToJson(v);
  throw ArgumentError('IFrameData.specialty no reconocido: $v');
}

Map<String, dynamic> frameDataToJson(IFrameData v) => _clean({
  'id': v.id,
  'name': v.name,
  'source': v.source,
  'license_id': v.licenseId,
  'license_level': v.licenseLevel,
  'mechtype': v.mechtype,
  'description': v.description,
  'mounts': v.mounts.map((e) => e.jsonValue).toList(),
  'stats': frameStatsToJson(v.stats),
  'traits': _list(v.traits, frameTraitDataToJson),
  'core_system': coreSystemDataToJson(v.coreSystem),
  'specialty': _frameSpecialtyToJson(v.specialty),
  'variant': v.variant,
  'image_url': v.imageUrl,
  'y_pos': v.yPos,
});

// --- Sección 15.2 (NPC Features) ---

Map<String, dynamic> npcDamageDataToJson(INpcDamageData v) => _clean({
  'type': v.type.jsonValue,
  'damage': v.damage,
  'aoe': v.aoe == null ? null : stringOrBoolToJson(v.aoe!),
  'save': _damageSaveObjectToJson(v.save),
  'save_half': v.saveHalf,
  'ap': v.ap,
  'target': v.target?.name,
});

Map<String, dynamic> _npcFeatureBaseToJson(INpcFeatureData v) => _clean({
  'id': v.id,
  'name': v.name,
  'origin': v.origin,
  'base': v.base,
  'deprecated': v.deprecated,
  'effect': v.effect == null ? null : textOrActiveEffectToJson(v.effect!),
  'hide_active': v.hideActive,
  'build_feature': v.buildFeature,
  'mod': v.mod,
  'tags': _list(v.tags, tagInstanceToJson),
  'actions': _list(v.actions, actionDataToJson),
  'bonuses': _list(v.bonuses, bonusDataToJson),
  'synergies': _list(v.synergies, synergyDataToJson),
  'deployables': _list(v.deployables, deployableDataToJson),
});

Map<String, dynamic> npcFeatureDataToJson(INpcFeatureData v) => switch (v) {
  INpcTraitFeatureData v => {..._npcFeatureBaseToJson(v), 'type': 'trait'},
  INpcSystemFeatureData v => {..._npcFeatureBaseToJson(v), 'type': 'system'},
  INpcReactionFeatureData v => _clean({
    ..._npcFeatureBaseToJson(v),
    'type': 'reaction',
    'trigger': v.trigger,
  }),
  INpcTechFeatureData v => _clean({
    ..._npcFeatureBaseToJson(v),
    'type': 'tech',
    'attack_bonus': v.attackBonus == null
        ? null
        : tierValueToJson(v.attackBonus!),
    'accuracy': v.accuracy == null ? null : tierValueToJson(v.accuracy!),
  }),
  INpcWeaponFeatureData v => _clean({
    ..._npcFeatureBaseToJson(v),
    'type': 'weapon',
    'weapon_type': v.weaponType,
    'damage': _list(v.damage, npcDamageDataToJson),
    'range': _list(v.range, rangeDataToJson),
    'attacks': tierValueToJson(v.attacks),
    'attack_bonus': v.attackBonus == null
        ? null
        : tierValueToJson(v.attackBonus!),
    'accuracy': v.accuracy == null ? null : tierValueToJson(v.accuracy!),
    'on_attack': v.onAttack == null
        ? null
        : activeEffectDataToJson(v.onAttack!),
    'on_hit': v.onHit == null ? null : activeEffectDataToJson(v.onHit!),
    'on_crit': v.onCrit == null ? null : activeEffectDataToJson(v.onCrit!),
    'on_miss': v.onMiss == null ? null : activeEffectDataToJson(v.onMiss!),
  }),
};

// --- Sección 15.1 (NPC Classes and Templates) ---

Map<String, dynamic> npcClassInfoToJson(INpcClassInfo v) => {
  'flavor': v.flavor,
  'tactics': v.tactics,
  'terse': v.terse,
};

Map<String, dynamic> npcClassStatsToJson(INpcClassStats v) => {
  'armor': tierValueToJson(v.armor),
  'hp': tierValueToJson(v.hp),
  'evade': tierValueToJson(v.evade),
  'edef': tierValueToJson(v.edef),
  'heatcap': tierValueToJson(v.heatcap),
  'speed': tierValueToJson(v.speed),
  'sensor': tierValueToJson(v.sensor),
  'save': tierValueToJson(v.save),
  'hull': tierValueToJson(v.hull),
  'agility': tierValueToJson(v.agility),
  'systems': tierValueToJson(v.systems),
  'engineering': tierValueToJson(v.engineering),
  'size': npcSizeToJson(v.size),
  'activations': tierValueToJson(v.activations),
};

Map<String, dynamic> npcClassDataToJson(INpcClassData v) => _clean({
  'id': v.id,
  'name': v.name,
  'role': v.role.name,
  'info': npcClassInfoToJson(v.info),
  'stats': npcClassStatsToJson(v.stats),
  'optionalClassMin': v.optionalClassMin,
  'optionalClassMax': v.optionalClassMax,
  'optionalClassPerTier': v.optionalClassPerTier,
  'active_effects': _list(v.activeEffects, activeEffectDataToJson),
});

Map<String, dynamic> npcTemplateDataToJson(INpcTemplateData v) => _clean({
  'id': v.id,
  'template': v.template,
  'name': v.name,
  'description': v.description,
  'forceTag': v.forceTag?.jsonValue,
  'prohibitTemplates': v.prohibitTemplates,
  'optionalMin': v.optionalMin,
  'optionalMax': v.optionalMax,
  'optionalPerTier': v.optionalPerTier,
  'optionalClassMin': v.optionalClassMin,
  'optionalClassMax': v.optionalClassMax,
  'optionalClassPerTier': v.optionalClassPerTier,
  'caveat': v.caveat,
  'active_effects': _list(v.activeEffects, activeEffectDataToJson),
});

// --- Sección 15.3 (Eidolons) ---

Map<String, dynamic> eidolonShardDataToJson(IEidolonShardData v) => _clean({
  'count': eidolonShardCountToJson(v.count),
  'detail': v.detail,
  'features': _list(v.features, npcFeatureDataToJson),
  'tier': v.tier,
});

Map<String, dynamic> eidolonLayerDataToJson(IEidolonLayerData v) => _clean({
  'id': v.id,
  'name': v.name,
  'appearance': v.appearance,
  'hints': v.hints,
  'rules': v.rules,
  'features': _list(v.features, npcFeatureDataToJson),
  'shards': v.shards == null ? null : eidolonShardDataToJson(v.shards!),
  'active_effects': _list(v.activeEffects, activeEffectDataToJson),
});

/// Despacho por tipo runtime a la función `xDataToJson` de cada una de
/// las 24 entidades — un único punto compartido por `ZipContentPackExporter`
/// (Crear) y por el guardado de Editar (una entidad editada se reconstruye
/// como objeto de dominio tipado vía `fromFormValues` y vuelve a pasar por
/// aquí antes de sustituir su JSON crudo en el paquete).
Map<String, dynamic> entityDataToJson(Object item) => switch (item) {
  IWeaponData v => weaponDataToJson(v),
  IManufacturerData v => manufacturerDataToJson(v),
  ITagData v => tagDataToJson(v),
  ISkillData v => skillDataToJson(v),
  IStatusConditionData v => statusConditionDataToJson(v),
  ISitrepData v => sitrepDataToJson(v),
  IEnvironmentData v => environmentDataToJson(v),
  IBackgroundData v => backgroundDataToJson(v),
  IBondData v => bondDataToJson(v),
  IReserveData v => reserveDataToJson(v),
  ICoreBonusData v => coreBonusDataToJson(v),
  ITalentData v => talentDataToJson(v),
  // IWeaponModData extiende IMechSystemData — su case debe ir antes, si no
  // el switch nunca lo alcanzaría (coincidiría primero con el caso del
  // tipo base).
  IWeaponModData v => weaponModDataToJson(v),
  IMechSystemData v => mechSystemDataToJson(v),
  IPilotGearData v => pilotGearDataToJson(v),
  IFrameData v => frameDataToJson(v),
  INpcFeatureData v => npcFeatureDataToJson(v),
  INpcClassData v => npcClassDataToJson(v),
  INpcTemplateData v => npcTemplateDataToJson(v),
  IEidolonLayerData v => eidolonLayerDataToJson(v),
  _ => throw ArgumentError(
    'Tipo de contenido sin mapeo JSON: ${item.runtimeType}',
  ),
};
