import 'package:flutter/material.dart';

import 'presentation/screens/crear/crear_arma_screen.dart';

void main() {
  runApp(const LcpBuilderApp());
}

class LcpBuilderApp extends StatelessWidget {
  const LcpBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LCP Builder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const CrearArmaScreen(),
    );
  }
}
