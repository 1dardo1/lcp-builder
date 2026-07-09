import 'dart:io';

import '../../domain/ports/file_writer.dart';
import 'android_saf_file_writer.dart';
import 'local_file_writer.dart';

/// Elige el adapter de [FileWriter] real según la plataforma — vive aquí
/// (junto a los adapters, no en `finalizar_lcp.dart`) para que ese punto
/// de uso no necesite saber que existe una diferencia entre plataformas,
/// igual que `crearEntidadConfigs` centraliza el registro de entidades en
/// vez de que cada pantalla conozca las 24.
FileWriter createPlatformFileWriter() =>
    Platform.isAndroid ? AndroidSafFileWriter() : LocalFileWriter();
