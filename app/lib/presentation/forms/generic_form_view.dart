import 'package:flutter/material.dart';

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
  const _FieldContext({required this.get, required this.set});
}

/// Motor genérico: interpreta una `List<FieldSpec>` y la pinta como
/// formulario Material, sin saber nada de qué entidad de dominio hay
/// detrás. Es deliberadamente feo (sin diseño de Figma todavía, ver
/// `vault/UI-UX`) — el objetivo de este primer corte es probar que el
/// mecanismo funciona, no la experiencia visual.
///
/// Convención de `key` para campos anidados (ver `field_spec.dart`):
/// - [ShapeChoiceFieldSpec] con `key = 'x'` espera que `optionA`/`optionB`
///   usen las keys `'x.a'` / `'x.b'`; la elección se guarda en `'x.choice'`.
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

  const GenericFormView({
    super.key,
    required this.fields,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final rootContext = _FieldContext(get: controller.get, set: controller.set);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final field in fields) _buildField(context, field, rootContext),
        ],
      ),
    );
  }

  Widget _buildField(BuildContext context, FieldSpec field, _FieldContext ctx) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: switch (field) {
        TextFieldSpec f => _buildText(
          f,
          ctx.get(f.key),
          (v) => ctx.set(f.key, v),
        ),
        NumberFieldSpec f => _buildNumber(
          f,
          ctx.get(f.key),
          (v) => ctx.set(f.key, v),
        ),
        BoolFieldSpec f => _buildBool(
          f,
          ctx.get(f.key),
          (v) => ctx.set(f.key, v),
        ),
        EnumFieldSpec f => _buildEnum(
          f,
          ctx.get(f.key),
          (v) => ctx.set(f.key, v),
        ),
        PatternTextFieldSpec f => _buildPatternText(
          f,
          ctx.get(f.key),
          (v) => ctx.set(f.key, v),
        ),
        ShapeChoiceFieldSpec f => _buildShapeChoice(context, f, ctx),
        CatalogFieldSpec f => _buildCatalog(context, f, ctx),
        ListFieldSpec f => _buildList(context, f, ctx),
        MultiEnumFieldSpec f => _buildMultiEnum(
          f,
          ctx.get(f.key),
          (v) => ctx.set(f.key, v),
        ),
        GroupFieldSpec f => _buildGroup(context, f, ctx),
      },
    );
  }

  Widget _buildText(
    TextFieldSpec f,
    dynamic current,
    ValueChanged<String> onChanged,
  ) {
    return TextFormField(
      key: ValueKey(f.key),
      initialValue: current as String?,
      maxLines: f.maxLines,
      decoration: InputDecoration(
        labelText: f.label + (f.required ? ' *' : ''),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildNumber(
    NumberFieldSpec f,
    dynamic current,
    ValueChanged<num?> onChanged,
  ) {
    return TextFormField(
      key: ValueKey(f.key),
      initialValue: current?.toString(),
      keyboardType: TextInputType.numberWithOptions(decimal: f.allowDecimal),
      decoration: InputDecoration(
        labelText: f.label + (f.required ? ' *' : ''),
      ),
      onChanged: (text) => onChanged(num.tryParse(text)),
    );
  }

  Widget _buildBool(
    BoolFieldSpec f,
    dynamic current,
    ValueChanged<bool> onChanged,
  ) {
    return CheckboxListTile(
      key: ValueKey(f.key),
      value: (current as bool?) ?? false,
      title: Text(f.label),
      onChanged: (v) => onChanged(v ?? false),
    );
  }

  Widget _buildEnum(
    EnumFieldSpec f,
    dynamic current,
    ValueChanged<dynamic> onChanged,
  ) {
    return DropdownButtonFormField(
      key: ValueKey(f.key),
      initialValue: current,
      decoration: InputDecoration(
        labelText: f.label + (f.required ? ' *' : ''),
      ),
      items: [
        for (final option in f.options)
          DropdownMenuItem(value: option, child: Text(f.labelFor(option))),
      ],
      onChanged: onChanged,
    );
  }

  Widget _buildPatternText(
    PatternTextFieldSpec f,
    dynamic current,
    ValueChanged<String> onChanged,
  ) {
    return TextFormField(
      key: ValueKey(f.key),
      initialValue: current as String?,
      decoration: InputDecoration(
        labelText: f.label + (f.required ? ' *' : ''),
        helperText: f.patternHint,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return f.required ? 'Requerido' : null;
        }
        return f.pattern.hasMatch(value)
            ? null
            : 'No coincide con: ${f.patternHint}';
      },
      onChanged: onChanged,
    );
  }

  Widget _buildShapeChoice(
    BuildContext context,
    ShapeChoiceFieldSpec f,
    _FieldContext ctx,
  ) {
    final choice = ctx.get('${f.key}.choice') as String? ?? 'A';
    final activeSpec = choice == 'A' ? f.optionA : f.optionB;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(f.label, style: Theme.of(context).textTheme.labelLarge),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(value: 'A', label: Text(f.optionALabel)),
            ButtonSegment(value: 'B', label: Text(f.optionBLabel)),
          ],
          selected: {choice},
          onSelectionChanged: (s) => ctx.set('${f.key}.choice', s.first),
        ),
        _buildField(context, activeSpec, ctx),
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
          key: ValueKey('${f.key}.id'),
          initialValue: selectedId,
          decoration: InputDecoration(
            labelText: f.label + (f.required ? ' *' : ''),
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
    MultiEnumFieldSpec f,
    dynamic current,
    ValueChanged<List<dynamic>> onChanged,
  ) {
    final selected = (current as List?)?.toSet() ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(f.label + (f.required ? ' *' : '')),
        Wrap(
          spacing: 8,
          children: [
            for (final option in f.options)
              FilterChip(
                key: ValueKey('${f.key}.${option.toString()}'),
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
        Text(f.label, style: Theme.of(context).textTheme.labelLarge),
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
    );
  }

  Widget _buildList(BuildContext context, ListFieldSpec f, _FieldContext ctx) {
    final items = (ctx.get(f.key) as List<Map<String, dynamic>>?) ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(f.label, style: Theme.of(context).textTheme.labelLarge),
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
                    label: const Text('Quitar'),
                  ),
                ],
              ),
            ),
          ),
        TextButton.icon(
          onPressed: () => _addListItem(f.key, ctx),
          icon: const Icon(Icons.add),
          label: Text('Añadir ${f.label}'),
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
