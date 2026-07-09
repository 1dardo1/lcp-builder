import 'package:flutter/material.dart';

import '../../forms/crear_entidad_configs.dart';
import '../../i18n/locale_controller.dart';
import '../../widgets/entity_display_card.dart';
import '../../widgets/language_switcher.dart';

/// Última pantalla del flujo Mostrar: una [EntityDisplayCard] por cada
/// instancia de [contentKey] encontrada en el `.lcp`, reutilizando el
/// mismo esquema (`EntityCrearConfig.buildSchema`) que ya describe esta
/// entidad para Crear.
class LcpEntityCardsScreen extends StatelessWidget {
  final String contentKey;
  final List<Map<String, dynamic>> entities;
  final LocaleController localeController;

  const LcpEntityCardsScreen({
    super.key,
    required this.contentKey,
    required this.entities,
    required this.localeController,
  });

  @override
  Widget build(BuildContext context) {
    final locale = localeController.locale;
    final config = crearEntidadConfigsByContentKey[contentKey];
    final schema = config?.buildSchema() ?? const [];
    return Scaffold(
      appBar: AppBar(
        title: Text(entityDisplayTitle(contentKey, locale)),
        actions: [LanguageSwitcher(controller: localeController)],
      ),
      body: ListView(
        children: [
          for (final entity in entities)
            EntityDisplayCard(schema: schema, data: entity, locale: locale),
        ],
      ),
    );
  }
}
