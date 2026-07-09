/// Modelo declarativo de campos de formulario — la "descripción" que el
/// motor genérico interpreta para pintar un formulario, sin necesidad de
/// reflexión en tiempo de ejecución (no viable en Dart/Flutter AOT). Cada
/// entidad aporta su propia lista de [FieldSpec]; el motor (`GenericFormView`)
/// es el único código compartido entre las 24 entidades.
///
/// Cubre las 6 categorías del catálogo de casos polimórficos
/// (`vault/Modelo de Dominio/19...`) — ninguna necesitó, al completar las
/// 24 entidades, una pieza más allá de las ya construidas para `IWeaponData`:
/// - Caso 1/2 (unión discriminada por tag `type`, o por campo exclusivo —
///   ej. `IPilotGearData`, `INpcFeatureData`): el discriminador vive en el
///   tipo Dart (`sealed class`), pero el formulario para construir una
///   instancia sí necesita elegir la variante en tiempo de ejecución —
///   resuelto con [ShapeChoiceFieldSpec] (una rama por variante) +
///   [GroupFieldSpec] (campos propios de cada rama).
/// - Caso 3 (forma decidida por el propio valor) → [ShapeChoiceFieldSpec].
/// - Caso 4 (catálogo externo) → [CatalogFieldSpec].
/// - Caso 5 (string con gramática propia) → [PatternTextFieldSpec].
/// - Caso 6 (variabilidad por tier, NPC — `TierValue`/`NpcSize`/
///   `EidolonShardCount`): misma composición que caso 1/2,
///   [ShapeChoiceFieldSpec] generalizado a N ramas + [GroupFieldSpec]
///   reutilizado para "exactamente 3 campos, uno por tier" — ver vault
///   "Decisión - variabilidad por tier de NPC".
library;

sealed class FieldSpec {
  final String
  key; // debe coincidir con el nombre de campo del dominio (camelCase)
  final String label;
  final bool required;

  /// Texto de ayuda para el usuario sin conocimientos técnicos ("¿qué pongo
  /// aquí?") — si no es `null`, el motor pinta un botón de ayuda junto al
  /// campo que lo muestra en un diálogo. Disponible en cualquier [FieldSpec]
  /// (vive en la clase base), no solo en campos de texto.
  final String? helpText;

  /// Nombre real del campo en el JSON del `.lcp` — usado por Mostrar
  /// (`GenericFormView`/Crear no lo necesita, solo escribe). Por defecto
  /// es igual a [key], que cubre la mayoría de campos; se sobreescribe
  /// explícitamente solo donde de verdad difieren (ej. `key: 'licenseId'`
  /// pero `jsonKey: 'license_id'`) — ver `domain_json_mapper.dart` para
  /// los nombres reales. En un [ShapeChoiceFieldSpec], [jsonKey] es la
  /// única clave real (sus ramas, ej. `type.a`/`type.b`, son puramente
  /// internas al formulario y nunca aparecen así en el JSON — Mostrar no
  /// debe recorrerlas).
  final String jsonKey;

  const FieldSpec({
    required this.key,
    required this.label,
    this.required = false,
    this.helpText,
    String? jsonKey,
  }) : jsonKey = jsonKey ?? key;
}

class TextFieldSpec extends FieldSpec {
  final int maxLines;

  /// `contentKey` (ver [EntityCrearConfig]) de la entidad que este campo
  /// referencia por id (ej. `'manufacturers'` para `IWeaponData.source`).
  /// Si no es `null`, el motor pinta un botón "Crear `referenceLabel`" junto
  /// al campo — al pulsarlo, navega a crear esa entidad y, si el usuario la
  /// completa, rellena este campo con su id. `field_spec.dart` no conoce
  /// `EntityCrearConfig` (evita el import circular con
  /// `entity_crear_config.dart`) — la resolución real de qué pantalla abrir
  /// vive en `CrearEntidadScreen`, inyectada en `GenericFormView` como
  /// callback (`onCreateReference`).
  final String? referenceEntityKey;

  /// Texto legible para el botón de creación (ej. `'fabricante'` →
  /// "Crear fabricante"). Requerido solo si `referenceEntityKey` no es nulo.
  final String? referenceLabel;

  const TextFieldSpec({
    required super.key,
    required super.label,
    super.required,
    super.helpText,
    super.jsonKey,
    this.maxLines = 1,
    this.referenceEntityKey,
    this.referenceLabel,
  });
}

class NumberFieldSpec extends FieldSpec {
  final bool allowDecimal;
  const NumberFieldSpec({
    required super.key,
    required super.label,
    super.required,
    super.helpText,
    super.jsonKey,
    this.allowDecimal = false,
  });
}

class BoolFieldSpec extends FieldSpec {
  const BoolFieldSpec({
    required super.key,
    required super.label,
    super.required,
    super.helpText,
    super.jsonKey,
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
    super.helpText,
    super.jsonKey,
    required this.options,
    required this.displayLabel,
  });

  /// El motor genérico solo conoce `FieldSpec` (sin el argumento de tipo
  /// concreto), así que no puede llamar a `displayLabel` directamente sin
  /// perder T por variance. Este método sí puede — T está fijado en el
  /// propio objeto desde su construcción, no en el punto de llamada.
  String labelFor(dynamic value) => displayLabel(value as T);
}

/// Una rama de un [ShapeChoiceFieldSpec]: `value` es el identificador
/// estable que se guarda como elección (y que, por convención de quien
/// construye el spec, también sirve de sufijo de key para los campos de
/// `field`, ej. `'type.a'`); `label` es el texto del selector; `field` es
/// el sub-campo a pintar tras elegir esta rama, o `null` si la rama no
/// necesita más datos (ej. el valor fijo `hostile_characters`).
class ShapeChoiceOption {
  final String value;
  final String label;
  final FieldSpec? field;
  const ShapeChoiceOption({
    required this.value,
    required this.label,
    this.field,
  });
}

/// Caso 3 del catálogo (el valor puede tener una de varias formas — ej.
/// `NumericOrFormulaValue` = número fijo o fórmula; `StringOrBool`) y caso
/// 6 (variabilidad por tier de NPC, ej. `EidolonShardCount` con 3 formas):
/// el usuario elige una rama con un selector de N opciones; el motor
/// renderiza después el sub-campo de la rama elegida, si tiene uno.
class ShapeChoiceFieldSpec extends FieldSpec {
  final List<ShapeChoiceOption> options;
  const ShapeChoiceFieldSpec({
    required super.key,
    required super.label,
    super.required,
    super.helpText,
    super.jsonKey,
    required this.options,
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
    super.helpText,
    super.jsonKey,
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
    super.helpText,
    super.jsonKey,
    required this.itemFields,
  });
}

/// Selector de un subconjunto de un enum cerrado (ej. `allowedTypes`, una
/// lista de `WeaponType`) — la versión "multi" de [EnumFieldSpec]. El valor
/// guardado bajo `key` es directamente la lista seleccionada, sin
/// envolver en mapas de ítem (a diferencia de [ListFieldSpec], aquí no hay
/// sub-formulario por elemento, solo pertenencia sí/no a un conjunto fijo).
class MultiEnumFieldSpec<T> extends FieldSpec {
  final List<T> options;
  final String Function(T) displayLabel;
  const MultiEnumFieldSpec({
    required super.key,
    required super.label,
    super.required,
    super.helpText,
    super.jsonKey,
    required this.options,
    required this.displayLabel,
  });

  /// Mismo motivo que [EnumFieldSpec.labelFor] — evita el problema de
  /// variance de funciones al invocar desde el motor genérico.
  String labelFor(dynamic value) => displayLabel(value as T);
}

/// Sub-formulario de forma fija (ej. `IEffectSaveData` = `stat` + `aoe`):
/// varios campos agrupados bajo una única `key`, pero a diferencia de
/// [ListFieldSpec] hay exactamente una instancia, no una lista repetible.
/// Se apoya en el mismo mecanismo de contexto anidado que los ítems de
/// lista (ver `_groupContext` en `generic_form_view.dart`), lo que permite
/// reutilizar la misma lista de [FieldSpec] tanto como `itemFields` de un
/// [ListFieldSpec] (repetido) como `fields` de un [GroupFieldSpec] (único) —
/// ej. `IDamageData` de `IActionData` (singular) vs. de `IActiveEffectData`
/// (lista).
class GroupFieldSpec extends FieldSpec {
  final List<FieldSpec> fields;
  const GroupFieldSpec({
    required super.key,
    required super.label,
    super.required,
    super.helpText,
    super.jsonKey,
    required this.fields,
  });
}

/// Caso 4 del catálogo (el difícil): la forma depende de un catálogo
/// externo (`BonusId` → `BonusValueKind`). No se puede resolver con las
/// piezas genéricas anteriores sin más información — el motor necesita que
/// la propia entidad le diga, para cada id del catálogo, qué [FieldSpec]
/// mostrar a continuación.
///
/// También se reutiliza para uniones discriminadas *cerradas* (ej.
/// `IResistanceData`: resist/vulnerability/immunity; `IOtherEffectData`:
/// overshield/hp/repair/cover) usando un enum de UI local en vez de un
/// catálogo externo — mismo mecanismo, catálogo más pequeño.
class CatalogFieldSpec<TId> extends FieldSpec {
  final List<TId> catalogIds;
  final String Function(TId) idLabel;
  final FieldSpec Function(TId) valueFieldFor;
  const CatalogFieldSpec({
    required super.key,
    required super.label,
    super.required,
    super.helpText,
    super.jsonKey,
    required this.catalogIds,
    required this.idLabel,
    required this.valueFieldFor,
  });

  /// Mismo motivo que [EnumFieldSpec.labelFor]: evita el problema de
  /// variance al invocar desde el motor genérico, que solo ve `FieldSpec`.
  String labelFor(dynamic id) => idLabel(id as TId);
  FieldSpec fieldFor(dynamic id) => valueFieldFor(id as TId);
}
