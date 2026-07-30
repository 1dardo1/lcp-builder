/// Manifest value objects: semver constraints, changelog items and
/// dependencies (vault domain model, section 17.1).
library;

/// String con gramática propia, mismo criterio que [DiceExpression]/
/// [MountAssignment]. Formas válidas: `"X.Y.Z"` (versión mínima, acepta esa
/// o cualquier posterior), `"*"` (cualquier versión), `"=X.Y.Z"`
/// (exclusivamente esa versión exacta).
class SemverConstraint {
  final String value;
  SemverConstraint(this.value)
    : assert(_pattern.hasMatch(value), 'SemverConstraint inválida: $value');
  static final RegExp _pattern = RegExp(r'^(\*|=?\d+\.\d+\.\d+)$');
}

class IChangelogItem {
  final String version; // semver estricto X.Y.Z, sin modificadores
  final String date; // YYYY-MM-DD
  final List<String> changes;
  const IChangelogItem({
    required this.version,
    required this.date,
    required this.changes,
  });
}

class ILcpDependency {
  final String
  name; // debe coincidir EXACTAMENTE con el `name` del manifest de la dependencia
  final SemverConstraint version;
  final String? link;
  const ILcpDependency({required this.name, required this.version, this.link});
}
