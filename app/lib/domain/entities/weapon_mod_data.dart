import '../enums/enums.dart';
import '../value_objects/value_objects.dart';
import 'mech_system_data.dart';

/// Sección 13.5 del modelo de dominio.
///
/// Entidad de catálogo: extiende todos los campos de [IMechSystemData],
/// añadiendo los propios de mod.
///
/// Regla de composición no trivial (no solo concatenación de arrays):
/// `addedDamage`/`addedRange` se SUMAN al daño/rango existente si el tipo
/// coincide con uno ya presente en el arma base; si no coincide, se añaden
/// como entrada separada. Debe implementarse explícitamente en el caso de
/// uso que aplique un mod, no asumirse como simple append.
///
/// `restrictedTypes`/`restrictedSizes` DEPRECADOS aquí — mantenidos solo
/// por compatibilidad con LCPs v2 (a diferencia de `Ammo`, sección 9, donde
/// los mismos nombres de campo están vigentes). COMP/CON los transforma
/// internamente a `allowed_*`; no se recomienda su uso en contenido nuevo.
class IWeaponModData extends IMechSystemData {
  final IActiveEffectData? onMiss;
  final IActiveEffectData? onAttack;
  final IActiveEffectData? onHit;
  final IActiveEffectData? onCrit;
  final List<WeaponType>? allowedTypes; // omitir = permitido en todos los tipos
  final List<WeaponSize>? allowedSizes; // omitir = permitido en todos los tamaños
  final List<ITagInstance>? addedTags; // se eliminan si el mod se quita o destruye
  final List<IDamageData>? addedDamage; // ver nota de regla de composición
  final List<IRangeData>? addedRange; // ver nota de regla de composición
  final List<WeaponType>? restrictedTypes; // DEPRECADO
  final List<WeaponSize>? restrictedSizes; // DEPRECADO

  const IWeaponModData({
    required super.id,
    required super.name,
    super.source,
    super.license,
    super.licenseId,
    required super.licenseLevel,
    super.type,
    super.effect,
    super.description,
    super.sp,
    super.tags,
    super.actions,
    super.bonuses,
    super.noBonus,
    super.synergies,
    super.noSynergy,
    super.deployables,
    super.counters,
    super.integrated,
    super.specialEquipment,
    super.activeEffects,
    this.onMiss,
    this.onAttack,
    this.onHit,
    this.onCrit,
    this.allowedTypes,
    this.allowedSizes,
    this.addedTags,
    this.addedDamage,
    this.addedRange,
    this.restrictedTypes,
    this.restrictedSizes,
  });
}
