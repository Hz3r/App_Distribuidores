import 'package:flutter_test/flutter_test.dart';
import 'package:panel_web/src/shared/formato.dart';

void main() {
  group('parsearSoles', () {
    test('acepta las formas usuales y devuelve céntimos', () {
      const casos = {
        '62.90': 6290,
        '62.9': 6290,
        '62': 6200,
        '0': 0,
        '0.05': 5,
        '62,90': 6290,
        'S/ 62.90': 6290,
        's/62.90': 6290,
        ' 1 234.50 ': 123450,
        '1,234.50': 123450,
        '1,234': 123400,
        '1,234,567': 123456700,
        '19.99': 1999,
      };
      casos.forEach((texto, centimos) {
        expect(parsearSoles(texto), centimos, reason: texto);
      });
    });

    test('rechaza lo que no es un monto', () {
      for (final texto in [
        '',
        '   ',
        'S/',
        'abc',
        '-5',
        '62.905',
        '62.9.0',
        '1,23,4',
        '12,3456',
        '.50',
        '1e3',
        '12345678901',
      ]) {
        expect(parsearSoles(texto), isNull, reason: '"$texto"');
      }
    });
  });

  test('solesEditables muestra siempre dos decimales, sin símbolo', () {
    expect(solesEditables(6290), '62.90');
    expect(solesEditables(5), '0.05');
    expect(solesEditables(120000), '1200.00');
    expect(parsearSoles(solesEditables(123456)), 123456);
  });

  test('parsearEntero solo acepta enteros no negativos de hasta 9 cifras', () {
    expect(parsearEntero(' 120 '), 120);
    expect(parsearEntero('0'), 0);
    for (final texto in ['', '-1', '1.5', '12a', '1234567890']) {
      expect(parsearEntero(texto), isNull, reason: '"$texto"');
    }
  });

  test('pluralDe y cantidadConUnidad', () {
    expect(pluralDe('botella'), 'botellas');
    expect(pluralDe('unidad'), 'unidades');
    expect(pluralDe('kg'), 'kg');
    expect(pluralDe('packs'), 'packs');
    expect(cantidadConUnidad(1, 'botella'), '1 botella');
    expect(cantidadConUnidad(12, 'botella'), '12 botellas');
    expect(cantidadConUnidad(0, 'unidad'), '0 unidades');
    expect(cantidadConUnidad(5, ''), '5');
  });
}
