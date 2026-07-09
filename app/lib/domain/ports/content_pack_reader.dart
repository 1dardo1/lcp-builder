import '../entities/lcp_manifest_data.dart';

/// Puerto hexagonal, inverso de [ContentPackExporter]: interpreta los
/// bytes de un `.lcp` ya existente para el flujo Mostrar.
///
/// Deliberadamente NO reconstruye los 24 tipos de dominio de cada
/// entidad — Mostrar solo necesita leer y pintar lo que hay, no operar
/// sobre ello (a diferencia de Crear, que sí necesita el tipo real para
/// poder ensamblarlo y volver a exportarlo), así que el contenido por
/// tipo de entidad se queda en JSON crudo. El manifest sí se tipa
/// completo — las pantallas de listado lo necesitan tal cual (nombre del
/// paquete, autor...), y es un único tipo, no 24.
abstract class ContentPackReader {
  ParsedContentPack read(List<int> bytes);
}

/// Resultado de leer un `.lcp`: el manifest tipado, y el resto del
/// contenido indexado por `contentKey` (mismo nombre que el archivo
/// dentro del zip, sin `.json` — ej. `'weapons'`), cada entidad todavía
/// como el `Map<String, dynamic>` tal cual venía en el JSON.
class ParsedContentPack {
  final ILcpManifestData manifest;
  final Map<String, List<Map<String, dynamic>>> contentByKey;

  const ParsedContentPack({
    required this.manifest,
    required this.contentByKey,
  });
}
