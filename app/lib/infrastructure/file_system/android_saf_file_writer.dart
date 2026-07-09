import 'dart:typed_data';

import '../../domain/ports/file_writer.dart';
import 'android_saf_channel.dart';

/// Adapter de Android (ver ADR-002 y comentario en `local_file_writer.dart`
/// sobre el selector restringido pendiente). [path] aquí no es una ruta de
/// archivo real — es la URI `content://` que devolvió el selector nativo
/// de Android (`pickLcpSaveLocation`, vía `ACTION_CREATE_DOCUMENT`), que
/// `dart:io` no puede abrir directamente por las restricciones de scoped
/// storage. La escritura de verdad ocurre en el lado nativo
/// (`MainActivity.kt`), a través de `ContentResolver`.
class AndroidSafFileWriter implements FileWriter {
  @override
  Future<void> write(String path, List<int> bytes) async {
    await androidSafChannel.invokeMethod<void>('writeBytes', {
      'uri': path,
      'bytes': Uint8List.fromList(bytes),
    });
  }
}
