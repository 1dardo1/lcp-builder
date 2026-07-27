import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../../i18n/locale_controller.dart';
import '../../platform/lcp_edit_location.dart';
import '../../session/edit_session.dart';
import '../../widgets/language_switcher.dart';
import '../../widgets/nav_option_card.dart';
import '../../widgets/page_body.dart';
import 'editar_entity_types_screen.dart';
import 'editar_folder_screen.dart';

/// Punto de entrada del flujo Editar — mismo esquema que
/// `MostrarMenuScreen` (elegir un `.lcp` suelto, o una carpeta con
/// varios), pero pasando [session] hacia abajo: una única instancia,
/// creada en `main.dart`, que sobrevive mientras el usuario navegue entre
/// varios `.lcp` sin perder los cambios que todavía no ha guardado.
class EditarMenuScreen extends StatelessWidget {
  final EditSession session;
  final LocaleController localeController;

  const EditarMenuScreen({
    super.key,
    required this.session,
    required this.localeController,
  });

  Future<void> _abrirLcp(BuildContext context) async {
    final path = await pickLcpEditLocation();
    if (path == null || !context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditarEntityTypesScreen(
          session: session,
          lcpPath: path,
          localeController: localeController,
        ),
      ),
    );
  }

  Future<void> _abrirCarpeta(BuildContext context) async {
    final directoryPath = await getDirectoryPath();
    if (directoryPath == null || !context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditarFolderScreen(
          session: session,
          directoryPath: directoryPath,
          localeController: localeController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.homeEditar),
        actions: [LanguageSwitcher(controller: localeController)],
      ),
      body: PageBody(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            NavOptionCard(
              icon: Icons.description_outlined,
              title: t.abrirLcp,
              description: t.abrirLcpDesc,
              onTap: () => _abrirLcp(context),
            ),
            const SizedBox(height: 14),
            NavOptionCard(
              icon: Icons.folder_outlined,
              title: t.abrirCarpeta,
              description: t.abrirCarpetaDesc,
              onTap: () => _abrirCarpeta(context),
            ),
          ],
        ),
      ),
    );
  }
}
