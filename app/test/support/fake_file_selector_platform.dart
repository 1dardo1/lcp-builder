import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

/// Doble de test para `FileSelectorPlatform.instance` — evita que los tests
/// disparen el selector nativo real (imposible en el entorno de test, y
/// fuera del propósito de estos tests: `pickLcpSaveLocation` es un adapter
/// fino, ver `lib/presentation/platform/lcp_save_location.dart`).
///
/// [nextSaveLocationPath] controla la respuesta de la próxima llamada a
/// `getSaveLocation` — `null` simula que el usuario cancela el diálogo,
/// igual que hace la plataforma real.
class FakeFileSelectorPlatform extends FileSelectorPlatform {
  String? nextSaveLocationPath;

  @override
  Future<FileSaveLocation?> getSaveLocation({
    List<XTypeGroup>? acceptedTypeGroups,
    SaveDialogOptions options = const SaveDialogOptions(),
  }) async {
    final path = nextSaveLocationPath;
    return path == null ? null : FileSaveLocation(path);
  }
}
