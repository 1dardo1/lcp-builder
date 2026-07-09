import 'dart:io';

import '../../domain/ports/lcp_directory_lister.dart';
import 'android_saf_directory_lister.dart';
import 'local_lcp_directory_lister.dart';

/// Elige el adapter de [LcpDirectoryLister] real según la plataforma —
/// mismo criterio que `createPlatformFileWriter`.
LcpDirectoryLister createPlatformLcpDirectoryLister() =>
    Platform.isAndroid ? AndroidSafDirectoryLister() : LocalLcpDirectoryLister();
