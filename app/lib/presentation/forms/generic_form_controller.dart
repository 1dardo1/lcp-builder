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
}
