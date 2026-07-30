import 'package:flutter/material.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../../forms/crear_entidad_configs.dart';
import '../../i18n/field_translations.dart';
import '../../i18n/locale_controller.dart';
import '../../session/edit_session.dart';
import '../../widgets/language_switcher.dart';
import '../../widgets/page_body.dart';
import 'edit_entity_screen.dart';

/// Lista las 24 entidades registradas (mismo `crearEntidadConfigs` que
/// `CreateMenuScreen`) para elegir de qué tipo crear la primera instancia
/// dentro del `.lcp` de [lcpPath] — a diferencia del botón de crear que ya
/// tiene `EditEntityCardsScreen`, este no exige que el tipo tenga ya
/// alguna entidad: `EditEntityTypesScreen` solo lista tipos con
/// contenido existente, así que sin esta pantalla no habría forma de
/// añadir el primer talento/tag/etc. a un `.lcp` que todavía no tenga
/// ninguno de ese tipo.
class EditChooseTypeScreen extends StatelessWidget {
  final EditSession session;
  final String lcpPath;
  final LocaleController localeController;

  const EditChooseTypeScreen({
    super.key,
    required this.session,
    required this.lcpPath,
    required this.localeController,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = localeController.locale;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.elegirTipoTitle),
        actions: [LanguageSwitcher(controller: localeController)],
      ),
      body: PageBody(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Card(
              child: Column(
                children: [
                  for (var i = 0; i < crearEntidadConfigs.length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    ListTile(
                      title: Text(
                        translateFieldText(
                          crearEntidadConfigs[i].title,
                          locale,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditEntityScreen(
                            config: crearEntidadConfigs[i],
                            session: session,
                            lcpPath: lcpPath,
                            contentKey: crearEntidadConfigs[i].contentKey,
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
    );
  }
}
