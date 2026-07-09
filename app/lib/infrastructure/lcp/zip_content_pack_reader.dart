import 'dart:convert';

import 'package:archive/archive.dart';

import '../../domain/ports/content_pack_reader.dart';
import 'domain_json_mapper.dart';

/// Implementa [ContentPackReader]: interpreta los bytes de un `.lcp`
/// (zip de un solo nivel, ver `zip_content_pack_exporter.dart` para el
/// formato exacto que produce este mismo Builder — pero un `.lcp` de
/// Mostrar puede venir de cualquier sitio, no solo de este Builder).
class ZipContentPackReader implements ContentPackReader {
  @override
  ParsedContentPack read(List<int> bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);

    final manifestFile = archive.findFile('lcp_manifest.json');
    if (manifestFile == null) {
      throw const FormatException(
        'El .lcp no contiene lcp_manifest.json — no es un content pack válido.',
      );
    }
    final manifestJson =
        jsonDecode(utf8.decode(manifestFile.content as List<int>))
            as Map<String, dynamic>;
    final manifest = lcpManifestDataFromJson(manifestJson);

    final contentByKey = <String, List<Map<String, dynamic>>>{};
    for (final file in archive.files) {
      if (!file.isFile) continue;
      if (file.name == 'lcp_manifest.json' || !file.name.endsWith('.json')) {
        continue;
      }
      final contentKey = file.name.substring(
        0,
        file.name.length - '.json'.length,
      );
      final decoded = jsonDecode(utf8.decode(file.content as List<int>));
      // Un .lcp ajeno a este Builder podría traer algo que no sea una
      // lista de objetos en algún archivo — se ignora en vez de fallar,
      // igual que se ignoran campos desconocidos dentro de cada entidad.
      if (decoded is! List) continue;
      contentByKey[contentKey] = decoded
          .whereType<Map<String, dynamic>>()
          .toList();
    }

    return ParsedContentPack(manifest: manifest, contentByKey: contentByKey);
  }
}
