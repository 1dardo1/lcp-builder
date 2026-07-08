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
    helpText:
        'El identificador corto que usarán otras entidades para '
        'referenciar este fabricante (ej. en el campo "Fabricante" de un '
        'arma). Minúsculas o mayúsculas, sin espacios.',
  ),
  const TextFieldSpec(
    key: 'name',
    label: 'Nombre',
    required: true,
    helpText: 'El nombre completo que verá el jugador en COMP/CON.',
  ),
  const TextFieldSpec(
    key: 'description',
    label: 'Descripción',
    required: true,
    maxLines: 3,
    helpText: 'Texto de sabor sobre el fabricante — quién es, qué hace.',
  ),
  const TextFieldSpec(
    key: 'quote',
    label: 'Cita',
    required: true,
    maxLines: 2,
    helpText: 'Una frase corta característica del fabricante, entre comillas.',
  ),
  const TextFieldSpec(
    key: 'light',
    label: 'Color tema claro (#XXXXXX)',
    required: true,
    helpText:
        'Color hexadecimal (sin el "#") usado como acento cuando COMP/CON '
        'está en modo claro, ej. "FFDD55".',
  ),
  const TextFieldSpec(
    key: 'dark',
    label: 'Color tema oscuro (#XXXXXX)',
    required: true,
    helpText:
        'Color hexadecimal (sin el "#") usado como acento cuando COMP/CON '
        'está en modo oscuro, ej. "552200".',
  ),
  const TextFieldSpec(
    key: 'iconSvg',
    label: 'Icono (SVG)',
    helpText: 'Contenido SVG del icono del fabricante. Opcional.',
  ),
  const TextFieldSpec(
    key: 'iconUrl',
    label: 'Icono (URL, si no hay SVG)',
    helpText: 'URL a una imagen de icono, solo si no hay SVG. Opcional.',
  ),
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
