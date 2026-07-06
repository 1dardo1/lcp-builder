import '../enums/enums.dart';
import '../value_objects/value_objects.dart';

/// Bloque `stats` de [IFrameData] — sin nombre propio en la fuente, todos
/// los campos requeridos y enteros positivos salvo `size` (admite 0.5).
class IFrameStats {
  final num size; // entero positivo o exactamente 0.5
  final num structure;
  final num stress;
  final num armor;
  final num hp;
  final num evasion;
  final num edef;
  final num heatcap;
  final num repcap;
  final num sensorRange;
  final num techAttack;
  final num save;
  final num speed;
  final num sp;

  const IFrameStats({
    required this.size,
    required this.structure,
    required this.stress,
    required this.armor,
    required this.hp,
    required this.evasion,
    required this.edef,
    required this.heatcap,
    required this.repcap,
    required this.sensorRange,
    required this.techAttack,
    required this.save,
    required this.speed,
    required this.sp,
  });
}

/// Sección 13.2 del modelo de dominio.
///
/// Entidad de catálogo: el piloto/cliente selecciona y desbloquea licencias
/// existentes, no crea instancias de frame con estado propio (el estado de
/// un mech concreto en partida es responsabilidad de COMP/CON).
class IFrameData {
  final String id; // único globalmente
  final String name;
  final String source; // debe coincidir con un Manufacturer ID
  final String? licenseId; // requerido SOLO SI variant está presente
  final int licenseLevel; // 0 a 3
  final List<String> mechtype; // al menos uno; solo hint de UI
  final String description; // v-html
  final List<MountType> mounts; // al menos uno
  final IFrameStats stats;
  final List<IFrameTraitData> traits; // puede ser vacío
  final ICoreSystemData coreSystem; // exactamente uno
  final Object?
  specialty; // bool | IPrerequisite — discriminado por la forma del valor, no por campo
  final String?
  variant; // id (preferido) o name (legacy) del frame del que es variante
  final String? imageUrl;
  final num? yPos; // alineación vertical en banners de UI

  const IFrameData({
    required this.id,
    required this.name,
    required this.source,
    this.licenseId,
    required this.licenseLevel,
    required this.mechtype,
    required this.description,
    required this.mounts,
    required this.stats,
    required this.traits,
    required this.coreSystem,
    this.specialty,
    this.variant,
    this.imageUrl,
    this.yPos,
  });
}
