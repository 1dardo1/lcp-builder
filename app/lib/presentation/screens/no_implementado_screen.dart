import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../i18n/locale_controller.dart';
import '../widgets/language_switcher.dart';

/// Placeholder para las fases todavía sin implementar del plan de fases
/// (ver ADR-003: Crear → Mostrar/localizar → Editar/eliminar) — sustituir
/// por la pantalla real de cada fase cuando le toque su turno.
class NoImplementadoScreen extends StatelessWidget {
  final String title;
  final LocaleController localeController;

  const NoImplementadoScreen({
    super.key,
    required this.title,
    required this.localeController,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [LanguageSwitcher(controller: localeController)],
      ),
      body: Center(child: Text(t.noImplementado)),
    );
  }
}
