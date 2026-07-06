/// Sección 7 del modelo de dominio.
///
/// `id` identifica una instancia con estado propio (valor actual del
/// contador) que persiste en los datos de guardado del jugador y puede
/// mutar con el tiempo. No es un catálogo compartido ni un agrupador de
/// valores intercambiable — por eso es Entidad y no Value Object.
class ICounterData {
  final String id; // único, persiste en datos de guardado
  final String name;
  final num? defaultValue; // default 0
  final num? min; // default -MAX_INT
  final num? max; // default MAX_INT

  const ICounterData({
    required this.id,
    required this.name,
    this.defaultValue,
    this.min,
    this.max,
  });
}
