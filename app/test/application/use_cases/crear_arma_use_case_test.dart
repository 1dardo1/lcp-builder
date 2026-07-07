import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/application/use_cases/crear_arma_use_case.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/infrastructure/file_system/local_file_writer.dart';
import 'package:lcp_builder/infrastructure/lcp/zip_content_pack_exporter.dart';

/// Test de aceptación (ADR-002: al menos uno por iteración, validando el
/// flujo desde la perspectiva del cliente): construye un arma completa,
/// ejecuta el caso de uso real (exportador + escritura a disco reales, sin
/// dobles de test) y verifica que el .lcp resultante es un zip de un solo
/// nivel, con lcp_manifest.json y weapons.json legibles y correctos —
/// exactamente lo que el cliente esperaría poder cargar en COMP/CON.
void main() {
  test('Crear arma produce un .lcp válido en disco', () async {
    final tempDir = await Directory.systemTemp.createTemp('lcp_builder_test');
    final outputPath = '${tempDir.path}/arma.lcp';

    final useCase = CrearArmaUseCase(
      exporter: ZipContentPackExporter(),
      fileWriter: LocalFileWriter(),
    );

    final weapon = IWeaponData(
      id: 'mw_test_rifle',
      name: 'Rifle de aceptación',
      source: 'GMS',
      license: 'GMS Everest',
      licenseId: 'mf_everest',
      licenseLevel: 0,
      effect: 'efecto de prueba',
      description: 'descripción de prueba',
      mount: MountType.main,
      type: WeaponType.rifle,
      damage: [
        IDamageData(
          type: DamageType.kinetic,
          val: DiceExpression.formula('2d6'),
        ),
      ],
      bonuses: [
        IBonusData(id: BonusId.accuracy, val: NumericOrFormulaValue.number(1)),
      ],
    );

    final manifest = ILcpManifestData(
      name: 'Paquete de aceptación',
      author: 'Test',
      description: 'desc',
      version: '1.0.0',
    );

    try {
      await useCase(weapon: weapon, manifest: manifest, outputPath: outputPath);

      final file = File(outputPath);
      expect(await file.exists(), isTrue);

      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // Zip de un solo nivel: sin subcarpetas (requisito del formato .lcp).
      expect(
        archive.files.map((f) => f.name),
        containsAll(['lcp_manifest.json', 'weapons.json']),
      );
      for (final f in archive.files) {
        expect(
          f.name.contains('/'),
          isFalse,
          reason: 'el .lcp no debe tener subcarpetas',
        );
      }

      final manifestJson = jsonDecode(
        utf8.decode(
          archive.findFile('lcp_manifest.json')!.content as List<int>,
        ),
      );
      expect(manifestJson['name'], 'Paquete de aceptación');
      expect(manifestJson['version'], '1.0.0');

      final weaponsJson =
          jsonDecode(
                utf8.decode(
                  archive.findFile('weapons.json')!.content as List<int>,
                ),
              )
              as List;
      expect(weaponsJson, hasLength(1));
      expect(weaponsJson.first['id'], 'mw_test_rifle');
      expect(weaponsJson.first['mount'], 'Main');
      expect(weaponsJson.first['damage'][0]['type'], 'Kinetic');
      expect(weaponsJson.first['bonuses'][0]['id'], 'accuracy');
    } finally {
      await tempDir.delete(recursive: true);
    }
  });
}
