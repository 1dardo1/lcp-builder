/// Sección 11.1 del modelo de dominio.
class IBackgroundData {
  final String id; // único globalmente
  final String name;
  final String description; // v-html
  final List<String>? skills; // IDs referenciando skills.json, por convención

  const IBackgroundData({
    required this.id,
    required this.name,
    required this.description,
    this.skills,
  });
}
