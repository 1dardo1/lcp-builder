/// Frame value objects: prerequisites, traits and core systems (vault domain
/// model, section 13.2).
library;

import '../enums/enums.dart';
import '../entities/counter_data.dart';
import 'actions_and_active_effects.dart';
import 'bonuses.dart';
import 'deployables.dart';
import 'synergies.dart';
import 'tags.dart';

/// Usado solo dentro de `specialty` de [IFrameData].
class IPrerequisite {
  final String source; // Manufacturer ID
  final int minRank;
  final bool cumulative; // default false

  const IPrerequisite({
    required this.source,
    required this.minRank,
    this.cumulative = false,
  });
}

/// Agrupa el contenido mecánico de un trait; no tiene `id` propio.
class IFrameTraitData {
  final String name;
  final String description;
  final List<IActionData>? actions;
  final List<IBonusData>? bonuses;
  final List<ISynergyData>? synergies;
  final List<IDeployableData>? deployables;
  final List<ICounterData>? counters;
  final List<String>? integrated; // no ocupa espacio de mount, no removible
  final List<String>? specialEquipment; // no se instala automáticamente
  final List<IActiveEffectData>? activeEffects;

  const IFrameTraitData({
    required this.name,
    required this.description,
    this.actions,
    this.bonuses,
    this.synergies,
    this.deployables,
    this.counters,
    this.integrated,
    this.specialEquipment,
    this.activeEffects,
  });
}

/// Cada Frame tiene exactamente uno; no tiene `id` propio.
class ICoreSystemData {
  final String name;
  final String? description;
  final String activeName;
  final String activeEffect;
  final ActivationType activation;
  final ActivationType?
  deactivation; // si se omite: activo hasta `use` o fin de misión
  final CoreSystemUse? use;
  final List<IActiveEffectData>? activeEffects; // añadidos al mech al activar
  final List<IActionData>? activeActions;
  final List<IBonusData>? activeBonuses;
  final List<ISynergyData>? activeSynergies;
  final String? passiveName;
  final String? passiveEffect;
  final List<IActionData>? passiveActions; // siempre disponibles
  final List<IBonusData>? passiveBonuses; // siempre activos
  final List<ISynergyData>? passiveSynergies; // siempre activas
  final List<IDeployableData>?
  deployables; // usables desde el panel del Core System
  final List<ICounterData>? counters; // siempre presentes
  final List<String>? integrated; // siempre instalado
  final List<String>? specialEquipment; // siempre instalado
  final List<ITagInstance>? tags;

  const ICoreSystemData({
    required this.name,
    this.description,
    required this.activeName,
    required this.activeEffect,
    required this.activation,
    this.deactivation,
    this.use,
    this.activeEffects,
    this.activeActions,
    this.activeBonuses,
    this.activeSynergies,
    this.passiveName,
    this.passiveEffect,
    this.passiveActions,
    this.passiveBonuses,
    this.passiveSynergies,
    this.deployables,
    this.counters,
    this.integrated,
    this.specialEquipment,
    this.tags,
  });
}
