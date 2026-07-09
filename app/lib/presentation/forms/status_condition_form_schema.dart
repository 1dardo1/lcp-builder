import '../../domain/domain.dart';
import 'entity_crear_config.dart';
import 'field_spec.dart';

/// Esquema de campos de [IStatusConditionData] (sección 17.4 del modelo de
/// dominio) — catálogo referenciado por `IStatusEffectData.id`.
List<FieldSpec> buildStatusConditionFormSchema() => [
  const TextFieldSpec(
    key: 'id',
    label: 'ID',
    required: true,
    helpText:
        'Identificador con el que otras entidades referencian este status/'
        'condition (ej. en `IStatusEffectData.id`). Minúsculas, sin espacios.',
  ),
  const TextFieldSpec(
    key: 'name',
    label: 'Nombre',
    required: true,
    helpText: 'El nombre visible, ej. "Stunned".',
  ),
  EnumFieldSpec<StatusConditionType>(
    key: 'type',
    label: 'Tipo',
    required: true,
    options: StatusConditionType.values,
    displayLabel: (t) => t.name,
  ),
  const TextFieldSpec(
    key: 'effects',
    label: 'Efectos',
    required: true,
    maxLines: 3,
    helpText:
        'Texto de reglas — qué le pasa a quien tiene este status/condition.',
  ),
  const TextFieldSpec(
    key: 'terse',
    label: 'Descripción corta',
    helpText:
        'Resumen de una línea, si hace falta un texto más corto que "Efectos".',
  ),
  const TextFieldSpec(
    key: 'iconSvg',
    jsonKey: 'icon_svg',
    label: 'Icono (SVG)',
    helpText: 'Contenido SVG del icono. Opcional.',
  ),
  const TextFieldSpec(
    key: 'iconUrl',
    jsonKey: 'icon_url',
    label: 'Icono (URL, si no hay SVG)',
    helpText: 'URL a una imagen de icono, solo si no hay SVG. Opcional.',
  ),
  EnumFieldSpec<ExclusiveTarget>(
    key: 'exclusive',
    label: 'Restringido a (opcional)',
    options: ExclusiveTarget.values,
    displayLabel: (t) => t.name,
  ),
];

IStatusConditionData statusConditionFromFormValues(
  Map<String, dynamic> values,
) => IStatusConditionData(
  id: values['id'] as String,
  name: values['name'] as String,
  type: values['type'] as StatusConditionType,
  effects: values['effects'] as String,
  terse: values['terse'] as String?,
  iconSvg: values['iconSvg'] as String?,
  iconUrl: values['iconUrl'] as String?,
  exclusive: values['exclusive'] as ExclusiveTarget?,
);

final statusConditionCrearConfig = EntityCrearConfig(
  title: 'Crear status/condition',
  contentKey: 'statuses',
  buildSchema: buildStatusConditionFormSchema,
  fromFormValues: statusConditionFromFormValues,
  idOf: (content) => (content as IStatusConditionData).id,
  nameOf: (content) => (content as IStatusConditionData).name,
);
