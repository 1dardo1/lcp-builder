import '../../domain/domain.dart';
import 'entity_crear_config.dart';
import 'field_spec.dart';

/// Esquema de campos de [IStatusConditionData] (sección 17.4 del modelo de
/// dominio) — catálogo referenciado por `IStatusEffectData.id`.
List<FieldSpec> buildStatusConditionFormSchema() => [
  const TextFieldSpec(key: 'id', label: 'ID', required: true),
  const TextFieldSpec(key: 'name', label: 'Nombre', required: true),
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
  ),
  const TextFieldSpec(key: 'terse', label: 'Descripción corta'),
  const TextFieldSpec(key: 'iconSvg', label: 'Icono (SVG)'),
  const TextFieldSpec(key: 'iconUrl', label: 'Icono (URL, si no hay SVG)'),
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
