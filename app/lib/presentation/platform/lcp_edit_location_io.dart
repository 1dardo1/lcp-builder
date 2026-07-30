import 'dart:io';

import 'package:file_selector/file_selector.dart';

import '../../infrastructure/file_system/android_saf_channel.dart';

/// Native pick of which `.lcp` to open for editing (Edit needs to write back
/// to the same file later). On Android `file_selector`'s `openFile()` only
/// yields a cache copy with no live `content://` URI, so it uses the SAF
/// channel (`openDocument`) which returns the real writable URI; elsewhere it
/// returns the picked file path. Returns `null` if the user cancels.
Future<String?> pickLcpEditLocationImpl() async {
  if (Platform.isAndroid) {
    return androidSafChannel.invokeMethod<String>('openDocument');
  }

  final file = await openFile(
    acceptedTypeGroups: const [
      XTypeGroup(label: 'Lancer Content Pack', extensions: ['lcp']),
    ],
  );
  return file?.path;
}
