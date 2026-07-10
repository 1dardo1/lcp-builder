import 'package:flutter/material.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../../forms/crear_entidad_configs.dart';
import '../../i18n/field_translations.dart';
import '../../i18n/locale_controller.dart';
import '../../session/edit_session.dart';
import '../../widgets/language_switcher.dart';
import 'editar_entidad_screen.dart';

/// Lista las 24 entidades registradas (mismo `crearEntidadConfigs` que
/// `CrearMenuScreen`) para elegir de qué tipo crear la primera instancia
/// dentro del `.lcp` de [lcpPath] — a diferencia del botón de crear que ya
/// tiene `EditarEntityCardsScreen`, este no exige que el tipo tenga ya
/// alguna entidad: `EditarEntityTypesScreen` solo lista tipos con
/// contenido existente, así que sin esta pantalla no habría forma de
/// añadir el primer talento/tag/etc. a un `.lcp` que todavía no tenga
/// ninguno de ese tipo.
class EditarElegirTipoScreen extends StatelessWidget {
  final EditSession session;
  final String lcpPath;
  final LocaleController localeController;

  const EditarElegirTipoScreen({
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
      body: ListView(
        children: [
          for (final config in crearEntidadConfigs)
            ListTile(
              title: Text(translateFieldText(config.title, locale)),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EditarEntidadScreen(
                    config: config,
                    session: session,
                    lcpPath: lcpPath,
                    contentKey: config.contentKey,
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
