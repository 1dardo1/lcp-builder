/// Counter field builder and assembler (domain section 7).
library;

import '../../domain/domain.dart';
import 'field_spec.dart';

// --- Sección 7: ICounterData ---

List<FieldSpec> counterItemFields() => [
  const TextFieldSpec(
    key: 'id',
    label: 'ID',
    required: true,
    helpText:
        'Identificador interno de este contador. Minúsculas, sin espacios.',
  ),
  const TextFieldSpec(
    key: 'name',
    label: 'Nombre',
    required: true,
    helpText: 'El nombre visible del contador, ej. "Cargas de granada".',
  ),
  const NumberFieldSpec(
    key: 'defaultValue',
    jsonKey: 'default_value',
    label: 'Valor por defecto',
  ),
  const NumberFieldSpec(key: 'min', label: 'Mínimo'),
  const NumberFieldSpec(key: 'max', label: 'Máximo'),
];

ICounterData counterFromItem(Map<String, dynamic> item) => ICounterData(
  id: item['id'] as String,
  name: item['name'] as String,
  defaultValue: item['defaultValue'] as num?,
  min: item['min'] as num?,
  max: item['max'] as num?,
);
