import 'package:flutter/foundation.dart';

import '../../domain/entities/lcp_manifest_data.dart';
import '../../domain/ports/content_pack_reader.dart';

/// Estado de la sesión de Editar en curso: mantiene, por cada `.lcp` que
/// el usuario ha abierto durante el procedimiento (uno suelto, o varios
/// si eligió una carpeta), el [ParsedContentPack] con el que trabajar —
/// permitiendo reemplazar o eliminar entidades concretas sin tocar el
/// resto, y sabiendo qué paquetes tienen cambios sin guardar.
///
/// Vive en `presentation/` por el mismo motivo que [CrearSession]: es
/// estado de UI efímero de la sesión de edición, no del dominio. Se crea
/// una única instancia al entrar en el flujo Editar y se pasa por toda su
/// jerarquía de pantallas, para que editar una entidad en un `.lcp` y
/// luego navegar a otro (de la misma carpeta) no pierda lo ya cambiado en
/// el primero — es justo el requisito de "editar varias entidades, de
/// varios tipos y de varios .lcp en el mismo procedimiento" sin perder
/// nada por el camino.
class EditSession extends ChangeNotifier {
  final Map<String, ParsedContentPack> _packs = {};
  final Set<String> _dirtyPaths = {};

  /// Registra (o sustituye) el paquete asociado a [path] — la primera vez
  /// que se abre un `.lcp`, tal cual lo devolvió `MostrarContenidoUseCase`.
  /// No marca el paquete como modificado.
  void load(String path, ParsedContentPack pack) {
    _packs[path] = pack;
    notifyListeners();
  }

  ParsedContentPack? packFor(String path) => _packs[path];

  bool isDirty(String path) => _dirtyPaths.contains(path);

  Iterable<String> get dirtyPaths => _dirtyPaths;

  /// Sustituye la entidad en la posición [index] de `contentByKey[contentKey]`
  /// por [entity] (ya en JSON crudo — ver `entityDataToJson`) dentro del
  /// paquete de [path]. El resto de entidades, de este tipo o de
  /// cualquier otro, no se tocan.
  void replaceEntity(
    String path,
    String contentKey,
    int index,
    Map<String, dynamic> entity,
  ) {
    final pack = _packs[path];
    if (pack == null) return;
    final list = List<Map<String, dynamic>>.from(
      pack.contentByKey[contentKey] ?? const [],
    );
    if (index < 0 || index >= list.length) return;
    list[index] = entity;
    _replaceContentByKey(path, pack, contentKey, list);
  }

  /// Elimina la entidad en la posición [index] de `contentByKey[contentKey]`
  /// dentro del paquete de [path].
  void deleteEntity(String path, String contentKey, int index) {
    final pack = _packs[path];
    if (pack == null) return;
    final list = List<Map<String, dynamic>>.from(
      pack.contentByKey[contentKey] ?? const [],
    );
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    _replaceContentByKey(path, pack, contentKey, list);
  }

  void _replaceContentByKey(
    String path,
    ParsedContentPack pack,
    String contentKey,
    List<Map<String, dynamic>> list,
  ) {
    final contentByKey = Map<String, List<Map<String, dynamic>>>.from(
      pack.contentByKey,
    );
    contentByKey[contentKey] = list;
    _packs[path] = ParsedContentPack(
      manifest: pack.manifest,
      contentByKey: contentByKey,
    );
    _dirtyPaths.add(path);
    notifyListeners();
  }

  /// Actualiza el manifest (nombre/autor/versión...) del paquete de [path].
  void replaceManifest(String path, ILcpManifestData manifest) {
    final pack = _packs[path];
    if (pack == null) return;
    _packs[path] = ParsedContentPack(
      manifest: manifest,
      contentByKey: pack.contentByKey,
    );
    _dirtyPaths.add(path);
    notifyListeners();
  }

  /// Marca [path] como guardado — llamarlo tras exportar con éxito
  /// (`EditarContenidoUseCase`), nunca antes.
  void markSaved(String path) {
    _dirtyPaths.remove(path);
    notifyListeners();
  }
}
