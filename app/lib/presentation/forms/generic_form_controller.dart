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
  final Map<String, dynamic> _values = {};

  dynamic get(String key) => _values[key];

  void set(String key, dynamic value) {
    _values[key] = value;
    notifyListeners();
  }

  Map<String, dynamic> get values => Map.unmodifiable(_values);
}
