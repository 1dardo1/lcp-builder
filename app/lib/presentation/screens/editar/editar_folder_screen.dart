import 'package:flutter/material.dart';

import '../../../domain/ports/content_pack_reader.dart';
import '../../../infrastructure/file_system/platform_lcp_directory_lister.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../i18n/locale_controller.dart';
import '../../session/edit_session.dart';
import '../../widgets/language_switcher.dart';
import '../../widgets/message_placeholder.dart';
import '../../widgets/nav_option_card.dart';
import '../../widgets/page_body.dart';
import 'editar_entity_types_screen.dart';

/// Lista los `.lcp` de la carpeta elegida en `EditarMenuScreen` — mismo
/// rol que `LcpFolderScreen` de Mostrar, pero navegando a
/// `EditarEntityTypesScreen` con [session] para poder editar cualquiera
/// de los `.lcp` de la carpeta en el mismo procedimiento.
class EditarFolderScreen extends StatefulWidget {
  final EditSession session;
  final String directoryPath;
  final LocaleController localeController;

  /// Inyectable solo para tests — ver `LcpFolderScreen.listLcpFiles`.
  final Future<List<String>> Function(String directoryPath)? listLcpFiles;

  /// Mismo motivo, reenviado a `EditarEntityTypesScreen` al navegar tras
  /// elegir un `.lcp` de la lista — ver su propio `loadContent`.
  final Future<ParsedContentPack> Function(String lcpPath)? loadContent;

  const EditarFolderScreen({
    super.key,
    required this.session,
    required this.directoryPath,
    required this.localeController,
    this.listLcpFiles,
    this.loadContent,
  });

  @override
  State<EditarFolderScreen> createState() => _EditarFolderScreenState();
}

class _EditarFolderScreenState extends State<EditarFolderScreen> {
  late final Future<List<String>> _lcpFiles;

  @override
  void initState() {
    super.initState();
    final listLcpFiles =
        widget.listLcpFiles ?? createPlatformLcpDirectoryLister().listLcpFiles;
    _lcpFiles = listLcpFiles(widget.directoryPath);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.abrirCarpeta),
        actions: [LanguageSwitcher(controller: widget.localeController)],
      ),
      body: FutureBuilder<List<String>>(
        future: _lcpFiles,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return MessagePlaceholder(
              icon: Icons.error_outline,
              tone: MessageTone.error,
              message: t.errorPrefix(snapshot.error.toString()),
            );
          }
          final files = snapshot.data!;
          if (files.isEmpty) {
            return MessagePlaceholder(
              icon: Icons.folder_off_outlined,
              message: t.carpetaSinLcp,
            );
          }
          return PageBody(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              itemCount: files.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) => NavOptionCard(
                icon: Icons.description_outlined,
                title: _displayName(files[i]),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EditarEntityTypesScreen(
                      session: widget.session,
                      lcpPath: files[i],
                      localeController: widget.localeController,
                      loadContent: widget.loadContent,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Mismo criterio que `lcp_folder_screen.dart` — ver ese archivo para el
/// porqué de decodificar y trocear por `/`, `\` o `:`.
String _displayName(String path) {
  final decoded = Uri.decodeComponent(path);
  final segments = decoded.split(RegExp(r'[/:\\]'))
    ..removeWhere((s) => s.isEmpty);
  return segments.isNotEmpty ? segments.last : decoded;
}
