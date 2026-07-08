import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/presentation/screens/home/home_screen.dart';
import 'package:lcp_builder/presentation/session/crear_session.dart';

void main() {
  testWidgets('HomeScreen muestra las 3 opciones del plan de fases', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(session: CrearSession())),
    );

    expect(find.text('Crear'), findsOneWidget);
    expect(find.text('Mostrar'), findsOneWidget);
    expect(find.text('Editar'), findsOneWidget);
  });

  testWidgets('Crear navega al menú de Crear', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(session: CrearSession())),
    );

    await tester.tap(find.text('Crear'));
    await tester.pumpAndSettle();

    expect(find.text('Crear arma'), findsOneWidget);
  });

  testWidgets('Mostrar navega a la pantalla de "aún no implementado"', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(session: CrearSession())),
    );

    await tester.tap(find.text('Mostrar'));
    await tester.pumpAndSettle();

    expect(find.text('Aún no se ha implementado.'), findsOneWidget);
  });

  testWidgets('Editar navega a la pantalla de "aún no implementado"', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(session: CrearSession())),
    );

    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    expect(find.text('Aún no se ha implementado.'), findsOneWidget);
  });
}
