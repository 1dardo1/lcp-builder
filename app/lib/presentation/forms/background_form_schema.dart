import '../../domain/domain.dart';
import 'entity_crear_config.dart';
import 'field_spec.dart';

/// Esquema de campos de [IBackgroundData] (sección 11.1 del modelo de
/// dominio).
List<FieldSpec> buildBackgroundFormSchema() => [
  const TextFieldSpec(key: 'id', label: 'ID', required: true),
  const TextFieldSpec(key: 'name', label: 'Nombre', required: true),
  const TextFieldSpec(
    key: 'description',
    label: 'Descripción',
    required: true,
    maxLines: 3,
  ),
  const ListFieldSpec(
    key: 'skills',
    label: 'Skills recomendadas (IDs de skills.json)',
    itemFields: [
      TextFieldSpec(key: 'id', label: 'ID de skill', required: true),
    ],
  ),
];

List<String>? _skillIdsFromValues(Map<String, dynamic> values) {
  final items = (values['skills'] as List<Map<String, dynamic>>?) ?? const [];
  if (items.isEmpty) return null;
  final ids = items.map((i) => i['id'] as String?).whereType<String>().toList();
  return ids.isEmpty ? null : ids;
}

IBackgroundData backgroundFromFormValues(Map<String, dynamic> values) =>
    IBackgroundData(
      id: values['id'] as String,
      name: values['name'] as String,
      description: values['description'] as String,
      skills: _skillIdsFromValues(values),
    );

final backgroundCrearConfig = EntityCrearConfig(
  title: 'Crear background',
  contentKey: 'backgrounds',
  buildSchema: buildBackgroundFormSchema,
  fromFormValues: backgroundFromFormValues,
  idOf: (content) => (content as IBackgroundData).id,
  nameOf: (content) => (content as IBackgroundData).name,
);
