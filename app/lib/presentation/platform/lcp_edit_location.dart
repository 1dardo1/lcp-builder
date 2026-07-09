import 'dart:io';

import 'package:file_selector/file_selector.dart';

import '../../infrastructure/file_system/android_saf_channel.dart';

/// Adapter de "selector nativo" (ver ADR-002) para elegir qué `.lcp` abrir
/// en el flujo Editar — a diferencia de Mostrar (que solo lee), Editar
/// necesita después poder escribir de vuelta en el mismo archivo.
///
/// En Android no basta con `file_selector`'s `openFile()`: esa función
/// copia el documento elegido a una ruta de caché local (un archivo
/// `dart:io` normal, ver el comentario en `AndroidSafFileReader`), útil
/// para leer pero sin ninguna URI `content://` viva — al guardar,
/// `AndroidSafFileWriter` fallaría con `PlatformException(write_failed,
/// No content provider...)` porque esa ruta de caché no es un documento
/// real. Se resuelve igual que [pickLcpSaveLocation]: hablando
/// directamente con el Storage Access Framework a través del mismo canal
/// nativo (`openDocument`, `ACTION_OPEN_DOCUMENT`), que sí devuelve la URI
/// `content://` real del documento, con permiso persistente de
/// lectura/escritura.
///
/// Devuelve `null` si el usuario cancela el diálogo.
Future<String?> pickLcpEditLocation() async {
  if (Platform.isAndroid) {
    return androidSafChannel.invokeMethod<String>('openDocument');
  }

  final file = await openFile(
    acceptedTypeGroups: const [
      XTypeGroup(label: 'Lancer Content Pack', extensions: ['lcp']),
    ],
  );
  return file?.path;
}
