/// Bond value objects (vault domain model, section 11.7).
library;

import '../enums/enums.dart';

class IQuestionData {
  final String question;
  final List<String> options;
  const IQuestionData({required this.question, required this.options});
}

/// Sin `id` propio (solo el Bond contenedor lo tiene). `origin` — regla de
/// integridad referencial entre archivos — ver vault MdD §11.7.
class IBondPowerData {
  final String name;
  final String description;
  final ActionFrequency? frequency;
  final String? prerequisite;
  final bool? veteran; // default false — solo disponible en estatus Veteran
  final bool? master; // default false — solo disponible en estatus Master
  final String? origin;

  const IBondPowerData({
    required this.name,
    required this.description,
    this.frequency,
    this.prerequisite,
    this.veteran,
    this.master,
    this.origin,
  });
}
