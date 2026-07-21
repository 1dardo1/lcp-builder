import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fija en [tester] las métricas de un móvil real (≈1080×2340 físicos,
/// densidad 2.75 → ~393×851 lógicos) en vez del lienzo por defecto de
/// `flutter test` (800×600) o del lienzo gigante 1080×20000 que usa el
/// test de aceptación para que todo quepa sin scroll.
///
/// Ese lienzo gigante es cómodo para automatizar taps, pero esconde justo
/// las realidades de tamaño que sí ve la persona usuaria en su teléfono:
/// overflows, constraints acotadas, y cualquier fallo de layout que solo
/// aparece cuando la pantalla es pequeña de verdad. Estos tests montan las
/// pantallas a tamaño real precisamente para cubrir ese ángulo.
void usePhoneMetrics(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
