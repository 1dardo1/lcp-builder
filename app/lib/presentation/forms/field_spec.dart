/// Modelo declarativo de campos de formulario — la "descripción" que el
/// motor genérico interpreta para pintar un formulario, sin necesidad de
/// reflexión en tiempo de ejecución (no viable en Dart/Flutter AOT). Cada
/// entidad aporta su propia lista de [FieldSpec]; el motor (`GenericFormView`)
/// es el único código compartido entre las 24 entidades.
///
/// Cubre las categorías del catálogo de casos polimórficos
/// (`vault/Modelo de Dominio/19...`) que aparecen en `IWeaponData`:
/// - Caso 3 (forma decidida por el propio valor) → [ShapeChoiceFieldSpec].
/// - Caso 4 (catálogo externo) → [CatalogFieldSpec].
/// - Caso 5 (string con gramática propia) → [PatternTextFieldSpec].
/// Caso 1/2 (unión con tag o campo exclusivo, ej. `IPilotGearData`) y caso 6
/// (variabilidad por tier, NPC) no aparecen en esta entidad — quedan
/// pendientes de un [FieldSpec] propio cuando se aborde una entidad que los
/// necesite.
library;

sealed class FieldSpec {
  final String
  key; // debe coincidir con el nombre de campo del dominio (camelCase)
  final String label;
  final bool required;
  const FieldSpec({
    required this.key,
    required this.label,
    this.required = false,
  });
}

class TextFieldSpec extends FieldSpec {
  final int maxLines;
  const TextFieldSpec({
    required super.key,
    required super.label,
    super.required,
    this.maxLines = 1,
  });
}

class NumberFieldSpec extends FieldSpec {
  final bool allowDecimal;
  const NumberFieldSpec({
    required super.key,
    required super.label,
    super.required,
    this.allowDecimal = false,
  });
}

class BoolFieldSpec extends FieldSpec {
  const BoolFieldSpec({
    required super.key,
    required super.label,
    super.required,
  });
}

/// Selector de un enum cerrado (ej. `MountType`, `WeaponType`) — no es un
/// caso polimórfico del catálogo, es el campo "simple" más común del dominio.
class EnumFieldSpec<T> extends FieldSpec {
  final List<T> options;
  final String Function(T) displayLabel;
  const EnumFieldSpec({
    required super.key,
    required super.label,
    super.required,
    required this.options,
    required this.displayLabel,
  });

  /// El motor genérico solo conoce `FieldSpec` (sin el argumento de tipo
  /// concreto), así que no puede llamar a `displayLabel` directamente sin
  /// perder T por variance. Este método sí puede — T está fijado en el
  /// propio objeto desde su construcción, no en el punto de llamada.
  String labelFor(dynamic value) => displayLabel(value as T);
}

/// Caso 3 del catálogo: el valor puede tener una de dos formas (ej.
/// `NumericOrFormulaValue` = número fijo o fórmula; `StringOrBool`). El
/// usuario elige la forma con un selector binario; el motor renderiza
/// después el sub-campo correspondiente.
class ShapeChoiceFieldSpec extends FieldSpec {
  final String optionALabel;
  final FieldSpec optionA;
  final String optionBLabel;
  final FieldSpec optionB;
  const ShapeChoiceFieldSpec({
    required super.key,
    required super.label,
    super.required,
    required this.optionALabel,
    required this.optionA,
    required this.optionBLabel,
    required this.optionB,
  });
}

/// Caso 5 del catálogo: string con gramática propia (`DiceExpression`,
/// `EffectDuration`...). Se valida el patrón, no la forma del valor.
class PatternTextFieldSpec extends FieldSpec {
  final RegExp pattern;
  final String patternHint;
  const PatternTextFieldSpec({
    required super.key,
    required super.label,
    super.required,
    required this.pattern,
    required this.patternHint,
  });
}

/// Lista repetible de un sub-formulario (ej. `damage: List<IDamageData>`).
/// El motor pinta un ítem por cada elemento actual, más un botón "añadir".
class ListFieldSpec extends FieldSpec {
  final List<FieldSpec> itemFields;
  const ListFieldSpec({
    required super.key,
    required super.label,
    super.required,
    required this.itemFields,
  });
}

/// Caso 4 del catálogo (el difícil): la forma depende de un catálogo
/// externo (`BonusId` → `BonusValueKind`). No se puede resolver con las
/// piezas genéricas anteriores sin más información — el motor necesita que
/// la propia entidad le diga, para cada id del catálogo, qué [FieldSpec]
/// mostrar a continuación.
class CatalogFieldSpec<TId> extends FieldSpec {
  final List<TId> catalogIds;
  final String Function(TId) idLabel;
  final FieldSpec Function(TId) valueFieldFor;
  const CatalogFieldSpec({
    required super.key,
    required super.label,
    super.required,
    required this.catalogIds,
    required this.idLabel,
    required this.valueFieldFor,
  });

  /// Mismo motivo que [EnumFieldSpec.labelFor]: evita el problema de
  /// variance al invocar desde el motor genérico, que solo ve `FieldSpec`.
  String labelFor(dynamic id) => idLabel(id as TId);
  FieldSpec fieldFor(dynamic id) => valueFieldFor(id as TId);
}
