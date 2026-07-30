import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import '../../domain/ports/file_writer.dart';

/// Web adapter for [FileWriter]. The browser has no writable filesystem, so
/// "writing" a `.lcp` triggers a normal browser download of the bytes. [path]
/// is used only as the download file name — the create flow passes the
/// suggested pack name (see the web `pickLcpSaveLocation`).
class WebFileWriter implements FileWriter {
  @override
  Future<void> write(String path, List<int> bytes) async {
    final data = Uint8List.fromList(bytes);
    final blob = web.Blob(
      <JSAny>[data.toJS].toJS,
      web.BlobPropertyBag(type: 'application/octet-stream'),
    );
    final url = web.URL.createObjectURL(blob);
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement
      ..href = url
      ..download = _fileName(path)
      ..style.display = 'none';
    web.document.body?.appendChild(anchor);
    anchor.click();
    anchor.remove();
    web.URL.revokeObjectURL(url);
  }

  static String _fileName(String path) {
    final slash = path.lastIndexOf(RegExp(r'[/\\]'));
    return slash == -1 ? path : path.substring(slash + 1);
  }
}
