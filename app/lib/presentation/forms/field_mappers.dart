/// Generic helpers that map raw form-list values onto domain lists.
library;

// --- Helpers genéricos de listas ---

List<T>? mapItems<T>(
  dynamic rawItems,
  T? Function(Map<String, dynamic>) fromItem,
) {
  final items = (rawItems as List<Map<String, dynamic>>?) ?? const [];
  if (items.isEmpty) return null;
  final mapped = items.map(fromItem).whereType<T>().toList();
  return mapped.isEmpty ? null : mapped;
}

List<String>? mapStringIdItems(dynamic rawItems) {
  final items = (rawItems as List<Map<String, dynamic>>?) ?? const [];
  if (items.isEmpty) return null;
  final ids = items.map((i) => i['id'] as String?).whereType<String>().toList();
  return ids.isEmpty ? null : ids;
}
List<T>? emptyToNull<T>(List<T>? list) =>
    (list == null || list.isEmpty) ? null : list;
