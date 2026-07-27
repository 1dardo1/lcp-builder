import 'package:flutter/material.dart';

import '../../../domain/ports/content_pack_reader.dart';
import '../../../infrastructure/file_system/platform_lcp_directory_lister.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../i18n/locale_controller.dart';
import '../../widgets/language_switcher.dart';
import '../../widgets/message_placeholder.dart';
import '../../widgets/nav_option_card.dart';
import '../../widgets/page_body.dart';
import 'lcp_entity_types_screen.dart';

/// Lista los `.lcp` de la carpeta elegida en `MostrarMenuScreen` — un
/// nivel intermedio que solo existe cuando el usuario eligió "carpeta" en
/// vez de un `.lcp` suelto (que va directo a [LcpEntityTypesScreen]).
class LcpFolderScreen extends StatefulWidget {
  final String directoryPath;
  final LocaleController localeController;

  /// Inyectable solo para tests — evita el mismo problema de fiabilidad de
  /// `dart:io` real dentro de `flutter test` ya resuelto en `finalizarLcp`
  /// (ver `presentation/session/finalizar_lcp.dart`). En producción usa
  /// siempre `createPlatformLcpDirectoryLister().listLcpFiles`.
  final Future<List<String>> Function(String directoryPath)? listLcpFiles;

  /// Mismo motivo, reenviado a [LcpEntityTypesScreen] al navegar tras
  /// elegir un `.lcp` de la lista — ver su propio `loadContent`.
  final Future<ParsedContentPack> Function(String lcpPath)? loadContent;

  const LcpFolderScreen({
    super.key,
    required this.directoryPath,
    required this.localeController,
    this.listLcpFiles,
    this.loadContent,
  });

  @override
  State<LcpFolderScreen> createState() => _LcpFolderScreenState();
}

class _LcpFolderScreenState extends State<LcpFolderScreen> {
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
                    builder: (_) => LcpEntityTypesScreen(
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

/// En escritorio (Linux/Windows/macOS) [path] ya es una ruta de archivo
/// real; en Android es una URI `content://` con el nombre codificado en el
/// último segmento tras decodificar (ver `AndroidSafDirectoryLister`). En
/// todos los casos el nombre que le interesa al usuario es el último trozo
/// entre separadores: `/` (POSIX/URI), `\` (Windows) o `:` (segmentos de
/// URI SAF y letra de unidad en Windows).
String _displayName(String path) {
  final decoded = Uri.decodeComponent(path);
  final segments = decoded.split(RegExp(r'[/:\\]'))
    ..removeWhere((s) => s.isEmpty);
  return segments.isNotEmpty ? segments.last : decoded;
}
