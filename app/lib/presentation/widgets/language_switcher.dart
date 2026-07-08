import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../i18n/locale_controller.dart';

/// Selector ES/EN para la esquina superior derecha de cualquier `AppBar` —
/// un único widget reutilizado en todas las pantallas (home, menú Crear,
/// formulario de entidad, placeholder de Mostrar/Editar) en vez de repetir
/// el botón en cada una. Escucha [controller] para resaltar el idioma
/// activo y llama a [LocaleController.setLocale] al elegir el otro.
class LanguageSwitcher extends StatelessWidget {
  final LocaleController controller;

  const LanguageSwitcher({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final current = controller.locale.languageCode;
        return PopupMenuButton<String>(
          tooltip: t.idioma,
          initialValue: current,
          onSelected: (code) => controller.setLocale(Locale(code)),
          icon: const Icon(Icons.language),
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'es', child: Text('Español')),
            PopupMenuItem(value: 'en', child: Text('English')),
          ],
        );
      },
    );
  }
}
