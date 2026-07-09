import '../../domain/ports/lcp_directory_lister.dart';
import 'android_saf_channel.dart';

/// Adapter de Android — [directoryPath] aquí es la URI de árbol SAF que
/// devuelve `file_selector`'s `getDirectoryPath` (esa parte ya funciona
/// con `file_selector`; lo que falta es listar lo que hay dentro,
/// `dart:io` no puede recorrer una URI de árbol). Cada entrada de la
/// lista devuelta es a su vez una URI `content://` — léela con
/// [AndroidSafFileReader], no con `LocalFileReader`.
class AndroidSafDirectoryLister implements LcpDirectoryLister {
  @override
  Future<List<String>> listLcpFiles(String directoryPath) async {
    final items = await androidSafChannel.invokeMethod<List<Object?>>(
      'listLcpFiles',
      {'treeUri': directoryPath},
    );
    return (items ?? const [])
        .cast<Map<Object?, Object?>>()
        .map((item) => item['uri'] as String)
        .toList();
  }
}
