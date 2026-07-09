import 'dart:io';

import '../../domain/ports/file_reader.dart';

/// Implementación con `dart:io`, universal (no solo Linux, a diferencia
/// de [LocalFileWriter]): tanto en Linux como al abrir un `.lcp`
/// concreto en Android vía `file_selector` (`openFile`, no
/// `getDirectoryPath`), la ruta que llega aquí ya es una ruta de archivo
/// real — el plugin de Android copia internamente el contenido de la
/// URI `content://` elegida a una ruta de caché de la app antes de
/// devolverla (comprobado leyendo su código fuente), así que no hace
/// falta ningún adapter nativo para leer un único archivo, a diferencia
/// de escribir (ver `android_saf_file_writer.dart`).
class LocalFileReader implements FileReader {
  @override
  Future<List<int>> read(String path) => File(path).readAsBytes();
}
