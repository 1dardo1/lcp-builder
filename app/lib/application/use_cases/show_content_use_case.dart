import '../../domain/ports/content_pack_reader.dart';
import '../../domain/ports/file_reader.dart';

/// Show use case — the inverse of [CreateContentUseCase]: reads an existing
/// `.lcp` from [path] and interprets it. It orchestrates ports, like its
/// Create counterpart — it doesn't know `infrastructure/` specifically, nor
/// which concrete adapter resolves [path] on each platform (that's decided by
/// whoever builds this use case, see `createPlatformFileReader`).
class ShowContentUseCase {
  final FileReader fileReader;
  final ContentPackReader contentPackReader;

  const ShowContentUseCase({
    required this.fileReader,
    required this.contentPackReader,
  });

  Future<ParsedContentPack> call(String path) async {
    final bytes = await fileReader.read(path);
    return contentPackReader.read(bytes);
  }
}
