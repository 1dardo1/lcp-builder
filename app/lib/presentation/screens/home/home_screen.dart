import 'package:flutter/material.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../../i18n/locale_controller.dart';
import '../../session/crear_session.dart';
import '../../widgets/language_switcher.dart';
import '../crear/crear_menu_screen.dart';
import '../mostrar/mostrar_menu_screen.dart';
import '../no_implementado_screen.dart';

/// Pantalla de inicio: las 3 fases del plan (ver ADR-003 — Crear →
/// Mostrar/localizar → Editar/eliminar). "Crear" y "Mostrar" navegan a
/// pantallas funcionales; "Editar" va a [NoImplementadoScreen] hasta que
/// le toque su turno en el plan de fases.
class HomeScreen extends StatelessWidget {
  final CrearSession session;
  final LocaleController localeController;

  const HomeScreen({
    super.key,
    required this.session,
    required this.localeController,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.appTitle),
        actions: [LanguageSwitcher(controller: localeController)],
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(t.homeCrear),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CrearMenuScreen(
                  session: session,
                  localeController: localeController,
                ),
              ),
            ),
          ),
          ListTile(
            title: Text(t.homeMostrar),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MostrarMenuScreen(
                  localeController: localeController,
                ),
              ),
            ),
          ),
          ListTile(
            title: Text(t.homeEditar),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => NoImplementadoScreen(
                  title: t.homeEditar,
                  localeController: localeController,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
