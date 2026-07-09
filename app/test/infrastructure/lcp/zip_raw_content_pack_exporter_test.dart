import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/infrastructure/lcp/zip_content_pack_reader.dart';
import 'package:lcp_builder/infrastructure/lcp/zip_raw_content_pack_exporter.dart';

/// Test de aceptación del lado de escritura de Editar: exporta contenido
/// ya en JSON crudo (sin pasar por ningún objeto de dominio tipado) y
/// confirma que `ZipContentPackReader` lo recupera intacto — el mismo
/// contrato que `ZipContentPackExporter`/`ZipContentPackReader` para
/// Crear, pero sin la reconstrucción tipada de por medio.
void main() {
  test('exporta JSON crudo tal cual, sin tocarlo, y se puede releer', () {
    final exporter = ZipRawContentPackExporter();
    const manifest = ILcpManifestData(
      name: 'Paquete editado',
      author: 'Test',
      description: 'desc',
      version: '1.0.1',
    );

    final bytes = exporter.export(
      manifest: manifest,
      content: {
        'weapons': [
          {'id': 'mw_uno', 'name': 'Arma editada', 'mount': 'Heavy'},
          {'id': 'mw_dos', 'name': 'Arma intacta', 'mount': 'Main'},
        ],
        'manufacturers': [
          {'id': 'GMS', 'name': 'General Manufacturing Systems'},
        ],
      },
    );

    final parsed = ZipContentPackReader().read(bytes);

    expect(parsed.manifest.name, 'Paquete editado');
    expect(parsed.manifest.version, '1.0.1');
    expect(parsed.contentByKey['weapons'], hasLength(2));
    expect(parsed.contentByKey['weapons']!.first['name'], 'Arma editada');
    expect(parsed.contentByKey['weapons']!.last['name'], 'Arma intacta');
    expect(parsed.contentByKey['manufacturers']!.first['id'], 'GMS');
  });
}
