import 'dart:io';
import 'dart:typed_data';

import '../../domain/ports/file_reader.dart';
import 'android_saf_channel.dart';

/// Adapter de Android para leer. La mayoría de rutas que llegan aquí ya
/// son rutas de archivo reales (un `.lcp` elegido con `file_selector`'s
/// `openFile`, que copia internamente la URI elegida a una caché real —
/// ver `local_file_reader.dart`), y para esas basta `dart:io`. Pero un
/// `.lcp` listado dentro de una carpeta (`AndroidSafDirectoryLister`) es
/// una URI `content://` de verdad, que `dart:io` no puede abrir — para
/// esas se usa el canal nativo (`ContentResolver`).
class AndroidSafFileReader implements FileReader {
  @override
  Future<List<int>> read(String path) async {
    if (path.startsWith('content://')) {
      final bytes = await androidSafChannel.invokeMethod<Uint8List>(
        'readBytes',
        {'uri': path},
      );
      return bytes!;
    }
    return File(path).readAsBytes();
  }
}
