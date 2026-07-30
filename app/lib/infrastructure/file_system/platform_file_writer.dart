import '../../domain/ports/file_writer.dart';
import 'file_writer_factory_web.dart'
    if (dart.library.io) 'file_writer_factory_io.dart';

/// Chooses the real [FileWriter] adapter for the current platform — native
/// (`dart:io`: Android SAF / desktop local) vs web (browser download),
/// resolved with a conditional import so the web build never pulls in
/// `dart:io`. Kept here (next to the adapters) so the call site
/// (`finalizarLcp`) doesn't need to know a platform difference exists.
FileWriter createPlatformFileWriter() => makePlatformFileWriter();
