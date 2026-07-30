import '../../domain/ports/lcp_directory_lister.dart';
import 'web_lcp_directory_lister.dart';

/// Web selection of the [LcpDirectoryLister] adapter (empty stub — the
/// folder-based flows are hidden on web).
LcpDirectoryLister makePlatformLcpDirectoryLister() => WebLcpDirectoryLister();
