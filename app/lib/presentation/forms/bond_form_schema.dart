import '../../domain/domain.dart';
import 'entity_crear_config.dart';
import 'field_spec.dart';

/// Esquema de campos de [IBondData] (sección 11.7 del modelo de dominio).
/// `questions` demuestra una lista anidada dentro de un ítem de otra lista
/// (`options` dentro de cada `question`) — mismo mecanismo genérico que
/// una lista dentro de un grupo, sin necesitar nada nuevo del motor.
List<FieldSpec> buildBondFormSchema() => [
  const TextFieldSpec(
    key: 'id',
    label: 'ID',
    required: true,
    helpText: 'Identificador único del bond. Minúsculas, sin espacios.',
  ),
  const TextFieldSpec(
    key: 'name',
    label: 'Nombre',
    required: true,
    helpText: 'El nombre visible del bond, ej. "The Hunter".',
  ),
  const ListFieldSpec(
    key: 'majorIdeals',
    label: 'Ideales mayores (2-5 típicamente)',
    itemFields: [
      TextFieldSpec(
        key: 'value',
        label: 'Ideal',
        required: true,
        helpText: 'Un ideal mayor de este bond, en pocas palabras.',
      ),
    ],
  ),
  const ListFieldSpec(
    key: 'minorIdeals',
    label: 'Ideales menores (2-5 típicamente)',
    itemFields: [
      TextFieldSpec(
        key: 'value',
        label: 'Ideal',
        required: true,
        helpText: 'Un ideal menor de este bond, en pocas palabras.',
      ),
    ],
  ),
  const ListFieldSpec(
    key: 'questions',
    label: 'Preguntas',
    itemFields: [
      TextFieldSpec(
        key: 'question',
        label: 'Pregunta',
        required: true,
        helpText: 'Una de las preguntas de trasfondo asociadas a este bond.',
      ),
      ListFieldSpec(
        key: 'options',
        label: 'Opciones de respuesta',
        itemFields: [
          TextFieldSpec(
            key: 'value',
            label: 'Opción',
            required: true,
            helpText: 'Una posible respuesta a la pregunta de arriba.',
          ),
        ],
      ),
    ],
  ),
  ListFieldSpec(
    key: 'powers',
    label: 'Powers',
    itemFields: [
      const TextFieldSpec(
        key: 'name',
        label: 'Nombre',
        required: true,
        helpText: 'El nombre visible de este power del bond.',
      ),
      const TextFieldSpec(
        key: 'description',
        label: 'Descripción',
        required: true,
        maxLines: 3,
        helpText: 'Texto de reglas de este power.',
      ),
      EnumFieldSpec<ActionFrequency>(
        key: 'frequency',
        label: 'Frecuencia',
        options: ActionFrequency.values,
        displayLabel: (f) => f.jsonValue,
      ),
      const TextFieldSpec(
        key: 'prerequisite',
        label: 'Prerrequisito',
        helpText: 'Qué hace falta para poder elegir este power, si aplica.',
      ),
      const BoolFieldSpec(key: 'veteran', label: 'Solo estatus Veteran'),
      const BoolFieldSpec(key: 'master', label: 'Solo estatus Master'),
      const TextFieldSpec(
        key: 'origin',
        label: 'Origen',
        helpText: 'De dónde viene este power (ej. clock, minor ideal...).',
      ),
    ],
  ),
];

List<String> _stringValuesFromItems(Map<String, dynamic> values, String key) {
  final items = (values[key] as List<Map<String, dynamic>>?) ?? const [];
  return items.map((i) => i['value'] as String? ?? '').toList();
}

IQuestionData _questionFromItem(Map<String, dynamic> item) => IQuestionData(
  question: item['question'] as String? ?? '',
  options: _stringValuesFromItems(item, 'options'),
);

IBondPowerData _powerFromItem(Map<String, dynamic> item) => IBondPowerData(
  name: item['name'] as String? ?? '',
  description: item['description'] as String? ?? '',
  frequency: item['frequency'] as ActionFrequency?,
  prerequisite: item['prerequisite'] as String?,
  veteran: item['veteran'] as bool?,
  master: item['master'] as bool?,
  origin: item['origin'] as String?,
);

IBondData bondFromFormValues(Map<String, dynamic> values) {
  final questionItems =
      (values['questions'] as List<Map<String, dynamic>>?) ?? const [];
  final powerItems =
      (values['powers'] as List<Map<String, dynamic>>?) ?? const [];
  return IBondData(
    id: values['id'] as String,
    name: values['name'] as String,
    majorIdeals: _stringValuesFromItems(values, 'majorIdeals'),
    minorIdeals: _stringValuesFromItems(values, 'minorIdeals'),
    questions: [for (final item in questionItems) _questionFromItem(item)],
    powers: [for (final item in powerItems) _powerFromItem(item)],
  );
}

final bondCrearConfig = EntityCrearConfig(
  title: 'Crear bond',
  contentKey: 'bonds',
  buildSchema: buildBondFormSchema,
  fromFormValues: bondFromFormValues,
  idOf: (content) => (content as IBondData).id,
  nameOf: (content) => (content as IBondData).name,
);
