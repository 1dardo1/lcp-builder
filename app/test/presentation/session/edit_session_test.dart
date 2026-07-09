import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/domain/domain.dart';
import 'package:lcp_builder/domain/ports/content_pack_reader.dart';
import 'package:lcp_builder/presentation/session/edit_session.dart';

ParsedContentPack _samplePack() => const ParsedContentPack(
  manifest: ILcpManifestData(
    name: 'Paquete',
    author: 'Test',
    description: 'd',
    version: '1.0.0',
  ),
  contentByKey: {
    'weapons': [
      {'id': 'mw_uno', 'name': 'Arma 1'},
      {'id': 'mw_dos', 'name': 'Arma 2'},
    ],
    'manufacturers': [
      {'id': 'GMS', 'name': 'General Manufacturing Systems'},
    ],
  },
);

void main() {
  test('load() registra el paquete sin marcarlo como modificado', () {
    final session = EditSession();
    session.load('/a.lcp', _samplePack());

    expect(session.packFor('/a.lcp'), isNotNull);
    expect(session.isDirty('/a.lcp'), isFalse);
  });

  test('replaceEntity sustituye solo esa entidad, deja el resto intacto', () {
    final session = EditSession();
    session.load('/a.lcp', _samplePack());

    session.replaceEntity('/a.lcp', 'weapons', 0, {
      'id': 'mw_uno',
      'name': 'Arma 1 editada',
    });

    final pack = session.packFor('/a.lcp')!;
    expect(pack.contentByKey['weapons']!.first['name'], 'Arma 1 editada');
    expect(pack.contentByKey['weapons']!.last['name'], 'Arma 2');
    expect(
      pack.contentByKey['manufacturers']!.first['name'],
      'General Manufacturing Systems',
    );
    expect(session.isDirty('/a.lcp'), isTrue);
  });

  test('deleteEntity elimina solo esa entidad', () {
    final session = EditSession();
    session.load('/a.lcp', _samplePack());

    session.deleteEntity('/a.lcp', 'weapons', 0);

    final pack = session.packFor('/a.lcp')!;
    expect(pack.contentByKey['weapons'], hasLength(1));
    expect(pack.contentByKey['weapons']!.first['id'], 'mw_dos');
    expect(session.isDirty('/a.lcp'), isTrue);
  });

  test('markSaved limpia el flag de modificado', () {
    final session = EditSession();
    session.load('/a.lcp', _samplePack());
    session.deleteEntity('/a.lcp', 'weapons', 0);
    expect(session.isDirty('/a.lcp'), isTrue);

    session.markSaved('/a.lcp');

    expect(session.isDirty('/a.lcp'), isFalse);
  });

  test('varios .lcp en la misma sesión no se pisan entre sí', () {
    final session = EditSession();
    session.load('/a.lcp', _samplePack());
    session.load('/b.lcp', _samplePack());

    session.replaceEntity('/a.lcp', 'weapons', 0, {
      'id': 'mw_uno',
      'name': 'Solo en A',
    });

    expect(
      session.packFor('/a.lcp')!.contentByKey['weapons']!.first['name'],
      'Solo en A',
    );
    expect(
      session.packFor('/b.lcp')!.contentByKey['weapons']!.first['name'],
      'Arma 1',
    );
    expect(session.isDirty('/a.lcp'), isTrue);
    expect(session.isDirty('/b.lcp'), isFalse);
    expect(session.dirtyPaths, ['/a.lcp']);
  });

  test('replaceEntity/deleteEntity con índice fuera de rango no rompen, no cambian nada', () {
    final session = EditSession();
    session.load('/a.lcp', _samplePack());

    session.replaceEntity('/a.lcp', 'weapons', 99, {'id': 'x', 'name': 'x'});
    session.deleteEntity('/a.lcp', 'weapons', -1);

    expect(session.packFor('/a.lcp')!.contentByKey['weapons'], hasLength(2));
    expect(session.isDirty('/a.lcp'), isFalse);
  });

  test('operar sobre un path nunca cargado no rompe', () {
    final session = EditSession();
    session.replaceEntity('/nunca.lcp', 'weapons', 0, {'id': 'x', 'name': 'x'});

    expect(session.packFor('/nunca.lcp'), isNull);
    expect(session.isDirty('/nunca.lcp'), isFalse);
  });

  test('replaceManifest actualiza el manifest, deja el contenido intacto', () {
    final session = EditSession();
    session.load('/a.lcp', _samplePack());

    session.replaceManifest(
      '/a.lcp',
      const ILcpManifestData(
        name: 'Nuevo nombre',
        author: 'Test',
        description: 'd',
        version: '1.0.1',
      ),
    );

    final pack = session.packFor('/a.lcp')!;
    expect(pack.manifest.name, 'Nuevo nombre');
    expect(pack.manifest.version, '1.0.1');
    expect(pack.contentByKey['weapons'], hasLength(2));
    expect(session.isDirty('/a.lcp'), isTrue);
  });
}
