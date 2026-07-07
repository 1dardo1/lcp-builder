// Script de verificación manual: genera un `.lcp` **por entidad** (no uno
// combinado) con varias instancias de cada una de las 8 entidades
// "simples" completadas en esta sesión (manufacturer, tag, skill,
// status_condition, sitrep, environment, background, bond) — mismo
// objetivo que `generar_lcp_pruebas.dart` para armas: confirmar en
// COMP/CON que el dominio/mapper produce JSON que el importador acepta,
// antes de dar por buena cada entidad. Un archivo por tipo, no uno con las
// 8 mezcladas, para que un rechazo de COMP/CON señale directamente qué
// entidad falla. Construye los objetos de dominio directamente (no pasa
// por los ensambladores del formulario) y exporta con
// `ContentPackExporter.export`.
//
// Uso:
//   dart run bin/generar_lcp_pruebas_entidades.dart [directorio_salida]
//
// Directorio por defecto si no se pasa argumento: build/pruebas_entidades/
// (genera manufacturers.lcp, tags.lcp, skills.lcp, statuses.lcp,
// sitreps.lcp, environments.lcp, backgrounds.lcp, bonds.lcp)

import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/infrastructure/file_system/local_file_writer.dart';
import 'package:lcp_builder/infrastructure/lcp/zip_content_pack_exporter.dart';

List<IManufacturerData> _manufacturers() => const [
  IManufacturerData(
    id: 'GMS',
    name: 'General Manufacturing Systems',
    description: 'El mayor fabricante de la Union.',
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
    id: 'tg_accurate',
    name: 'Accurate',
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
    id: 'st_shredded',
    name: 'Shredded',
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
    id: 'env_vacuum',
    name: 'Vacuum',
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

ILcpManifestData _manifestDePruebas() => const ILcpManifestData(
  name: 'LCP Builder — paquete de pruebas (entidades simples)',
  author: 'LCP Builder',
  description:
      'Paquete generado por generar_lcp_pruebas_entidades.dart para '
      'verificar en COMP/CON las 8 entidades simples completadas en esta '
      'sesión.',
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
  };

  final exporter = ZipContentPackExporter();
  final fileWriter = LocalFileWriter();

  // Un .lcp por tipo de contenido (no uno combinado): así, si COMP/CON
  // rechaza alguno al importar, queda claro cuál sin tener que aislarlo a
  // mano dentro de un paquete con las 8 entidades mezcladas.
  for (final entry in content.entries) {
    final outputPath = '$outputDir/${entry.key}.lcp';
    final bytes = exporter.export(
      manifest: _manifestDePruebas(),
      content: {entry.key: entry.value},
    );
    await fileWriter.write(outputPath, bytes);
    // ignore: avoid_print
    print('Generado: $outputPath');
  }
}
