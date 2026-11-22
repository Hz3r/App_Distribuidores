import 'package:core/core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Las pruebas de serialización de modelos están en modelos_test.dart.

  group('ThemeBuilder', () {
    test('arma un ThemeData desde ConfigTema con colores del distribuidor', () {
      const config = ConfigTema(
        nombre: 'Licores Demo',
        colorPrimario: '#8B0000',
        colorSecundario: '#F2A900',
      );

      final theme = ThemeBuilder.desde(config);

      expect(theme.colorScheme.primary, const Color(0xFF8B0000));
      expect(theme.colorScheme.secondary, const Color(0xFFF2A900));
      expect(theme.useMaterial3, isTrue);
    });

    test('rechaza colores con formato inválido', () {
      expect(
        () => ThemeBuilder.colorDesdeHex('rojo'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('Dinero', () {
    test('formatea céntimos a soles', () {
      expect(1050.formatoSoles, 'S/ 10.50');
      expect(123450.formatoSoles, 'S/ 1,234.50');
    });
  });
}
