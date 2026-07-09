import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/infrastructure/file_system/local_file_reader.dart';
import 'package:lcp_builder/infrastructure/file_system/platform_file_reader.dart';

/// Mismo límite que `platform_file_writer_test.dart`: `flutter test`
/// corre en el host (Linux), así que solo se puede cubrir esa rama.
void main() {
  test('fuera de Android, usa LocalFileReader', () {
    expect(createPlatformFileReader(), isA<LocalFileReader>());
  });
}
