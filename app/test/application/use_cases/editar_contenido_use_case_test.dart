import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/application/use_cases/crear_contenido_use_case.dart';
import 'package:lcp_builder/application/use_cases/editar_contenido_use_case.dart';
import 'package:lcp_builder/application/use_cases/mostrar_contenido_use_case.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/infrastructure/file_system/local_file_reader.dart';
import 'package:lcp_builder/infrastructure/file_system/local_file_writer.dart';
import 'package:lcp_builder/infrastructure/lcp/zip_content_pack_exporter.dart';
import 'package:lcp_builder/infrastructure/lcp/zip_content_pack_reader.dart';
import 'package:lcp_builder/infrastructure/lcp/zip_raw_content_pack_exporter.dart';
import 'package:lcp_builder/presentation/session/edit_session.dart';

/// Test de aceptación del ciclo completo de Editar: genera un `.lcp` real
/// con dos armas y un fabricante (Crear), lo lee de vuelta (Mostrar),
/// edita SOLO el nombre de una de las armas a través de `EditSession`, lo
/// guarda encima del mismo archivo (Editar) y confirma releyéndolo que:
/// el cambio se aplicó, y todo lo demás — el resto de campos de esa
/// misma arma, el arma no tocada, el fabricante — sigue exactamente
/// igual. Es la prueba directa del requisito "no perder ni los cambios
/// ni la información no tocada".
void main() {
  test(
    'edita el nombre de un arma sin perder el resto de campos ni las otras entidades',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'editar_contenido_use_case_test',
      );
      final path = '${tempDir.path}/paquete.lcp';

      try {
        await CrearContenidoUseCase(
          exporter: ZipContentPackExporter(),
          fileWriter: LocalFileWriter(),
        )(
          content: {
            'weapons': [
              IWeaponData(
                id: 'mw_uno',
                name: 'Nombre original',
                source: 'GMS',
                license: 'GMS Everest',
                licenseId: 'mf_everest',
                licenseLevel: 2,
                effect: 'Efecto original',
                description: 'Descripción original',
                mount: MountType.heavy,
                type: WeaponType.rifle,
                sp: 3,
              ),
              IWeaponData(
                id: 'mw_dos',
                name: 'Arma intacta',
                source: 'GMS',
                license: 'GMS Everest',
                licenseId: 'mf_everest',
                licenseLevel: 0,
                effect: 'e',
                description: 'd',
                mount: MountType.main,
                type: WeaponType.melee,
              ),
            ],
            'manufacturers': const [
              IManufacturerData(
                id: 'GMS',
                name: 'General Manufacturing Systems',
                description: 'd',
                quote: 'q',
                light: '#FFFFFF',
                dark: '#000000',
              ),
            ],
          },
          manifest: const ILcpManifestData(
            name: 'Paquete de prueba',
            author: 'Test',
            description: 'desc',
            version: '1.0.0',
          ),
          outputPath: path,
        );

        final mostrar = MostrarContenidoUseCase(
          fileReader: LocalFileReader(),
          contentPackReader: ZipContentPackReader(),
        );
        final parsed = await mostrar(path);

        final session = EditSession();
        session.load(path, parsed);

        // Edita solo el "name" del primer arma — el resto de sus propios
        // campos (effect/description/mount/sp/...) se copian tal cual del
        // JSON ya leído, no se reinventan.
        final original = Map<String, dynamic>.from(
          session.packFor(path)!.contentByKey['weapons']!.first,
        );
        final edited = {...original, 'name': 'Nombre editado'};
        session.replaceEntity(path, 'weapons', 0, edited);

        expect(session.isDirty(path), isTrue);

        await EditarContenidoUseCase(
          exporter: ZipRawContentPackExporter(),
          fileWriter: LocalFileWriter(),
        )(pack: session.packFor(path)!, outputPath: path);

        session.markSaved(path);
        expect(session.isDirty(path), isFalse);

        final reread = await mostrar(path);
        final weapons = reread.contentByKey['weapons']!;

        expect(weapons.first['name'], 'Nombre editado');
        // Resto de campos de la entidad editada, intactos.
        expect(weapons.first['effect'], 'Efecto original');
        expect(weapons.first['description'], 'Descripción original');
        expect(weapons.first['mount'], 'Heavy');
        expect(weapons.first['sp'], 3);
        // Entidad no tocada, intacta.
        expect(weapons.last['name'], 'Arma intacta');
        // Tipo de entidad no tocado, intacto.
        expect(
          reread.contentByKey['manufacturers']!.first['name'],
          'General Manufacturing Systems',
        );
      } finally {
        await tempDir.delete(recursive: true);
      }
    },
  );
}
