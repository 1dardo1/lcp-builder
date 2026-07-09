import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/infrastructure/file_system/android_saf_channel.dart';
import 'package:lcp_builder/infrastructure/file_system/android_saf_file_reader.dart';

/// Igual que `android_saf_file_writer_test.dart`: no se puede ejercitar
/// `MainActivity.kt` de verdad desde `flutter test`. Aquí se verifica el
/// lado Dart — que una URI `content://` va por el canal nativo, y que
/// una ruta de archivo real (caso `openFile`, ver
/// `local_file_reader.dart`) no lo toca en absoluto.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final reader = AndroidSafFileReader();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(androidSafChannel, null);
  });

  test('una uri content:// se lee vía el canal nativo (readBytes)', () async {
    MethodCall? received;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(androidSafChannel, (call) async {
      received = call;
      return Uint8List.fromList([9, 8, 7]);
    });

    final bytes = await reader.read('content://fake/paquete.lcp');

    expect(received?.method, 'readBytes');
    expect(received?.arguments['uri'], 'content://fake/paquete.lcp');
    expect(bytes, [9, 8, 7]);
  });

  test('una ruta real (no content://) se lee con dart:io, sin tocar el '
      'canal nativo', () async {
    var channelCalled = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(androidSafChannel, (call) async {
      channelCalled = true;
      return null;
    });

    await expectLater(
      reader.read('/ruta/que/no/existe.lcp'),
      throwsA(anything),
    );
    expect(channelCalled, isFalse);
  });
}
