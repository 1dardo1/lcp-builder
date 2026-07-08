import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcp_builder/presentation/i18n/field_translations.dart';

/// Prueba directa de `translateFieldText`, sin montar ningún widget — el
/// resto de la cobertura de este diccionario es indirecta (a través de
/// `GenericFormView`/pantallas), pero el contrato de la propia función
/// (nunca dejar un campo en blanco, no tocar el español) no tenía ningún
/// test unitario propio.
void main() {
  group('translateFieldText', () {
    test('con locale es, devuelve el texto sin tocar aunque haya entrada '
        'en el diccionario', () {
      expect(
        translateFieldText('Fabricante (source)', const Locale('es')),
        'Fabricante (source)',
      );
    });

    test('con locale en, devuelve la traducción cuando existe en el '
        'diccionario', () {
      expect(
        translateFieldText('Fabricante (source)', const Locale('en')),
        'Manufacturer (source)',
      );
    });

    test('con locale en, un texto sin traducción se devuelve tal cual '
        '(nunca en blanco)', () {
      const sinTraducir = 'Este texto no está en el diccionario';
      expect(
        translateFieldText(sinTraducir, const Locale('en')),
        sinTraducir,
      );
    });

    test('un locale en distinto (p. ej. en_GB) también traduce', () {
      expect(
        translateFieldText('Fabricante (source)', const Locale('en', 'GB')),
        'Manufacturer (source)',
      );
    });
  });
}
