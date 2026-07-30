import 'package:flutter/material.dart';

import '../../../infrastructure/lcp/domain_json_mapper.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../forms/entity_crear_config.dart';
import '../../forms/form_values_from_json.dart';
import '../../forms/generic_form_controller.dart';
import '../../forms/generic_form_view.dart';
import '../../forms/validate_and_scroll.dart';
import '../../i18n/field_translations.dart';
import '../../i18n/locale_controller.dart';
import '../../session/edit_session.dart';
import '../../widgets/form_error_banner.dart';
import '../../widgets/language_switcher.dart';
import '../../widgets/page_body.dart';

/// Pantalla de edición (o creación) de una entidad, dentro del flujo
/// Editar: reutiliza el mismo [GenericFormView]/[EntityCrearConfig] que
/// Crear.
///
/// Dos modos, según si se pasa [index]/[rawEntity] o no:
/// - **Editar** (ambos presentes): el controlador arranca precargado con
///   los datos que ya tenía la entidad (vía `formValuesFromJson`), y
///   "Guardar" sustituye esa misma entidad en [EditSession]
///   (`replaceEntity`).
/// - **Crear** (ambos `null`): el controlador arranca vacío, como en
///   `CreateEntityScreen`, y "Guardar" añade una entidad nueva al final de
///   la lista (`EditSession.addEntity`) en vez de sustituir nada.
///
/// En ambos casos el cambio queda en memoria (`EditSession`), no en disco
/// todavía — el guardado a disco es una acción aparte, ver
/// `EditEntityTypesScreen`.
class EditEntityScreen extends StatefulWidget {
  final EntityCrearConfig config;
  final EditSession session;
  final String lcpPath;
  final String contentKey;
  final int? index;
  final Map<String, dynamic>? rawEntity;
  final LocaleController localeController;

  const EditEntityScreen({
    super.key,
    required this.config,
    required this.session,
    required this.lcpPath,
    required this.contentKey,
    this.index,
    this.rawEntity,
    required this.localeController,
  });

  @override
  State<EditEntityScreen> createState() => _EditEntityScreenState();
}

class _EditEntityScreenState extends State<EditEntityScreen> {
  late final _schema = widget.config.buildSchema();
  late final _controller = GenericFormController(
    initialValues: formValuesFromJson(_schema, widget.rawEntity ?? const {}),
  );
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  void _guardar() {
    if (!validateAndScrollToFirstError(_formKey)) {
      setState(
        () => _errorMessage = AppLocalizations.of(context).revisaCamposMarcados,
      );
      return;
    }
    try {
      _controller.trimTextValues();
      final content = widget.config.fromFormValues(_controller.values);
      final rawJson = entityDataToJson(content);
      final index = widget.index;
      if (index == null) {
        widget.session.addEntity(widget.lcpPath, widget.contentKey, rawJson);
      } else {
        widget.session.replaceEntity(
          widget.lcpPath,
          widget.contentKey,
          index,
          rawJson,
        );
      }
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
      body: PageBody(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            GenericFormView(
              fields: _schema,
              controller: _controller,
              formKey: _formKey,
              locale: locale,
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _guardar, child: Text(t.guardarCambios)),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              FormErrorBanner(message: _errorMessage!),
            ],
          ],
        ),
      ),
    );
  }
}
