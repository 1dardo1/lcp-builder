import 'dart:io';

import '../../domain/ports/file_reader.dart';
import 'android_saf_file_reader.dart';
import 'local_file_reader.dart';

/// Native (`dart:io`) selection of the [FileReader] adapter.
FileReader makePlatformFileReader() =>
    Platform.isAndroid ? AndroidSafFileReader() : LocalFileReader();
