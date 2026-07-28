import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/presentation/forms/validate_and_scroll.dart';

void main() {
  testWidgets(
    'al fallar la validación, desplaza a la vista el primer campo con error y '
    'lo marca',
    (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final formKey = GlobalKey<FormState>();
      const fieldKey = ValueKey('campoObligatorio');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => validateAndScrollToFirstError(formKey),
                      child: const Text('Guardar'),
                    ),
                    // Empuja el campo obligatorio muy por debajo del pliegue.
                    const SizedBox(height: 2000),
                    TextFormField(
                      key: fieldKey,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // De inicio el campo está fuera de pantalla (por debajo de 800px).
      expect(tester.getTopLeft(find.byKey(fieldKey)).dy, greaterThan(800));

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      // Tras guardar con el campo vacío: se ha desplazado hasta él (ya visible)
      // y muestra su error.
      expect(tester.getTopLeft(find.byKey(fieldKey)).dy, lessThan(800));
      expect(find.text('Requerido'), findsOneWidget);
    },
  );

  testWidgets('si la validación pasa, devuelve true y no desplaza', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    late bool result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () =>
                    result = validateAndScrollToFirstError(formKey),
                child: const Text('Guardar'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });
}
