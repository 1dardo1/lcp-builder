import '../entities/lcp_manifest_data.dart';

/// Puerto hexagonal para Editar, inverso de [ContentPackReader] en vez de
/// [ContentPackExporter]: serializa contenido que ya viene en JSON crudo
/// (`Map<String, dynamic>` por entidad, la misma forma que produce
/// `ContentPackReader`), no objetos de dominio tipados.
///
/// Por qué no reutilizar [ContentPackExporter] tal cual: Editar guarda un
/// `ParsedContentPack` donde solo la entidad que el usuario tocó se
/// reconstruyó como objeto de dominio (vía `fromFormValues`, para poder
/// reutilizar el mismo formulario de Crear) — el resto se queda en JSON
/// crudo tal como se leyó, precisamente para no arriesgar perder
/// información al forzar una reconstrucción tipada que nadie pidió. Un
/// exportador que solo acepta objetos de dominio obligaría a "inventar"
/// un objeto tipado para cada entidad no tocada, con el riesgo de que la
/// reconstrucción no sea perfecta — este puerto evita ese problema de raíz:
/// nunca reconstruye nada que no haya sido editado.
abstract class RawContentPackExporter {
  List<int> export({
    required ILcpManifestData manifest,
    required Map<String, List<Map<String, dynamic>>> content,
  });
}
