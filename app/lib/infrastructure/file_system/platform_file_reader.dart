import '../../domain/ports/file_reader.dart';
import 'file_reader_factory_web.dart'
    if (dart.library.io) 'file_reader_factory_io.dart';

/// Chooses the real [FileReader] adapter for the current platform — same
/// criterion as `createPlatformFileWriter`, with the web build isolated from
/// `dart:io` via a conditional import.
FileReader createPlatformFileReader() => makePlatformFileReader();
