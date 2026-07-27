import 'package:flutter/material.dart';

/// Tarjeta de navegación reutilizable: icono en un cuadro tintado, título,
/// una línea opcional de descripción y un chevron; toda la tarjeta es
/// pulsable. Es la unidad visual de las pantallas de "elegir una opción" —
/// la home (Crear/Mostrar/Editar) y los menús de Mostrar/Editar (abrir un
/// `.lcp` / abrir una carpeta).
///
/// Se extrajo aquí al aparecer el segundo y tercer consumidor reales (los
/// menús), no por especulación — mismo criterio de "extraer con un consumidor
/// que lo confirma" ya aplicado al paquete de campos comunes del dominio.
class NavOptionCard extends StatelessWidget {
  final IconData icon;

  /// Color del icono y su fondo tintado. Si es `null`, usa el primario del
  /// tema — así los menús pueden dejar todas las opciones en el mismo acento
  /// y la home variar (primario/secundario/terciario) por fase.
  final Color? accent;
  final String title;
  final String? description;
  final VoidCallback onTap;

  const NavOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.accent,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = accent ?? scheme.primary;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleLarge),
                    if (description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        description!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
