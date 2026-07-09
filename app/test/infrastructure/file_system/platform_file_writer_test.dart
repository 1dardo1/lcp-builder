import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/infrastructure/file_system/local_file_writer.dart';
import 'package:lcp_builder/infrastructure/file_system/platform_file_writer.dart';

/// `flutter test` corre en el host (Linux en CI), nunca como Android —
/// `Platform.isAndroid` es siempre `false` aquí, así que esta prueba solo
/// puede cubrir la rama de escritorio. La rama Android
/// (`AndroidSafFileWriter`) no es alcanzable desde este test; ver
/// `android_saf_file_writer_test.dart` para lo que sí se puede probar de
/// esa rama sin un dispositivo real.
void main() {
  test('fuera de Android, usa LocalFileWriter', () {
    expect(createPlatformFileWriter(), isA<LocalFileWriter>());
  });
}
