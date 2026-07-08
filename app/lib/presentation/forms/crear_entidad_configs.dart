import 'background_form_schema.dart';
import 'bond_form_schema.dart';
import 'core_bonus_form_schema.dart';
import 'eidolon_layer_form_schema.dart';
import 'entity_crear_config.dart';
import 'environment_form_schema.dart';
import 'frame_form_schema.dart';
import 'manufacturer_form_schema.dart';
import 'mech_system_form_schema.dart';
import 'npc_class_form_schema.dart';
import 'npc_feature_form_schema.dart';
import 'npc_template_form_schema.dart';
import 'pilot_gear_form_schema.dart';
import 'reserve_form_schema.dart';
import 'sitrep_form_schema.dart';
import 'skill_form_schema.dart';
import 'status_condition_form_schema.dart';
import 'tag_form_schema.dart';
import 'talent_form_schema.dart';
import 'weapon_form_schema.dart';
import 'weapon_mod_form_schema.dart';

/// Registro de entidades disponibles en el flujo Crear — cada esquema
/// aporta su propio [EntityCrearConfig]; ni `CrearMenuScreen` ni
/// `CrearEntidadScreen` conocen ningún tipo de dominio concreto, solo esta
/// lista. Añadir una entidad nueva es añadir una línea aquí.
///
/// Vive en su propio archivo (no en `crear_menu_screen.dart`, donde vivía
/// antes) porque `CrearEntidadScreen` también lo necesita — para resolver
/// a qué pantalla navegar cuando el usuario pulsa "Crear `referencia`" en
/// un campo que referencia otra entidad (`TextFieldSpec.referenceEntityKey`,
/// ver `generic_form_view.dart`) — y `crear_menu_screen.dart` ya importa
/// `crear_entidad_screen.dart`, así que ponerlo ahí habría creado un import
/// circular entre las dos pantallas.
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

/// Mismo registro, indexado por `contentKey` — lo usa `CrearEntidadScreen`
/// para resolver el `EntityCrearConfig` de una referencia
/// (`referenceEntityKey`) sin recorrer la lista cada vez.
final Map<String, EntityCrearConfig> crearEntidadConfigsByContentKey = {
  for (final config in crearEntidadConfigs) config.contentKey: config,
};
