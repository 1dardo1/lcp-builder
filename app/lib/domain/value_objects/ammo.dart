/// Ammo value object (vault domain model, section 9).
library;

import '../enums/enums.dart';

/// `restricted_*` con precedencia sobre `allowed_*` — vigentes aquí (a
/// diferencia de `IWeaponModData`, §13.5, donde están deprecados). Ver
/// vault MdD §9.
class IAmmoData {
  final String name;
  final String description;
  final int? cost; // default 1
  final List<WeaponType>? allowedTypes; // omitir = todos
  final List<WeaponSize>? allowedSizes; // omitir = todos
  final List<WeaponType>? restrictedTypes;
  final List<WeaponSize>? restrictedSizes;

  const IAmmoData({
    required this.name,
    required this.description,
    this.cost,
    this.allowedTypes,
    this.allowedSizes,
    this.restrictedTypes,
    this.restrictedSizes,
  });
}
