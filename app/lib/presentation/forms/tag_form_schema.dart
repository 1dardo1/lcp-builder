import '../../domain/domain.dart';
import 'entity_crear_config.dart';
import 'field_spec.dart';

/// Esquema de campos de [ITagData] — catálogo de tags (sección 6 del
/// modelo de dominio), distinto de [ITagInstance] (referencia de uso
/// dentro de otras entidades, ver `weapon_form_schema.dart`).
List<FieldSpec> buildTagFormSchema() => [
  const TextFieldSpec(
    key: 'id',
    label: 'ID',
    required: true,
    helpText:
        'Identificador con el que otras entidades referencian este tag '
        '(ej. "limited"). Minúsculas, sin espacios.',
  ),
  const TextFieldSpec(
    key: 'name',
    label: 'Nombre',
    required: true,
    helpText: 'El nombre visible del tag, ej. "Limited".',
  ),
  const TextFieldSpec(
    key: 'description',
    label: 'Descripción (puede contener {VAL})',
    required: true,
    maxLines: 3,
    helpText:
        'Texto de reglas del tag. Si el tag lleva un valor numérico al '
        'usarse (ej. "Limited X"), escribe "{VAL}" donde debería ir ese '
        'número.',
  ),
  const BoolFieldSpec(key: 'hidden', label: 'Oculto (uso interno de UI)'),
  const BoolFieldSpec(
    key: 'filterIgnore',
    jsonKey: 'filter_ignore',
    label: 'No aparece en filtros de equipo',
  ),
];

ITagData tagFromFormValues(Map<String, dynamic> values) => ITagData(
  id: values['id'] as String,
  name: values['name'] as String,
  description: values['description'] as String,
  hidden: values['hidden'] as bool?,
  filterIgnore: values['filterIgnore'] as bool?,
);

final tagCrearConfig = EntityCrearConfig(
  title: 'Crear tag',
  contentKey: 'tags',
  buildSchema: buildTagFormSchema,
  fromFormValues: tagFromFormValues,
  idOf: (content) => (content as ITagData).id,
  nameOf: (content) => (content as ITagData).name,
);
