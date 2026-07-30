/// Web pick of which `.lcp` to edit. The Edit flow is hidden on web (see
/// `HomeScreen`), so this is never reached; it returns `null` (cancelled) and
/// exists only so the app compiles for web without `dart:io`.
Future<String?> pickLcpEditLocationImpl() async => null;
