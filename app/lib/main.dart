import 'package:flutter/material.dart';

import 'presentation/screens/crear/crear_menu_screen.dart';
import 'presentation/session/crear_session.dart';

void main() {
  runApp(LcpBuilderApp());
}

/// Sesión de Crear: una única instancia por app, creada aquí y pasada por
/// toda la jerarquía de pantallas (ver `CrearSession`) — no puede ser
/// `const` porque `CrearSession` es un `ChangeNotifier` mutable, así que
/// `LcpBuilderApp` deja de ser un widget const.
class LcpBuilderApp extends StatelessWidget {
  final CrearSession session;

  LcpBuilderApp({super.key}) : session = CrearSession();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LCP Builder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: CrearMenuScreen(session: session),
    );
  }
}
