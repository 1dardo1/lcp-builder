import 'package:flutter/material.dart';

import '../../../application/use_cases/editar_contenido_use_case.dart';
import '../../../application/use_cases/mostrar_contenido_use_case.dart';
import '../../../domain/ports/content_pack_reader.dart';
import '../../../infrastructure/file_system/platform_file_reader.dart';
import '../../../infrastructure/file_system/platform_file_writer.dart';
import '../../../infrastructure/lcp/zip_content_pack_reader.dart';
import '../../../infrastructure/lcp/zip_raw_content_pack_exporter.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../forms/crear_entidad_configs.dart';
import '../../i18n/locale_controller.dart';
import '../../session/edit_session.dart';
import '../../widgets/language_switcher.dart';
import 'editar_entity_cards_screen.dart';

/// Carga (si hace falta) el `.lcp` de [lcpPath] en [session] y lista sus
/// tipos de entidad con recuento — mismo rol que `LcpEntityTypesScreen`
/// de Mostrar, pero:
/// - si [session] ya tiene este `.lcp` cargado (porque el usuario ya
///   entró antes en el mismo procedimiento de Editar y lo dejó con
///   cambios sin guardar), reutiliza ese estado en vez de releerlo del
///   disco — perder esos cambios al volver a entrar sería justo el tipo
///   de pérdida que Editar tiene que evitar.
/// - muestra un botón "Guardar .lcp" cuando este `.lcp` tiene cambios
///   pendientes (`session.isDirty`), que reexporta a la misma ruta.
class EditarEntityTypesScreen extends StatefulWidget {
  final EditSession session;
  final String lcpPath;
  final LocaleController localeController;

  /// Inyectables solo para tests — mismo patrón que el resto de
  /// pantallas de Mostrar/Editar (ver `finalizarLcp`).
  final Future<ParsedContentPack> Function(String lcpPath)? loadContent;
  final Future<void> Function(ParsedContentPack pack, String outputPath)?
  saveContent;

  const EditarEntityTypesScreen({
    super.key,
    required this.session,
    required this.lcpPath,
    required this.localeController,
    this.loadContent,
    this.saveContent,
  });

  @override
  State<EditarEntityTypesScreen> createState() =>
      _EditarEntityTypesScreenState();
}

class _EditarEntityTypesScreenState extends State<EditarEntityTypesScreen> {
  late final Future<void> _ensureLoaded = _load();

  Future<void> _load() async {
    if (widget.session.packFor(widget.lcpPath) != null) return;
    final loadContent =
        widget.loadContent ??
        MostrarContenidoUseCase(
          fileReader: createPlatformFileReader(),
          contentPackReader: ZipContentPackReader(),
        ).call;
    final parsed = await loadContent(widget.lcpPath);
    widget.session.load(widget.lcpPath, parsed);
  }

  Future<void> _guardar() async {
    final pack = widget.session.packFor(widget.lcpPath);
    if (pack == null) return;
    final t = AppLocalizations.of(context);
    final saveContent =
        widget.saveContent ??
        EditarContenidoUseCase(
          exporter: ZipRawContentPackExporter(),
          fileWriter: createPlatformFileWriter(),
        ).call;
    try {
      await saveContent(pack, widget.lcpPath);
      widget.session.markSaved(widget.lcpPath);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.generadoSnackbar(widget.lcpPath))));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.errorPrefix('$e'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = widget.localeController.locale;
    return Scaffold(
      appBar: AppBar(
        actions: [LanguageSwitcher(controller: widget.localeController)],
      ),
      body: FutureBuilder<void>(
        future: _ensureLoaded,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(t.errorPrefix(snapshot.error.toString())),
            );
          }
          return ListenableBuilder(
            listenable: widget.session,
            builder: (context, _) {
              final pack = widget.session.packFor(widget.lcpPath)!;
              final entries = pack.contentByKey.entries
                  .where((entry) => entry.value.isNotEmpty)
                  .toList();
              final dirty = widget.session.isDirty(widget.lcpPath);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            pack.manifest.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        if (dirty)
                          FilledButton(
                            onPressed: _guardar,
                            child: Text(t.guardarLcp),
                          ),
                      ],
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
                                builder: (_) => EditarEntityCardsScreen(
                                  session: widget.session,
                                  lcpPath: widget.lcpPath,
                                  contentKey: entry.key,
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
          );
        },
      ),
    );
  }
}
