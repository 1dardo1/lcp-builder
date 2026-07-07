// Script de verificación headless del flujo Crear (arma) — sin interfaz
// todavía, para comprobar que el .lcp generado es correcto antes de
// construir el formulario real. Uso:
//
//   dart run bin/crear_arma_ejemplo.dart [ruta_salida.lcp]
//
// Ruta por defecto si no se pasa argumento: build/arma_ejemplo.lcp

import 'package:lcp_builder/application/use_cases/crear_contenido_use_case.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/infrastructure/file_system/local_file_writer.dart';
import 'package:lcp_builder/infrastructure/lcp/zip_content_pack_exporter.dart';

IWeaponData _armaDeEjemplo() {
  return IWeaponData(
    id: 'mw_ejemplo_rifle',
    name: 'Rifle de ejemplo',
    source: 'GMS',
    license: 'GMS Everest',
    licenseId: 'mf_everest',
    licenseLevel: 0,
    effect: 'Un rifle de ejemplo para verificar el flujo de exportación.',
    description: 'Arma generada por el script de verificación headless.',
    mount: MountType.main,
    type: WeaponType.rifle,
    damage: [
      IDamageData(type: DamageType.kinetic, val: DiceExpression.formula('2d6')),
    ],
    range: [IRangeData(type: RangeType.range, val: DiceExpression.number(10))],
    tags: [ITagInstance(id: 'tg_accurate')],
    sp: 1,
    bonuses: [
      IBonusData(id: BonusId.accuracy, val: NumericOrFormulaValue.number(1)),
    ],
    actions: [
      IActionData(
        name: 'Disparar',
        activation: ActivationType.quick,
        detail: 'Dispara el rifle de ejemplo.',
      ),
    ],
  );
}

ILcpManifestData _manifestDeEjemplo() {
  return ILcpManifestData(
    name: 'LCP Builder — paquete de ejemplo',
    author: 'LCP Builder',
    description:
        'Paquete de verificación generado por crear_arma_ejemplo.dart.',
    version: '0.1.0',
    v3: true,
  );
}

Future<void> main(List<String> args) async {
  final outputPath = args.isNotEmpty ? args[0] : 'build/arma_ejemplo.lcp';

  final useCase = CrearContenidoUseCase(
    exporter: ZipContentPackExporter(),
    fileWriter: LocalFileWriter(),
  );

  await useCase(
    contentKey: 'weapons',
    content: _armaDeEjemplo(),
    manifest: _manifestDeEjemplo(),
    outputPath: outputPath,
  );

  // ignore: avoid_print
  print('Generado: $outputPath');
}
