import 'package:flutter/foundation.dart';

/// Estado mutable de un formulario genérico: un árbol de valores, indexado
/// por `key` de [FieldSpec]. Deliberadamente `dynamic` — el motor no conoce
/// el tipo de dominio final, solo lo que cada [FieldSpec] necesita para
/// renderizarse. El ensamblado a un tipo de dominio concreto (`IWeaponData`)
/// vive en el esquema de cada entidad (`weapon_form_schema.dart`), no aquí.
///
/// Las listas (`ListFieldSpec`) y sus ítems anidados se gestionan con estos
/// mismos `get`/`set` genéricos — ver `_FieldContext` en
/// `generic_form_view.dart`, que construye un contexto de lectura/escritura
/// por ítem sin necesitar métodos especiales aquí.
class GenericFormController extends ChangeNotifier {
  final Map<String, dynamic> _values;

  /// [initialValues]: precarga el formulario (Editar) con valores ya
  /// resueltos por `form_values_from_json.dart` — misma forma que
  /// [values], solo que puestos antes del primer build en vez de campo a
  /// campo mientras el usuario escribe.
  GenericFormController({Map<String, dynamic>? initialValues})
    : _values = initialValues == null
          ? {}
          : Map<String, dynamic>.from(initialValues);

  dynamic get(String key) => _values[key];

  void set(String key, dynamic value) {
    _values[key] = value;
    notifyListeners();
  }

  Map<String, dynamic> get values => Map.unmodifiable(_values);

  /// Recorta (`trim`) todos los textos del árbol de valores. Se llama al
  /// Guardar (Crear y Editar), justo antes de ensamblar el dominio, para que
  /// ningún texto —ids incluidos— llegue con espacios sobrantes.
  ///
  /// Nace de #73: un `tg_thrown ` con un espacio al final rompía el tag en
  /// COMP/CON en silencio (compara ids de forma exacta contra el Core). En
  /// vez de recortar campo a campo en cada `xFromFormValues` —que fue justo
  /// lo que dejó el hueco: el mismo campo estaba duplicado en varios sitios—
  /// se hace aquí, el punto único por el que pasan ambos flujos de guardado.
  ///
  /// Recorta in situ (no reconstruye el árbol) a propósito: los ensambladores
  /// castean listas de ítems a `List<Map<String, dynamic>>`, y rehacerlas como
  /// `List<dynamic>` rompería ese cast. Mutar solo los strings de dentro
  /// conserva el tipo en tiempo de ejecución de cada lista.
  void trimTextValues() {
    for (final key in _values.keys.toList()) {
      _values[key] = _deepTrim(_values[key]);
    }
  }

  static dynamic _deepTrim(dynamic value) {
    if (value is String) return value.trim();
    if (value is Map) {
      // Se reconstruye como Map<String, dynamic> (el tipo que esperan todos
      // los `as Map<String, dynamic>?` de los ensambladores).
      final trimmed = <String, dynamic>{};
      value.forEach((k, v) => trimmed[k as String] = _deepTrim(v));
      return trimmed;
    }
    if (value is List) {
      // In situ: conserva el tipo de la lista (p.ej. List<Map<String,
      // dynamic>>) — solo se sustituye cada elemento por su versión recortada.
      for (var i = 0; i < value.length; i++) {
        value[i] = _deepTrim(value[i]);
      }
      return value;
    }
    return value;
  }
}
