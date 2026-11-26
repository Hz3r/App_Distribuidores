import 'package:app_movil/src/features/registro/domain/codigo_invitacion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizarCodigo', () {
    test('quita espacios y guiones y pasa a mayúsculas', () {
      expect(normalizarCodigo('ab2c-d3e4 '), 'AB2CD3E4');
    });

    test('quita los espacios de en medio', () {
      expect(normalizarCodigo(' a b '), 'AB');
    });

    test('corta al largo del código', () {
      expect(normalizarCodigo('ABCDEFGH23'), 'ABCDEFGH');
    });

    test('una entrada vacía queda vacía', () {
      expect(normalizarCodigo(''), '');
      expect(normalizarCodigo(' - '), '');
    });
  });

  test('codigoCompleto solo con $largoCodigo caracteres', () {
    expect(codigoCompleto(''), isFalse);
    expect(codigoCompleto('AB2CD3E'), isFalse);
    expect(codigoCompleto('AB2CD3E4'), isTrue);
    expect(codigoCompleto('AB2CD3E45'), isFalse);
  });
}
