import 'package:app_movil/src/features/registro/domain/datos_registro.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validarNombre', () {
    test('obligatorio, de 2 a 80 caracteres', () {
      expect(validarNombre(''), 'Escribe tu nombre.');
      expect(validarNombre('   '), 'Escribe tu nombre.');
      expect(validarNombre('A'), 'Escribe tu nombre.');
      expect(validarNombre('Jo'), isNull);
      expect(validarNombre('José Ramírez'), isNull);
      expect(validarNombre('a' * 80), isNull);
      expect(validarNombre('a' * 81), 'Escribe tu nombre.');
    });
  });

  group('validarCorreo', () {
    test('obligatorio, con forma a@b.c', () {
      expect(validarCorreo(''), 'Escribe un correo válido.');
      expect(validarCorreo('a@b'), 'Escribe un correo válido.');
      expect(validarCorreo('ab.co'), 'Escribe un correo válido.');
      expect(validarCorreo('a b@c.co'), 'Escribe un correo válido.');
      expect(validarCorreo('a@b.co'), isNull);
      expect(validarCorreo('  jose@bodega.pe  '), isNull);
    });
  });

  group('validarContrasena', () {
    test('mínimo 8 caracteres', () {
      const mensaje = 'La contraseña debe tener al menos 8 caracteres.';
      expect(validarContrasena(''), mensaje);
      expect(validarContrasena('1234567'), mensaje);
      expect(validarContrasena('12345678'), isNull);
    });
  });

  group('validarDocumento', () {
    test('vacío, DNI de 8 dígitos o RUC de 11', () {
      const mensaje = 'Debe ser un DNI (8 dígitos) o un RUC (11 dígitos).';
      expect(validarDocumento(''), isNull);
      expect(validarDocumento('12345678'), isNull);
      expect(validarDocumento('20601234567'), isNull);
      expect(validarDocumento(' 20601234567 '), isNull);
      expect(validarDocumento('123'), mensaje);
      expect(validarDocumento('2060123456A'), mensaje);
      expect(validarDocumento('123456789'), mensaje);
    });
  });

  group('validarTelefono', () {
    test('vacío, o 9 dígitos que empiezan en 9; acepta espacios y +51', () {
      const mensaje = 'Escribe un celular de 9 dígitos.';
      expect(validarTelefono(''), isNull);
      expect(validarTelefono('987654321'), isNull);
      expect(validarTelefono('+51 987 654 321'), isNull);
      expect(validarTelefono('987 654 321'), isNull);
      expect(validarTelefono('12345'), mensaje);
      expect(validarTelefono('887654321'), mensaje);
      expect(validarTelefono('9876543210'), mensaje);
      expect(validarTelefono('+52 987 654 321'), mensaje);
    });
  });

  group('validarDireccion', () {
    test('vacía o hasta 200 caracteres', () {
      expect(validarDireccion(''), isNull);
      expect(validarDireccion('Av. Los Olivos 123, Comas'), isNull);
      expect(validarDireccion('a' * 200), isNull);
      expect(validarDireccion('a' * 201), 'La dirección es demasiado larga.');
    });
  });
}
