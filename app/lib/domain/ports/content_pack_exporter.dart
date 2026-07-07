import '../entities/lcp_manifest_data.dart';
import '../entities/weapon_data.dart';

/// Puerto hexagonal: serializa contenido del dominio al formato `.lcp`
/// (bytes de un zip de un solo nivel con `lcp_manifest.json` + un JSON por
/// tipo de contenido, ver `infrastructure/lcp`). No es específico de
/// plataforma — a diferencia de [FileWriter], no necesita un adapter
/// distinto por plataforma, pero vive detrás de un puerto igualmente para
/// que `application/use_cases` no dependa de `infrastructure/` en directo.
abstract class ContentPackExporter {
  List<int> exportWeapons({
    required ILcpManifestData manifest,
    required List<IWeaponData> weapons,
  });
}
