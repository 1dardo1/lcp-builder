import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/infrastructure/lcp/zip_content_pack_reader.dart';
import 'package:lcp_builder/infrastructure/lcp/zip_content_pack_exporter.dart';

/// Test de aceptación del lado de lectura de Mostrar: exporta con el
/// `ZipContentPackExporter` real (ya probado por su cuenta) y confirma
/// que `ZipContentPackReader` recupera exactamente lo mismo — manifest
/// tipado, contenido en JSON crudo indexado por contentKey.
void main() {
  test('lee un .lcp producido por ZipContentPackExporter: manifest tipado '
      '+ contenido crudo por tipo', () {
    final exporter = ZipContentPackExporter();
    const manifest = ILcpManifestData(
      name: 'Paquete de prueba',
      author: 'Test',
      description: 'desc',
      version: '1.0.0',
    );

    final bytes = exporter.export(
      manifest: manifest,
      content: {
        'weapons': [
          IWeaponData(
            id: 'mw_test',
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
      },
    );

    final reader = ZipContentPackReader();
    final parsed = reader.read(bytes);

    expect(parsed.manifest.name, 'Paquete de prueba');
    expect(parsed.manifest.version, '1.0.0');

    expect(parsed.contentByKey.keys, containsAll(['weapons', 'manufacturers']));
    expect(parsed.contentByKey['weapons'], hasLength(1));
    expect(parsed.contentByKey['weapons']!.first['id'], 'mw_test');
    expect(parsed.contentByKey['weapons']!.first['mount'], 'Main');
    expect(parsed.contentByKey['manufacturers']!.first['id'], 'GMS');
  });

  test('bytes que no son un zip válido lanzan, en vez de fallar en '
      'silencio o devolver un manifest inventado', () {
    expect(() => ZipContentPackReader().read([1, 2, 3]), throwsA(anything));
  });

  test('un archivo dentro del zip que no es una lista de objetos se '
      'ignora, no rompe la lectura del resto — un .lcp ajeno a este '
      'Builder podría traer algo así', () {
    final archive = Archive();
    void addJsonFile(String name, Object content) {
      final bytes = utf8.encode(jsonEncode(content));
      archive.addFile(ArchiveFile(name, bytes.length, bytes));
    }

    addJsonFile('lcp_manifest.json', {
      'name': 'x',
      'author': 'x',
      'description': 'x',
      'version': '1.0.0',
    });
    addJsonFile('weapons.json', [
      {'id': 'mw_test', 'name': 'Arma'},
    ]);
    // Un archivo con forma inesperada (objeto, no lista) — no debe
    // tumbar la lectura del resto del .lcp.
    addJsonFile('raro.json', {'esto': 'no es una lista'});

    final bytes = ZipEncoder().encode(archive);
    final parsed = ZipContentPackReader().read(bytes);

    expect(parsed.contentByKey['weapons'], hasLength(1));
    expect(parsed.contentByKey.containsKey('raro'), isFalse);
  });

  Archive archiveWith(void Function(void Function(String, List<int>)) build) {
    final archive = Archive();
    build((name, bytes) => archive.addFile(ArchiveFile(name, bytes.length, bytes)));
    return archive;
  }

  List<int> jsonBytes(Object content) => utf8.encode(jsonEncode(content));

  test('un manifest que es JSON válido pero no un objeto (una lista) lanza '
      'FormatException, no un TypeError opaco', () {
    final archive = archiveWith((add) {
      add('lcp_manifest.json', jsonBytes([1, 2, 3]));
    });
    expect(
      () => ZipContentPackReader().read(ZipEncoder().encode(archive)),
      throwsA(isA<FormatException>()),
    );
  });

  test('un archivo de contenido con JSON inválido se ignora, no tumba la '
      'lectura del resto del paquete', () {
    final archive = archiveWith((add) {
      add('lcp_manifest.json', jsonBytes({
        'name': 'x',
        'author': 'x',
        'description': 'x',
        'version': '1.0.0',
      }));
      add('weapons.json', jsonBytes([
        {'id': 'mw_test', 'name': 'Arma'},
      ]));
      // JSON truncado/corrupto en un archivo suelto.
      add('roto.json', utf8.encode('{ esto no es json'));
    });

    final parsed = ZipContentPackReader().read(ZipEncoder().encode(archive));

    expect(parsed.contentByKey['weapons'], hasLength(1));
    expect(parsed.contentByKey.containsKey('roto'), isFalse);
  });

  test('un archivo de contenido con bytes que no son UTF-8 válido se '
      'ignora, no tumba la lectura del resto', () {
    final archive = archiveWith((add) {
      add('lcp_manifest.json', jsonBytes({
        'name': 'x',
        'author': 'x',
        'description': 'x',
        'version': '1.0.0',
      }));
      add('weapons.json', jsonBytes([
        {'id': 'mw_test', 'name': 'Arma'},
      ]));
      // Bytes inválidos como UTF-8 (0xFF no aparece en UTF-8 bien formado).
      add('binario.json', [0xFF, 0xFE, 0x00, 0x01]);
    });

    final parsed = ZipContentPackReader().read(ZipEncoder().encode(archive));

    expect(parsed.contentByKey['weapons'], hasLength(1));
    expect(parsed.contentByKey.containsKey('binario'), isFalse);
  });
}
