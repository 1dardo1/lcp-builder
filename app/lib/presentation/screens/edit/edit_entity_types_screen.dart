import 'package:flutter/material.dart';

import '../../../application/use_cases/edit_content_use_case.dart';
import '../../../application/use_cases/show_content_use_case.dart';
import '../../../domain/ports/content_pack_reader.dart';
import '../../../infrastructure/file_system/platform_file_reader.dart';
import '../../../infrastructure/file_system/platform_file_writer.dart';
import '../../../infrastructure/lcp/zip_content_pack_reader.dart';
import '../../../infrastructure/lcp/zip_raw_content_pack_exporter.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../forms/create_entity_configs.dart';
import '../../i18n/locale_controller.dart';
import '../../session/edit_session.dart';
import '../../widgets/count_badge.dart';
import '../../widgets/language_switcher.dart';
import '../../widgets/message_placeholder.dart';
import '../../widgets/page_body.dart';
import 'edit_choose_type_screen.dart';
import 'edit_entity_cards_screen.dart';
import 'edit_manifest_screen.dart';

/// Adapter real por defecto de [EditEntityTypesScreen.saveContent] —
/// extraído a función propia (en vez de vivir inline en `_guardar()`) para
/// poder darle un tipo estático explícito y así poder probarlo sin montar
/// el widget completo (evita el problema ya documentado de E/S real de
/// `dart:io` dentro de un test de `pump`/`pumpAndSettle`, ver
/// `edit_content_use_case_test.dart`). `EditContentUseCase.call`
/// usa parámetros nombrados; este adapter expone la forma posicional que
/// pide el campo `saveContent` de la pantalla.
Future<void> Function(ParsedContentPack pack, String outputPath)
defaultEditarSaveContent() =>
    (pack, outputPath) => EditContentUseCase(
      exporter: ZipRawContentPackExporter(),
      fileWriter: createPlatformFileWriter(),
    ).call(pack: pack, outputPath: outputPath);

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
class EditEntityTypesScreen extends StatefulWidget {
  final EditSession session;
  final String lcpPath;
  final LocaleController localeController;

  /// Inyectables solo para tests — mismo patrón que el resto de
  /// pantallas de Mostrar/Editar (ver `finalizarLcp`).
  final Future<ParsedContentPack> Function(String lcpPath)? loadContent;
  final Future<void> Function(ParsedContentPack pack, String outputPath)?
  saveContent;

  const EditEntityTypesScreen({
    super.key,
    required this.session,
    required this.lcpPath,
    required this.localeController,
    this.loadContent,
    this.saveContent,
  });

  @override
  State<EditEntityTypesScreen> createState() =>
      _EditEntityTypesScreenState();
}

class _EditEntityTypesScreenState extends State<EditEntityTypesScreen> {
  late final Future<void> _ensureLoaded = _load();

  Future<void> _load() async {
    if (widget.session.packFor(widget.lcpPath) != null) return;
    final loadContent =
        widget.loadContent ??
        ShowContentUseCase(
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
    final saveContent = widget.saveContent ?? defaultEditarSaveContent();
    try {
      await saveContent(pack, widget.lcpPath);
      widget.session.markSaved(widget.lcpPath);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.generadoSnackbar(widget.lcpPath))),
      );
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
            return MessagePlaceholder(
              icon: Icons.error_outline,
              tone: MessageTone.error,
              message: t.errorPrefix(snapshot.error.toString()),
            );
          }
          return ListenableBuilder(
            listenable: widget.session,
            builder: (context, _) {
              final theme = Theme.of(context);
              final pack = widget.session.packFor(widget.lcpPath)!;
              final entries = pack.contentByKey.entries
                  .where((entry) => entry.value.isNotEmpty)
                  .toList();
              final dirty = widget.session.isDirty(widget.lcpPath);
              return PageBody(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pack.manifest.name,
                            style: theme.textTheme.headlineSmall,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: t.editarPaquete,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EditManifestScreen(
                                session: widget.session,
                                lcpPath: widget.lcpPath,
                                localeController: widget.localeController,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Guardar a disco: solo aparece cuando hay cambios sin
                    // guardar; a lo ancho, porque es la acción importante de
                    // esta pantalla en ese momento.
                    if (dirty) ...[
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _guardar,
                        icon: const Icon(Icons.save_outlined),
                        label: Text(t.guardarLcp),
                      ),
                    ],
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditChooseTypeScreen(
                            session: widget.session,
                            lcpPath: widget.lcpPath,
                            localeController: widget.localeController,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.add),
                      label: Text(t.crearTipoNuevo),
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
                              trailing: CountBadge(
                                t.tipoCount(entries[i].value.length),
                              ),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => EditEntityCardsScreen(
                                    session: widget.session,
                                    lcpPath: widget.lcpPath,
                                    contentKey: entries[i].key,
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
          );
        },
      ),
    );
  }
}
