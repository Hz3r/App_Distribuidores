import 'package:app_movil/src/features/catalogo/domain/catalogo.dart';
import 'package:app_movil/src/features/inicio/domain/resumen_compras.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../catalogo/fabricas.dart';
import 'fabricas_pedidos.dart';

void main() {
  final ahora = DateTime.utc(2026, 11, 26, 15);
  final noviembre = DateTime.utc(2026, 11, 10, 15);
  final octubre = DateTime.utc(2026, 10, 15, 15);

  ResumenCompras resumir(List<Pedido> pedidos, {Pedido? ultimo}) =>
      resumirCompras(
        pedidos,
        distribuidorId: 'd1',
        clienteId: 'cn-d1',
        ultimoPedido: ultimo,
        ahora: ahora,
      );

  group('resumirCompras', () {
    test('sin pedidos: nada que mostrar', () {
      final r = resumir(const []);

      expect(r.distribuidorId, 'd1');
      expect(r.clienteId, 'cn-d1');
      expect(r.ultimoPedido, isNull);
      expect(r.compradoEsteMesCentimos, 0);
      expect(r.variacionPorcentaje, isNull);
      expect(r.productosMasPedidos, isEmpty);
      expect(r.mesAnterior, 10);
    });

    test('suma el mes sin cancelados y compara con el anterior', () {
      final r = resumir([
        pedido('a', total: 100000, creadoEn: noviembre),
        pedido('b', total: 134000, creadoEn: noviembre),
        pedido(
          'c',
          total: 50000,
          estado: EstadoPedido.cancelado,
          creadoEn: noviembre,
        ),
        pedido('d', total: 216667, creadoEn: octubre),
      ]);

      expect(r.compradoEsteMesCentimos, 234000);
      // (234000 − 216667) × 100 / 216667 = 7.99…
      expect(r.variacionPorcentaje, 8);
    });

    test('con el mes anterior en 0 no hay variación', () {
      final r = resumir([pedido('a', total: 100000, creadoEn: noviembre)]);

      expect(r.compradoEsteMesCentimos, 100000);
      expect(r.variacionPorcentaje, isNull);
    });

    test('con este mes en 0 y el anterior en 100000 la variación es −100', () {
      final r = resumir([pedido('a', total: 100000, creadoEn: octubre)]);

      expect(r.compradoEsteMesCentimos, 0);
      expect(r.variacionPorcentaje, -100);
    });

    test('la variación redondea al entero más cercano también si baja', () {
      // (100000 − 120000) × 100 / 120000 = −16.67
      final r = resumir([
        pedido('a', total: 100000, creadoEn: noviembre),
        pedido('b', total: 120000, creadoEn: octubre),
      ]);

      expect(r.variacionPorcentaje, -17);
    });

    test('el 1 de noviembre a las 03:00 UTC cuenta para octubre (en Lima es '
        '31 de octubre, 22:00)', () {
      final r = resumir([
        pedido('a', total: 100000, creadoEn: DateTime.utc(2026, 11, 1, 3)),
        pedido('b', total: 50000, creadoEn: DateTime.utc(2026, 11, 1, 5)),
      ]);

      expect(r.compradoEsteMesCentimos, 50000);
      expect(r.variacionPorcentaje, -50);
    });

    test('un mes de hace dos no cuenta como anterior', () {
      final r = resumir([
        pedido('a', total: 100000, creadoEn: DateTime.utc(2026, 9, 15)),
      ]);

      expect(r.variacionPorcentaje, isNull);
    });

    test('en enero el mes anterior es diciembre del año previo', () {
      final r = resumirCompras(
        [
          pedido('a', total: 100000, creadoEn: DateTime.utc(2026, 12, 20)),
          pedido('b', total: 150000, creadoEn: DateTime.utc(2027, 1, 10)),
        ],
        distribuidorId: 'd1',
        clienteId: 'cn-d1',
        ultimoPedido: null,
        ahora: DateTime.utc(2027, 1, 15),
      );

      expect(r.mesAnterior, 12);
      expect(r.compradoEsteMesCentimos, 150000);
      expect(r.variacionPorcentaje, 50);
    });

    test('el último pedido es el que se le pasa, aunque tenga más de 90 '
        'días y no esté entre los recientes', () {
      final viejo = pedido(
        'viejo',
        numero: 900,
        estado: EstadoPedido.entregado,
        creadoEn: ahora.subtract(const Duration(days: 120)),
        items: [linea('A', cantidad: 5)],
      );

      final r = resumir(const [], ultimo: viejo);

      expect(r.ultimoPedido, viejo);
      expect(r.compradoEsteMesCentimos, 0);
      expect(r.variacionPorcentaje, isNull);
      expect(r.productosMasPedidos, isEmpty);
    });

    test('guarda lo comprado el mes anterior para comparar totales', () {
      final iguales = resumir([
        pedido('a', total: 100000, creadoEn: noviembre),
        pedido('b', total: 100000, creadoEn: octubre),
      ]);
      expect(iguales.variacionPorcentaje, 0);
      expect(iguales.compradoMesAnteriorCentimos, 100000);

      // +0.4 % redondea a 0 aunque los totales difieran.
      final casi = resumir([
        pedido('a', total: 100400, creadoEn: noviembre),
        pedido('b', total: 100000, creadoEn: octubre),
      ]);
      expect(casi.variacionPorcentaje, 0);
      expect(casi.compradoEsteMesCentimos, 100400);
      expect(casi.compradoMesAnteriorCentimos, 100000);
    });

    test('más pedidos: por unidades base (cantidad × factor)', () {
      final r = resumir([
        pedido(
          'a',
          creadoEn: noviembre,
          items: [
            linea('A', cantidad: 2, factor: 12),
            linea('B', cantidad: 30),
          ],
        ),
      ]);

      expect(r.productosMasPedidos, ['B', 'A']);
    });

    test('más pedidos: no cuentan los de hace 100 días ni los cancelados', () {
      final r = resumir([
        pedido(
          'a',
          creadoEn: noviembre,
          items: [linea('A', cantidad: 2, factor: 12)],
        ),
        pedido(
          'viejo',
          creadoEn: ahora.subtract(const Duration(days: 100)),
          items: [linea('B', cantidad: 500)],
        ),
        pedido(
          'cancelado',
          estado: EstadoPedido.cancelado,
          creadoEn: noviembre,
          items: [linea('C', cantidad: 500)],
        ),
      ]);

      expect(r.productosMasPedidos, ['A']);
    });

    test('más pedidos: suma entre pedidos y deja como máximo 6', () {
      final r = resumir([
        pedido(
          'a',
          creadoEn: noviembre,
          items: [for (var i = 1; i <= 7; i++) linea('P$i', cantidad: i)],
        ),
        pedido('b', creadoEn: octubre, items: [linea('P1', cantidad: 10)]),
      ]);

      expect(r.productosMasPedidos, ['P1', 'P7', 'P6', 'P5', 'P4', 'P3']);
    });
  });

  group('desdeParaResumen', () {
    // El mes anterior empieza como mucho 62 días atrás, así que con 90 días
    // siempre gana la marca de 90 días; se comprueba que cubre los dos.
    for (final ahora in [
      DateTime.utc(2026, 11, 26, 15),
      // En Lima aún es 31 de diciembre: el mes anterior es noviembre.
      DateTime.utc(2027, 1, 1, 2),
      DateTime.utc(2027, 3, 31, 23),
    ]) {
      test('en $ahora cubre 90 días y el mes anterior completo', () {
        final desde = desdeParaResumen(ahora: ahora);
        final local = ahora.add(const Duration(hours: -5));
        final inicioMesAnterior = DateTime.utc(
          local.year,
          local.month - 1,
        ).add(const Duration(hours: 5));

        expect(desde, ahora.subtract(const Duration(days: 90)));
        expect(desde.isAfter(inicioMesAnterior), isFalse);
      });
    }
  });

  test('el desfase del distribuidor es UTC−5 (America/Lima)', () {
    expect(desfaseZonaDistribuidor, const Duration(hours: -5));
  });

  test('productosEnOrden: en el orden dado y solo los que siguen', () {
    final catalogo = productosDelCatalogo(
      Catalogo(
        distribuidorId: 'd1',
        categorias: [categoria('c1')],
        productos: [producto('p1'), producto('p2'), producto('p3')],
        preciosLista: const {},
      ),
    );

    expect(
      productosEnOrden(catalogo, [
        'p3',
        'ya-no',
        'p1',
      ]).map((p) => p.producto.id),
      ['p3', 'p1'],
    );
  });

  test('etiquetaEstado para los seis estados', () {
    expect(
      {for (final e in EstadoPedido.values) e: etiquetaEstado(e)},
      {
        EstadoPedido.recibido: 'Recibido',
        EstadoPedido.confirmado: 'Confirmado',
        EstadoPedido.enCamino: 'En camino',
        EstadoPedido.listoRecojo: 'Listo para recoger',
        EstadoPedido.entregado: 'Entregado',
        EstadoPedido.cancelado: 'Cancelado',
      },
    );
  });

  test('nombreMes en minúsculas', () {
    expect(nombreMes(1), 'enero');
    expect(nombreMes(10), 'octubre');
    expect(nombreMes(12), 'diciembre');
  });
}
