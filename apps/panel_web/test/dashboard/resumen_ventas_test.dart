import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panel_web/src/features/dashboard/domain/resumen_ventas.dart';

import '../soporte/dobles_pedidos.dart';

void main() {
  // Miércoles 25 de noviembre de 2026, 3 p. m., hora del dispositivo.
  final ahora = DateTime(2026, 11, 25, 15);

  Pedido venta(
    String id,
    DateTime creado, {
    int total = 10000,
    String clienteId = 'c1',
    EstadoPedido estado = EstadoPedido.entregado,
  }) => pedido(
    id,
    creadoEn: creado,
    total: total,
    clienteId: clienteId,
    estado: estado,
  );

  test('inicioDelResumen es el día 1 del mes anterior, también en enero', () {
    expect(inicioDelResumen(ahora), DateTime(2026, 10));
    expect(inicioDelResumen(DateTime(2027, 1, 10)), DateTime(2026, 12));
  });

  test('sin pedidos todo queda en cero y hay 7 días en el gráfico', () {
    final resumen = resumirVentas(const [], ahora);

    expect(resumen.ventasMesCentimos, 0);
    expect(resumen.porConfirmar, 0);
    expect(resumen.topClientes, isEmpty);
    expect(resumen.ultimosDias, hasLength(7));
    expect(resumen.ultimosDias.first.dia, DateTime(2026, 11, 19));
    expect(resumen.ultimosDias.last.dia, DateTime(2026, 11, 25));
    expect(resumen.ventasUltimosDiasCentimos, 0);
  });

  test('las ventas del mes van desde el día 1 y no cuentan cancelados', () {
    final resumen = resumirVentas([
      venta('a', DateTime(2026, 11, 1, 0, 5), total: 5000),
      venta('b', DateTime(2026, 11, 25, 9), total: 7000),
      venta(
        'c',
        DateTime(2026, 11, 20),
        total: 90000,
        estado: EstadoPedido.cancelado,
      ),
      // Octubre no entra en el mes.
      venta('d', DateTime(2026, 10, 31, 23, 59), total: 3000),
    ], ahora);

    expect(resumen.ventasMesCentimos, 12000);
    expect(resumen.pedidosMes, 2);
  });

  test('compara con el mes anterior solo hasta el mismo día y hora', () {
    final resumen = resumirVentas([
      venta('a', DateTime(2026, 10, 1), total: 1000),
      venta('b', DateTime(2026, 10, 25, 15), total: 2000),
      // Después del corte: 25 de octubre, 3:01 p. m.
      venta('c', DateTime(2026, 10, 25, 15, 1), total: 40000),
      venta('d', DateTime(2026, 10, 30), total: 50000),
    ], ahora);

    expect(resumen.ventasMesAnteriorCentimos, 3000);
  });

  test('si el mes anterior es más corto, el corte es su último día', () {
    // 31 de marzo: febrero de 2026 tiene 28 días.
    final resumen = resumirVentas([
      venta('a', DateTime(2026, 2, 28, 10), total: 1500),
      venta('b', DateTime(2026, 2, 1), total: 500),
    ], DateTime(2026, 3, 31, 12));

    expect(resumen.ventasMesAnteriorCentimos, 2000);
  });

  test('por confirmar cuenta los recibidos y cuántos llegaron hoy', () {
    final resumen = resumirVentas([
      venta('a', DateTime(2026, 11, 25, 8), estado: EstadoPedido.recibido),
      venta('b', DateTime(2026, 11, 25), estado: EstadoPedido.recibido),
      venta('c', DateTime(2026, 11, 24, 23, 59), estado: EstadoPedido.recibido),
      venta('d', DateTime(2026, 11, 25, 9), estado: EstadoPedido.confirmado),
    ], ahora);

    expect(resumen.porConfirmar, 3);
    expect(resumen.llegaronHoy, 2);
  });

  test('los últimos 7 días suman por día, de hace 6 días a hoy', () {
    final resumen = resumirVentas([
      venta('a', DateTime(2026, 11, 25, 9), total: 1000),
      venta('b', DateTime(2026, 11, 25, 14), total: 2000),
      venta('c', DateTime(2026, 11, 19), total: 500),
      // Hace 7 días: ya no entra.
      venta('d', DateTime(2026, 11, 18, 23, 59), total: 9999),
    ], ahora);

    expect(resumen.ultimosDias.map((d) => d.centimos), [
      500,
      0,
      0,
      0,
      0,
      0,
      3000,
    ]);
    expect(resumen.ultimosDias.last.pedidos, 2);
    expect(resumen.ventasUltimosDiasCentimos, 3500);
  });

  test('top de clientes: del que más compró al que menos, máximo 5, y '
      'cuenta cuántos clientes distintos compraron', () {
    final resumen = resumirVentas([
      for (final (i, monto) in [100, 600, 300, 200, 500, 400].indexed)
        venta('p$i', DateTime(2026, 11, 10), total: monto, clienteId: 'c$i'),
      // Segundo pedido del mismo cliente: se suma.
      venta('extra', DateTime(2026, 11, 11), total: 250, clienteId: 'c2'),
    ], ahora);

    expect(resumen.clientesQueCompraron, 6);
    expect(resumen.topClientes.map((v) => '${v.clienteId}:${v.centimos}'), [
      'c1:600',
      'c2:550',
      'c4:500',
      'c5:400',
      'c3:200',
    ]);
    expect(resumen.topClientes[1].pedidos, 2);
  });

  test('variacionPorcentual redondea y no compara contra cero', () {
    expect(variacionPorcentual(1120, 1000), 12);
    expect(variacionPorcentual(500, 1000), -50);
    expect(variacionPorcentual(1000, 1000), 0);
    expect(variacionPorcentual(1000, 0), isNull);
  });
}
