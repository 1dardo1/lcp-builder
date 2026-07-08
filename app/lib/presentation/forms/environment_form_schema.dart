import '../../domain/domain.dart';
import 'entity_crear_config.dart';
import 'field_spec.dart';

/// Esquema de campos de [IEnvironmentData] (sección 17.2 del modelo de
/// dominio) — la entidad más simple del dominio, sin listas ni casos
/// polimórficos.
List<FieldSpec> buildEnvironmentFormSchema() => [
  const TextFieldSpec(
    key: 'id',
    label: 'ID',
    required: true,
    helpText: 'Identificador único del entorno. Minúsculas, sin espacios.',
  ),
  const TextFieldSpec(
    key: 'name',
    label: 'Nombre',
    required: true,
    helpText: 'El nombre visible del entorno, ej. "Sistema de Dombrovski".',
  ),
  const TextFieldSpec(
    key: 'description',
    label: 'Descripción',
    required: true,
    maxLines: 3,
    helpText: 'Texto de ambientación sobre este entorno/lugar.',
  ),
];

IEnvironmentData environmentFromFormValues(Map<String, dynamic> values) =>
    IEnvironmentData(
      id: values['id'] as String,
      name: values['name'] as String,
      description: values['description'] as String,
    );

final environmentCrearConfig = EntityCrearConfig(
  title: 'Crear entorno',
  contentKey: 'environments',
  buildSchema: buildEnvironmentFormSchema,
  fromFormValues: environmentFromFormValues,
  idOf: (content) => (content as IEnvironmentData).id,
  nameOf: (content) => (content as IEnvironmentData).name,
);
