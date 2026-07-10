import 'package:flutter/material.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../../forms/crear_entidad_configs.dart';
import '../../i18n/field_translations.dart';
import '../../i18n/locale_controller.dart';
import '../../session/edit_session.dart';
import '../../widgets/entity_display_card.dart';
import '../../widgets/language_switcher.dart';
import 'editar_entidad_screen.dart';

/// Lista de entidades de [contentKey] dentro del `.lcp` de [lcpPath], cada
/// una con su [EntityDisplayCard] de solo lectura (misma pieza que
/// Mostrar) más botones de editar/eliminar, y un botón de crear una
/// entidad nueva de este mismo tipo (arriba del todo y también abajo de
/// la lista, para no tener que hacer scroll de vuelta si la lista es
/// larga) — reutiliza `EditarEntidadScreen` en su modo "crear"
/// (`index`/`rawEntity` sin pasar). Escucha [session]
/// (`ListenableBuilder`) porque editar, eliminar o crear una entidad
/// cambia directamente el estado ahí, sin pasar por esta pantalla.
class EditarEntityCardsScreen extends StatelessWidget {
  final EditSession session;
  final String lcpPath;
  final String contentKey;
  final LocaleController localeController;

  const EditarEntityCardsScreen({
    super.key,
    required this.session,
    required this.lcpPath,
    required this.contentKey,
    required this.localeController,
  });

  Future<void> _editar(
    BuildContext context,
    int index,
    Map<String, dynamic> raw,
  ) async {
    final config = crearEntidadConfigsByContentKey[contentKey];
    if (config == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditarEntidadScreen(
          config: config,
          session: session,
          lcpPath: lcpPath,
          contentKey: contentKey,
          index: index,
          rawEntity: raw,
          localeController: localeController,
        ),
      ),
    );
  }

  Future<void> _crear(BuildContext context) async {
    final config = crearEntidadConfigsByContentKey[contentKey];
    if (config == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditarEntidadScreen(
          config: config,
          session: session,
          lcpPath: lcpPath,
          contentKey: contentKey,
          localeController: localeController,
        ),
      ),
    );
  }

  Future<void> _confirmarEliminar(BuildContext context, int index) async {
    final t = AppLocalizations.of(context);
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.confirmarEliminarTitulo),
        content: Text(t.confirmarEliminarMensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(t.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(t.eliminar),
          ),
        ],
      ),
    );
    if (confirmado == true) session.deleteEntity(lcpPath, contentKey, index);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = localeController.locale;
    final config = crearEntidadConfigsByContentKey[contentKey];
    final schema = config?.buildSchema() ?? const [];
    return Scaffold(
      appBar: AppBar(
        title: Text(entityDisplayTitle(contentKey, locale)),
        actions: [LanguageSwitcher(controller: localeController)],
      ),
      body: ListenableBuilder(
        listenable: session,
        builder: (context, _) {
          final entities =
              session.packFor(lcpPath)?.contentByKey[contentKey] ?? const [];
          final crearButton = config == null
              ? null
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton.icon(
                    onPressed: () => _crear(context),
                    icon: const Icon(Icons.add),
                    label: Text(translateFieldText(config.title, locale)),
                  ),
                );
          if (entities.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [Text(t.sinEntidades), ?crearButton],
              ),
            );
          }
          return ListView(
            children: [
              ?crearButton,
              for (var i = 0; i < entities.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EntityDisplayCard(
                        schema: schema,
                        data: entities[i],
                        locale: locale,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            TextButton.icon(
                              onPressed: config == null
                                  ? null
                                  : () => _editar(context, i, entities[i]),
                              icon: const Icon(Icons.edit_outlined),
                              label: Text(t.editar),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => _confirmarEliminar(context, i),
                              icon: const Icon(Icons.delete_outline),
                              label: Text(t.eliminar),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ?crearButton,
            ],
          );
        },
      ),
    );
  }
}
