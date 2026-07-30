/// Tag instance value object (vault domain model, section 6).
library;

/// `id` referencia una entrada del catálogo [ITagData], no identidad de
/// instancia propia.
class ITagInstance {
  final String id;
  final Object? val; // string|number — sustituye el token {VAL} del catálogo
  const ITagInstance({required this.id, this.val});
}
