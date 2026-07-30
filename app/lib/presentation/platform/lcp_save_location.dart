import 'lcp_save_location_web.dart'
    if (dart.library.io) 'lcp_save_location_io.dart';

/// Picks where to save a `.lcp` (a user/OS interaction, so it lives in
/// `presentation/` — the domain and use cases only ever receive the resolved
/// path, never that a dialog happened). Native uses a real save dialog / the
/// Android SAF; web has no dialog and returns the suggested name (the web
/// `FileWriter` downloads under it). Resolved with a conditional import so the
/// web build never pulls in `dart:io`. Returns `null` if the user cancels.
Future<String?> pickLcpSaveLocation(String suggestedName) =>
    pickLcpSaveLocationImpl(suggestedName);
