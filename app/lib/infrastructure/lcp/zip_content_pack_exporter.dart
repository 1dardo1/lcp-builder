import 'dart:convert';

import 'package:archive/archive.dart';

import '../../domain/domain.dart';
import '../../domain/ports/content_pack_exporter.dart';
import 'domain_json_mapper.dart';

/// Implementa [ContentPackExporter]: produce los bytes de un `.lcp` —
/// un zip de un solo nivel (sin subcarpetas, requisito del formato) con
/// `lcp_manifest.json` y un archivo por tipo de contenido (aquí,
/// `weapons.json`), tal como lo espera COMP/CON.
class ZipContentPackExporter implements ContentPackExporter {
  @override
  List<int> exportWeapons({
    required ILcpManifestData manifest,
    required List<IWeaponData> weapons,
  }) {
    final archive = Archive();

    void addJsonFile(String name, Object content) {
      final bytes = utf8.encode(
        const JsonEncoder.withIndent('  ').convert(content),
      );
      archive.addFile(ArchiveFile(name, bytes.length, bytes));
    }

    addJsonFile('lcp_manifest.json', lcpManifestDataToJson(manifest));
    addJsonFile('weapons.json', weapons.map(weaponDataToJson).toList());

    final zipBytes = ZipEncoder().encode(archive);
    return zipBytes;
  }
}
