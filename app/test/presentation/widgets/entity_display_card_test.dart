import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/presentation/forms/field_spec.dart';
import 'package:lcp_builder/presentation/widgets/entity_display_card.dart';

import '../../support/test_app.dart';

void main() {
  testWidgets('campo obligatorio sin rellenar muestra que falta', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithLocalization(
        const EntityDisplayCard(
          schema: [
            TextFieldSpec(key: 'name', label: 'Nombre', required: true),
          ],
          data: {},
        ),
      ),
    );

    expect(find.text('Falta: Nombre'), findsOneWidget);
  });

  testWidgets('campo opcional sin rellenar no se muestra', (tester) async {
    await tester.pumpWidget(
      wrapWithLocalization(
        const EntityDisplayCard(
          schema: [TextFieldSpec(key: 'quote', label: 'Cita')],
          data: {},
        ),
      ),
    );

    expect(find.textContaining('Cita'), findsNothing);
    expect(find.textContaining('Falta'), findsNothing);
  });

  testWidgets('campo relleno muestra su valor, leyendo por jsonKey', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithLocalization(
        const EntityDisplayCard(
          schema: [
            TextFieldSpec(key: 'licenseId', label: 'ID de licencia', jsonKey: 'license_id'),
          ],
          data: {'license_id': 'ms_everest'},
        ),
      ),
    );

    expect(find.textContaining('ms_everest'), findsOneWidget);
  });

  testWidgets('GroupFieldSpec pinta su etiqueta y recorre sus campos anidados', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithLocalization(
        const EntityDisplayCard(
          schema: [
            GroupFieldSpec(
              key: 'stats',
              label: 'Stats',
              fields: [NumberFieldSpec(key: 'hp', label: 'HP')],
            ),
          ],
          data: {
            'stats': {'hp': 10},
          },
        ),
      ),
    );

    expect(find.text('Stats'), findsOneWidget);
    expect(find.textContaining('10'), findsOneWidget);
  });

  testWidgets('ListFieldSpec se resume como número de elementos, no uno a uno', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithLocalization(
        const EntityDisplayCard(
          schema: [
            ListFieldSpec(
              key: 'traits',
              label: 'Traits',
              itemFields: [TextFieldSpec(key: 'name', label: 'Nombre')],
            ),
          ],
          data: {
            'traits': [
              {'name': 'a'},
              {'name': 'b'},
            ],
          },
        ),
      ),
    );

    expect(find.textContaining('2 elementos'), findsOneWidget);
  });
}
