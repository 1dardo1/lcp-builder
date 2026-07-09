import 'package:flutter/services.dart';

/// Canal nativo compartido entre [pickLcpSaveLocation] (Android) y
/// [AndroidSafFileWriter] — el mismo `MethodChannel`, no uno por archivo,
/// porque ambos hablan con el mismo código nativo mínimo en
/// `MainActivity.kt` (sin registrar un plugin de verdad, no hace falta
/// para un único canal de una app, no de un paquete reutilizable).
///
/// Existe porque `file_selector` no implementa guardado en Android (ver
/// `lcp_save_location.dart`) — aquí se habla directamente con el Storage
/// Access Framework: `createDocument` (selector nativo "guardar como",
/// `ACTION_CREATE_DOCUMENT`) y `writeBytes` (escribe en la URI
/// `content://` resultante vía `ContentResolver`, algo que `dart:io` no
/// sabe hacer).
const MethodChannel androidSafChannel = MethodChannel(
  'com.example.lcp_builder/saf',
);
