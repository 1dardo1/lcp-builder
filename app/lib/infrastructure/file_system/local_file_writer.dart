import 'dart:io';

import '../../domain/ports/file_writer.dart';

/// Adapter de escritorio (Linux/Windows/macOS): escritura abierta con
/// `dart:io` a una ruta real, sin selector restringido (ver ADR-002).
/// Sirve igual en los tres porque `dart:io` abstrae el sistema de
/// archivos; Android usa su propio adapter (`AndroidSafFileWriter`) porque
/// allí no hay ruta real, sino una URI `content://` del SAF.
class LocalFileWriter implements FileWriter {
  @override
  Future<void> write(String path, List<int> bytes) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
  }
}
