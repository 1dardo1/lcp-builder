import 'dart:io';

import '../../domain/ports/lcp_directory_lister.dart';

/// Adapter de Linux (`dart:io`, ruta real). Suficiente por ahora — el
/// selector de carpetas de Android (`getDirectoryPath`, vía
/// `ACTION_OPEN_DOCUMENT_TREE`) devuelve una URI de árbol SAF, no una
/// ruta de archivo, y `Directory.list()` no sabe recorrerla; hace falta
/// un adapter nativo aparte (`DocumentsContract`) para Android, todavía
/// sin implementar — pendiente de decidir si merece la pena para esta
/// fase o si de momento Android solo ofrece "abrir un .lcp" suelto.
class LocalLcpDirectoryLister implements LcpDirectoryLister {
  @override
  Future<List<String>> listLcpFiles(String directoryPath) async {
    final dir = Directory(directoryPath);
    if (!await dir.exists()) return const [];
    final entries = await dir
        .list()
        .where(
          (entity) => entity is File && entity.path.toLowerCase().endsWith('.lcp'),
        )
        .map((entity) => entity.path)
        .toList();
    entries.sort();
    return entries;
  }
}
