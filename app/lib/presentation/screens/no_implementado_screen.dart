import 'package:flutter/material.dart';

/// Placeholder para las fases todavía sin implementar del plan de fases
/// (ver ADR-003: Crear → Mostrar/localizar → Editar/eliminar) — sustituir
/// por la pantalla real de cada fase cuando le toque su turno.
class NoImplementadoScreen extends StatelessWidget {
  final String title;

  const NoImplementadoScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(child: Text('Aún no se ha implementado.')),
    );
  }
}
