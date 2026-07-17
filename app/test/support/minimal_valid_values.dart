import 'package:lcp_builder/presentation/forms/common_entity_fields.dart'
    show diceExpressionPattern, effectDurationPattern, synergyLocationPattern;
import 'package:lcp_builder/presentation/forms/field_spec.dart';

/// Ejemplo válido para cada `PatternTextFieldSpec.pattern` que existe hoy
/// en el dominio (ver `common_entity_fields.dart`) — no se genera por regex
/// genérica (poco fiable para un `RegExp` arbitrario cualquiera), se
/// mantiene una lista cerrada de los 3 patrones reales. Si aparece un
/// patrón nuevo sin registrar aquí, lanza en vez de producir un dato
/// inválido en silencio — así un esquema nuevo con un patrón propio hace
/// fallar el test de aceptación exhaustivo con un mensaje claro, no con un
/// "no coincide con el patrón" opaco.
String _sampleForPattern(RegExp pattern) {
  if (identical(pattern, diceExpressionPattern)) return '1d6';
  if (identical(pattern, effectDurationPattern)) return 'round_start_1';
  if (identical(pattern, synergyLocationPattern)) return 'weapon';
  throw StateError('Sin ejemplo válido registrado para el patrón $pattern');
}

/// Valores "mínimos válidos" para que un esquema completo pase la propia
/// validación de [GenericFormView] (el `Form.validate()` que conectan
/// `CrearEntidadScreen`/`EditarEntidadScreen`) y `fromFormValues()` no
/// lance por falta de un campo obligatorio.
///
/// Recorre los campos requeridos de nivel superior y de cualquier
/// [GroupFieldSpec] anidado (siempre visible en el formulario), pero
/// deliberadamente NO entra en [ListFieldSpec]: sus ítems no existen hasta
/// que el usuario pulsa "añadir", así que el validator del motor nunca los
/// exige (ver el comentario de alcance en `generic_form_view.dart` sobre
/// qué tipos de campo tienen `validator` conectado). Tampoco toca
/// [ShapeChoiceFieldSpec]/[CatalogFieldSpec]: su rama por defecto
/// (`f.options.first`) ya se resuelve en el propio motor sin necesitar un
/// valor explícito en el controller.
Map<String, dynamic> minimalValidValues(List<FieldSpec> fields) {
  final values = <String, dynamic>{};
  for (final f in fields) {
    switch (f) {
      case TextFieldSpec(:final required, :final key):
        if (required) values[key] = 'x';
      case NumberFieldSpec(:final required, :final key):
        if (required) values[key] = 1;
      case EnumFieldSpec(:final required, :final key, :final options):
        if (required) values[key] = options.first;
      case PatternTextFieldSpec(:final required, :final key, :final pattern):
        if (required) values[key] = _sampleForPattern(pattern);
      case GroupFieldSpec(:final key, :final fields):
        final nested = minimalValidValues(fields);
        if (nested.isNotEmpty) values[key] = nested;
      case BoolFieldSpec():
      case MultiEnumFieldSpec():
      case ListFieldSpec():
      case ShapeChoiceFieldSpec():
      case CatalogFieldSpec():
        break;
    }
  }
  return values;
}
