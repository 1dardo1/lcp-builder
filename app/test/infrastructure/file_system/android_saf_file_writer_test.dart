import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/infrastructure/file_system/android_saf_channel.dart';
import 'package:lcp_builder/infrastructure/file_system/android_saf_file_writer.dart';

/// No se puede ejercitar `MainActivity.kt` de verdad desde `flutter
/// test` (corre en el host, no en un dispositivo Android) — lo único
/// verificable aquí es el lado Dart: que `AndroidSafFileWriter.write`
/// llama al canal correcto, con los argumentos correctos, y que un error
/// nativo se propaga como excepción en vez de tragárselo en silencio
/// (justo el fallo real que tenía `pickLcpSaveLocation` antes de este
/// cambio). La verificación de que el propio selector nativo y la
/// escritura en el content resolver funcionan de verdad solo puede
/// hacerse en un dispositivo Android real.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final writer = AndroidSafFileWriter();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(androidSafChannel, null);
  });

  test('write() invoca writeBytes con la uri y los bytes recibidos', () async {
    MethodCall? received;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(androidSafChannel, (call) async {
      received = call;
      return null;
    });

    await writer.write('content://fake/paquete.lcp', [1, 2, 3]);

    expect(received?.method, 'writeBytes');
    expect(received?.arguments['uri'], 'content://fake/paquete.lcp');
    expect(received?.arguments['bytes'], [1, 2, 3]);
  });

  test('un error nativo se propaga como excepción (no se traga en silencio)', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(androidSafChannel, (call) async {
      throw PlatformException(code: 'write_failed', message: 'boom');
    });

    expect(
      () => writer.write('content://fake/paquete.lcp', [1]),
      throwsA(isA<PlatformException>()),
    );
  });
}
