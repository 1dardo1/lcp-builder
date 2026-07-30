import 'lcp_edit_location_web.dart'
    if (dart.library.io) 'lcp_edit_location_io.dart';

/// Picks which `.lcp` to open in the Edit flow. Native uses a real open
/// dialog / the Android SAF (returning a writable location); on web the Edit
/// flow is hidden, so this returns `null`. Resolved with a conditional import
/// so the web build never pulls in `dart:io`. Returns `null` if cancelled.
Future<String?> pickLcpEditLocation() => pickLcpEditLocationImpl();
