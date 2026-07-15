import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../i18n/field_translations.dart';
import 'field_spec.dart';
import 'generic_form_controller.dart';

/// Contexto de lectura/escritura para un nivel del formulario: el nivel
/// superior lee/escribe en el [GenericFormController]; un ítem de
/// [ListFieldSpec] o un [GroupFieldSpec] leen/escriben en su propio mapa.
/// Con esta indirección, el mismo código de `_buildField` sirve en todos
/// los niveles — incluidos [ShapeChoiceFieldSpec]/[CatalogFieldSpec]
/// anidados dentro de una lista o de un grupo (ej. varios `bonuses` por
/// arma, cada uno con su propio catálogo; o `IEffectSaveData` como grupo
/// único dentro de un ítem de `actions`).
class _FieldContext {
  final dynamic Function(String key) get;
  final void Function(String key, dynamic value) set;

  /// Prefijo para construir la `ValueKey` de un campo de este nivel (ej.
  /// `'damage.'` dentro del [GroupFieldSpec] `damage`) — sin esto, dos
  /// grupos hermanos con un campo del mismo nombre (ej. `damage.val` y
  /// `range.val`, ambos con key local `'val'`) producirían dos widgets con
  /// la misma `ValueKey('val')` en el mismo árbol: Flutter no lo rechaza
  /// (no son hermanos directos), pero cualquier `find.byKey`/automatización
  /// de test no puede distinguirlos (ver `crear_entidad_screen_all_configs_test.dart`,
  /// que lo atrapó con weapon mod/frame). No se aplica todavía al mismo
  /// problema dentro de [ListFieldSpec] (ítems repetidos comparten key
  /// local igual) — fuera de alcance de este fix, ver nota en `_itemContext`.
  final String keyPrefix;

  const _FieldContext({
    required this.get,
    required this.set,
    this.keyPrefix = '',
  });
}

/// Motor genérico: interpreta una `List<FieldSpec>` y la pinta como
/// formulario Material, sin saber nada de qué entidad de dominio hay
/// detrás. Es deliberadamente feo (sin diseño de Figma todavía, ver
/// `vault/UI-UX`) — el objetivo de este primer corte es probar que el
/// mecanismo funciona, no la experiencia visual.
///
/// Convención de `key` para campos anidados (ver `field_spec.dart`):
/// - [ShapeChoiceFieldSpec] con `key = 'x'` guarda la rama elegida (el
///   `value` de la [ShapeChoiceOption] activa) en `'x.choice'`; por
///   convención cada opción usa `'x.<value>'` como key de su propio campo
///   (ej. `'x.a'`/`'x.b'` para dos ramas, aunque el número de ramas es
///   libre — ver caso 6 del catálogo, con 3 ramas en `EidolonShardCount`).
/// - [CatalogFieldSpec] con `key = 'x'` espera que `valueFieldFor` use
///   siempre la key `'x.value'`; el id elegido se guarda en `'x.id'`.
/// - [GroupFieldSpec] con `key = 'x'` guarda sus `fields` en un único mapa
///   bajo `'x'` (no una lista); admite anidar los mismos catálogos/shape
///   choices que un ítem de lista.
/// - [MultiEnumFieldSpec] guarda directamente la `List<T>` seleccionada
///   bajo su `key`, sin mapa de ítem (no hay sub-formulario por elemento).
/// - Estas convenciones son relativas al [_FieldContext] activo: dentro de
///   un ítem de [ListFieldSpec] o de un [GroupFieldSpec] son claves
///   propias de ese nivel, no del controlador global.
class GenericFormView extends StatelessWidget {
  final List<FieldSpec> fields;
  final GenericFormController controller;

  /// Clave del `Form` que envuelve el árbol de campos — quien construye
  /// esta pantalla (`CrearEntidadScreen`/`EditarEntidadScreen`) la usa para
  /// llamar a `formKey.currentState!.validate()` antes de ensamblar la
  /// entidad, y así los `validator` de los campos (antes sin efecto: no
  /// había ningún `Form` que los disparara) bloqueen de verdad el envío
  /// con campos obligatorios vacíos.
  final GlobalKey<FormState> formKey;

  /// Idioma activo — traduce `FieldSpec.label`/`helpText`/`patternHint` y
  /// `ShapeChoiceOption.label` en el punto de render (ver
  /// `field_translations.dart`); el texto de ayuda fijo del propio motor
  /// (botones "Ayuda"/"Cerrar"/"Quitar"...) usa `AppLocalizations` en su
  /// lugar, ya que es un conjunto finito de cadenas, no contenido por
  /// entidad. Default `es` para no romper los tests existentes que no lo
  /// pasan explícitamente.
  final Locale locale;

  /// Callback para el botón "Crear `referencia`" de un [TextFieldSpec] con
  /// `referenceEntityKey` — recibe ese key y devuelve el id de la entidad
  /// creada (o `null` si el usuario cancela). El motor no sabe qué pantalla
  /// abrir ni qué es un `EntityCrearConfig`; solo pinta el botón y escribe
  /// el resultado en el campo — quien resuelve la navegación real es
  /// `CrearEntidadScreen`, que sí conoce el registro de configs.
  final Future<String?> Function(String referenceEntityKey)? onCreateReference;

  const GenericFormView({
    super.key,
    required this.fields,
    required this.controller,
    required this.formKey,
    this.locale = const Locale('es'),
    this.onCreateReference,
  });

  String _tr(String text) => translateFieldText(text, locale);

  @override
  Widget build(BuildContext context) {
    final rootContext = _FieldContext(get: controller.get, set: controller.set);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final field in fields)
              _buildField(context, field, rootContext),
          ],
        ),
      ),
    );
  }

  Widget _buildField(BuildContext context, FieldSpec field, _FieldContext ctx) {
    final key = ValueKey('${ctx.keyPrefix}${field.key}');
    final content = switch (field) {
      TextFieldSpec f => _buildText(
        context,
        key,
        f,
        ctx.get(f.key),
        (v) => ctx.set(f.key, v),
      ),
      NumberFieldSpec f => _buildNumber(
        context,
        key,
        f,
        ctx.get(f.key),
        (v) => ctx.set(f.key, v),
      ),
      BoolFieldSpec f => _buildBool(
        key,
        f,
        ctx.get(f.key),
        (v) => ctx.set(f.key, v),
      ),
      EnumFieldSpec f => _buildEnum(
        context,
        key,
        f,
        ctx.get(f.key),
        (v) => ctx.set(f.key, v),
      ),
      PatternTextFieldSpec f => _buildPatternText(
        context,
        key,
        f,
        ctx.get(f.key),
        (v) => ctx.set(f.key, v),
      ),
      ShapeChoiceFieldSpec f => _buildShapeChoice(context, f, ctx),
      CatalogFieldSpec f => _buildCatalog(context, f, ctx),
      ListFieldSpec f => _buildList(context, f, ctx),
      MultiEnumFieldSpec f => _buildMultiEnum(
        key,
        f,
        ctx.get(f.key),
        (v) => ctx.set(f.key, v),
      ),
      GroupFieldSpec f => _buildGroup(context, f, ctx),
    };

    Widget wrapped = field.helpText == null
        ? content
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: content),
              _buildHelpButton(context, _tr(field.helpText!)),
            ],
          );

    if (field is TextFieldSpec &&
        field.referenceEntityKey != null &&
        onCreateReference != null) {
      final t = AppLocalizations.of(context);
      wrapped = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          wrapped,
          TextButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              t.crearReferencia(
                _tr(field.referenceLabel ?? field.referenceEntityKey!),
              ),
            ),
            onPressed: () async {
              final id = await onCreateReference!(field.referenceEntityKey!);
              if (id != null) ctx.set(field.key, id);
            },
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: wrapped,
    );
  }

  Widget _buildHelpButton(BuildContext context, String helpText) {
    final t = AppLocalizations.of(context);
    return IconButton(
      icon: const Icon(Icons.help_outline, size: 18),
      tooltip: t.ayuda,
      onPressed: () => showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          // scrollable: true — algunos helpText son largos de verdad
          // (ej. la referencia de tags/fabricantes del Core de Lancer,
          // ver common_entity_fields.dart), y sin esto el contenido
          // desborda el diálogo en vez de poder desplazarse.
          scrollable: true,
          content: Text(helpText),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(t.cerrar),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildText(
    BuildContext context,
    ValueKey<String> key,
    TextFieldSpec f,
    dynamic current,
    ValueChanged<String> onChanged,
  ) {
    // `TextFormField.initialValue` solo se aplica en la primera
    // construcción del Element — no refleja cambios posteriores del valor
    // "desde fuera" (ej. el botón "Crear <referencia>" escribiendo un id
    // recién creado en el campo). Un `TextEditingController` propio, con
    // key estable por campo, sí se sincroniza en rebuilds posteriores (ver
    // `_ControlledTextField`).
    final t = AppLocalizations.of(context);
    return _ControlledTextField(
      key: key,
      current: current as String?,
      maxLines: f.maxLines,
      labelText: _tr(f.label) + (f.required ? ' *' : ''),
      onChanged: onChanged,
      validator: f.required
          ? (value) => (value == null || value.isEmpty) ? t.requerido : null
          : null,
    );
  }

  Widget _buildNumber(
    BuildContext context,
    ValueKey<String> key,
    NumberFieldSpec f,
    dynamic current,
    ValueChanged<num?> onChanged,
  ) {
    final t = AppLocalizations.of(context);
    return TextFormField(
      key: key,
      initialValue: current?.toString(),
      keyboardType: TextInputType.numberWithOptions(decimal: f.allowDecimal),
      decoration: InputDecoration(
        labelText: _tr(f.label) + (f.required ? ' *' : ''),
      ),
      onChanged: (text) => onChanged(num.tryParse(text)),
      validator: f.required
          ? (value) =>
                (value == null || value.isEmpty) ? t.requerido : null
          : null,
    );
  }

  Widget _buildBool(
    ValueKey<String> key,
    BoolFieldSpec f,
    dynamic current,
    ValueChanged<bool> onChanged,
  ) {
    return CheckboxListTile(
      key: key,
      value: (current as bool?) ?? false,
      title: Text(_tr(f.label)),
      onChanged: (v) => onChanged(v ?? false),
    );
  }

  Widget _buildEnum(
    BuildContext context,
    ValueKey<String> key,
    EnumFieldSpec f,
    dynamic current,
    ValueChanged<dynamic> onChanged,
  ) {
    final t = AppLocalizations.of(context);
    return DropdownButtonFormField(
      key: key,
      initialValue: current,
      decoration: InputDecoration(
        labelText: _tr(f.label) + (f.required ? ' *' : ''),
      ),
      items: [
        for (final option in f.options)
          DropdownMenuItem(value: option, child: Text(f.labelFor(option))),
      ],
      onChanged: onChanged,
      validator: f.required ? (value) => value == null ? t.requerido : null : null,
    );
  }

  Widget _buildPatternText(
    BuildContext context,
    ValueKey<String> key,
    PatternTextFieldSpec f,
    dynamic current,
    ValueChanged<String> onChanged,
  ) {
    final t = AppLocalizations.of(context);
    final hint = _tr(f.patternHint);
    return TextFormField(
      key: key,
      initialValue: current as String?,
      decoration: InputDecoration(
        labelText: _tr(f.label) + (f.required ? ' *' : ''),
        helperText: hint,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return f.required ? t.requerido : null;
        }
        return f.pattern.hasMatch(value) ? null : t.noCoincidePattern(hint);
      },
      onChanged: onChanged,
    );
  }

  Widget _buildShapeChoice(
    BuildContext context,
    ShapeChoiceFieldSpec f,
    _FieldContext ctx,
  ) {
    final choice =
        ctx.get('${f.key}.choice') as String? ?? f.options.first.value;
    final activeOption = f.options.firstWhere(
      (o) => o.value == choice,
      orElse: () => f.options.first,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_tr(f.label), style: Theme.of(context).textTheme.labelLarge),
        SegmentedButton<String>(
          segments: [
            for (final o in f.options)
              ButtonSegment(value: o.value, label: Text(_tr(o.label))),
          ],
          selected: {choice},
          onSelectionChanged: (s) => ctx.set('${f.key}.choice', s.first),
        ),
        if (activeOption.field != null)
          _buildField(context, activeOption.field!, ctx),
      ],
    );
  }

  Widget _buildCatalog(
    BuildContext context,
    CatalogFieldSpec f,
    _FieldContext ctx,
  ) {
    final selectedId = ctx.get('${f.key}.id');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField(
          key: ValueKey('${ctx.keyPrefix}${f.key}.id'),
          initialValue: selectedId,
          decoration: InputDecoration(
            labelText: _tr(f.label) + (f.required ? ' *' : ''),
          ),
          items: [
            for (final id in f.catalogIds)
              DropdownMenuItem(value: id, child: Text(f.labelFor(id))),
          ],
          onChanged: (v) => ctx.set('${f.key}.id', v),
        ),
        if (selectedId != null)
          _buildField(context, f.fieldFor(selectedId), ctx),
      ],
    );
  }

  Widget _buildMultiEnum(
    ValueKey<String> key,
    MultiEnumFieldSpec f,
    dynamic current,
    ValueChanged<List<dynamic>> onChanged,
  ) {
    final selected = (current as List?)?.toSet() ?? {};
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_tr(f.label) + (f.required ? ' *' : '')),
        Wrap(
          spacing: 8,
          children: [
            for (final option in f.options)
              FilterChip(
                key: ValueKey('${key.value}.${option.toString()}'),
                label: Text(f.labelFor(option)),
                selected: selected.contains(option),
                onSelected: (isSelected) {
                  final next = selected.toList();
                  if (isSelected) {
                    next.add(option);
                  } else {
                    next.remove(option);
                  }
                  onChanged(next);
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildGroup(
    BuildContext context,
    GroupFieldSpec f,
    _FieldContext ctx,
  ) {
    final groupCtx = _groupContext(f.key, ctx);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_tr(f.label), style: Theme.of(context).textTheme.labelLarge),
        for (final field in f.fields) _buildField(context, field, groupCtx),
      ],
    );
  }

  /// Contexto de un [GroupFieldSpec]: lee/escribe en el mapa único guardado
  /// bajo `key`, análogo a [_itemContext] pero sin índice de lista (una
  /// sola instancia, no una repetición).
  _FieldContext _groupContext(String key, _FieldContext ctx) {
    Map<String, dynamic> currentValue() =>
        (ctx.get(key) as Map<String, dynamic>?) ?? const {};
    return _FieldContext(
      get: (subKey) => currentValue()[subKey],
      set: (subKey, value) {
        final current = Map<String, dynamic>.from(currentValue());
        current[subKey] = value;
        ctx.set(key, current);
      },
      keyPrefix: '${ctx.keyPrefix}$key.',
    );
  }

  Widget _buildList(BuildContext context, ListFieldSpec f, _FieldContext ctx) {
    final t = AppLocalizations.of(context);
    final items = (ctx.get(f.key) as List<Map<String, dynamic>>?) ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_tr(f.label), style: Theme.of(context).textTheme.labelLarge),
        for (var i = 0; i < items.length; i++)
          Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final itemField in f.itemFields)
                    _buildField(
                      context,
                      itemField,
                      _itemContext(f.key, i, ctx),
                    ),
                  TextButton.icon(
                    onPressed: () => _removeListItem(f.key, i, ctx),
                    icon: const Icon(Icons.delete_outline),
                    label: Text(t.quitar),
                  ),
                ],
              ),
            ),
          ),
        TextButton.icon(
          onPressed: () => _addListItem(f.key, ctx),
          icon: const Icon(Icons.add),
          label: Text(t.anadirCampo(_tr(f.label))),
        ),
      ],
    );
  }

  /// Contexto de un ítem concreto de una lista: lee/escribe en el mapa de
  /// ese ítem, dentro de la lista guardada en `ctx` bajo `listKey`. Las
  /// keys de los campos del ítem (incluidas las de un `Catalog`/`Shape`
  /// anidado) son relativas a este mapa, no al contexto padre.
  _FieldContext _itemContext(String listKey, int index, _FieldContext ctx) {
    List<Map<String, dynamic>> currentItems() =>
        (ctx.get(listKey) as List<Map<String, dynamic>>?) ?? const [];
    return _FieldContext(
      get: (key) => currentItems()[index][key],
      set: (key, value) {
        final items = List<Map<String, dynamic>>.from(
          (ctx.get(listKey) as List<Map<String, dynamic>>?) ?? const [],
        );
        items[index] = {...items[index], key: value};
        ctx.set(listKey, items);
      },
    );
  }

  void _addListItem(String key, _FieldContext ctx) {
    final items = List<Map<String, dynamic>>.from(
      (ctx.get(key) as List<Map<String, dynamic>>?) ?? const [],
    );
    items.add({});
    ctx.set(key, items);
  }

  void _removeListItem(String key, int index, _FieldContext ctx) {
    final items = List<Map<String, dynamic>>.from(
      (ctx.get(key) as List<Map<String, dynamic>>?) ?? const [],
    );
    items.removeAt(index);
    ctx.set(key, items);
  }
}

/// `TextFormField` con un `TextEditingController` propio, sincronizado con
/// [current] en cada rebuild (no solo en el primero, a diferencia de
/// `TextFormField.initialValue`). Necesario para que un valor escrito
/// "desde fuera" del propio campo — ej. el botón "Crear `referencia`"
/// rellenando el id de la entidad recién creada — se refleje en pantalla.
class _ControlledTextField extends StatefulWidget {
  final String? current;
  final int maxLines;
  final String labelText;
  final ValueChanged<String> onChanged;
  final FormFieldValidator<String>? validator;

  const _ControlledTextField({
    super.key,
    required this.current,
    required this.maxLines,
    required this.labelText,
    required this.onChanged,
    this.validator,
  });

  @override
  State<_ControlledTextField> createState() => _ControlledTextFieldState();
}

class _ControlledTextFieldState extends State<_ControlledTextField> {
  late final _controller = TextEditingController(text: widget.current);

  @override
  void didUpdateWidget(covariant _ControlledTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.current != oldWidget.current &&
        widget.current != _controller.text) {
      // Escribir en el controller aquí, en mitad del build del padre,
      // dispara sus listeners de forma síncrona — con el `Form` que ahora
      // envuelve el árbol (ver `GenericFormView.build`), eso incluye
      // `FormFieldState.didChange`, que llama a `setState` sobre el propio
      // `Form` mientras el framework todavía lo está construyendo
      // ("setState() or markNeedsBuild() called during build"). Se pospone
      // al siguiente frame, ya fuera de la fase de build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.text = widget.current ?? '';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      maxLines: widget.maxLines,
      decoration: InputDecoration(labelText: widget.labelText),
      onChanged: widget.onChanged,
      validator: widget.validator,
    );
  }
}
