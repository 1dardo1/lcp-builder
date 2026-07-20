import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../forms/field_spec.dart';
import '../i18n/field_translations.dart';

/// Tarjeta de solo lectura para una entidad ya ensamblada (Mostrar) — el
/// inverso de `GenericFormView`, reutilizando el mismo [FieldSpec] que ya
/// describe la entidad para Crear (etiqueta, ayuda, obligatoriedad),
/// pero leyendo del JSON crudo por su [FieldSpec.jsonKey] en vez de
/// escribir en un [GenericFormController].
///
/// Reglas (acordadas antes de implementar, ver conversación):
/// - Campo obligatorio sin rellenar → se muestra que falta.
/// - Campo opcional sin rellenar → no se muestra nada.
/// - [ListFieldSpec]/[GroupFieldSpec]: se resumen ("N elementos") o se
///   recorren un nivel (grupo), no se renderiza cada campo de cada ítem
///   de una lista — ver decisión de alcance en la conversación.
/// - [ShapeChoiceFieldSpec]/[CatalogFieldSpec]: su propio `jsonKey` es la
///   única clave real (sus ramas internas son sintéticas, nunca
///   aparecen así en el JSON) — se muestra el valor crudo tal cual.
class EntityDisplayCard extends StatelessWidget {
  final List<FieldSpec> schema;
  final Map<String, dynamic> data;
  final Locale locale;

  const EntityDisplayCard({
    super.key,
    required this.schema,
    required this.data,
    this.locale = const Locale('es'),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildFields(context, schema, data),
        ),
      ),
    );
  }

  List<Widget> _buildFields(
    BuildContext context,
    List<FieldSpec> fields,
    Map<String, dynamic> data,
  ) {
    final rows = <Widget>[];
    for (final field in fields) {
      final value = data[field.jsonKey];
      final present = _isPresent(value);
      if (!present && !field.required) continue;
      rows.add(_buildFieldRow(context, field, value, present));
    }
    return rows;
  }

  Widget _buildFieldRow(
    BuildContext context,
    FieldSpec field,
    dynamic value,
    bool present,
  ) {
    final t = AppLocalizations.of(context);
    final label = translateFieldText(field.label, locale);

    if (!present) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber, size: 16, color: Colors.orange),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                t.campoFaltante(label),
                style: const TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      );
    }

    return switch (field) {
      // Un [GroupFieldSpec] espera un mapa (sus sub-campos), pero el JSON
      // real puede no coincidir con el esquema (un `.lcp` ajeno a este
      // Builder, o una entidad cuyo `jsonKey` de grupo apunta de hecho a
      // una lista). Si el valor no es un mapa, se degrada a resumen en vez
      // de romper toda la tarjeta con un cast fallido — una tarjeta de
      // solo lectura nunca debe tumbar la pantalla por un dato inesperado.
      GroupFieldSpec() when value is Map<String, dynamic> => Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildFields(context, field.fields, value),
              ),
            ),
          ],
        ),
      ),
      ListFieldSpec() when value is List => _textRow(
        label,
        t.nElementos(value.length),
      ),
      _ => _textRow(label, _formatScalar(value)),
    };
  }

  Widget _textRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ],
      ),
    ),
  );

  String _formatScalar(dynamic value) {
    if (value is List) return value.map(_formatScalar).join(', ');
    return value.toString();
  }

  bool _isPresent(dynamic value) {
    if (value == null) return false;
    if (value is String) return value.isNotEmpty;
    if (value is List) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    return true;
  }
}
