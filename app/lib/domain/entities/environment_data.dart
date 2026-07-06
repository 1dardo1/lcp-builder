/// Sección 17.2 del modelo de dominio.
class IEnvironmentData {
  final String id; // único globalmente
  final String name;
  final String description; // v-html, texto de regla/detalle

  const IEnvironmentData({
    required this.id,
    required this.name,
    required this.description,
  });
}
