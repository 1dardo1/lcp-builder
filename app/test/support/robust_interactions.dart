import 'package:flutter_test/flutter_test.dart';

/// Interacciones robustas para los tests de aceptación, pensadas para
/// sobrevivir tanto a `flutter test` (debug/JIT) como a `flutter drive`
/// (profile/AOT), que difieren en timing y en cómo entregan el foco.
///
/// Se usa `pump()` (un frame) en vez de `pumpAndSettle()` tras enfocar un
/// campo de texto: un `TextField` enfocado tiene el cursor parpadeando —
/// una animación periódica que nunca "asienta" — así que `pumpAndSettle`
/// podría colgarse esperando a que pare. `pump()` avanza un frame sin esa
/// espera.

/// Bombea hasta [tries] frames de [step] cada uno hasta que [finder]
/// encuentre algo, o se agoten los intentos. Devuelve si apareció. Útil
/// cuando un widget (un diálogo, una pantalla nueva) tarda un número
/// indeterminado de frames en construirse en modo profile — más fiable que
/// un único `pumpAndSettle`, y sin riesgo de colgarse con animaciones
/// perpetuas (cursor parpadeante).
Future<bool> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int tries = 60,
  Duration step = const Duration(milliseconds: 100),
}) async {
  for (var i = 0; i < tries; i++) {
    if (finder.evaluate().isNotEmpty) return true;
    await tester.pump(step);
  }
  return finder.evaluate().isNotEmpty;
}

/// Enfoca un campo (tocándolo) antes de escribir en él: en un dispositivo
/// real, `enterText` sobre un campo que no tiene el foco no siempre dispara
/// `onChanged`, así que el valor se ve en pantalla pero no llega al
/// controlador del formulario (bug ya visto en el campo `name` de Editar).
Future<void> focusAndEnterText(
  WidgetTester tester,
  Finder finder,
  String text,
) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
  await tester.enterText(finder, text);
  await tester.pump();
}
