import 'package:flutter/foundation.dart';

/// Estado de la sesión de Crear en curso: acumula entidades ya ensambladas
/// (de cualquier tipo — arma, fabricante, frame...) hasta que el usuario
/// pulsa "Finalizar lcp" y se exportan todas juntas en un único `.lcp`.
///
/// Vive en `presentation/` a propósito: es estado de UI efímero de la
/// sesión de edición, no del dominio. Se crea una única instancia en
/// `main.dart` y se pasa por la jerarquía de pantallas (`CrearMenuScreen`,
/// `CrearEntidadScreen`) — mismo criterio que ya se usa para no acoplar el
/// motor genérico a ningún tipo de dominio concreto.
class CrearSession extends ChangeNotifier {
  final Map<String, List<Object>> _content = {};

  /// `contentKey` → entidades ya ensambladas de ese tipo. Misma forma que
  /// espera `ContentPackExporter.export` — no hace falta transformarlo al
  /// finalizar.
  Map<String, List<Object>> get content => Map.unmodifiable(_content);

  int get entityCount =>
      _content.values.fold(0, (total, list) => total + list.length);

  bool get isEmpty => _content.isEmpty;

  void add(String contentKey, Object entity) {
    (_content[contentKey] ??= []).add(entity);
    notifyListeners();
  }

  void clear() {
    _content.clear();
    notifyListeners();
  }
}
