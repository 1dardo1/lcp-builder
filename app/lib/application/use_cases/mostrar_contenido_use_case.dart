import '../../domain/ports/content_pack_reader.dart';
import '../../domain/ports/file_reader.dart';

/// Caso de uso Mostrar — inverso de [CrearContenidoUseCase]: lee un `.lcp`
/// ya existente desde [path] y lo interpreta. Orquesta puertos, igual que
/// su contraparte de Crear — no conoce `infrastructure/` en concreto, ni
/// qué adapter concreto resuelve [path] en cada plataforma (eso lo decide
/// quien construye este caso de uso, ver `createPlatformFileReader`).
class MostrarContenidoUseCase {
  final FileReader fileReader;
  final ContentPackReader contentPackReader;

  const MostrarContenidoUseCase({
    required this.fileReader,
    required this.contentPackReader,
  });

  Future<ParsedContentPack> call(String path) async {
    final bytes = await fileReader.read(path);
    return contentPackReader.read(bytes);
  }
}
