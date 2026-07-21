import 'package:flutter/material.dart';

import '../../../domain/entities/lcp_manifest_data.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../i18n/locale_controller.dart';
import '../../session/edit_session.dart';
import '../../widgets/language_switcher.dart';

/// Edita el manifest del `.lcp` de [lcpPath] dentro del flujo Editar:
/// nombre, autor, versión y descripción del paquete (los campos que un
/// máster querría tocar), reusando [EditSession.replaceManifest]. El
/// guardado a disco es la misma acción aparte que el resto de Editar
/// (`EditarEntityTypesScreen`, botón "Guardar .lcp") — aquí solo se
/// actualiza el estado en memoria y se marca el `.lcp` como modificado.
///
/// Los campos que esta pantalla no expone (`imageUrl`, `website`,
/// `dependencies`, `v3`, `versionHistory`) se conservan tal cual del
/// manifest original — editar el nombre nunca debe descartar, por
/// ejemplo, las dependencias declaradas de un `.lcp` ajeno que se abrió
/// para retocar.
class EditarManifestScreen extends StatefulWidget {
  final EditSession session;
  final String lcpPath;
  final LocaleController localeController;

  const EditarManifestScreen({
    super.key,
    required this.session,
    required this.lcpPath,
    required this.localeController,
  });

  @override
  State<EditarManifestScreen> createState() => _EditarManifestScreenState();
}

class _EditarManifestScreenState extends State<EditarManifestScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ILcpManifestData _original =
      widget.session.packFor(widget.lcpPath)!.manifest;
  late final _nombre = TextEditingController(text: _original.name);
  late final _autor = TextEditingController(text: _original.author);
  late final _version = TextEditingController(text: _original.version);
  late final _descripcion = TextEditingController(text: _original.description);

  @override
  void dispose() {
    _nombre.dispose();
    _autor.dispose();
    _version.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.session.replaceManifest(
      widget.lcpPath,
      ILcpManifestData(
        name: _nombre.text,
        author: _autor.text,
        version: _version.text,
        description: _descripcion.text,
        // Campos no editados aquí: se conservan del original para no
        // perderlos al guardar (ver doc de la clase).
        imageUrl: _original.imageUrl,
        website: _original.website,
        dependencies: _original.dependencies,
        v3: _original.v3,
        versionHistory: _original.versionHistory,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    String? requerido(String? v) =>
        (v == null || v.trim().isEmpty) ? t.requerido : null;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.editarPaquete),
        actions: [LanguageSwitcher(controller: widget.localeController)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                key: const ValueKey('manifestName'),
                controller: _nombre,
                decoration: InputDecoration(labelText: '${t.nombrePaqueteLabel} *'),
                validator: requerido,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('manifestAuthor'),
                controller: _autor,
                decoration: InputDecoration(labelText: '${t.manifestAutor} *'),
                validator: requerido,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('manifestVersion'),
                controller: _version,
                decoration: InputDecoration(labelText: '${t.manifestVersion} *'),
                validator: requerido,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('manifestDescription'),
                controller: _descripcion,
                decoration: InputDecoration(labelText: t.manifestDescripcion),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _guardar,
                child: Text(t.guardarCambios),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
