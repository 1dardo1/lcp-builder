import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/infrastructure/file_system/local_lcp_directory_lister.dart';

void main() {
  test(
    'lista solo los .lcp de la carpeta, ordenados, ignorando otras extensiones',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'local_lcp_directory_lister_test',
      );
      try {
        await File('${tempDir.path}/zeta.lcp').writeAsBytes([1]);
        await File('${tempDir.path}/alfa.lcp').writeAsBytes([1]);
        await File('${tempDir.path}/notas.txt').writeAsBytes([1]);

        final result = await LocalLcpDirectoryLister().listLcpFiles(
          tempDir.path,
        );

        // Se comparan los NOMBRES, no las rutas completas: `Directory.list()`
        // devuelve la ruta con el separador del SO (`\` en Windows, `/` en
        // Linux/macOS), así que comparar contra rutas construidas con `/` a
        // mano fallaba solo en Windows (visto en CI). Lo que importa aquí es
        // que solo salen los `.lcp`, ordenados y sin el `.txt`.
        final names = result
            .map((path) => path.split(RegExp(r'[/\\]')).last)
            .toList();
        expect(names, ['alfa.lcp', 'zeta.lcp']);
      } finally {
        await tempDir.delete(recursive: true);
      }
    },
  );

  test('una carpeta inexistente devuelve lista vacía, no lanza', () async {
    final result = await LocalLcpDirectoryLister().listLcpFiles(
      '/no/existe/de/verdad',
    );
    expect(result, isEmpty);
  });
}
