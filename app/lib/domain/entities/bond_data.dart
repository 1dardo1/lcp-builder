import '../value_objects/value_objects.dart';

/// Sección 11.7 del modelo de dominio.
///
/// Entidad de catálogo. Contenido condicionado a un suplemento: la UI de
/// Bonds solo se muestra si el Karrakin Trade Baronies LCP está instalado y
/// activado — a diferencia del resto de Pilot Data, no forma parte del Core
/// Book base (relevante para la priorización de fases del ADR-003).
class IBondData {
  final String id; // único globalmente
  final String name;
  final List<String> majorIdeals; // típicamente 2-5 elementos
  final List<String> minorIdeals; // típicamente 2-5 elementos
  final List<IQuestionData> questions;
  final List<IBondPowerData> powers;

  const IBondData({
    required this.id,
    required this.name,
    required this.majorIdeals,
    required this.minorIdeals,
    required this.questions,
    required this.powers,
  });
}
