/// Bonus value objects (vault domain model, section 4).
library;

import '../enums/enums.dart';
import 'shared_value_types.dart';

/// Gramática distinta de [DiceExpression]: solo suma/resta de tiradas y
/// enteros encadenados, sin `*`, `/`, paréntesis, ni bonus strings.
/// Usado únicamente en `IBonusData.val` cuando `id = "overcharge"`.
class DieRoll {
  final String value;
  DieRoll(this.value)
    : assert(_pattern.hasMatch(value), 'DieRoll inválido: $value');
  static final RegExp _pattern = RegExp(
    r'^(\d*d\d+|\d+)([+-](\d*d\d+|\d+))*$',
    caseSensitive: false,
  );
}

/// Extraído del formato de string `add_mount` (`"mount_type:max_mounts"`).
class MountAssignment {
  final MountAssignmentType mountType;
  final int maxMounts;
  const MountAssignment({required this.mountType, required this.maxMounts});
}

/// `id` es [BonusId] (catálogo COMP/CON, ver vault MdD §4) — el tipo real
/// de `val` depende del id usado (`id.valueKind`), validado en el
/// constructor. Decisión de por qué se resuelve así (enum con campo
/// asociado, no una sealed class por id) documentada en el vault
/// (Aprendizajes).
class IBonusData {
  final BonusId id;
  final Object
  val; // NumericOrFormulaValue | bool | List<DieRoll> | MountAssignment — forma validada contra id.valueKind
  final num? accuracy;
  final List<DamageType>? damageTypes; // sin filtro "any" — omitir = todos
  final List<BonusRangeTypeFilter>?
  rangeTypes; // sin filtro "any" — omitir = todos
  final List<BonusWeaponTypeFilter>? weaponTypes; // default 'any' si se omite
  final List<BonusWeaponSizeFilter>? weaponSizes; // default 'any' si se omite
  final bool? overwrite;
  final bool? replace;

  IBonusData({
    required this.id,
    required this.val,
    this.accuracy,
    this.damageTypes,
    this.rangeTypes,
    this.weaponTypes,
    this.weaponSizes,
    this.overwrite,
    this.replace,
  }) : assert(
         _matchesValueKind(id, val),
         'IBonusData.val no coincide con la forma esperada para '
         '${id.jsonValue} (${id.valueKind}) — ver vault MdD §4',
       );

  static bool _matchesValueKind(BonusId id, Object val) {
    switch (id.valueKind) {
      case BonusValueKind.numericOrFormula:
        return val is NumericOrFormulaValue;
      case BonusValueKind.boolean:
        return val is bool;
      case BonusValueKind.dieRollList:
        return val is List<DieRoll>;
      case BonusValueKind.mountAssignment:
        return val is MountAssignment;
      case BonusValueKind.unverified:
        return true; // sin ejemplo real confirmado — no bloquear todavía
    }
  }
}
