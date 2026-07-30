/// Hexagonal port, the inverse of [FileWriter]: reads bytes from a path.
/// Different implementation per platform — like [FileWriter], on Android
/// [path] is not a real file path but a `content://` URI (see
/// `infrastructure/file_system/android_saf_file_reader.dart`).
abstract class FileReader {
  Future<List<int>> read(String path);
}
