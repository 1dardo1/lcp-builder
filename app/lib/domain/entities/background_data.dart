/// Sección 11.1 del modelo de dominio.
///
/// Entidad de catálogo: el jugador elige una entrada existente, no crea una
/// instancia con estado propio. Puramente descriptivo — sin campos
/// mecánicos propios.
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
