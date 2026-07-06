/// Enums del dominio LCP Builder.
///
/// Transcripción directa de `vault/Modelo de Dominio/` (secciones 1-17).
/// Las decisiones de nombrado y valores ya están verificadas contra JSON
/// real (lancer-data) — ver notas de cada sección en el vault antes de
/// "corregir" cualquier valor aquí.
///
/// `jsonValue` conserva la grafía exacta requerida por el formato `.lcp`
/// (case-sensitive, con espacios o barras en algunos casos) allí donde
/// difiere del identificador Dart idiomático.
library;

// --- Sección 1: tipos primitivos compuestos ---

enum DamageType { kinetic, energy, explosive, heat, burn, variable }

enum RangeType { threat, range, burst, blast, cone, line }

/// "CQB" verificado contra lib/weapons.json — "CQC" (visto en la página de
/// Bonuses) es un error de tecleo de esa página, no un valor real.
enum WeaponType {
  rifle('Rifle'),
  cannon('Cannon'),
  launcher('Launcher'),
  cqb('CQB'),
  nexus('Nexus'),
  melee('Melee');

  final String jsonValue;
  const WeaponType(this.jsonValue);
}

/// "Auxiliary" verificado contra lib/weapons.json (campo `mount`) — "Aux"
/// (visto en README inicial y en la página de weapons) es incorrecto para
/// este campo. Distinto del valor "Aux" de MountAssignment (sección 4).
enum WeaponSize {
  auxiliary('Auxiliary'),
  main('Main'),
  heavy('Heavy'),
  superheavy('Superheavy');

  final String jsonValue;
  const WeaponSize(this.jsonValue);
}

/// Tipo transversal (Damage/Range y subtipos de Active Effects). El default
/// cuando se omite varía según el tipo contenedor — no hay un default único.
enum TargetType { self, ally, enemy }

// --- Sección 2: subtipos de Active Effects ---

enum MechStat { hull, agi, sys, eng }

enum AttackType { melee, ranged, tech }

enum CoverLevel { soft, hard, none }

/// Fijo, SIN variable entera (distinto de [ReactionFrequency]).
enum ActionFrequency {
  unlimited('unlimited'),
  perRound('1/round'),
  perTurn('1/turn'),
  perScene('1/scene'),
  perEncounter('1/encounter'), // alias de perScene
  perMission('1/mission');

  final String jsonValue;
  const ActionFrequency(this.jsonValue);
}

/// Valores de resist/vulnerability/immunity (sección 2, IResistanceData).
enum ResistanceValue { kinetic, energy, explosive, heat, burn, aoe, all }

// --- Sección 3: contenedores de efectos ---

enum ActivationType {
  free('Free'),
  protocol('Protocol'),
  quick('Quick'),
  full('Full'),
  invade('Invade'),
  quickTech('Quick Tech'),
  fullTech('Full Tech'),
  reaction('Reaction');

  final String jsonValue;
  const ActivationType(this.jsonValue);
}

// --- Sección 4: Bonuses ---

/// Filtros propios de Bonuses, distintos de los enums "reales" de arma
/// (sección 1) — incluyen el comodín `any`. Ver vault MdD §4.
enum BonusWeaponTypeFilter {
  rifle('Rifle'),
  cannon('Cannon'),
  launcher('Launcher'),
  cqb('CQB'),
  nexus('Nexus'),
  melee('Melee'),
  improvised('Improvised'),
  any('any');

  final String jsonValue;
  const BonusWeaponTypeFilter(this.jsonValue);
}

enum BonusWeaponSizeFilter {
  auxiliary('Auxiliary'),
  main('Main'),
  heavy('Heavy'),
  superheavy('Superheavy'),
  any('any');

  final String jsonValue;
  const BonusWeaponSizeFilter(this.jsonValue);
}

/// Sin valor "any" — la fuente no lo documenta para este campo.
enum BonusRangeTypeFilter { threat, range, burst, blast, cone, line, melee }

/// Enum de `add_mount` (Bonuses) — conjunto distinto de [MountType] (Frames,
/// sección 13.2): no incluye Flex ni Integrated. Dos enums independientes.
enum MountAssignmentType {
  aux('Aux'),
  auxAux('Aux/Aux'),
  auxMain('Aux/Main'),
  main('Main'),
  heavy('Heavy'),
  superheavy('Superheavy');

  final String jsonValue;
  const MountAssignmentType(this.jsonValue);
}

// --- Sección 5: Synergies ---

enum SystemType {
  ai('AI'),
  deployable('Deployable'),
  drone('Drone'),
  flightSystem('Flight System'),
  shield('Shield'),
  system('System'),
  tech('Tech');

  final String jsonValue;
  const SystemType(this.jsonValue);
}

// --- Sección 13: Frames ---

/// Lista completa y autoritativa (Frames, sección 13.2). Distinto de
/// [MountAssignmentType] (sección 4, `add_mount`).
enum MountType {
  main('Main'),
  heavy('Heavy'),
  auxAux('Aux/Aux'),
  aux('Aux'),
  mainAux('Main/Aux'),
  flex('Flex'),
  integrated('Integrated');

  final String jsonValue;
  const MountType(this.jsonValue);
}

/// Valor de `ICoreSystemData.use` — si se omite, activo hasta deactivation
/// o fin de misión.
enum CoreSystemUse {
  round('Round'),
  nextRound('Next Round'),
  scene('Scene'),
  encounter('Encounter'),
  mission('Mission');

  final String jsonValue;
  const CoreSystemUse(this.jsonValue);
}

// --- Sección 11: Pilot Data ---

enum ReserveType { mech, tactical, resource, bonus }

/// "int" es palabra reservada en Dart — jsonValue conserva el valor real.
enum SkillFamily {
  str('str'),
  con('con'),
  dex('dex'),
  intFamily('int'),
  cha('cha');

  final String jsonValue;
  const SkillFamily(this.jsonValue);
}

// --- Sección 15: NPC Data ---

/// COMP/CON no soporta multi-rol.
enum NpcRole { artillery, controller, defender, striker, support, tank }

enum NpcForceTag {
  mech('Mech'),
  ship('Ship'),
  vehicle('Vehicle'),
  biological('Biological'),
  squad('Squad'),
  other('Other');

  final String jsonValue;
  const NpcForceTag(this.jsonValue);
}

/// Discriminador de las 5 variantes de INpcFeatureData. Default si se omite: trait.
enum NpcFeatureType { trait, system, reaction, tech, weapon }

// --- Sección 17: Other ---

enum StatusConditionType { status, condition }

enum ExclusiveTarget { mech, pilot }
