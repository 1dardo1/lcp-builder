/// SITREP value object (vault domain model, section 17.3).
library;

class ISitrepCondition {
  final String title;
  final String condition;
  const ISitrepCondition({required this.title, required this.condition});
}
