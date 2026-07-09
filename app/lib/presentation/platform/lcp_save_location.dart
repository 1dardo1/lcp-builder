import 'dart:io';

import 'package:file_selector/file_selector.dart';

import '../../infrastructure/file_system/android_saf_channel.dart';

/// Adapter de "selector nativo" (ver ADR-002) para elegir dónde guardar un
/// `.lcp`. Vive en `presentation/` a propósito, no en `infrastructure/`: es
/// una interacción con el usuario/SO, no una operación de E/S pura — el
/// dominio y los casos de uso (`CrearContenidoUseCase`) solo reciben la ruta ya
/// resuelta, nunca saben que hubo un diálogo (ver "El dominio solo recibe
/// rutas de archivo..." en `vault/Aprendizajes/Principios y decisiones
/// clave.md`).
///
/// Devuelve `null` si el usuario cancela el diálogo.
///
/// En Android no se puede usar `file_selector` para esto: el paquete no
/// implementa guardado en esa plataforma (`getSaveLocation` lanza
/// `UnimplementedError` — comprobado leyendo su código, no documentado en
/// ningún sitio visible). Ahí se habla directamente con el Storage Access
/// Framework a través de un canal nativo mínimo (ver
/// `android_saf_channel.dart` y `MainActivity.kt`): el valor que devuelve
/// no es una ruta de archivo, es una URI `content://` — por eso la
/// escritura real (`AndroidSafFileWriter`) tampoco puede usar `dart:io`.
Future<String?> pickLcpSaveLocation(String suggestedName) async {
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
