import 'package:flutter/foundation.dart';

/// Estado mutable de un formulario genérico: un árbol de valores, indexado
/// por `key` de [FieldSpec]. Deliberadamente `dynamic` — el motor no conoce
/// el tipo de dominio final, solo lo que cada [FieldSpec] necesita para
/// renderizarse. El ensamblado a un tipo de dominio concreto (`IWeaponData`)
/// vive en el esquema de cada entidad (`weapon_form_schema.dart`), no aquí.
class GenericFormController extends ChangeNotifier {
  final Map<String, dynamic> _values = {};

  dynamic get(String key) => _values[key];

  void set(String key, dynamic value) {
    _values[key] = value;
    notifyListeners();
  }

  List<Map<String, dynamic>> listValues(String key) =>
      (_values[key] as List<Map<String, dynamic>>?) ?? const [];

  void addListItem(String key) {
    final list = List<Map<String, dynamic>>.from(listValues(key));
    list.add({});
    _values[key] = list;
    notifyListeners();
  }

  void removeListItem(String key, int index) {
    final list = List<Map<String, dynamic>>.from(listValues(key));
    list.removeAt(index);
    _values[key] = list;
    notifyListeners();
  }

  void setListItemValue(String key, int index, String itemKey, dynamic value) {
    final list = List<Map<String, dynamic>>.from(listValues(key));
    list[index] = {...list[index], itemKey: value};
    _values[key] = list;
    notifyListeners();
  }

  Map<String, dynamic> get values => Map.unmodifiable(_values);
}
