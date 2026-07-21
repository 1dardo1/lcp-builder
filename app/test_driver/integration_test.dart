import 'package:integration_test/integration_test_driver.dart';

/// Driver estándar de `integration_test` para poder correr los tests de
/// aceptación con `flutter drive` en modo **profile** (AOT + tree-shaking),
/// no solo con `flutter test` (que siempre compila JIT/debug). Es la única
/// forma de ejercitar la app en un modo cercano al release que instala la
/// persona usuaria — donde aparecen fallos que el debug esconde (un widget
/// que revienta al construirse muestra el `ErrorWidget` gris en release, no
/// la pantalla roja de debug; ver la clase de bug de la pantalla gris al
/// editar). No lleva lógica propia: toda la aserción vive en el `target`
/// (`integration_test/*.dart`).
Future<void> main() => integrationDriver();
