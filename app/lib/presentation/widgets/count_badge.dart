import 'package:flutter/material.dart';

/// Pastilla tenue de recuento, a la derecha de una fila (cuántas instancias
/// tiene un tipo de entidad). Toma la etiqueta ya formateada: un número
/// pelado en Mostrar, o el texto completo ("1 entidad") en Editar.
class CountBadge extends StatelessWidget {
  final String label;

  const CountBadge(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
