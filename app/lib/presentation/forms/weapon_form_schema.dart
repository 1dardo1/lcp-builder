import '../../domain/domain.dart';
import 'field_spec.dart';

/// Esquema de campos de [IWeaponData] para el motor genérico — primer
/// corte, no exhaustivo. Cubre representativamente cada categoría del
/// catálogo de casos polimórficos (campos simples, enum-select, listas de
/// sub-formulario, caso 3 vía `aoe`, caso 4 vía `bonuses`/`BonusId`).
///
/// Pendiente (no es una limitación del motor, es alcance de este primer
/// corte): `actions`, `active_effects`, `synergies`, `deployables`,
/// `profiles` — repetirían el mismo patrón ya demostrado sin aportar
/// mecanismo nuevo. `bonuses` se admite como un único bonus, no una lista
/// — anidar [CatalogFieldSpec] dentro de [ListFieldSpec] queda pendiente
/// de extender el motor.
final _diceExpressionPattern = RegExp(r'^[0-9dD+\-*/(){}A-Za-z_ ]+$');

List<FieldSpec> buildWeaponFormSchema() => [
  const TextFieldSpec(key: 'id', label: 'ID', required: true),
  const TextFieldSpec(key: 'name', label: 'Nombre', required: true),
  const TextFieldSpec(
    key: 'source',
    label: 'Fabricante (source)',
    required: true,
  ),
  const TextFieldSpec(
    key: 'license',
    label: 'Licencia (nombre de display)',
    required: true,
  ),
  const TextFieldSpec(
    key: 'licenseId',
    label: 'ID de la licencia (frame)',
    required: true,
  ),
  const NumberFieldSpec(
    key: 'licenseLevel',
    label: 'Nivel de licencia (0-3)',
    required: true,
  ),
  const TextFieldSpec(
    key: 'effect',
    label: 'Efecto',
    required: true,
    maxLines: 3,
  ),
  const TextFieldSpec(
    key: 'description',
    label: 'Descripción',
    required: true,
    maxLines: 3,
  ),
  const NumberFieldSpec(key: 'sp', label: 'SP'),
  EnumFieldSpec<MountType>(
    key: 'mount',
    label: 'Mount',
    required: true,
    options: MountType.values,
    displayLabel: (m) => m.jsonValue,
  ),
  EnumFieldSpec<WeaponType>(
    key: 'type',
    label: 'Tipo de arma',
    required: true,
    options: WeaponType.values,
    displayLabel: (t) => t.jsonValue,
  ),
  const BoolFieldSpec(key: 'barrage', label: 'Barrage'),
  const BoolFieldSpec(key: 'skirmish', label: 'Skirmish'),
  ListFieldSpec(
    key: 'damage',
    label: 'Daño',
    itemFields: [
      EnumFieldSpec<DamageType>(
        key: 'type',
        label: 'Tipo de daño',
        required: true,
        options: DamageType.values,
        displayLabel: (d) => d.jsonValue,
      ),
      PatternTextFieldSpec(
        key: 'val',
        label: 'Valor (número o dados)',
        required: true,
        pattern: _diceExpressionPattern,
        patternHint: 'ej. 2d6, 10, 1d6+{grit}',
      ),
    ],
  ),
  ListFieldSpec(
    key: 'range',
    label: 'Alcance',
    itemFields: [
      EnumFieldSpec<RangeType>(
        key: 'type',
        label: 'Tipo de alcance',
        required: true,
        options: RangeType.values,
        displayLabel: (r) => r.jsonValue,
      ),
      PatternTextFieldSpec(
        key: 'val',
        label: 'Valor',
        required: true,
        pattern: _diceExpressionPattern,
        patternHint: 'ej. 10, 1d6',
      ),
    ],
  ),
  const ListFieldSpec(
    key: 'tags',
    label: 'Tags',
    itemFields: [
      TextFieldSpec(
        key: 'id',
        label: 'ID del tag (ej. tg_accurate)',
        required: true,
      ),
    ],
  ),
  CatalogFieldSpec<BonusId>(
    key: 'bonus',
    label: 'Bonus (opcional, uno solo en este primer corte)',
    catalogIds: BonusId.values,
    idLabel: (id) => id.jsonValue,
    valueFieldFor: (id) => switch (id.valueKind) {
      BonusValueKind.numericOrFormula => const ShapeChoiceFieldSpec(
        key: 'bonus.value',
        label: 'Valor',
        required: true,
        optionALabel: 'Número',
        optionA: NumberFieldSpec(
          key: 'bonus.value.a',
          label: 'Número',
          allowDecimal: true,
        ),
        optionBLabel: 'Fórmula',
        optionB: TextFieldSpec(
          key: 'bonus.value.b',
          label: 'Fórmula (ej. {grit}+2)',
        ),
      ),
      BonusValueKind.boolean => const BoolFieldSpec(
        key: 'bonus.value',
        label: 'Activo',
      ),
      BonusValueKind.dieRollList => const TextFieldSpec(
        key: 'bonus.value',
        label: 'Progresión, separada por comas (ej. 1d6, 1d6+1d8, 2d6+1d10)',
      ),
      BonusValueKind.mountAssignment => const TextFieldSpec(
        key: 'bonus.value',
        label: 'mount_type:max_mounts (ej. main:3)',
      ),
      BonusValueKind.unverified => const TextFieldSpec(
        key: 'bonus.value',
        label: 'Valor (sin confirmar, ver vault MdD §4)',
      ),
    },
  ),
];

DiceExpression _diceExpressionFromInput(String raw) {
  final n = num.tryParse(raw);
  return n != null ? DiceExpression.number(n) : DiceExpression.formula(raw);
}

/// Ensambla los valores crudos del formulario en un [IWeaponData] real.
/// Este paso es intrínsecamente específico de la entidad — el motor
/// genérico no puede (ni debe) saber cómo construir un `IWeaponData`.
IWeaponData weaponFromFormValues(Map<String, dynamic> values) {
  final damageItems =
      (values['damage'] as List<Map<String, dynamic>>?) ?? const [];
  final rangeItems =
      (values['range'] as List<Map<String, dynamic>>?) ?? const [];
  final tagItems = (values['tags'] as List<Map<String, dynamic>>?) ?? const [];
  final bonusId = values['bonus.id'] as BonusId?;

  IBonusData? bonus;
  if (bonusId != null) {
    final Object val = switch (bonusId.valueKind) {
      BonusValueKind.numericOrFormula =>
        (values['bonus.value.choice'] as String? ?? 'A') == 'A'
            ? NumericOrFormulaValue.number(
                (values['bonus.value.a'] as num?) ?? 0,
              )
            : NumericOrFormulaValue.formula(
                (values['bonus.value.b'] as String?) ?? '',
              ),
      BonusValueKind.boolean => (values['bonus.value'] as bool?) ?? false,
      // Cada elemento de la lista es ya una cadena DieRoll completa (ej. la
      // progresión de overcharge: "1d6", "1d6+1d8", "2d6+1d10"...) — se
      // separan por comas, no se trocea una sola cadena por sus +/-.
      BonusValueKind.dieRollList =>
        (values['bonus.value'] as String? ?? '')
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .map(DieRoll.new)
            .toList(),
      BonusValueKind.mountAssignment => () {
        final raw = (values['bonus.value'] as String? ?? 'main:1').split(':');
        final type = MountAssignmentType.values.firstWhere(
          (t) => t.jsonValue.toLowerCase() == raw[0].toLowerCase(),
          orElse: () => MountAssignmentType.main,
        );
        return MountAssignment(
          mountType: type,
          maxMounts: int.tryParse(raw.length > 1 ? raw[1] : '1') ?? 1,
        );
      }(),
      BonusValueKind.unverified => values['bonus.value'] as String? ?? '',
    };
    bonus = IBonusData(id: bonusId, val: val);
  }

  return IWeaponData(
    id: values['id'] as String,
    name: values['name'] as String,
    source: values['source'] as String,
    license: values['license'] as String,
    licenseId: values['licenseId'] as String,
    licenseLevel: (values['licenseLevel'] as num?)?.toInt() ?? 0,
    effect: values['effect'] as String,
    description: values['description'] as String,
    mount: values['mount'] as MountType,
    type: values['type'] as WeaponType,
    sp: (values['sp'] as num?)?.toInt(),
    barrage: values['barrage'] as bool?,
    skirmish: values['skirmish'] as bool?,
    damage: damageItems.isEmpty
        ? null
        : [
            for (final item in damageItems)
              IDamageData(
                type: item['type'] as DamageType,
                val: _diceExpressionFromInput(item['val'] as String? ?? '0'),
              ),
          ],
    range: rangeItems.isEmpty
        ? null
        : [
            for (final item in rangeItems)
              IRangeData(
                type: item['type'] as RangeType,
                val: _diceExpressionFromInput(item['val'] as String? ?? '0'),
              ),
          ],
    tags: tagItems.isEmpty
        ? null
        : [for (final item in tagItems) ITagInstance(id: item['id'] as String)],
    bonuses: bonus == null ? null : [bonus],
  );
}
