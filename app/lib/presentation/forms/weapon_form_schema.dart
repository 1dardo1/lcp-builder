import '../../domain/domain.dart';
import 'field_spec.dart';

/// Esquema de campos de [IWeaponData] para el motor genérico — primer
/// corte, no exhaustivo. Cubre representativamente cada categoría del
/// catálogo de casos polimórficos (campos simples, enum-select, listas de
/// sub-formulario, caso 3 vía `aoe`, caso 4 vía `bonuses`/`BonusId`
/// anidado dentro de una lista).
///
/// Pendiente (no es una limitación del motor, es alcance de este primer
/// corte): `actions`, `active_effects`, `synergies`, `deployables`,
/// `profiles` — repetirían el mismo patrón ya demostrado sin aportar
/// mecanismo nuevo.
final _diceExpressionPattern = RegExp(r'^[0-9dD+\-*/(){}A-Za-z_ ]+$');

FieldSpec _bonusCatalogField() => CatalogFieldSpec<BonusId>(
  key: 'bonus',
  label: 'Bonus',
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
);

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
  ListFieldSpec(
    key: 'bonuses',
    label: 'Bonuses',
    // Catálogo (caso 4) anidado dentro de una lista: cada ítem elige su
    // propio BonusId de forma independiente. Demuestra que el motor ya no
    // limita CatalogFieldSpec/ShapeChoiceFieldSpec al nivel superior.
    itemFields: [_bonusCatalogField()],
  ),
];

DiceExpression _diceExpressionFromInput(String raw) {
  final n = num.tryParse(raw);
  return n != null ? DiceExpression.number(n) : DiceExpression.formula(raw);
}

/// Ensambla un `IBonusData` a partir de los valores de un ítem de la lista
/// `bonuses` (ver [_bonusCatalogField]).
IBonusData? _bonusFromItemValues(Map<String, dynamic> item) {
  final bonusId = item['bonus.id'] as BonusId?;
  if (bonusId == null) return null;

  final Object val = switch (bonusId.valueKind) {
    BonusValueKind.numericOrFormula =>
      (item['bonus.value.choice'] as String? ?? 'A') == 'A'
          ? NumericOrFormulaValue.number((item['bonus.value.a'] as num?) ?? 0)
          : NumericOrFormulaValue.formula(
              (item['bonus.value.b'] as String?) ?? '',
            ),
    BonusValueKind.boolean => (item['bonus.value'] as bool?) ?? false,
    // Cada elemento de la lista es ya una cadena DieRoll completa (ej. la
    // progresión de overcharge: "1d6", "1d6+1d8", "2d6+1d10"...) — se
    // separan por comas, no se trocea una sola cadena por sus +/-.
    BonusValueKind.dieRollList =>
      (item['bonus.value'] as String? ?? '')
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .map(DieRoll.new)
          .toList(),
    BonusValueKind.mountAssignment => () {
      final raw = (item['bonus.value'] as String? ?? 'main:1').split(':');
      final type = MountAssignmentType.values.firstWhere(
        (t) => t.jsonValue.toLowerCase() == raw[0].toLowerCase(),
        orElse: () => MountAssignmentType.main,
      );
      return MountAssignment(
        mountType: type,
        maxMounts: int.tryParse(raw.length > 1 ? raw[1] : '1') ?? 1,
      );
    }(),
    BonusValueKind.unverified => item['bonus.value'] as String? ?? '',
  };
  return IBonusData(id: bonusId, val: val);
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
  final bonusItems =
      (values['bonuses'] as List<Map<String, dynamic>>?) ?? const [];
  final bonuses = bonusItems
      .map(_bonusFromItemValues)
      .whereType<IBonusData>()
      .toList();

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
    bonuses: bonuses.isEmpty ? null : bonuses,
  );
}
