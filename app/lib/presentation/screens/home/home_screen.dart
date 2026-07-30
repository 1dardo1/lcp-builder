import 'package:flutter/material.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../../i18n/locale_controller.dart';
import '../../session/create_session.dart';
import '../../session/edit_session.dart';
import '../../widgets/language_switcher.dart';
import '../../widgets/nav_option_card.dart';
import '../../widgets/page_body.dart';
import '../create/create_menu_screen.dart';
import '../edit/edit_menu_screen.dart';
import '../show/show_menu_screen.dart';

/// Pantalla de inicio: el punto de entrada del máster (perfil objetivo) al
/// abrir la app. Presenta las 3 fases del plan (ver ADR-003 — Crear →
/// Mostrar/localizar → Editar/eliminar) como tarjetas con icono y una línea
/// de descripción, en vez de una lista pelada, para que quede claro de un
/// vistazo qué hace cada una sin conocimiento técnico previo.
///
/// El contenido se acota a un ancho máximo y se centra: en móvil ocupa todo,
/// pero en las ventanas anchas de escritorio (Windows/macOS/Linux) las
/// tarjetas no se estiran de lado a lado.
class HomeScreen extends StatelessWidget {
  final CreateSession session;
  final EditSession editSession;
  final LocaleController localeController;

  const HomeScreen({
    super.key,
    required this.session,
    required this.editSession,
    required this.localeController,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(actions: [LanguageSwitcher(controller: localeController)]),
      body: PageBody(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _Header(title: t.appTitle, tagline: t.homeTagline),
            const SizedBox(height: 28),
            NavOptionCard(
              icon: Icons.add_box_outlined,
              accent: scheme.primary,
              title: t.homeCrear,
              description: t.homeCrearDesc,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreateMenuScreen(
                    session: session,
                    localeController: localeController,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            NavOptionCard(
              icon: Icons.folder_open_outlined,
              accent: scheme.secondary,
              title: t.homeMostrar,
              description: t.homeMostrarDesc,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      ShowMenuScreen(localeController: localeController),
                ),
              ),
            ),
            const SizedBox(height: 14),
            NavOptionCard(
              icon: Icons.edit_note_outlined,
              accent: scheme.tertiary,
              title: t.homeEditar,
              description: t.homeEditarDesc,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EditMenuScreen(
                    session: editSession,
                    localeController: localeController,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cabecera de marca: una "chapa" con el icono de la app + el título y su
/// eslogan.
class _Header extends StatelessWidget {
  final String title;
  final String tagline;

  const _Header({required this.title, required this.tagline});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: scheme.primary.withValues(alpha: 0.5)),
          ),
          child: Icon(Icons.inventory_2_outlined, color: scheme.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 2),
              Text(
                tagline,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
