import 'dart:io';

import '../../domain/ports/file_writer.dart';

/// Adapter de Linux (escritura abierta, sin selector restringido — ver
/// ADR-002). Implementación mínima con `dart:io`, suficiente para el
/// entorno de escritorio; Android necesitará su propio adapter cuando
/// llegue su turno (selector de sistema, no acceso directo a rutas).
class LocalFileWriter implements FileWriter {
  @override
  Future<void> write(String path, List<int> bytes) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
  }
}
