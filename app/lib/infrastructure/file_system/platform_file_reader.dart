import 'dart:io';

import '../../domain/ports/file_reader.dart';
import 'android_saf_file_reader.dart';
import 'local_file_reader.dart';

/// Elige el adapter de [FileReader] real según la plataforma — mismo
/// criterio que `createPlatformFileWriter`.
FileReader createPlatformFileReader() =>
    Platform.isAndroid ? AndroidSafFileReader() : LocalFileReader();
