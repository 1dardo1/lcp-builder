import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/infrastructure/file_system/local_file_reader.dart';
import 'package:lcp_builder/infrastructure/file_system/local_file_writer.dart';

/// Tests del adapter de escritura de escritorio (Linux/Windows/macOS) sobre
/// el sistema de archivos REAL (`Directory.systemTemp`), no un mock — así,
/// al correr `flutter test` en el runner de cada SO (ver build-*.yml), se
/// ejercita la E/S real de esa plataforma, incluidos los separadores y la
/// creación de rutas propios de Windows.
///
/// `LocalFileWriter` no tenía ningún test hasta ahora (el lado de lectura y
/// el listado de carpeta sí) — hueco que este archivo cierra.
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('local_file_writer_test');
  });
  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('escribe los bytes y se releen idénticos', () async {
    final path = '${tempDir.path}${Platform.pathSeparator}paquete.lcp';
    final bytes = [80, 75, 3, 4, 0, 255, 10];

    await LocalFileWriter().write(path, bytes);

    expect(await File(path).exists(), isTrue);
    expect(await LocalFileReader().read(path), bytes);
  });

  test('crea los directorios padre que falten', () async {
    // Ruta con subcarpetas inexistentes — el adapter hace
    // `parent.create(recursive: true)` antes de escribir.
    final path = [
      tempDir.path,
      'sub',
      'carpeta',
      'x.lcp',
    ].join(Platform.pathSeparator);

    await LocalFileWriter().write(path, [1, 2, 3]);

    expect(await File(path).exists(), isTrue);
    expect(await LocalFileReader().read(path), [1, 2, 3]);
  });

  test('sobrescribe (trunca) un archivo existente con contenido más corto',
      () async {
    final path = '${tempDir.path}${Platform.pathSeparator}p.lcp';
    await LocalFileWriter().write(path, List.filled(100, 7));

    await LocalFileWriter().write(path, [1, 2]);

    // No quedan bytes de la escritura anterior (no es un problema de
    // truncado como el que hubo en Android #39, pero se comprueba igual).
    expect(await LocalFileReader().read(path), [1, 2]);
  });
}
