import 'package:flutter/material.dart';

import '../../../infrastructure/lcp/domain_json_mapper.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../forms/entity_crear_config.dart';
import '../../forms/form_values_from_json.dart';
import '../../forms/generic_form_controller.dart';
import '../../forms/generic_form_view.dart';
import '../../i18n/field_translations.dart';
import '../../i18n/locale_controller.dart';
import '../../session/edit_session.dart';
import '../../widgets/language_switcher.dart';

/// Pantalla de edición de una entidad ya existente: reutiliza el mismo
/// [GenericFormView]/[EntityCrearConfig] que Crear, pero el controlador
/// arranca precargado con los datos que ya tenía la entidad (vía
/// `formValuesFromJson` — ver esa auditoría) en vez de vacío.
///
/// A diferencia de `CrearEntidadScreen`, un único botón: "Guardar" no crea
/// una entidad nueva, sustituye la que ya había en [EditSession] (en
/// memoria, no en disco todavía — el guardado a disco es una acción
/// aparte, ver `EditarEntityTypesScreen`).
class EditarEntidadScreen extends StatefulWidget {
  final EntityCrearConfig config;
  final EditSession session;
  final String lcpPath;
  final String contentKey;
  final int index;
  final Map<String, dynamic> rawEntity;
  final LocaleController localeController;

  const EditarEntidadScreen({
    super.key,
    required this.config,
    required this.session,
    required this.lcpPath,
    required this.contentKey,
    required this.index,
    required this.rawEntity,
    required this.localeController,
  });

  @override
  State<EditarEntidadScreen> createState() => _EditarEntidadScreenState();
}

class _EditarEntidadScreenState extends State<EditarEntidadScreen> {
  late final _schema = widget.config.buildSchema();
  late final _controller = GenericFormController(
    initialValues: formValuesFromJson(_schema, widget.rawEntity),
  );
  String? _errorMessage;

  void _guardar() {
    try {
      final content = widget.config.fromFormValues(_controller.values);
      final rawJson = entityDataToJson(content);
      widget.session.replaceEntity(
        widget.lcpPath,
        widget.contentKey,
        widget.index,
        rawJson,
      );
      Navigator.pop(context);
    } catch (e) {
      setState(
        () => _errorMessage = AppLocalizations.of(context).errorPrefix('$e'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = widget.localeController.locale;
    return Scaffold(
      appBar: AppBar(
        title: Text(translateFieldText(widget.config.title, locale)),
        actions: [LanguageSwitcher(controller: widget.localeController)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            GenericFormView(
              fields: _schema,
              controller: _controller,
              locale: locale,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _guardar, child: Text(t.guardarCambios)),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(_errorMessage!),
            ],
          ],
        ),
      ),
    );
  }
}
