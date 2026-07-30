import 'dart:io';

import 'package:file_selector/file_selector.dart';

import '../../infrastructure/file_system/android_saf_channel.dart';

/// Native pick of where to save a `.lcp`. On Android `file_selector` can't
/// save (`getSaveLocation` throws `UnimplementedError`), so it talks to the
/// Storage Access Framework via a minimal native channel and returns a
/// `content://` URI; elsewhere it returns a real file path. Returns `null`
/// if the user cancels.
Future<String?> pickLcpSaveLocationImpl(String suggestedName) async {
  if (Platform.isAndroid) {
    return androidSafChannel.invokeMethod<String>('createDocument', {
      'suggestedName': suggestedName,
    });
  }

  final location = await getSaveLocation(
    suggestedName: suggestedName,
    acceptedTypeGroups: const [
      XTypeGroup(label: 'Lancer Content Pack', extensions: ['lcp']),
    ],
  );
  return location?.path;
}
