import 'package:flutter/material.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../../i18n/locale_controller.dart';
import '../../session/crear_session.dart';
import '../../session/edit_session.dart';
import '../../widgets/language_switcher.dart';
import '../crear/crear_menu_screen.dart';
import '../editar/editar_menu_screen.dart';
import '../mostrar/mostrar_menu_screen.dart';

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
  final CrearSession session;
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
      appBar: AppBar(
        actions: [LanguageSwitcher(controller: localeController)],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                _Header(title: t.appTitle, tagline: t.homeTagline),
                const SizedBox(height: 28),
                _PhaseCard(
                  icon: Icons.add_box_outlined,
                  accent: scheme.primary,
                  title: t.homeCrear,
                  description: t.homeCrearDesc,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CrearMenuScreen(
                        session: session,
                        localeController: localeController,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _PhaseCard(
                  icon: Icons.folder_open_outlined,
                  accent: scheme.secondary,
                  title: t.homeMostrar,
                  description: t.homeMostrarDesc,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MostrarMenuScreen(
                        localeController: localeController,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _PhaseCard(
                  icon: Icons.edit_note_outlined,
                  accent: scheme.tertiary,
                  title: t.homeEditar,
                  description: t.homeEditarDesc,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditarMenuScreen(
                        session: editSession,
                        localeController: localeController,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
            border: Border.all(
              color: scheme.primary.withValues(alpha: 0.5),
            ),
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

/// Tarjeta de una fase: icono en un cuadro tintado, título, descripción y un
/// chevron. Toda la tarjeta es pulsable.
class _PhaseCard extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _PhaseCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
