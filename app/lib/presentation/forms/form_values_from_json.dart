import 'field_spec.dart';

/// Inverso de lo que produce cada `xFromFormValues` de las 24 entidades —
/// dado un [schema] y el JSON crudo de una entidad ya escrita en un `.lcp`
/// (con las claves reales del `.lcp`, las de [FieldSpec.jsonKey], no las
/// del formulario), reconstruye el mapa de valores con la forma exacta que
/// `GenericFormController`/`GenericFormView` esperan bajo [FieldSpec.key]
/// — para que Editar pueda abrir el mismo formulario de Crear ya relleno,
/// en vez de vacío.
///
/// [ShapeChoiceFieldSpec] y [CatalogFieldSpec] (casos 3/4/6 del catálogo)
/// se dejan sin rellenar por ahora a propósito: averiguar qué rama/id de
/// catálogo eligió el JSON original no es un simple `fromJsonValue` por
/// campo como en [EnumFieldSpec] — la propia `xFromFormValues` de cada
/// entidad ya lo resuelve con lógica específica suya, no genérica. Pendiente
/// de decidir el enfoque antes de dar por completo el flujo de Editar (ver
/// conversación).
Map<String, dynamic> formValuesFromJson(
  List<FieldSpec> schema,
  Map<String, dynamic> json,
) {
  final values = <String, dynamic>{};
  for (final field in schema) {
    _hydrateField(field, json, values);
  }
  return values;
}

void _hydrateField(
  FieldSpec field,
  Map<String, dynamic> json,
  Map<String, dynamic> values,
) {
  final raw = json[field.jsonKey];
  if (raw == null) return;

  switch (field) {
    case TextFieldSpec():
    case NumberFieldSpec():
    case BoolFieldSpec():
    case PatternTextFieldSpec():
      values[field.key] = raw;

    case EnumFieldSpec f:
      final parsed = f.valueFromJson(raw as String);
      if (parsed != null) values[field.key] = parsed;

    case MultiEnumFieldSpec f:
      final parsed = (raw as List)
          .map((v) => f.valueFromJson(v as String))
          .where((v) => v != null)
          .toList();
      if (parsed.isNotEmpty) values[field.key] = parsed;

    case GroupFieldSpec f:
      values[field.key] = formValuesFromJson(
        f.fields,
        raw as Map<String, dynamic>,
      );

    case ListFieldSpec f:
      values[field.key] = [
        for (final item in raw as List)
          formValuesFromJson(f.itemFields, item as Map<String, dynamic>),
      ];

    case ShapeChoiceFieldSpec():
    case CatalogFieldSpec():
      return;
  }
}
