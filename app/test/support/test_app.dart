import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lcp_builder/l10n/gen/app_localizations.dart';
import 'package:lcp_builder/presentation/i18n/locale_controller.dart';

/// Envuelve [home] en un `MaterialApp` con `AppLocalizations` configurado
/// — necesario en cualquier test que monte una pantalla real (no solo
/// `GenericFormView` aislado), ya que `AppLocalizations.of(context)` lanza
/// si no hay delegates/supportedLocales registrados. Evita repetir este
/// boilerplate en cada test file.
///
/// Fuerza `locale: Locale('es')` explícitamente (salvo que se pase
/// [locale]): sin `locale:`, `MaterialApp` resuelve el idioma a partir del
/// locale de la plataforma, que en el entorno de test suele ser `en_US` —
/// los tests que comprueban texto en español (el idioma por defecto de la
/// app, ver `LocaleController`) fallarían al buscar "Continuar" y
/// encontrar "Continue".
///
/// Si se pasa [controller], el `MaterialApp` se envuelve en un
/// `ListenableBuilder` que sigue `controller.locale` (igual que
/// `LcpBuilderApp` en `main.dart`) en vez de fijar `locale` una sola vez —
/// necesario para tests que verifican que el `LanguageSwitcher` cambia el
/// idioma de toda la pantalla en caliente, ya que con un `locale` fijo el
/// `MaterialApp` nunca se enteraría de que `controller` cambió.
Widget wrapWithLocalization(
  Widget home, {
  Locale locale = const Locale('es'),
  LocaleController? controller,
}) {
  if (controller != null) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => MaterialApp(
        locale: controller.locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );
  }
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}
