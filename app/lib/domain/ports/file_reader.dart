/// Puerto hexagonal, inverso de [FileWriter]: lee bytes desde una ruta.
/// Implementación distinta por plataforma — igual que [FileWriter], en
/// Android [path] no es una ruta de archivo real sino una URI
/// `content://` (ver `infrastructure/file_system/android_saf_file_reader.dart`).
abstract class FileReader {
  Future<List<int>> read(String path);
}
