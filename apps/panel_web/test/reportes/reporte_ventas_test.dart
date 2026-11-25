import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panel_web/src/features/reportes/domain/reporte_ventas.dart';

import '../soporte/dobles_clientes.dart';
import '../soporte/dobles_pedidos.dart';

PedidoItem linea(
  String productoId,
  String nombre, {
  required int cantidad,
  required int factor,
  required int subtotal,
}) {
  return PedidoItem(
    id: 'i-$productoId-$cantidad',
    distribuidorId: 'd1',
    pedidoId: 'x',
    presentacionId: 'pr-$productoId',
    productoId: productoId,
    nombreProducto: nombre,
    nombrePresentacion: factor == 1 ? 'Botella' : 'Caja x$factor',
    factor: factor,
    cantidad: cantidad,
    precioUnitarioCentimos: subtotal ~/ cantidad,
    subtotalCentimos: subtotal,
    creadoEn: ahoraDePrueba,
  );
}

void main() {
  const nombres = {'c1': 'Bodega El Roble', 'c2': 'Licorería La Esquina'};
  const categoriaDe = <String, String?>{'p1': 'cat1', 'p2': 'cat1', 'p3': null};
  const nombreCategoria = {'cat1': 'Cervezas'};

  ReporteVentas armar(List<Pedido> pedidos) => armarReporte(
    pedidos,
    nombreCliente: nombres,
    categoriaDeProducto: categoriaDe,
    nombreCategoria: nombreCategoria,
  );

  final pedidos = [
    pedido(
      'a',
      clienteId: 'c1',
      total: 15000,
      saldo: 5000,
      items: [
        linea('p1', 'Cerveza Lager', cantidad: 2, factor: 12, subtotal: 10000),
        linea('p2', 'Cerveza Negra', cantidad: 5, factor: 1, subtotal: 5000),
      ],
    ),
    pedido(
      'b',
      clienteId: 'c2',
      estado: EstadoPedido.entregado,
      total: 9000,
      saldo: 0,
      items: [
        linea('p1', 'Cerveza Lager', cantidad: 6, factor: 1, subtotal: 3000),
        linea('p3', 'Hielo', cantidad: 3, factor: 1, subtotal: 6000),
      ],
    ),
    pedido(
      'c',
      clienteId: 'c1',
      estado: EstadoPedido.cancelado,
      total: 99999,
      items: [
        linea('p1', 'Cerveza Lager', cantidad: 9, factor: 12, subtotal: 99999),
      ],
    ),
  ];

  test('sin pedidos queda todo en cero y sin dividir entre cero', () {
    final reporte = armar(const []);

    expect(reporte.ventasCentimos, 0);
    expect(reporte.ticketPromedioCentimos, 0);
    expect(reporte.porProducto, isEmpty);
  });

  test('totales: los cancelados no cuentan como venta', () {
    final reporte = armar(pedidos);

    expect(reporte.ventasCentimos, 24000);
    expect(reporte.pedidos, 2);
    expect(reporte.cancelados, 1);
    expect(reporte.clientes, 2);
    expect(reporte.porCobrarCentimos, 5000);
    expect(reporte.ticketPromedioCentimos, 12000);
  });

  test('por producto: suma entre pedidos y cuenta unidades base', () {
    final reporte = armar(pedidos);

    expect(
      reporte.porProducto.map((f) => '${f.nombre}:${f.centimos}:${f.cantidad}'),
      // Lager: 2 cajas x12 + 6 botellas = 30 unidades.
      ['Cerveza Lager:13000:30', 'Hielo:6000:3', 'Cerveza Negra:5000:5'],
    );
  });

  test('por cliente: de mayor a menor, con sus pedidos', () {
    final reporte = armar(pedidos);

    expect(
      reporte.porCliente.map((f) => '${f.nombre}:${f.centimos}:${f.cantidad}'),
      ['Bodega El Roble:15000:1', 'Licorería La Esquina:9000:1'],
    );
  });

  test('por categoría: agrupa y deja aparte lo que no tiene categoría', () {
    final reporte = armar(pedidos);

    expect(
      reporte.porCategoria.map(
        (f) => '${f.nombre}:${f.centimos}:${f.cantidad}',
      ),
      ['Cervezas:18000:35', 'Sin categoría:6000:3'],
    );
    expect(reporte.porCategoria.last.clave, sinCategoria);
  });

  test('un producto que ya no está en el catálogo sigue saliendo, con el '
      'nombre guardado en el pedido', () {
    final reporte = armar([
      pedido(
        'a',
        total: 4000,
        items: [
          linea(
            'borrado',
            'Vodka Viejo',
            cantidad: 4,
            factor: 1,
            subtotal: 4000,
          ),
        ],
      ),
    ]);

    expect(reporte.porProducto.single.nombre, 'Vodka Viejo');
    expect(reporte.porCategoria.single.nombre, 'Sin categoría');
  });

  test('el ticket promedio se redondea a céntimos enteros', () {
    final reporte = armar([
      pedido('a', total: 1000),
      pedido('b', total: 1000),
      pedido('c', total: 1001),
    ]);

    expect(reporte.ticketPromedioCentimos, 1000);
  });

  test('porcentajeDe redondea y no divide entre cero', () {
    expect(porcentajeDe(13000, 24000), 54);
    expect(porcentajeDe(24000, 24000), 100);
    expect(porcentajeDe(5, 0), 0);
  });
}
