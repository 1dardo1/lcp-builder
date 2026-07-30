import '../../domain/ports/lcp_directory_lister.dart';
import 'lister_factory_web.dart'
    if (dart.library.io) 'lister_factory_io.dart';

/// Chooses the real [LcpDirectoryLister] adapter for the current platform —
/// same criterion as `createPlatformFileWriter`, web isolated from `dart:io`.
LcpDirectoryLister createPlatformLcpDirectoryLister() =>
    makePlatformLcpDirectoryLister();
