// Script de verificación manual: genera un único `.lcp` con varias armas,
// cada una centrada en una combinación distinta de campos/casos
// polimórficos de `IWeaponData` (los mismos que ya cubre por completo
// `weapon_form_schema.dart` — ver PR "Completar el esquema de IWeaponData").
// El objetivo NO es que el ensamblado del formulario, sino verificar que
// COMP/CON acepta como válida cualquier forma que nosotros demos por válida
// a nivel de dominio/exportación — construye los `IWeaponData` directamente
// (no pasa por `weaponFromFormValues`), igual que `crear_arma_ejemplo.dart`.
//
// Cada arma exercita un subconjunto de campos con un `name`/`id` propio
// ("TEST NN - ..."), para poder identificar en COMP/CON qué combinación
// falla si el import se rechaza.
//
// Uso:
//   dart run bin/generar_lcp_pruebas.dart [ruta_salida.lcp]
//
// Ruta por defecto si no se pasa argumento: build/lcp_pruebas.lcp

import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/infrastructure/file_system/local_file_writer.dart';
import 'package:lcp_builder/infrastructure/lcp/zip_content_pack_exporter.dart';

IWeaponData _test01DanioCompleto() => IWeaponData(
  id: 'mw_test_01_danio',
  name: 'TEST 01 - Daño completo',
  source: 'GMS',
  license: 'GMS Everest',
  licenseId: 'mf_everest',
  licenseLevel: 0,
  effect: 'Prueba de todas las variantes de IDamageData.',
  description:
      'aoe texto/bool, save texto/estructurado, saveHalf, ap, target, min.',
  mount: MountType.main,
  type: WeaponType.rifle,
  damage: [
    IDamageData(
      type: DamageType.kinetic,
      val: DiceExpression.formula('2d6'),
      aoe: StringOrBool.flag(true),
      save: 'hull',
      saveHalf: true,
      ap: true,
      target: TargetType.enemy,
    ),
    IDamageData(
      type: DamageType.explosive,
      val: DiceExpression.number(3),
      aoe: StringOrBool.text('Blast 2'),
      save: const IDamageSaveData(stat: 'agi', aoe: true),
      target: TargetType.ally,
    ),
  ],
  range: [
    IRangeData(
      type: RangeType.range,
      val: DiceExpression.number(10),
      min: DiceExpression.number(3),
    ),
  ],
);

IWeaponData _test02TypeComoLista() => IWeaponData(
  id: 'mw_test_02_type_lista',
  name: 'TEST 02 - Type como lista',
  source: 'GMS',
  license: 'GMS Everest',
  licenseId: 'mf_everest',
  licenseLevel: 0,
  effect: 'Prueba de type: List<WeaponType> en vez de un único valor.',
  description: 'Pertenece a Rifle y Melee a la vez.',
  mount: MountType.main,
  type: const [WeaponType.rifle, WeaponType.melee],
  damage: [
    IDamageData(type: DamageType.kinetic, val: DiceExpression.formula('1d6')),
  ],
);

IWeaponData _test03OnAttackOnHit() => IWeaponData(
  id: 'mw_test_03_on_attack',
  name: 'TEST 03 - onAttack/onHit/onCrit/onMiss',
  source: 'GMS',
  license: 'GMS Everest',
  licenseId: 'mf_everest',
  licenseLevel: 0,
  effect: 'Prueba de TextOrActiveEffect y IActiveEffectData completo.',
  description:
      'onAttack como texto plano; onHit como active effect con addStatus/'
      'addResist (3 variantes)/addSpecial/removeSpecial/addOther (4 variantes)/save.',
  mount: MountType.main,
  type: WeaponType.rifle,
  damage: [
    IDamageData(type: DamageType.energy, val: DiceExpression.formula('1d6')),
  ],
  onAttack: TextOrActiveEffect.text('El arma zumba antes de disparar.'),
  onHit: TextOrActiveEffect.effect(
    IActiveEffectData(
      name: 'Descarga',
      detail: 'El objetivo queda marcado.',
      condition: 'Si el objetivo está expuesto',
      frequency: ActionFrequency.perRound,
      duration: EffectDuration.roundEnd(1),
      bonusDamage: DiceExpression.formula('1d4'),
      damage: [
        IDamageData(type: DamageType.energy, val: DiceExpression.number(2)),
      ],
      range: [IRangeData(type: RangeType.burst, val: DiceExpression.number(1))],
      addStatus: [
        const IStatusEffectData(id: 'st_shredded', target: TargetType.enemy),
      ],
      addResist: [
        const ResistEffectData(resist: ResistanceValue.energy),
        const VulnerabilityEffectData(vulnerability: ResistanceValue.kinetic),
        ImmunityEffectData(immunity: ImmunityValue.known(ResistanceValue.burn)),
        ImmunityEffectData(
          immunity: ImmunityValue.conditionId('cd_shaken'),
          target: TargetType.self,
        ),
      ],
      addSpecial: const [
        ISpecialStatusData(
          attribute: 'Marcado',
          detail: 'Sufre daño extra el próximo turno.',
          target: TargetType.enemy,
        ),
      ],
      removeSpecial: const ['Marcado'],
      addOther: [
        OvershieldEffectData(val: NumericOrFormulaValue.number(2)),
        HpEffectData(val: NumericOrFormulaValue.formula('{grit}')),
        RepairEffectData(val: NumericOrFormulaValue.number(1)),
        const CoverEffectData(val: CoverLevel.soft),
      ],
      save: const IEffectSaveData(stat: MechStat.agi, aoe: false),
      attack: AttackType.ranged,
      pilot: false,
      mech: true,
      accuracy: 1,
      attackBonus: 2,
    ),
  ),
  onCrit: TextOrActiveEffect.text('Doble descarga.'),
  onMiss: TextOrActiveEffect.text('El arma se sobrecalienta.'),
);

IWeaponData _test04Actions() => IWeaponData(
  id: 'mw_test_04_actions',
  name: 'TEST 04 - Actions',
  source: 'GMS',
  license: 'GMS Everest',
  licenseId: 'mf_everest',
  licenseLevel: 0,
  effect: 'Prueba de IActionData con damage/range singulares.',
  description:
      'Incluye trigger (Reaction), addStatus/addResist/addOther, activeEffects, save.',
  mount: MountType.heavy,
  type: WeaponType.cannon,
  damage: [
    IDamageData(type: DamageType.kinetic, val: DiceExpression.formula('3d6')),
  ],
  actions: [
    IActionData(
      name: 'Disparo cargado',
      activation: ActivationType.full,
      detail: 'Carga y dispara con más potencia.',
      frequency: ActionFrequency.perScene,
      cost: 1,
      pilot: false,
      mech: true,
      hideActive: false,
      bonusDamage: DiceExpression.formula('1d6'),
      damage: IDamageData(
        type: DamageType.kinetic,
        val: DiceExpression.number(5),
      ),
      range: IRangeData(type: RangeType.range, val: DiceExpression.number(8)),
      addStatus: const [IStatusEffectData(id: 'st_prone')],
      addResist: const [
        ResistEffectData(resist: ResistanceValue.all, target: TargetType.self),
      ],
      addOther: [CoverEffectData(val: CoverLevel.hard)],
      activeEffects: [
        const IActiveEffectData(
          name: 'Retroceso',
          detail: 'El mech retrocede 1 espacio.',
        ),
      ],
      save: const IEffectSaveData(stat: MechStat.hull),
    ),
    IActionData(
      name: 'Contraataque',
      activation: ActivationType.reaction,
      detail: 'Dispara cuando el enemigo falla su ataque.',
      trigger: 'Un enemigo falla un ataque cuerpo a cuerpo contra ti.',
    ),
  ],
);

IWeaponData _test05Ammo() => IWeaponData(
  id: 'mw_test_05_ammo',
  name: 'TEST 05 - Ammo',
  source: 'GMS',
  license: 'GMS Everest',
  licenseId: 'mf_everest',
  licenseLevel: 0,
  effect: 'Prueba de IAmmoData.',
  description: 'allowed/restricted types y sizes.',
  mount: MountType.main,
  type: WeaponType.rifle,
  damage: [
    IDamageData(type: DamageType.kinetic, val: DiceExpression.formula('2d6')),
  ],
  ammo: const [
    IAmmoData(
      name: 'Munición perforante',
      description: 'Ignora parte de la armadura.',
      cost: 1,
      allowedTypes: [WeaponType.rifle, WeaponType.cannon],
      allowedSizes: [WeaponSize.main, WeaponSize.heavy],
    ),
    IAmmoData(
      name: 'Munición incendiaria',
      description: 'Aplica burn.',
      restrictedTypes: [WeaponType.melee],
      restrictedSizes: [WeaponSize.superheavy],
    ),
  ],
);

IWeaponData _test06BonusesConFiltros() => IWeaponData(
  id: 'mw_test_06_bonuses',
  name: 'TEST 06 - Bonuses con filtros',
  source: 'GMS',
  license: 'GMS Everest',
  licenseId: 'mf_everest',
  licenseLevel: 0,
  effect: 'Prueba de los 4 BonusValueKind y de los filtros de IBonusData.',
  description: 'numericOrFormula, boolean, dieRollList, mountAssignment.',
  mount: MountType.main,
  type: WeaponType.rifle,
  damage: [
    IDamageData(type: DamageType.kinetic, val: DiceExpression.formula('2d6')),
  ],
  bonuses: [
    IBonusData(
      id: BonusId.accuracy,
      val: NumericOrFormulaValue.formula('{grit}'),
      accuracy: 1,
      damageTypes: const [DamageType.kinetic, DamageType.energy],
      rangeTypes: const [BonusRangeTypeFilter.range],
      weaponTypes: const [
        BonusWeaponTypeFilter.rifle,
        BonusWeaponTypeFilter.cqb,
      ],
      weaponSizes: const [BonusWeaponSizeFilter.main],
      overwrite: true,
      replace: false,
    ),
    IBonusData(id: BonusId.cheapStruct, val: true),
    IBonusData(
      id: BonusId.overcharge,
      val: [DieRoll('1d6'), DieRoll('1d6+1d8'), DieRoll('2d6+1d10')],
    ),
    IBonusData(
      id: BonusId.addMount,
      val: const MountAssignment(
        mountType: MountAssignmentType.main,
        maxMounts: 2,
      ),
    ),
  ],
);

IWeaponData _test07Synergies() => IWeaponData(
  id: 'mw_test_07_synergies',
  name: 'TEST 07 - Synergies',
  source: 'GMS',
  license: 'GMS Everest',
  licenseId: 'mf_everest',
  licenseLevel: 0,
  effect: 'Prueba de ISynergyData con location preset y personalizada.',
  description:
      'locations mezcla constantes fijas y action_<id>; filtros de tipo.',
  mount: MountType.main,
  type: WeaponType.rifle,
  damage: [
    IDamageData(type: DamageType.kinetic, val: DiceExpression.formula('2d6')),
  ],
  synergies: [
    ISynergyData(
      locations: [
        SynergyLocation.weapon,
        SynergyLocation.actionX('mw_test_04_actions'),
      ],
      detail: 'Sinergia con el disparo cargado.',
      weaponTypes: const [WeaponType.rifle],
      weaponSizes: const [WeaponSize.main],
      systemTypes: const [SystemType.tech],
    ),
  ],
);

IWeaponData _test08Deployables() => IWeaponData(
  id: 'mw_test_08_deployables',
  name: 'TEST 08 - Deployables',
  source: 'GMS',
  license: 'GMS Everest',
  licenseId: 'mf_everest',
  licenseLevel: 0,
  effect: 'Prueba de IDeployableData con campos num|NumericOrFormulaValue.',
  description:
      'type personalizado, actions/bonuses/synergies/counters/activeEffects/tags anidados.',
  mount: MountType.heavy,
  type: WeaponType.launcher,
  damage: [
    IDamageData(type: DamageType.explosive, val: DiceExpression.formula('2d6')),
  ],
  deployables: [
    IDeployableData(
      name: 'Torreta de despliegue',
      type: DeployableType.custom('Turret'),
      detail: 'Una torreta automática.',
      activation: ActivationType.quick,
      deactivation: ActivationType.free,
      instances: 1,
      cost: 1,
      size: 0.5,
      armor: NumericOrFormulaValue.number(2),
      hp: NumericOrFormulaValue.formula('{grit}+5'),
      evasion: NumericOrFormulaValue.number(8),
      edef: NumericOrFormulaValue.number(8),
      heatcap: NumericOrFormulaValue.number(0),
      repcap: NumericOrFormulaValue.number(0),
      sensorRange: NumericOrFormulaValue.number(5),
      techAttack: NumericOrFormulaValue.number(0),
      save: NumericOrFormulaValue.number(10),
      speed: NumericOrFormulaValue.number(0),
      grapple: NumericOrFormulaValue.number(0),
      attackBonus: NumericOrFormulaValue.number(2),
      damage: [
        IDamageData(
          type: DamageType.kinetic,
          val: DiceExpression.formula('1d6'),
        ),
      ],
      range: [IRangeData(type: RangeType.range, val: DiceExpression.number(8))],
      actions: [
        IActionData(
          name: 'Disparar',
          activation: ActivationType.quick,
          detail: 'La torreta dispara.',
        ),
      ],
      bonuses: [
        IBonusData(id: BonusId.accuracy, val: NumericOrFormulaValue.number(1)),
      ],
      synergies: const [
        ISynergyData(
          locations: [SynergyLocation.deployable],
          detail: 'Sinergia de torreta.',
        ),
      ],
      counters: const [
        ICounterData(id: 'ct_charges', name: 'Cargas', defaultValue: 3),
      ],
      activeEffects: const [
        IActiveEffectData(
          name: 'Blindada',
          detail: 'Ignora el primer impacto.',
        ),
      ],
      tags: const [ITagInstance(id: 'tg_deployed')],
      pilot: false,
      mech: true,
    ),
  ],
);

IWeaponData _test09Profiles() => IWeaponData(
  id: 'mw_test_09_profiles',
  name: 'TEST 09 - Profiles',
  source: 'GMS',
  license: 'GMS Everest',
  licenseId: 'mf_everest',
  licenseLevel: 0,
  effect:
      'Prueba de IWeaponProfile reutilizando el mismo bundle de campos que el arma.',
  description:
      'Perfil alternativo con su propio damage/range/actions/bonuses/onAttack.',
  mount: MountType.main,
  type: WeaponType.rifle,
  damage: [
    IDamageData(type: DamageType.kinetic, val: DiceExpression.formula('2d6')),
  ],
  profiles: [
    IWeaponProfile(
      name: 'Modo ráfaga',
      effect: TextOrActiveEffect.text('Dispara 3 veces con -1 accuracy.'),
      skirmish: true,
      barrage: false,
      onAttack: TextOrActiveEffect.text('El cañón vibra.'),
      damage: [
        IDamageData(
          type: DamageType.kinetic,
          val: DiceExpression.formula('1d6'),
        ),
      ],
      range: [IRangeData(type: RangeType.range, val: DiceExpression.number(6))],
      actions: [
        IActionData(
          name: 'Ráfaga',
          activation: ActivationType.full,
          detail: 'Tres disparos consecutivos.',
        ),
      ],
      bonuses: [
        IBonusData(id: BonusId.accuracy, val: NumericOrFormulaValue.number(-1)),
      ],
      integrated: const ['mw_test_09_profiles'],
    ),
  ],
);

IWeaponData _test10FlagsYListasSimples() => IWeaponData(
  id: 'mw_test_10_flags',
  name: 'TEST 10 - Flags y listas simples',
  source: 'GMS',
  license: 'GMS Everest',
  licenseId: 'mf_everest',
  licenseLevel: 0,
  effect: 'Prueba de flags booleanas y listas de string simples.',
  description:
      'noAttack/noMods/noCoreBonus/noBonus/noSynergy, counters, integrated, '
      'specialEquipment, cost + tag limited.',
  mount: MountType.aux,
  type: WeaponType.nexus,
  cost: 2,
  noAttack: false,
  noMods: true,
  noCoreBonus: false,
  noBonus: false,
  noSynergy: true,
  damage: [
    IDamageData(type: DamageType.variable, val: DiceExpression.formula('1d6')),
  ],
  tags: const [ITagInstance(id: 'tg_limited', val: 2)],
  counters: const [
    ICounterData(
      id: 'ct_test10',
      name: 'Usos',
      defaultValue: 2,
      min: 0,
      max: 2,
    ),
  ],
  integrated: const ['mw_test_05_ammo'],
  specialEquipment: const ['mw_test_09_profiles'],
);

ILcpManifestData _manifestDePruebas() => const ILcpManifestData(
  name: 'LCP Builder — paquete de pruebas',
  author: 'LCP Builder',
  description:
      'Paquete generado por generar_lcp_pruebas.dart para verificar en '
      'COMP/CON que todas las formas que el dominio da por válidas son '
      'aceptadas al importar.',
  version: '0.1.0',
  v3: true,
);

Future<void> main(List<String> args) async {
  final outputPath = args.isNotEmpty ? args[0] : 'build/lcp_pruebas.lcp';

  final weapons = [
    _test01DanioCompleto(),
    _test02TypeComoLista(),
    _test03OnAttackOnHit(),
    _test04Actions(),
    _test05Ammo(),
    _test06BonusesConFiltros(),
    _test07Synergies(),
    _test08Deployables(),
    _test09Profiles(),
    _test10FlagsYListasSimples(),
  ];

  final bytes = ZipContentPackExporter().export(
    manifest: _manifestDePruebas(),
    content: {'weapons': weapons},
  );
  await LocalFileWriter().write(outputPath, bytes);

  // ignore: avoid_print
  print('Generado: $outputPath (${weapons.length} armas de prueba)');
}
