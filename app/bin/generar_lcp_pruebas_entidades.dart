// Script de verificación manual: genera un `.lcp` **por entidad** (no uno
// combinado) con varias instancias de cada una de las entidades "simples"
// (sin mecanismo polimórfico propio) ya completadas: manufacturer, tag,
// skill, status_condition, sitrep, environment, background, bond, reserve,
// core_bonus, talent — mismo objetivo que `generar_lcp_pruebas.dart` para
// armas: confirmar en COMP/CON que el dominio/mapper produce JSON que el
// importador acepta, antes de dar por buena cada entidad. Un archivo por
// tipo, no uno con todas mezcladas, para que un rechazo de COMP/CON señale
// directamente qué entidad falla. Construye los objetos de dominio
// directamente (no pasa por los ensambladores del formulario) y exporta
// con `ContentPackExporter.export`.
//
// Uso:
//   dart run bin/generar_lcp_pruebas_entidades.dart [directorio_salida]
//
// Directorio por defecto si no se pasa argumento: build/pruebas_entidades/
// (genera manufacturers.lcp, tags.lcp, skills.lcp, statuses.lcp,
// sitreps.lcp, environments.lcp, backgrounds.lcp, bonds.lcp, reserves.lcp,
// core_bonuses.lcp, talents.lcp)

import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/infrastructure/file_system/local_file_writer.dart';
import 'package:lcp_builder/infrastructure/lcp/zip_content_pack_exporter.dart';

List<IManufacturerData> _manufacturers() => const [
  IManufacturerData(
    // id distinto de los fabricantes reales de core data (GMS, IPS-N,
    // SSC, HORUS, HA...) — un id que colisione se confunde en COMP/CON
    // con el fabricante oficial en vez de aparecer como contenido nuevo.
    id: 'TEST_MFR',
    name: 'TEST Manufacturing',
    description: 'Fabricante de prueba, no colisiona con core data.',
    quote: '"Fiable donde otros fallan."',
    light: '#D9D9D9',
    dark: '#1A1A1A',
    iconSvg: '<svg></svg>',
  ),
  IManufacturerData(
    id: 'TEST_SIN_ICONO',
    name: 'TEST — sin icono',
    description: 'Prueba sin iconSvg ni iconUrl (ambos opcionales).',
    quote: 'q',
    light: '#FFFFFF',
    dark: '#000000',
  ),
];

List<ITagData> _tags() => const [
  ITagData(
    // id distinto de los tags reales de core data (tg_accurate ya existe
    // oficialmente) — mismo motivo que el id de manufacturer más abajo.
    id: 'tg_test_accurate',
    name: 'TEST — Accurate',
    description: 'Tira el dado de ataque dos veces, queda el mayor.',
  ),
  ITagData(
    id: 'tg_test_hidden',
    name: 'TEST — hidden + filterIgnore',
    description: 'd',
    hidden: true,
    filterIgnore: true,
  ),
];

List<ISkillData> _skills() => [
  for (final family in SkillFamily.values)
    ISkillData(
      id: 'sk_test_${family.jsonValue}',
      name: 'TEST — familia ${family.jsonValue}',
      description: 'd',
      detail: 'flavor text',
      family: family,
    ),
];

List<IStatusConditionData> _statusConditions() => const [
  IStatusConditionData(
    // id distinto de los statuses reales de core data (st_shredded ya
    // existe oficialmente) — mismo motivo que el id de manufacturer.
    id: 'st_test_shredded',
    name: 'TEST — Shredded',
    type: StatusConditionType.status,
    effects: 'Vulnerable a Energy.',
    terse: 'Vuln. Energy',
  ),
  IStatusConditionData(
    id: 'cd_test_exclusive',
    name: 'TEST — condition con exclusive',
    type: StatusConditionType.condition,
    effects: 'e',
    exclusive: ExclusiveTarget.pilot,
  ),
];

List<ISitrepData> _sitreps() => const [
  ISitrepData(
    id: 'sitrep_test_completo',
    name: 'TEST — sitrep completo',
    description: 'd',
    deployment: 'despliegue',
    objective: 'objetivo',
    extraction: 'extracción',
    conditions: [
      ISitrepCondition(title: 'Victoria por objetivo', condition: 'c'),
    ],
    pcVictory: 'Los PCs ganan si...',
    enemyVictory: 'El enemigo gana si...',
    noVictory: 'Nadie gana si...',
  ),
  ISitrepData(
    id: 'sitrep_test_minimo',
    name: 'TEST — sitrep mínimo',
    description: 'solo campos requeridos',
  ),
];

List<IEnvironmentData> _environments() => const [
  IEnvironmentData(
    // id distinto de los entornos reales de core data (env_vacuum podría
    // colisionar) — mismo motivo que el id de manufacturer.
    id: 'env_test_vacuum',
    name: 'TEST — Vacuum',
    description: 'Sin atmósfera. Reglas especiales de movimiento y daño.',
  ),
];

List<IBackgroundData> _backgrounds() => const [
  IBackgroundData(
    id: 'bg_test_con_skills',
    name: 'TEST — con skills recomendadas',
    description: 'd',
    skills: ['sk_test_str', 'sk_test_dex'],
  ),
  IBackgroundData(
    id: 'bg_test_sin_skills',
    name: 'TEST — sin skills',
    description: 'skills es opcional',
  ),
];

List<IBondData> _bonds() => const [
  IBondData(
    id: 'bond_test_completo',
    name: 'TEST — bond completo',
    majorIdeals: ['Honor', 'Venganza'],
    minorIdeals: ['Cautela', 'Curiosidad'],
    questions: [
      IQuestionData(
        question: '¿Por qué luchas?',
        options: ['Por dinero', 'Por venganza', 'Por el equipo'],
      ),
    ],
    powers: [
      IBondPowerData(
        name: 'Poder de prueba',
        description: 'd',
        frequency: ActionFrequency.perScene,
        prerequisite: 'ninguno',
        veteran: true,
      ),
      IBondPowerData(
        name: 'Poder Master',
        description: 'd',
        master: true,
        origin: 'origen de prueba',
      ),
    ],
  ),
];

List<IReserveData> _reserves() => [
  IReserveData(
    id: 'reserve_test_tactical',
    name: 'TEST — reserve táctica',
    type: ReserveType.tactical,
    description: 'd',
    consumable: true,
    bonuses: [
      IBonusData(id: BonusId.accuracy, val: NumericOrFormulaValue.number(1)),
    ],
  ),
  const IReserveData(
    id: 'reserve_test_minima',
    name: 'TEST — reserve mínima',
    type: ReserveType.resource,
  ),
];

List<ICoreBonusData> _coreBonuses() => const [
  ICoreBonusData(
    id: 'cb_test_completo',
    name: 'TEST — core bonus completo',
    source: 'TEST_MFR',
    effect: 'e',
    description: 'd',
    mountedEffect: 'efecto al instalar en un mount',
  ),
];

List<ITalentData> _talents() => [
  ITalentData(
    id: 'tal_test_con_ranks',
    name: 'TEST — talent con ranks',
    description: 'd',
    ranks: [
      IRankData(
        name: 'Rank 1',
        description: 'd',
        bonuses: [
          IBonusData(
            id: BonusId.accuracy,
            val: NumericOrFormulaValue.number(1),
          ),
        ],
      ),
      const IRankData(name: 'Rank 2', description: 'd'),
      const IRankData(name: 'Rank 3', description: 'd', exclusive: true),
    ],
  ),
];

/// Un manifest por entidad, con `name` propio — COMP/CON identifica un
/// content pack por su manifest (nombre/autor/versión), así que 8 `.lcp`
/// con el mismo manifest se tratan como el mismo pack: cada uno que se
/// carga sobrescribe al anterior en vez de sumarse. Ver vault
/// "Principios y decisiones clave" — mismo tipo de bug que las keys
/// duplicadas en un `Map`, pero a nivel de content pack.
ILcpManifestData _manifestDePruebas(String contentKey) => ILcpManifestData(
  name: 'LCP Builder — paquete de pruebas ($contentKey)',
  author: 'LCP Builder',
  description:
      'Paquete generado por generar_lcp_pruebas_entidades.dart para '
      'verificar en COMP/CON la entidad "$contentKey".',
  version: '0.1.0',
  v3: true,
);

Future<void> main(List<String> args) async {
  final outputDir = args.isNotEmpty ? args[0] : 'build/pruebas_entidades';

  final content = <String, List<Object>>{
    'manufacturers': _manufacturers(),
    'tags': _tags(),
    'skills': _skills(),
    'statuses': _statusConditions(),
    'sitreps': _sitreps(),
    'environments': _environments(),
    'backgrounds': _backgrounds(),
    'bonds': _bonds(),
    'reserves': _reserves(),
    'core_bonuses': _coreBonuses(),
    'talents': _talents(),
  };

  final exporter = ZipContentPackExporter();
  final fileWriter = LocalFileWriter();

  // Un .lcp por tipo de contenido (no uno combinado): así, si COMP/CON
  // rechaza alguno al importar, queda claro cuál sin tener que aislarlo a
  // mano dentro de un paquete con las 8 entidades mezcladas.
  for (final entry in content.entries) {
    final outputPath = '$outputDir/${entry.key}.lcp';
    final bytes = exporter.export(
      manifest: _manifestDePruebas(entry.key),
      content: {entry.key: entry.value},
    );
    await fileWriter.write(outputPath, bytes);
    // ignore: avoid_print
    print('Generado: $outputPath');
  }
}
