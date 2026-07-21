import 'dart:convert';

import 'package:archive/archive.dart';

import '../../domain/ports/content_pack_reader.dart';
import 'domain_json_mapper.dart';

/// Implementa [ContentPackReader]: interpreta los bytes de un `.lcp`
/// (zip de un solo nivel, ver `zip_content_pack_exporter.dart` para el
/// formato exacto que produce este mismo Builder — pero un `.lcp` de
/// Mostrar puede venir de cualquier sitio, no solo de este Builder).
///
/// Al ser entrada no confiable (un `.lcp` ajeno, corrupto o a medias), la
/// política es: fallar limpio con [FormatException] cuando lo que falta es
/// estructural (no es un zip, no hay manifest, el manifest no es un
/// objeto) — para que la UI muestre un error claro en vez de un stack de
/// `TypeError` — pero tolerar y saltarse los archivos de contenido sueltos
/// que vengan con forma inesperada (JSON inválido, UTF-8 roto, o algo que
/// no sea una lista de objetos), igual que se ignoran campos desconocidos
/// dentro de cada entidad, sin tumbar la lectura del resto del paquete.
class ZipContentPackReader implements ContentPackReader {
  @override
  ParsedContentPack read(List<int> bytes) {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (_) {
      throw const FormatException(
        'El archivo no es un .lcp válido (no se pudo abrir como zip).',
      );
    }

    final manifestFile = archive.findFile('lcp_manifest.json');
    if (manifestFile == null) {
      throw const FormatException(
        'El .lcp no contiene lcp_manifest.json — no es un content pack válido.',
      );
    }
    final manifestDecoded = _tryDecodeJson(manifestFile.content as List<int>);
    if (manifestDecoded is! Map<String, dynamic>) {
      throw const FormatException(
        'El lcp_manifest.json del .lcp no es un objeto JSON válido.',
      );
    }
    final manifest = lcpManifestDataFromJson(manifestDecoded);

    final contentByKey = <String, List<Map<String, dynamic>>>{};
    for (final file in archive.files) {
      if (!file.isFile) continue;
      if (file.name == 'lcp_manifest.json' || !file.name.endsWith('.json')) {
        continue;
      }
      final decoded = _tryDecodeJson(file.content as List<int>);
      // Un .lcp ajeno a este Builder podría traer un archivo con JSON
      // inválido, UTF-8 roto o algo que no sea una lista de objetos — se
      // ignora en vez de tumbar la lectura del resto, igual que se ignoran
      // campos desconocidos dentro de cada entidad.
      if (decoded is! List) continue;
      final contentKey = file.name.substring(
        0,
        file.name.length - '.json'.length,
      );
      contentByKey[contentKey] = decoded
          .whereType<Map<String, dynamic>>()
          .toList();
    }

    return ParsedContentPack(manifest: manifest, contentByKey: contentByKey);
  }

  /// Decodifica bytes UTF-8 → JSON, devolviendo `null` si algo va mal
  /// (bytes que no son UTF-8 válido, o texto que no es JSON) — la política
  /// de tolerancia por archivo la decide quien llama, no este helper.
  Object? _tryDecodeJson(List<int> bytes) {
    try {
      return jsonDecode(utf8.decode(bytes));
    } catch (_) {
      return null;
    }
  }
}
