import '../../domain/domain.dart';
import '../../domain/ports/content_pack_exporter.dart';
import 'domain_json_mapper.dart';
import 'lcp_zip_encoder.dart';

/// Implementa [ContentPackExporter]: produce los bytes de un `.lcp` —
/// un zip de un solo nivel (sin subcarpetas, requisito del formato) con
/// `lcp_manifest.json` y un archivo por tipo de contenido, tal como lo
/// espera COMP/CON.
///
/// El puerto (`ContentPackExporter`) no conoce el tipo concreto de cada
/// entidad, por eso `content` llega como `Object` — el despacho por tipo
/// runtime vive en `entityDataToJson` (`domain_json_mapper.dart`),
/// compartido con el guardado de Editar. El empaquetado zip en sí es
/// común con [ZipRawContentPackExporter] y vive en `encodeLcpZip`.
class ZipContentPackExporter implements ContentPackExporter {
  @override
  List<int> export({
    required ILcpManifestData manifest,
    required Map<String, List<Object>> content,
  }) {
    return encodeLcpZip(
      manifestJson: lcpManifestDataToJson(manifest),
      contentByKey: {
        for (final entry in content.entries)
          entry.key: entry.value.map(entityDataToJson).toList(),
      },
    );
  }
}
