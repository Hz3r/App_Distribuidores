import 'package:core/core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Serialización de modelos', () {
    test('Producto ida y vuelta con snake_case', () {
      final json = <String, dynamic>{
        'id': 'p1',
        'distribuidor_id': 'd1',
        'categoria_id': 'c1',
        'nombre': 'Ron Cartavio 7 años',
        'activo': true,
      };

      final producto = Producto.fromJson(json);

      expect(producto.distribuidorId, 'd1');
      expect(producto.nombre, 'Ron Cartavio 7 años');
      expect(producto.toJson()['categoria_id'], 'c1');
    });

    test('Pedido con estado en_camino se lee desde la BD', () {
      final pedido = Pedido.fromJson(<String, dynamic>{
        'id': 'ped1',
        'distribuidor_id': 'd1',
        'cliente_id': 'cli1',
        'estado': 'en_camino',
        'total_centimos': 25000,
        'creado_en': '2026-11-17T10:00:00Z',
        'items': <dynamic>[],
      });

      expect(pedido.estado, EstadoPedido.enCamino);
      expect(pedido.toJson()['estado'], 'en_camino');
      expect(pedido.totalCentimos, 25000);
    });

    test('Presentacion six_pack mapea desde six_pack', () {
      final presentacion = Presentacion.fromJson(<String, dynamic>{
        'id': 'pr1',
        'producto_id': 'p1',
        'tipo': 'six_pack',
        'nombre': 'Six pack 650 ml',
        'precio_base_centimos': 4200,
        'stock': 12,
      });

      expect(presentacion.tipo, TipoPresentacion.sixPack);
      expect(presentacion.unidadesPorPresentacion, 1);
    });
  });

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
