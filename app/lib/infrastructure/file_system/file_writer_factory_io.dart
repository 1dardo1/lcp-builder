import 'dart:io';

import '../../domain/ports/file_writer.dart';
import 'android_saf_file_writer.dart';
import 'local_file_writer.dart';

/// Native (`dart:io`) selection of the [FileWriter] adapter.
FileWriter makePlatformFileWriter() =>
    Platform.isAndroid ? AndroidSafFileWriter() : LocalFileWriter();
