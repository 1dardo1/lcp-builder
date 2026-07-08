import 'package:flutter/widgets.dart';

/// Idioma actual de la app (es/en), como `ChangeNotifier` a nivel de app —
/// mismo patrón que `CrearSession`: una única instancia creada en
/// `LcpBuilderApp` y pasada hacia abajo, para que cambiar de idioma en
/// cualquier pantalla reconstruya toda la jerarquía (incluido `MaterialApp
/// .locale`) sin pasar por `setState` local en cada pantalla.
class LocaleController extends ChangeNotifier {
  Locale _locale;

  LocaleController([Locale initial = const Locale('es')]) : _locale = initial;

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }

  void toggle() {
    setLocale(_locale.languageCode == 'es' ? const Locale('en') : const Locale('es'));
  }
}
