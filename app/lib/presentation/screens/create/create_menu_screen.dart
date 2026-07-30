import 'package:flutter/material.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../../forms/create_entity_configs.dart';
import '../../i18n/field_translations.dart';
import '../../i18n/locale_controller.dart';
import '../../session/create_session.dart';
import '../../session/finalizar_lcp.dart';
import '../../widgets/language_switcher.dart';
import '../../widgets/page_body.dart';
import 'create_entity_screen.dart';

/// Pantalla de inicio del flujo Crear: el catálogo de tipos de entidad que
/// se pueden crear, como lista de filas dentro de una tarjeta.
///
/// Además de la lista de entidades, muestra el estado de la sesión de
/// Crear en curso ([CreateSession]) — cuántas entidades se han acumulado ya
/// (de cualquier tipo) para el `.lcp` que se está montando, con un botón
/// para finalizarlo. Escucha la sesión (`ListenableBuilder`) porque vuelve
/// a esta pantalla cada vez que se completa una entidad (botón "Continuar"
/// de `CreateEntityScreen`), y el resumen debe reflejarlo sin reconstruir
/// la pantalla entera a mano.
class CreateMenuScreen extends StatelessWidget {
  final CreateSession session;
  final LocaleController localeController;

  const CreateMenuScreen({
    super.key,
    required this.session,
    required this.localeController,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = localeController.locale;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.crearMenuTitle),
        actions: [LanguageSwitcher(controller: localeController)],
      ),
      body: ListenableBuilder(
        listenable: session,
        builder: (context, _) => PageBody(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              if (!session.isEmpty) ...[
                _SessionSummaryCard(
                  countLabel: t.entidadCount(session.entityCount),
                  finalizarLabel: t.finalizarLcp,
                  onFinalizar: () => finalizarLcp(context, session),
                ),
                const SizedBox(height: 24),
              ],
              _SectionLabel(t.crearMenuPrompt),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    for (var i = 0; i < createEntityConfigs.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      ListTile(
                        title: Text(
                          translateFieldText(
                            createEntityConfigs[i].title,
                            locale,
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CreateEntityScreen(
                              config: createEntityConfigs[i],
                              session: session,
                              localeController: localeController,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Resumen de la sesión de Crear en curso: cuántas entidades se llevan
/// acumuladas para el `.lcp` que se está montando, con el botón de
/// finalizarlo. Se destaca como tarjeta tonal porque es la llamada a la
/// acción ("ya tienes contenido, ciérralo en un .lcp"), no una fila más.
class _SessionSummaryCard extends StatelessWidget {
  final String countLabel;
  final String finalizarLabel;
  final VoidCallback onFinalizar;

  const _SessionSummaryCard({
    required this.countLabel,
    required this.finalizarLabel,
    required this.onFinalizar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      color: scheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.inventory_2_outlined, color: scheme.primary),
            const SizedBox(width: 14),
            Expanded(child: Text(countLabel, style: theme.textTheme.bodyLarge)),
            const SizedBox(width: 12),
            FilledButton(onPressed: onFinalizar, child: Text(finalizarLabel)),
          ],
        ),
      ),
    );
  }
}

/// Etiqueta de sección en versalitas con tracking — el toque "tech" del
/// tema, para separar bloques sin meter una cabecera pesada.
class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
