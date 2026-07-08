import 'package:flutter/material.dart';

import '../../forms/crear_entidad_configs.dart';
import '../../forms/entity_crear_config.dart';
import '../../forms/generic_form_controller.dart';
import '../../forms/generic_form_view.dart';
import '../../session/crear_session.dart';
import '../../session/finalizar_lcp.dart';

/// Pantalla Crear genérica: una sola implementación para las 24 entidades,
/// parametrizada por [EntityCrearConfig]. Sin diseño de Figma todavía
/// (`vault/UI-UX`): Material por defecto, funcional, no definitivo.
///
/// Dos botones al final del formulario, ambos añaden la entidad ya
/// ensamblada a [session] (no crean un `.lcp` por sí solos):
/// - **Continuar**: `Navigator.pop(context, entity)` — vuelve a la
///   pantalla anterior. Si esta pantalla se abrió desde el menú Crear
///   (creación de nivel superior), esa pantalla anterior es
///   `CrearMenuScreen`, y el usuario puede elegir otra entidad para seguir
///   añadiendo al mismo `.lcp`. Si se abrió como referencia desde OTRA
///   entidad (botón "Crear `referencia`" de un campo, ver
///   `generic_form_view.dart`), esa pantalla anterior es el formulario que
///   pidió la referencia — que sigue viva con sus campos intactos (nunca
///   se destruyó, solo quedó debajo en la pila de `Navigator`) y recibe el
///   id de la entidad recién creada a través del propio valor de retorno
///   de `Navigator.push`.
/// - **Finalizar lcp**: además de añadir la entidad, exporta toda la
///   sesión acumulada (esta entidad y cualquier otra ya añadida antes) en
///   un único archivo — ver `finalizar_lcp.dart`.
class CrearEntidadScreen extends StatefulWidget {
  final EntityCrearConfig config;
  final CrearSession session;

  const CrearEntidadScreen({
    super.key,
    required this.config,
    required this.session,
  });

  @override
  State<CrearEntidadScreen> createState() => _CrearEntidadScreenState();
}

class _CrearEntidadScreenState extends State<CrearEntidadScreen> {
  final _controller = GenericFormController();
  late final _schema = widget.config.buildSchema();
  String? _errorMessage;

  Object? _ensamblar() {
    try {
      final content = widget.config.fromFormValues(_controller.values);
      setState(() => _errorMessage = null);
      return content;
    } catch (e) {
      setState(() => _errorMessage = 'Error: $e');
      return null;
    }
  }

  void _continuar() {
    final content = _ensamblar();
    if (content == null) return;
    widget.session.add(widget.config.contentKey, content);
    Navigator.pop(context, content);
  }

  Future<void> _finalizar() async {
    final content = _ensamblar();
    if (content == null) return;
    await finalizarLcp(
      context,
      widget.session,
      pendingContentKey: widget.config.contentKey,
      pendingContent: content,
    );
  }

  /// Callback que [GenericFormView] invoca cuando el usuario pulsa
  /// "Crear `referencia`" en un campo — resuelve el `EntityCrearConfig` de
  /// esa referencia y navega a crearla, esperando el resultado (el objeto
  /// de dominio ya ensamblado, o `null` si se canceló).
  Future<String?> _onCreateReference(String referenceEntityKey) async {
    final refConfig = crearEntidadConfigsByContentKey[referenceEntityKey];
    if (refConfig == null) return null;
    final created = await Navigator.of(context).push<Object>(
      MaterialPageRoute(
        builder: (_) =>
            CrearEntidadScreen(config: refConfig, session: widget.session),
      ),
    );
    if (created == null) return null;
    return refConfig.idOf(created);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.config.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            GenericFormView(
              fields: _schema,
              controller: _controller,
              onCreateReference: _onCreateReference,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                OutlinedButton(
                  onPressed: _continuar,
                  child: const Text('Continuar'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _finalizar,
                  child: const Text('Finalizar lcp'),
                ),
              ],
            ),
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
