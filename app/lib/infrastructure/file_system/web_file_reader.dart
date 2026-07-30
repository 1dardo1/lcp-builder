import '../../domain/ports/file_reader.dart';

/// Web adapter for [FileReader]. The web build only exposes the Create flow
/// (which downloads), so reading an existing `.lcp` back from disk is not
/// wired on web — the Show/Edit entries are hidden on web (see `HomeScreen`).
/// This stub exists so the app still compiles for web; it is never reached at
/// runtime there.
class WebFileReader implements FileReader {
  @override
  Future<List<int>> read(String path) async =>
      throw UnsupportedError('Reading .lcp files is not available on web.');
}
