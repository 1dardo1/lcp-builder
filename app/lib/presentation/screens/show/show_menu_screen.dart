import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../../i18n/locale_controller.dart';
import '../../widgets/language_switcher.dart';
import '../../widgets/nav_option_card.dart';
import '../../widgets/page_body.dart';
import 'lcp_entity_types_screen.dart';
import 'lcp_folder_screen.dart';

/// Punto de entrada del flujo Mostrar: elegir un `.lcp` suelto, o una
/// carpeta con varios (ver `LcpFolderScreen`). `openFile` (para el .lcp
/// suelto) funciona igual en Linux y Android — a diferencia de guardar,
/// abrir no necesita ningún adapter nativo propio (ver
/// `local_file_reader.dart`).
class ShowMenuScreen extends StatelessWidget {
  final LocaleController localeController;

  const ShowMenuScreen({super.key, required this.localeController});

  Future<void> _abrirLcp(BuildContext context) async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'Lancer Content Pack', extensions: ['lcp']),
      ],
    );
    if (file == null || !context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LcpEntityTypesScreen(
          lcpPath: file.path,
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
        builder: (_) => LcpFolderScreen(
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
        title: Text(t.mostrarMenuTitle),
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
