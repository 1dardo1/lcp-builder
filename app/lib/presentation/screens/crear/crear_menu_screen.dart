import 'package:flutter/material.dart';

import '../../forms/background_form_schema.dart';
import '../../forms/bond_form_schema.dart';
import '../../forms/core_bonus_form_schema.dart';
import '../../forms/entity_crear_config.dart';
import '../../forms/eidolon_layer_form_schema.dart';
import '../../forms/environment_form_schema.dart';
import '../../forms/frame_form_schema.dart';
import '../../forms/manufacturer_form_schema.dart';
import '../../forms/mech_system_form_schema.dart';
import '../../forms/npc_class_form_schema.dart';
import '../../forms/npc_feature_form_schema.dart';
import '../../forms/npc_template_form_schema.dart';
import '../../forms/pilot_gear_form_schema.dart';
import '../../forms/reserve_form_schema.dart';
import '../../forms/sitrep_form_schema.dart';
import '../../forms/skill_form_schema.dart';
import '../../forms/status_condition_form_schema.dart';
import '../../forms/tag_form_schema.dart';
import '../../forms/talent_form_schema.dart';
import '../../forms/weapon_form_schema.dart';
import '../../forms/weapon_mod_form_schema.dart';
import 'crear_entidad_screen.dart';

/// Registro de entidades disponibles en el flujo Crear — cada esquema
/// aporta su propio [EntityCrearConfig]; este menú no conoce ningún tipo
/// de dominio concreto, solo la lista. Añadir una entidad nueva es añadir
/// una línea aquí, no tocar el menú ni la pantalla genérica.
final List<EntityCrearConfig> crearEntidadConfigs = [
  weaponCrearConfig,
  manufacturerCrearConfig,
  tagCrearConfig,
  skillCrearConfig,
  statusConditionCrearConfig,
  sitrepCrearConfig,
  environmentCrearConfig,
  backgroundCrearConfig,
  bondCrearConfig,
  reserveCrearConfig,
  coreBonusCrearConfig,
  talentCrearConfig,
  mechSystemCrearConfig,
  weaponModCrearConfig,
  pilotGearCrearConfig,
  frameCrearConfig,
  npcFeatureCrearConfig,
  npcClassCrearConfig,
  npcTemplateCrearConfig,
  eidolonLayerCrearConfig,
];

/// Pantalla de inicio del flujo Crear: menú de entidades disponibles. Sin
/// diseño de Figma todavía — Material por defecto, funcional, no
/// definitivo (ver `vault/UI-UX`).
class CrearMenuScreen extends StatelessWidget {
  const CrearMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear')),
      body: ListView(
        children: [
          for (final config in crearEntidadConfigs)
            ListTile(
              title: Text(config.title),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CrearEntidadScreen(config: config),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
