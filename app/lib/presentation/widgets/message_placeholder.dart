import 'package:flutter/material.dart';

/// Estado centrado con icono + mensaje, para pantallas vacías o con error
/// (una carpeta sin `.lcp`, un fallo de lectura...). En vez de un texto
/// suelto en medio de la pantalla. `tone` decide el color del icono:
/// neutro por defecto, o el de error del tema.
enum MessageTone { neutral, error }

class MessagePlaceholder extends StatelessWidget {
  final IconData icon;
  final String message;
  final MessageTone tone;

  const MessagePlaceholder({
    super.key,
    required this.icon,
    required this.message,
    this.tone = MessageTone.neutral,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = tone == MessageTone.error
        ? scheme.error
        : scheme.onSurfaceVariant;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
