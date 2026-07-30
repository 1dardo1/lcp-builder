import 'package:flutter/material.dart';

import '../../../application/use_cases/show_content_use_case.dart';
import '../../../domain/ports/content_pack_reader.dart';
import '../../../infrastructure/file_system/platform_file_reader.dart';
import '../../../infrastructure/lcp/zip_content_pack_reader.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../forms/create_entity_configs.dart';
import '../../i18n/locale_controller.dart';
import '../../widgets/count_badge.dart';
import '../../widgets/language_switcher.dart';
import '../../widgets/message_placeholder.dart';
import '../../widgets/page_body.dart';
import 'lcp_entity_cards_screen.dart';

/// Lee y parsea el `.lcp` elegido (suelto o desde [LcpFolderScreen]) y
/// lista los tipos de entidad que contiene con su recuento — el manifest
/// da el título de la pantalla.
class LcpEntityTypesScreen extends StatefulWidget {
  final String lcpPath;
  final LocaleController localeController;

  /// Inyectable solo para tests — mismo motivo que
  /// `LcpFolderScreen.listLcpFiles` (ver `finalizarLcp`). En producción
  /// usa siempre `ShowContentUseCase` con los adapters reales de la
  /// plataforma.
  final Future<ParsedContentPack> Function(String lcpPath)? loadContent;

  const LcpEntityTypesScreen({
    super.key,
    required this.lcpPath,
    required this.localeController,
    this.loadContent,
  });

  @override
  State<LcpEntityTypesScreen> createState() => _LcpEntityTypesScreenState();
}

class _LcpEntityTypesScreenState extends State<LcpEntityTypesScreen> {
  late final Future<ParsedContentPack> _parsed;

  @override
  void initState() {
    super.initState();
    final loadContent =
        widget.loadContent ??
        ShowContentUseCase(
          fileReader: createPlatformFileReader(),
          contentPackReader: ZipContentPackReader(),
        ).call;
    _parsed = loadContent(widget.lcpPath);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = widget.localeController.locale;
    return Scaffold(
      appBar: AppBar(
        actions: [LanguageSwitcher(controller: widget.localeController)],
      ),
      body: FutureBuilder<ParsedContentPack>(
        future: _parsed,
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
          final parsed = snapshot.data!;
          final entries = parsed.contentByKey.entries
              .where((entry) => entry.value.isNotEmpty)
              .toList();
          final theme = Theme.of(context);
          return PageBody(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Text(
                  parsed.manifest.name,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      for (var i = 0; i < entries.length; i++) ...[
                        if (i > 0) const Divider(height: 1),
                        ListTile(
                          title: Text(
                            entityDisplayTitle(entries[i].key, locale),
                          ),
                          trailing: CountBadge('${entries[i].value.length}'),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => LcpEntityCardsScreen(
                                contentKey: entries[i].key,
                                entities: entries[i].value,
                                localeController: widget.localeController,
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
          );
        },
      ),
    );
  }
}
