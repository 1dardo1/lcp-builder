import 'package:flutter/material.dart';

import '../../session/crear_session.dart';
import '../crear/crear_menu_screen.dart';
import '../no_implementado_screen.dart';

/// Pantalla de inicio: las 3 fases del plan (ver ADR-003 — Crear →
/// Mostrar/localizar → Editar/eliminar). Solo "Crear" navega a una pantalla
/// funcional por ahora; "Mostrar" y "Editar" van a [NoImplementadoScreen]
/// hasta que les toque su turno en el plan de fases.
class HomeScreen extends StatelessWidget {
  final CrearSession session;

  const HomeScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LCP Builder')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Crear'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CrearMenuScreen(session: session),
              ),
            ),
          ),
          ListTile(
            title: const Text('Mostrar'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const NoImplementadoScreen(title: 'Mostrar'),
              ),
            ),
          ),
          ListTile(
            title: const Text('Editar'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const NoImplementadoScreen(title: 'Editar'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
