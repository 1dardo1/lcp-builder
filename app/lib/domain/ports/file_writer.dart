/// Hexagonal port: persists bytes to a path. Different implementation per
/// platform (Linux: open write; Android: restricted picker — see ADR-002),
/// which is why it lives behind a port instead of being called directly from
/// `application/use_cases`.
abstract class FileWriter {
  Future<void> write(String path, List<int> bytes);
}
