import 'package:flutter/material.dart';

import '../../../application/use_cases/mostrar_contenido_use_case.dart';
import '../../../domain/ports/content_pack_reader.dart';
import '../../../infrastructure/file_system/platform_file_reader.dart';
import '../../../infrastructure/lcp/zip_content_pack_reader.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../forms/crear_entidad_configs.dart';
import '../../i18n/locale_controller.dart';
import '../../widgets/language_switcher.dart';
import 'lcp_entity_cards_screen.dart';

/// Lee y parsea el `.lcp` elegido (suelto o desde [LcpFolderScreen]) y
/// lista los tipos de entidad que contiene con su recuento — el manifest
/// da el título de la pantalla.
class LcpEntityTypesScreen extends StatefulWidget {
  final String lcpPath;
  final LocaleController localeController;

  /// Inyectable solo para tests — mismo motivo que
  /// `LcpFolderScreen.listLcpFiles` (ver `finalizarLcp`). En producción
  /// usa siempre `MostrarContenidoUseCase` con los adapters reales de la
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
        MostrarContenidoUseCase(
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
            return Center(
              child: Text(t.errorPrefix(snapshot.error.toString())),
            );
          }
          final parsed = snapshot.data!;
          final entries = parsed.contentByKey.entries
              .where((entry) => entry.value.isNotEmpty)
              .toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  parsed.manifest.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    for (final entry in entries)
                      ListTile(
                        title: Text(entityDisplayTitle(entry.key, locale)),
                        trailing: Text(t.tipoCount(entry.value.length)),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => LcpEntityCardsScreen(
                              contentKey: entry.key,
                              entities: entry.value,
                              localeController: widget.localeController,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
