import '../../domain/domain.dart';
import 'entity_crear_config.dart';
import 'field_spec.dart';

/// Esquema de campos de [IManufacturerData] — entidad simple, sin casos
/// polimórficos propios (sección 13.1 del modelo de dominio).
List<FieldSpec> buildManufacturerFormSchema() => [
  const TextFieldSpec(
    key: 'id',
    label: 'ID (acrónimo, ej. GMS)',
    required: true,
  ),
  const TextFieldSpec(key: 'name', label: 'Nombre', required: true),
  const TextFieldSpec(
    key: 'description',
    label: 'Descripción',
    required: true,
    maxLines: 3,
  ),
  const TextFieldSpec(key: 'quote', label: 'Cita', required: true, maxLines: 2),
  const TextFieldSpec(
    key: 'light',
    label: 'Color tema claro (#XXXXXX)',
    required: true,
  ),
  const TextFieldSpec(
    key: 'dark',
    label: 'Color tema oscuro (#XXXXXX)',
    required: true,
  ),
  const TextFieldSpec(key: 'iconSvg', label: 'Icono (SVG)'),
  const TextFieldSpec(key: 'iconUrl', label: 'Icono (URL, si no hay SVG)'),
];

IManufacturerData manufacturerFromFormValues(Map<String, dynamic> values) =>
    IManufacturerData(
      id: values['id'] as String,
      name: values['name'] as String,
      description: values['description'] as String,
      quote: values['quote'] as String,
      light: values['light'] as String,
      dark: values['dark'] as String,
      iconSvg: values['iconSvg'] as String?,
      iconUrl: values['iconUrl'] as String?,
    );

final manufacturerCrearConfig = EntityCrearConfig(
  title: 'Crear fabricante',
  contentKey: 'manufacturers',
  buildSchema: buildManufacturerFormSchema,
  fromFormValues: manufacturerFromFormValues,
  idOf: (content) => (content as IManufacturerData).id,
  nameOf: (content) => (content as IManufacturerData).name,
);
