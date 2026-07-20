import '../../domain/domain.dart';
import '../../domain/ports/raw_content_pack_exporter.dart';
import 'domain_json_mapper.dart';
import 'lcp_zip_encoder.dart';

/// Implementa [RawContentPackExporter]: mismo formato de `.lcp` que
/// [ZipContentPackExporter] (zip de un solo nivel, `lcp_manifest.json` +
/// un archivo por tipo de contenido, empaquetado por `encodeLcpZip`), pero
/// el contenido ya viene en JSON crudo — no hay ningún despacho por tipo
/// de dominio que hacer, cada entidad se escribe tal cual.
class ZipRawContentPackExporter implements RawContentPackExporter {
  @override
  List<int> export({
    required ILcpManifestData manifest,
    required Map<String, List<Map<String, dynamic>>> content,
  }) {
    return encodeLcpZip(
      manifestJson: lcpManifestDataToJson(manifest),
      contentByKey: content,
    );
  }
}
