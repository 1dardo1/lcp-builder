import 'package:flutter/material.dart';

import '../../forms/crear_entidad_configs.dart';
import '../../session/crear_session.dart';
import '../../session/finalizar_lcp.dart';
import 'crear_entidad_screen.dart';

/// Pantalla de inicio del flujo Crear: menú de entidades disponibles. Sin
/// diseño de Figma todavía — Material por defecto, funcional, no
/// definitivo (ver `vault/UI-UX`).
///
/// Además de la lista de entidades, muestra el estado de la sesión de
/// Crear en curso ([CrearSession]) — cuántas entidades se han acumulado ya
/// (de cualquier tipo) para el `.lcp` que se está montando, con un botón
/// para finalizarlo. Escucha la sesión (`ListenableBuilder`) porque vuelve
/// a esta pantalla cada vez que se completa una entidad (botón "Continuar"
/// de `CrearEntidadScreen`), y el resumen debe reflejarlo sin reconstruir
/// la pantalla entera a mano.
class CrearMenuScreen extends StatelessWidget {
  final CrearSession session;

  const CrearMenuScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear')),
      body: ListenableBuilder(
        listenable: session,
        builder: (context, _) => Column(
          children: [
            if (!session.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${session.entityCount} entidad(es) en el .lcp actual',
                      ),
                    ),
                    FilledButton(
                      onPressed: () => finalizarLcp(context, session),
                      child: const Text('Finalizar lcp'),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView(
                children: [
                  for (final config in crearEntidadConfigs)
                    ListTile(
                      title: Text(config.title),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CrearEntidadScreen(
                            config: config,
                            session: session,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
