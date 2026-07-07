import 'package:file_selector/file_selector.dart';

/// Adapter de "selector nativo" (ver ADR-002) para elegir dónde guardar un
/// `.lcp`. Vive en `presentation/` a propósito, no en `infrastructure/`: es
/// una interacción con el usuario/SO, no una operación de E/S pura — el
/// dominio y los casos de uso (`CrearArmaUseCase`) solo reciben la ruta ya
/// resuelta, nunca saben que hubo un diálogo (ver "El dominio solo recibe
/// rutas de archivo..." en `vault/Aprendizajes/Principios y decisiones
/// clave.md`).
///
/// Devuelve `null` si el usuario cancela el diálogo.
Future<String?> pickLcpSaveLocation(String suggestedName) async {
  final location = await getSaveLocation(
    suggestedName: suggestedName,
    acceptedTypeGroups: const [
      XTypeGroup(label: 'Lancer Content Pack', extensions: ['lcp']),
    ],
  );
  return location?.path;
}
