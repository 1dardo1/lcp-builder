/// Sección 7 del modelo de dominio.
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
