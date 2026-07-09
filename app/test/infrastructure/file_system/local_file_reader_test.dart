import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/infrastructure/file_system/local_file_reader.dart';

void main() {
  test('lee los bytes exactos que había en el archivo', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'local_file_reader_test',
    );
    final file = File('${tempDir.path}/paquete.lcp');
    await file.writeAsBytes([1, 2, 3, 4]);

    try {
      final bytes = await LocalFileReader().read(file.path);
      expect(bytes, [1, 2, 3, 4]);
    } finally {
      await tempDir.delete(recursive: true);
    }
  });

  test('un archivo inexistente lanza, no devuelve una lista vacía', () async {
    expect(
      () => LocalFileReader().read('/no/existe/de/verdad.lcp'),
      throwsA(anything),
    );
  });
}
