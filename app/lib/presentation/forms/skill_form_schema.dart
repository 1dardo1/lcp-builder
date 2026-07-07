import '../../domain/domain.dart';
import 'entity_crear_config.dart';
import 'field_spec.dart';

/// Esquema de campos de [ISkillData] (Trigger, sección 11.5 del modelo de
/// dominio).
List<FieldSpec> buildSkillFormSchema() => [
  const TextFieldSpec(key: 'id', label: 'ID', required: true),
  const TextFieldSpec(key: 'name', label: 'Nombre', required: true),
  const TextFieldSpec(
    key: 'description',
    label: 'Descripción (terso)',
    required: true,
    maxLines: 2,
  ),
  const TextFieldSpec(
    key: 'detail',
    label: 'Detalle (flavor text)',
    required: true,
    maxLines: 3,
  ),
  EnumFieldSpec<SkillFamily>(
    key: 'family',
    label: 'Familia (solo posición en la lista)',
    required: true,
    options: SkillFamily.values,
    displayLabel: (f) => f.jsonValue,
  ),
];

ISkillData skillFromFormValues(Map<String, dynamic> values) => ISkillData(
  id: values['id'] as String,
  name: values['name'] as String,
  description: values['description'] as String,
  detail: values['detail'] as String,
  family: values['family'] as SkillFamily,
);

final skillCrearConfig = EntityCrearConfig(
  title: 'Crear skill (trigger)',
  contentKey: 'skills',
  buildSchema: buildSkillFormSchema,
  fromFormValues: skillFromFormValues,
  idOf: (content) => (content as ISkillData).id,
  nameOf: (content) => (content as ISkillData).name,
);
