import 'package:flutter/material.dart';

import 'field_spec.dart';
import 'generic_form_controller.dart';

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
/// - Dentro de [ListFieldSpec] solo se soportan campos simples (Text,
///   Number, Bool, Enum) en esta primera versión — anidar otro
///   Shape/Catalog/List dentro de una lista queda pendiente.
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
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final field in fields) _buildTopLevelField(context, field),
        ],
      ),
    );
  }

  Widget _buildTopLevelField(BuildContext context, FieldSpec field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: switch (field) {
        TextFieldSpec f => _buildText(
          f,
          controller.get(f.key),
          (v) => controller.set(f.key, v),
        ),
        NumberFieldSpec f => _buildNumber(
          f,
          controller.get(f.key),
          (v) => controller.set(f.key, v),
        ),
        BoolFieldSpec f => _buildBool(
          f,
          controller.get(f.key),
          (v) => controller.set(f.key, v),
        ),
        EnumFieldSpec f => _buildEnum(
          f,
          controller.get(f.key),
          (v) => controller.set(f.key, v),
        ),
        PatternTextFieldSpec f => _buildPatternText(
          f,
          controller.get(f.key),
          (v) => controller.set(f.key, v),
        ),
        ShapeChoiceFieldSpec f => _buildShapeChoice(context, f),
        CatalogFieldSpec f => _buildCatalog(context, f),
        ListFieldSpec f => _buildList(context, f),
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

  Widget _buildShapeChoice(BuildContext context, ShapeChoiceFieldSpec f) {
    final choice = controller.get('${f.key}.choice') as String? ?? 'A';
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
          onSelectionChanged: (s) => controller.set('${f.key}.choice', s.first),
        ),
        _buildTopLevelField(context, activeSpec),
      ],
    );
  }

  Widget _buildCatalog(BuildContext context, CatalogFieldSpec f) {
    final selectedId = controller.get('${f.key}.id');
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
          onChanged: (v) => controller.set('${f.key}.id', v),
        ),
        if (selectedId != null)
          _buildTopLevelField(context, f.fieldFor(selectedId)),
      ],
    );
  }

  Widget _buildList(BuildContext context, ListFieldSpec f) {
    final items = controller.listValues(f.key);
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
                    _buildListItemField(f.key, i, itemField, items[i]),
                  TextButton.icon(
                    onPressed: () => controller.removeListItem(f.key, i),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Quitar'),
                  ),
                ],
              ),
            ),
          ),
        TextButton.icon(
          onPressed: () => controller.addListItem(f.key),
          icon: const Icon(Icons.add),
          label: Text('Añadir ${f.label}'),
        ),
      ],
    );
  }

  Widget _buildListItemField(
    String listKey,
    int index,
    FieldSpec itemField,
    Map<String, dynamic> itemValues,
  ) {
    final current = itemValues[itemField.key];
    void onChanged(dynamic v) =>
        controller.setListItemValue(listKey, index, itemField.key, v);

    return switch (itemField) {
      TextFieldSpec f => _buildText(f, current, onChanged),
      NumberFieldSpec f => _buildNumber(f, current, onChanged),
      BoolFieldSpec f => _buildBool(f, current, onChanged),
      EnumFieldSpec f => _buildEnum(f, current, onChanged),
      PatternTextFieldSpec f => _buildPatternText(f, current, onChanged),
      ShapeChoiceFieldSpec() || CatalogFieldSpec() || ListFieldSpec() =>
        const Text('Anidación no soportada todavía dentro de una lista'),
    };
  }
}
