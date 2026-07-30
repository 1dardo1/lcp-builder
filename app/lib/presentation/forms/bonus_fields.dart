/// Bonus field builder and assembler (domain section 4).
library;

import '../../domain/domain.dart';
import 'field_spec.dart';
import 'field_mappers.dart';

// --- Sección 4: IBonusData (con todos sus filtros, no solo id/val) ---

final _bonusIdByJsonValue = {for (final id in BonusId.values) id.jsonValue: id};

FieldSpec bonusCatalogField() => CatalogFieldSpec<BonusId>(
  key: 'bonus',
  label: 'Bonus',
  catalogIds: BonusId.values,
  idLabel: (id) => id.jsonValue,
  // A diferencia de `resistance`/`otherEffect`, aquí sí hay un campo `id`
  // real (ver `bonusDataToJson`) — no hay que adivinar la clave presente.
  idFromJson: (json) => _bonusIdByJsonValue[json['id']],
  valueFieldFor: (id) => switch (id.valueKind) {
    BonusValueKind.numericOrFormula => ShapeChoiceFieldSpec(
      key: 'bonus.value',
      jsonKey: 'val',
      label: 'Valor',
      required: true,
      branchFromJson: (json) {
        final raw = json['val'];
        if (raw is num) return 'A';
        if (raw is String) return 'B';
        return null;
      },
      options: const [
        ShapeChoiceOption(
          value: 'A',
          label: 'Número',
          field: NumberFieldSpec(
            key: 'bonus.value.a',
            jsonKey: 'val',
            label: 'Número',
            allowDecimal: true,
          ),
        ),
        ShapeChoiceOption(
          value: 'B',
          label: 'Fórmula',
          field: TextFieldSpec(
            key: 'bonus.value.b',
            jsonKey: 'val',
            label: 'Fórmula (ej. {grit}+2)',
            helpText:
                'Fórmula en vez de número fijo — usa llaves para referirte a '
                'un stat del piloto/mech, ej. "{grit}+2" o "{level}".',
          ),
        ),
      ],
    ),
    BonusValueKind.boolean => const BoolFieldSpec(
      key: 'bonus.value',
      jsonKey: 'val',
      label: 'Activo',
    ),
    // dieRollList/mountAssignment/unverified quedan sin jsonKey a
    // propósito: el formulario los representa como un único string (una
    // progresión separada por comas, o "tipo:max"), pero el JSON real es
    // una lista (`dieRollToJson`) o un objeto `{mount_type, max_mounts}`
    // (`mountAssignmentToJson`) — asignárselo tal cual a un TextFieldSpec
    // rompería el campo en vez de precargarlo. Necesitan una conversión
    // de forma que el hydrator genérico todavía no sabe hacer (ver
    // conversación pendiente).
    BonusValueKind.dieRollList => const TextFieldSpec(
      key: 'bonus.value',
      label: 'Progresión, separada por comas (ej. 1d6, 1d6+1d8, 2d6+1d10)',
      helpText:
          'Un valor de dados por cada rango del bonus, separados por comas — '
          'el primero para el rango 1, el segundo para el rango 2, etc.',
    ),
    BonusValueKind.mountAssignment => const TextFieldSpec(
      key: 'bonus.value',
      label: 'mount_type:max_mounts (ej. main:3)',
      helpText:
          'Tipo de mount seguido de dos puntos y el número máximo de mounts '
          'de ese tipo, ej. "main:3" o "flex:1".',
    ),
    BonusValueKind.unverified => const TextFieldSpec(
      key: 'bonus.value',
      label: 'Valor (sin confirmar, ver vault MdD §4)',
      helpText:
          'Este bonus todavía no tiene forma confirmada en el modelo de '
          'dominio — escribe el valor tal cual aparece en la spec oficial.',
    ),
  },
);

List<FieldSpec> bonusItemFields() => [
  bonusCatalogField(),
  const NumberFieldSpec(key: 'accuracy', label: 'Accuracy asociado'),
  MultiEnumFieldSpec<DamageType>(
    key: 'damageTypes',
    jsonKey: 'damage_types',
    label: 'Tipos de daño (vacío = todos)',
    options: DamageType.values,
    displayLabel: (d) => d.jsonValue,
    fromJsonValue: (s) => DamageType.values.firstWhere((d) => d.jsonValue == s),
  ),
  MultiEnumFieldSpec<BonusRangeTypeFilter>(
    key: 'rangeTypes',
    jsonKey: 'range_types',
    label: 'Tipos de alcance (vacío = todos)',
    options: BonusRangeTypeFilter.values,
    displayLabel: (r) => r.jsonValue,
    fromJsonValue: (s) =>
        BonusRangeTypeFilter.values.firstWhere((r) => r.jsonValue == s),
  ),
  MultiEnumFieldSpec<BonusWeaponTypeFilter>(
    key: 'weaponTypes',
    jsonKey: 'weapon_types',
    label: 'Tipos de arma (vacío = any)',
    options: BonusWeaponTypeFilter.values,
    displayLabel: (t) => t.jsonValue,
    fromJsonValue: (s) =>
        BonusWeaponTypeFilter.values.firstWhere((t) => t.jsonValue == s),
  ),
  MultiEnumFieldSpec<BonusWeaponSizeFilter>(
    key: 'weaponSizes',
    jsonKey: 'weapon_sizes',
    label: 'Tamaños de arma (vacío = any)',
    options: BonusWeaponSizeFilter.values,
    displayLabel: (s) => s.jsonValue,
    fromJsonValue: (s) =>
        BonusWeaponSizeFilter.values.firstWhere((f) => f.jsonValue == s),
  ),
  const BoolFieldSpec(key: 'overwrite', label: 'Overwrite'),
  const BoolFieldSpec(key: 'replace', label: 'Replace'),
];

/// Ensambla un `IBonusData` a partir de los valores de un ítem de la lista
/// `bonuses` (ver [bonusCatalogField]).
IBonusData? bonusFromItemValues(Map<String, dynamic> item) {
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
  return IBonusData(
    id: bonusId,
    val: val,
    accuracy: item['accuracy'] as num?,
    damageTypes: emptyToNull(item['damageTypes'] as List?)?.cast<DamageType>(),
    rangeTypes: emptyToNull(
      item['rangeTypes'] as List?,
    )?.cast<BonusRangeTypeFilter>(),
    weaponTypes: emptyToNull(
      item['weaponTypes'] as List?,
    )?.cast<BonusWeaponTypeFilter>(),
    weaponSizes: emptyToNull(
      item['weaponSizes'] as List?,
    )?.cast<BonusWeaponSizeFilter>(),
    overwrite: item['overwrite'] as bool?,
    replace: item['replace'] as bool?,
  );
}
