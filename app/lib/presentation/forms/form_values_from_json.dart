import 'field_spec.dart';

/// Inverso de lo que produce cada `xFromFormValues` de las 24 entidades —
/// dado un [schema] y el JSON crudo de una entidad ya escrita en un `.lcp`
/// (con las claves reales del `.lcp`, las de [FieldSpec.jsonKey], no las
/// del formulario), reconstruye el mapa de valores con la forma exacta que
/// `GenericFormController`/`GenericFormView` esperan bajo [FieldSpec.key]
/// — para que Editar pueda abrir el mismo formulario de Crear ya relleno,
/// en vez de vacío.
///
/// [ShapeChoiceFieldSpec]/[CatalogFieldSpec] se resuelven con
/// [ShapeChoiceFieldSpec.branchFromJson]/[CatalogFieldSpec.idFromJson] —
/// funciones que cada esquema rellena a mano (auditoría en curso, igual
/// que [EnumFieldSpec.fromJsonValue]); mientras un campo no las tenga, se
/// deja sin rellenar en vez de arriesgar un valor incorrecto.
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
  switch (field) {
    // Estos dos casos operan sobre el JSON del contenedor completo (no un
    // valor ya aislado por `jsonKey`) — el discriminador de rama/id puede
    // vivir en la forma del valor o en qué clave está presente, no
    // necesariamente bajo la propia `jsonKey` del campo (que muchas veces
    // ni existe como tal en el JSON real).
    case ShapeChoiceFieldSpec f:
      final branch = f.branchFromJson?.call(json);
      if (branch == null) return;
      values['${field.key}.choice'] = branch;
      final option = f.options.firstWhere(
        (o) => o.value == branch,
        orElse: () => f.options.first,
      );
      if (option.field != null) _hydrateField(option.field!, json, values);
      return;

    case CatalogFieldSpec f:
      final id = f.idFromJsonDynamic(json);
      if (id == null) return;
      values['${field.key}.id'] = id;
      _hydrateField(f.fieldFor(id), json, values);
      return;

    // Grupo cuyos campos son hermanos directos en el JSON del contenedor
    // (ver [GroupFieldSpec.inline]) — se recorre sobre el mismo `json`
    // recibido, no sobre `json[jsonKey]`.
    case GroupFieldSpec f when f.inline:
      values[field.key] = formValuesFromJson(f.fields, json);
      return;

    default:
      break;
  }

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
          .map((v) => f.valueFromJson(v))
          .where((v) => v != null)
          .toList();
      if (parsed.isNotEmpty) values[field.key] = parsed;

    case GroupFieldSpec f:
      values[field.key] = raw is List
          // Caso 6 (TierValue.perTier/NpcSize): el JSON es un array
          // posicional, no un objeto — cada posición corresponde al campo
          // de [f.fields] en el mismo índice, no a una clave con nombre.
          ? _hydratePositionalGroup(f.fields, raw)
          : formValuesFromJson(f.fields, raw as Map<String, dynamic>);

    case ListFieldSpec f:
      values[field.key] = [
        for (final item in raw as List)
          formValuesFromJson(f.itemFields, item as Map<String, dynamic>),
      ];

    case ShapeChoiceFieldSpec():
    case CatalogFieldSpec():
      break; // ya resueltos arriba, inalcanzable aquí.
  }
}

/// Hidrata un [GroupFieldSpec] cuyo JSON es un array posicional (ej.
/// `[4, 6, 8]` para `tier1`/`tier2`/`tier3`) en vez de un objeto con
/// nombres de clave — cada campo de [fields] lee de `raw[i]`, no de
/// `raw[field.jsonKey]`. Envuelve cada posición en un mapa de una sola
/// clave (la propia `jsonKey` del campo) para poder reutilizar
/// [_hydrateField] sin duplicar su lógica por tipo de campo.
Map<String, dynamic> _hydratePositionalGroup(
  List<FieldSpec> fields,
  List<dynamic> raw,
) {
  final values = <String, dynamic>{};
  for (var i = 0; i < fields.length && i < raw.length; i++) {
    final field = fields[i];
    _hydrateField(field, {field.jsonKey: raw[i]}, values);
  }
  return values;
}
