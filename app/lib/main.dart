import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/gen/app_localizations.dart';
import 'presentation/i18n/locale_controller.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/session/create_session.dart';
import 'presentation/session/edit_session.dart';
import 'presentation/theme/app_theme.dart';

void main() {
  runApp(LcpBuilderApp());
}

/// Sesión de Crear, sesión de Editar y controlador de idioma: instancias
/// únicas por app, creadas aquí y pasadas por toda la jerarquía de
/// pantallas (ver `CreateSession`/`EditSession`/`LocaleController`) — no
/// puede ser `const` porque las tres son `ChangeNotifier` mutables, así
/// que `LcpBuilderApp` deja de ser un widget const.
///
/// `locale` escucha [localeController] con `ListenableBuilder` envolviendo
/// el propio `MaterialApp`: cambiar de idioma desde cualquier pantalla
/// (selector en la esquina superior derecha, ver `LanguageSwitcher`)
/// reconstruye `MaterialApp` con la nueva `Locale`, que Flutter propaga a
/// `AppLocalizations.of(context)` en toda la jerarquía sin más cableado.
class LcpBuilderApp extends StatelessWidget {
  final CreateSession session;
  final EditSession editSession;
  final LocaleController localeController;

  LcpBuilderApp({super.key})
    : session = CreateSession(),
      editSession = EditSession(),
      localeController = LocaleController();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: localeController,
      builder: (context, _) => MaterialApp(
        title: 'LCP Builder',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        // Arranca en oscuro (estética COMP/CON); el claro queda disponible
        // para quien prefiera el tema del sistema en el futuro.
        themeMode: ThemeMode.dark,
        locale: localeController.locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeScreen(
          session: session,
          editSession: editSession,
          localeController: localeController,
        ),
      ),
    );
  }
}
