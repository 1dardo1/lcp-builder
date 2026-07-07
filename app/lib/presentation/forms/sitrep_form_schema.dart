import '../../domain/domain.dart';
import 'entity_crear_config.dart';
import 'field_spec.dart';

/// Esquema de campos de [ISitrepData] (sección 17.3 del modelo de
/// dominio).
List<FieldSpec> buildSitrepFormSchema() => [
  const TextFieldSpec(key: 'id', label: 'ID', required: true),
  const TextFieldSpec(key: 'name', label: 'Nombre', required: true),
  const TextFieldSpec(
    key: 'description',
    label: 'Descripción',
    required: true,
    maxLines: 3,
  ),
  const TextFieldSpec(key: 'deployment', label: 'Despliegue', maxLines: 2),
  const TextFieldSpec(key: 'objective', label: 'Objetivo', maxLines: 2),
  const TextFieldSpec(key: 'extraction', label: 'Extracción', maxLines: 2),
  const ListFieldSpec(
    key: 'conditions',
    label: 'Condiciones de victoria (no confirmado de forma cruzada)',
    itemFields: [
      TextFieldSpec(key: 'title', label: 'Título', required: true),
      TextFieldSpec(
        key: 'condition',
        label: 'Condición',
        required: true,
        maxLines: 2,
      ),
    ],
  ),
  const TextFieldSpec(
    key: 'pcVictory',
    label: 'Victoria de los PCs',
    maxLines: 2,
  ),
  const TextFieldSpec(
    key: 'enemyVictory',
    label: 'Victoria enemiga',
    maxLines: 2,
  ),
  const TextFieldSpec(key: 'noVictory', label: 'Sin victoria', maxLines: 2),
];

List<ISitrepCondition>? _conditionsFromValues(Map<String, dynamic> values) {
  final items =
      (values['conditions'] as List<Map<String, dynamic>>?) ?? const [];
  if (items.isEmpty) return null;
  return [
    for (final item in items)
      ISitrepCondition(
        title: item['title'] as String? ?? '',
        condition: item['condition'] as String? ?? '',
      ),
  ];
}

ISitrepData sitrepFromFormValues(Map<String, dynamic> values) => ISitrepData(
  id: values['id'] as String,
  name: values['name'] as String,
  description: values['description'] as String,
  deployment: values['deployment'] as String?,
  objective: values['objective'] as String?,
  extraction: values['extraction'] as String?,
  conditions: _conditionsFromValues(values),
  pcVictory: values['pcVictory'] as String?,
  enemyVictory: values['enemyVictory'] as String?,
  noVictory: values['noVictory'] as String?,
);

final sitrepCrearConfig = EntityCrearConfig(
  title: 'Crear sitrep',
  contentKey: 'sitreps',
  buildSchema: buildSitrepFormSchema,
  fromFormValues: sitrepFromFormValues,
  idOf: (content) => (content as ISitrepData).id,
  nameOf: (content) => (content as ISitrepData).name,
);
