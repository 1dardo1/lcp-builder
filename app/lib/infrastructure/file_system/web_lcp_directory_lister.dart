import '../../domain/ports/lcp_directory_lister.dart';

/// Web adapter for [LcpDirectoryLister]. Browsers can't enumerate a folder,
/// and the folder-based flows are hidden on web (see `HomeScreen`), so this
/// returns an empty list. Present only so the app compiles for web; never
/// reached at runtime there.
class WebLcpDirectoryLister implements LcpDirectoryLister {
  @override
  Future<List<String>> listLcpFiles(String directoryPath) async => const [];
}
