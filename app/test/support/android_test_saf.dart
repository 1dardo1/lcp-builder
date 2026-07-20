import 'package:lcp_builder/infrastructure/file_system/android_saf_channel.dart';

/// Arma en el lado nativo (ver el método `useTestSafDocument` en
/// `MainActivity.kt`) una URI `content://` de FileProvider como respuesta
/// fija del selector de guardar/abrir, para que los tests de aceptación de
/// Android ejerciten el camino REAL de escritura/lectura SAF sin abrir el
/// selector del sistema.
///
/// Necesario porque `flutter test integration_test/... -d emulator` conduce
/// la app por el VM service, no por la instrumentación de Android — así que
/// no hay forma de interceptar/automatizar el selector real (DocumentsUI),
/// y sin esto el `await` de `createDocument`/`openDocument` se cuelga para
/// siempre (visto en runs reales del workflow: la app conecta y se queda en
/// "awaiting test result" hasta el timeout).
///
/// Se llama al principio del cuerpo de cada test de aceptación, que solo se
/// ejecuta en Android (`skip: !Platform.isAndroid`), así que no hace falta
/// comprobar la plataforma aquí.
Future<void> armAndroidTestSaf() =>
    androidSafChannel.invokeMethod<void>('useTestSafDocument');
