import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:panel_web/src/features/configuracion/domain/validaciones.dart';

import '../soporte/dobles_configuracion.dart';

Uint8List bytes(List<int> inicio, {int largo = 64}) =>
    Uint8List(largo)..setAll(0, inicio);

void main() {
  group('validarNombre', () {
    test('pide algo escrito y lo dice con lo que falta', () {
      expect(validarNombre('  ', que: 'tu nombre'), 'Escribe tu nombre.');
      expect(validarNombre('Licores del Norte'), isNull);
    });

    test('tiene un largo máximo', () {
      expect(validarNombre('a' * largoMaximoNombre), isNull);
      expect(validarNombre('a' * (largoMaximoNombre + 1)), isNotNull);
    });
  });

  group('validarTelefono', () {
    test('vacío vale: es opcional', () {
      expect(validarTelefono(''), isNull);
      expect(validarTelefono('   '), isNull);
    });

    test('acepta fijos, celulares y código de país con separadores', () {
      for (final valido in [
        '044 123456',
        '987654321',
        '987 654 321',
        '+51 987-654-321',
        '(01) 456-7890',
      ]) {
        expect(validarTelefono(valido), isNull, reason: valido);
      }
    });

    test('rechaza letras y largos imposibles', () {
      expect(validarTelefono('987 ABC 321'), isNotNull);
      expect(validarTelefono('12345'), isNotNull);
      expect(validarTelefono('1234567890123456'), isNotNull);
      expect(validarTelefono('98+7654321'), isNotNull);
    });
  });

  group('colores', () {
    test('normaliza a #RRGGBB en mayúsculas, con o sin #', () {
      expect(normalizarColor('#1f3a5f'), '#1F3A5F');
      expect(normalizarColor(' 1F3A5F '), '#1F3A5F');
      expect(normalizarColor('#1F3A5'), isNull);
      expect(normalizarColor('#GGGGGG'), isNull);
      expect(normalizarColor('azul'), isNull);
      expect(validarColor('#1F3A5F'), isNull);
      expect(validarColor('#12'), isNotNull);
    });

    test('argbDe da el color opaco', () {
      expect(argbDe('#1F3A5F'), 0xFF1F3A5F);
      expect(argbDe('nada'), isNull);
    });

    test('contraste WCAG: blanco con negro es 21, consigo mismo 1', () {
      expect(contraste(0xFFFFFFFF, 0xFF000000), closeTo(21, 0.01));
      expect(contraste(0xFF1F3A5F, 0xFF1F3A5F), closeTo(1, 0.001));
    });

    test('texto blanco: se lee sobre azul marino, no sobre ámbar', () {
      expect(textoBlancoLegible(0xFF1F3A5F), isTrue);
      expect(textoBlancoLegible(0xFFF2A900), isFalse);
      expect(textoSobre(0xFF1F3A5F), 0xFFFFFFFF);
      expect(textoSobre(0xFFF2A900), isNot(0xFFFFFFFF));
    });

    test('los colores sugeridos son válidos y no se repiten', () {
      final codigos = [for (final (_, hex) in coloresSugeridos) hex];
      expect(codigos.toSet(), hasLength(codigos.length));
      for (final hex in codigos) {
        expect(normalizarColor(hex), hex);
      }
    });
  });

  group('logo', () {
    test('reconoce PNG, JPEG y WebP por sus primeros bytes', () {
      expect(tipoDeImagen(pngDePrueba), TipoImagen.png);
      expect(tipoDeImagen(bytes([0xFF, 0xD8, 0xFF, 0xE0])), TipoImagen.jpeg);
      expect(
        tipoDeImagen(
          bytes([
            0x52, 0x49, 0x46, 0x46, 0, 0, 0, 0, //
            0x57, 0x45, 0x42, 0x50,
          ]),
        ),
        TipoImagen.webp,
      );
    });

    test('un archivo que no es imagen, aunque se llame .png, no pasa', () {
      expect(tipoDeImagen(bytes('%PDF-1.7'.codeUnits)), isNull);
      expect(tipoDeImagen(Uint8List(0)), isNull);
      expect(validarLogo(bytes('GIF89a'.codeUnits)), contains('PNG, JPG'));
    });

    test('pesa como máximo 2 MB', () {
      expect(validarLogo(pngDePrueba), isNull);
      final pesado = bytes(pngDePrueba, largo: pesoMaximoLogo + 1);
      expect(validarLogo(pesado), contains('2 MB'));
      expect(validarLogo(bytes(pngDePrueba, largo: pesoMaximoLogo)), isNull);
    });

    test('rutaDeLogo solo devuelve logos del distribuidor subidos por el '
        'panel', () {
      expect(rutaDeLogo(urlLogoD1, 'd1'), 'd1/marca/logo-1.png');
      expect(rutaDeLogo('$urlLogoD1?t=123', 'd1'), 'd1/marca/logo-1.png');
      expect(rutaDeLogo(urlLogoD1, 'd2'), isNull);
      expect(
        rutaDeLogo(
          'https://demo.supabase.co/storage/v1/object/public/catalogo/d1/productos/a.png',
          'd1',
        ),
        isNull,
      );
      expect(
        rutaDeLogo(
          'https://demo.supabase.co/storage/v1/object/public/catalogo/d1/marca/../productos/a.png',
          'd1',
        ),
        isNull,
      );
      expect(rutaDeLogo('https://otro.com/logo.png', 'd1'), isNull);
    });
  });
}
