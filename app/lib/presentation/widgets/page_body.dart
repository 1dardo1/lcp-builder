import 'package:flutter/material.dart';

/// Envoltorio de cuerpo de pantalla: `SafeArea` + centrado + ancho máximo.
/// En móvil el contenido ocupa todo; en las ventanas anchas de escritorio
/// (Windows/macOS/Linux) se acota y se centra en vez de estirarse de lado a
/// lado. Un único sitio para ese criterio, en vez de repetir el
/// `Center`/`ConstrainedBox` en cada pantalla.
class PageBody extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const PageBody({super.key, required this.child, this.maxWidth = 560});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
