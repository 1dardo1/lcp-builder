import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/application/use_cases/crear_contenido_use_case.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/infrastructure/file_system/local_file_writer.dart';
import 'package:lcp_builder/infrastructure/lcp/zip_content_pack_exporter.dart';

/// Test de aceptación (ADR-002: al menos uno por iteración, validando el
/// flujo desde la perspectiva del cliente): construye una entidad
/// completa, ejecuta el caso de uso real (exportador + escritura a disco
/// reales, sin dobles de test) y verifica que el .lcp resultante es un zip
/// de un solo nivel, con lcp_manifest.json y el archivo de contenido
/// legibles y correctos — exactamente lo que el cliente esperaría poder
/// cargar en COMP/CON.
void main() {
  test('Crear (arma) produce un .lcp válido en disco', () async {
    final tempDir = await Directory.systemTemp.createTemp('lcp_builder_test');
    final outputPath = '${tempDir.path}/arma.lcp';

    final useCase = CrearContenidoUseCase(
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
      await useCase(
        content: {
          'weapons': [weapon],
        },
        manifest: manifest,
        outputPath: outputPath,
      );

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

  test('Crear admite varias entidades de varios tipos en el mismo .lcp '
      '(sesión multi-entidad)', () async {
    final tempDir = await Directory.systemTemp.createTemp('lcp_builder_test');
    final outputPath = '${tempDir.path}/batch.lcp';

    final useCase = CrearContenidoUseCase(
      exporter: ZipContentPackExporter(),
      fileWriter: LocalFileWriter(),
    );

    const manifest = ILcpManifestData(
      name: 'Paquete multi-entidad',
      author: 'Test',
      description: 'desc',
      version: '1.0.0',
    );

    try {
      await useCase(
        content: {
          'weapons': [
            IWeaponData(
              id: 'mw_uno',
              name: 'Arma 1',
              source: 'GMS',
              license: 'GMS Everest',
              licenseId: 'mf_everest',
              licenseLevel: 0,
              effect: 'e',
              description: 'd',
              mount: MountType.main,
              type: WeaponType.rifle,
            ),
            IWeaponData(
              id: 'mw_dos',
              name: 'Arma 2',
              source: 'GMS',
              license: 'GMS Everest',
              licenseId: 'mf_everest',
              licenseLevel: 0,
              effect: 'e',
              description: 'd',
              mount: MountType.main,
              type: WeaponType.rifle,
            ),
          ],
          'frames': [
            IFrameData(
              id: 'mf_uno',
              name: 'Frame 1',
              source: 'GMS',
              licenseLevel: 0,
              mechtype: const ['Striker'],
              description: 'd',
              mounts: const [MountType.main],
              stats: const IFrameStats(
                size: 1,
                structure: 4,
                stress: 4,
                armor: 0,
                hp: 8,
                evasion: 8,
                edef: 8,
                heatcap: 5,
                repcap: 5,
                sensorRange: 10,
                techAttack: 0,
                save: 10,
                speed: 5,
                sp: 5,
              ),
              traits: const [],
              coreSystem: const ICoreSystemData(
                name: 'Core',
                activeName: 'Active',
                activeEffect: 'e',
                activation: ActivationType.quick,
              ),
            ),
          ],
        },
        manifest: manifest,
        outputPath: outputPath,
      );

      final bytes = await File(outputPath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      expect(
        archive.files.map((f) => f.name),
        containsAll(['lcp_manifest.json', 'weapons.json', 'frames.json']),
      );

      final weaponsJson =
          jsonDecode(
                utf8.decode(
                  archive.findFile('weapons.json')!.content as List<int>,
                ),
              )
              as List;
      expect(weaponsJson, hasLength(2));

      final framesJson =
          jsonDecode(
                utf8.decode(
                  archive.findFile('frames.json')!.content as List<int>,
                ),
              )
              as List;
      expect(framesJson, hasLength(1));
    } finally {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'ZipContentPackExporter.export produce un archivo por tipo de contenido, '
    'para varias entidades a la vez',
    () async {
      final exporter = ZipContentPackExporter();
      const manifest = ILcpManifestData(
        name: 'Paquete multi-contenido',
        author: 'Test',
        description: 'desc',
        version: '1.0.0',
      );

      final bytes = exporter.export(
        manifest: manifest,
        content: {
          'weapons': [
            IWeaponData(
              id: 'mw_multi',
              name: 'Arma',
              source: 'GMS',
              license: 'GMS Everest',
              licenseId: 'mf_everest',
              licenseLevel: 0,
              effect: 'e',
              description: 'd',
              mount: MountType.main,
              type: WeaponType.rifle,
            ),
          ],
          'manufacturers': const [
            IManufacturerData(
              id: 'GMS',
              name: 'General Manufacturing Systems',
              description: 'd',
              quote: 'q',
              light: '#FFFFFF',
              dark: '#000000',
            ),
          ],
          'tags': const [
            ITagData(id: 'tg_test', name: 'Test', description: 'd'),
          ],
        },
      );

      final archive = ZipDecoder().decodeBytes(bytes);
      expect(
        archive.files.map((f) => f.name),
        containsAll([
          'lcp_manifest.json',
          'weapons.json',
          'manufacturers.json',
          'tags.json',
        ]),
      );

      Object? decode(String name) =>
          jsonDecode(utf8.decode(archive.findFile(name)!.content as List<int>));

      expect((decode('weapons.json') as List).first['id'], 'mw_multi');
      expect((decode('manufacturers.json') as List).first['id'], 'GMS');
      expect((decode('tags.json') as List).first['id'], 'tg_test');
    },
  );
}
