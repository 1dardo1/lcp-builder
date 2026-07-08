import 'package:flutter/material.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../../forms/crear_entidad_configs.dart';
import '../../i18n/field_translations.dart';
import '../../i18n/locale_controller.dart';
import '../../session/crear_session.dart';
import '../../session/finalizar_lcp.dart';
import '../../widgets/language_switcher.dart';
import 'crear_entidad_screen.dart';

/// Pantalla de inicio del flujo Crear: menú de entidades disponibles. Sin
/// diseño de Figma todavía — Material por defecto, funcional, no
/// definitivo (ver `vault/UI-UX`).
///
/// Además de la lista de entidades, muestra el estado de la sesión de
/// Crear en curso ([CrearSession]) — cuántas entidades se han acumulado ya
/// (de cualquier tipo) para el `.lcp` que se está montando, con un botón
/// para finalizarlo. Escucha la sesión (`ListenableBuilder`) porque vuelve
/// a esta pantalla cada vez que se completa una entidad (botón "Continuar"
/// de `CrearEntidadScreen`), y el resumen debe reflejarlo sin reconstruir
/// la pantalla entera a mano.
class CrearMenuScreen extends StatelessWidget {
  final CrearSession session;
  final LocaleController localeController;

  const CrearMenuScreen({
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
        builder: (context, _) => Column(
          children: [
            if (!session.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(t.entidadCount(session.entityCount)),
                    ),
                    FilledButton(
                      onPressed: () => finalizarLcp(context, session),
                      child: Text(t.finalizarLcp),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView(
                children: [
                  for (final config in crearEntidadConfigs)
                    ListTile(
                      title: Text(translateFieldText(config.title, locale)),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CrearEntidadScreen(
                            config: config,
                            session: session,
                            localeController: localeController,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
