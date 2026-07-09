import 'dart:convert';

import 'package:archive/archive.dart';

import '../../domain/domain.dart';
import '../../domain/ports/raw_content_pack_exporter.dart';
import 'domain_json_mapper.dart';

/// Implementa [RawContentPackExporter]: mismo formato de `.lcp` que
/// [ZipContentPackExporter] (zip de un solo nivel, `lcp_manifest.json` +
/// un archivo por tipo de contenido), pero el contenido ya viene en JSON
/// crudo — no hay ningún despacho por tipo de dominio que hacer, cada
/// entidad se escribe tal cual.
class ZipRawContentPackExporter implements RawContentPackExporter {
  @override
  List<int> export({
    required ILcpManifestData manifest,
    required Map<String, List<Map<String, dynamic>>> content,
  }) {
    final archive = Archive();

    void addJsonFile(String name, Object content) {
      final bytes = utf8.encode(
        const JsonEncoder.withIndent('  ').convert(content),
      );
      archive.addFile(ArchiveFile(name, bytes.length, bytes));
    }

    addJsonFile('lcp_manifest.json', lcpManifestDataToJson(manifest));
    for (final entry in content.entries) {
      addJsonFile('${entry.key}.json', entry.value);
    }

    return ZipEncoder().encode(archive);
  }
}
