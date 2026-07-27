import 'package:flutter/material.dart';

/// Aviso de error de formulario: un recuadro tintado con el color de error
/// del tema, icono y mensaje — en vez de un texto rojo suelto. Lo comparten
/// las pantallas de Crear y Editar entidad, que muestran el mismo tipo de
/// mensaje ("revisa los campos marcados" o el error de ensamblado).
class FormErrorBanner extends StatelessWidget {
  final String message;

  const FormErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: scheme.onErrorContainer, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
