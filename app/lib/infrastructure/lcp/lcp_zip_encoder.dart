import 'dart:convert';

import 'package:archive/archive.dart';

/// Ensambla los bytes de un `.lcp`: un zip de un solo nivel (sin
/// subcarpetas, requisito del formato de COMP/CON) con `lcp_manifest.json`
/// y un archivo `<contentKey>.json` por tipo de contenido.
///
/// Los dos exportadores (`ZipContentPackExporter`, que despacha objetos de
/// dominio a JSON, y `ZipRawContentPackExporter`, que ya recibe JSON crudo)
/// solo se diferencian en cómo obtienen ese JSON; el empaquetado en sí —
/// indentado, un archivo por clave, orden manifest-primero — es idéntico y
/// vive aquí, en un único sitio.
List<int> encodeLcpZip({
  required Map<String, dynamic> manifestJson,
  required Map<String, List<Map<String, dynamic>>> contentByKey,
}) {
  final archive = Archive();

  void addJsonFile(String name, Object content) {
    final bytes = utf8.encode(
      const JsonEncoder.withIndent('  ').convert(content),
    );
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  }

  addJsonFile('lcp_manifest.json', manifestJson);
  for (final entry in contentByKey.entries) {
    addJsonFile('${entry.key}.json', entry.value);
  }

  return ZipEncoder().encode(archive);
}
