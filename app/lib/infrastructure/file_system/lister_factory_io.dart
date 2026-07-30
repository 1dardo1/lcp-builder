import 'dart:io';

import '../../domain/ports/lcp_directory_lister.dart';
import 'android_saf_directory_lister.dart';
import 'local_lcp_directory_lister.dart';

/// Native (`dart:io`) selection of the [LcpDirectoryLister] adapter.
LcpDirectoryLister makePlatformLcpDirectoryLister() =>
    Platform.isAndroid ? AndroidSafDirectoryLister() : LocalLcpDirectoryLister();
