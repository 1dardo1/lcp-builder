import 'dart:convert';

import 'package:archive/archive.dart';

import '../../domain/domain.dart';
import '../../domain/ports/content_pack_exporter.dart';
import 'domain_json_mapper.dart';

/// Implementa [ContentPackExporter]: produce los bytes de un `.lcp` —
/// un zip de un solo nivel (sin subcarpetas, requisito del formato) con
/// `lcp_manifest.json` y un archivo por tipo de contenido, tal como lo
/// espera COMP/CON.
///
/// El puerto (`ContentPackExporter`) no conoce el tipo concreto de cada
/// entidad, por eso `content` llega como `Object` — el despacho por tipo
/// runtime vive en `entityDataToJson` (`domain_json_mapper.dart`),
/// compartido con el guardado de Editar.
class ZipContentPackExporter implements ContentPackExporter {
  @override
  List<int> export({
    required ILcpManifestData manifest,
    required Map<String, List<Object>> content,
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
      addJsonFile(
        '${entry.key}.json',
        entry.value.map(entityDataToJson).toList(),
      );
    }

    return ZipEncoder().encode(archive);
  }
}
