import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/infrastructure/file_system/android_saf_channel.dart';
import 'package:lcp_builder/infrastructure/file_system/android_saf_directory_lister.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final lister = AndroidSafDirectoryLister();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(androidSafChannel, null);
  });

  test('listLcpFiles pide al canal nativo la uri de árbol y devuelve las '
      'uris de cada .lcp encontrado', () async {
    MethodCall? received;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(androidSafChannel, (call) async {
      received = call;
      return [
        {'uri': 'content://fake/alfa.lcp', 'name': 'alfa.lcp'},
        {'uri': 'content://fake/zeta.lcp', 'name': 'zeta.lcp'},
      ];
    });

    final result = await lister.listLcpFiles('content://fake/tree');

    expect(received?.method, 'listLcpFiles');
    expect(received?.arguments['treeUri'], 'content://fake/tree');
    expect(result, ['content://fake/alfa.lcp', 'content://fake/zeta.lcp']);
  });

  test('sin resultado del canal (null), devuelve lista vacía en vez de '
      'lanzar', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(androidSafChannel, (call) async => null);

    final result = await lister.listLcpFiles('content://fake/tree');

    expect(result, isEmpty);
  });
}
