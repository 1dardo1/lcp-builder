import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/presentation/session/crear_session.dart';

void main() {
  group('CrearSession', () {
    test('acumula entidades por contentKey y cuenta el total', () {
      final session = CrearSession();
      expect(session.isEmpty, isTrue);

      session.add('weapons', Object());
      session.add('weapons', Object());
      session.add('frames', Object());

      expect(session.isEmpty, isFalse);
      expect(session.entityCount, 3);
      expect(session.content['weapons'], hasLength(2));
      expect(session.content['frames'], hasLength(1));
    });

    test('notifica a los listeners al añadir', () {
      final session = CrearSession();
      var notified = 0;
      session.addListener(() => notified++);

      session.add('weapons', Object());

      expect(notified, 1);
    });

    test('clear() vacía la sesión y notifica', () {
      final session = CrearSession();
      session.add('weapons', Object());
      var notified = 0;
      session.addListener(() => notified++);

      session.clear();

      expect(session.isEmpty, isTrue);
      expect(session.entityCount, 0);
      expect(notified, 1);
    });
  });
}
