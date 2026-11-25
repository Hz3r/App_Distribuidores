import 'package:core/core.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panel_web/src/features/reportes/data/excel_pedidos.dart';

import '../soporte/dobles_pedidos.dart';

/// Valor de una celda tal como lo vería la persona al abrir el archivo.
Object? valor(Data? celda) => switch (celda?.value) {
  null => null,
  TextCellValue(:final value) => value.toString(),
  IntCellValue(:final value) => value,
  DoubleCellValue(:final value) => value,
  final otro => otro.toString(),
};

List<Object?> fila(Sheet hoja, int indice) => [
  for (final celda in hoja.rows[indice]) valor(celda),
];

void main() {
  const nombres = {'c1': 'Bodega El Roble'};
  // Hora del dispositivo, para que la columna Fecha no dependa de la zona.
  final creado = DateTime(2026, 11, 5, 9, 7);

  Excel exportar(List<Pedido> pedidos) =>
      Excel.decodeBytes(armarExcelPedidos(pedidos, nombreCliente: nombres));

  test('el archivo trae solo las hojas Pedidos y Detalle', () {
    final libro = exportar([pedido('a')]);

    expect(libro.tables.keys, unorderedEquals([hojaPedidos, hojaDetalle]));
  });

  test('hoja Pedidos: una fila por pedido, con los montos en soles', () {
    final libro = exportar([
      pedido(
        'a',
        numero: 1043,
        total: 15050,
        saldo: 5000,
        nota: 'Tocar el timbre',
        creadoEn: creado,
      ),
    ]);
    final hoja = libro.tables[hojaPedidos]!;

    expect(hoja.rows, hasLength(2));
    expect(fila(hoja, 0), [
      'N.º',
      'Fecha',
      'Cliente',
      'Estado',
      'Forma de pago',
      'Total (S/)',
      'Cobrado (S/)',
      'Saldo (S/)',
      'Cobro',
      'Dirección de entrega',
      'Nota del cliente',
      'Motivo de cancelación',
    ]);
    expect(fila(hoja, 1), [
      1043,
      '2026-11-05 09:07',
      'Bodega El Roble',
      'Por confirmar',
      'Contado',
      150.5,
      100.5,
      50,
      'Pago parcial',
      'Av. Los Olivos 123',
      'Tocar el timbre',
      '',
    ]);
  });

  test('los montos se muestran con dos decimales; el resto, sin formato', () {
    final libro = exportar([pedido('a', numero: 1043, total: 15050)]);
    final datos = libro.tables[hojaPedidos]!.rows[1];
    final detalle = libro.tables[hojaDetalle]!.rows[1];

    for (final celda in [
      datos[5],
      datos[6],
      datos[7],
      detalle[7],
      detalle[8],
    ]) {
      expect(celda!.cellStyle?.numberFormat.formatCode, '0.00');
    }
    expect(datos[0]!.cellStyle?.numberFormat.formatCode, isNot('0.00'));
    expect(detalle[6]!.cellStyle?.numberFormat.formatCode, isNot('0.00'));
  });

  test('un pedido cancelado sale, pero sin saldo por cobrar', () {
    final libro = exportar([
      pedido(
        'c',
        estado: EstadoPedido.cancelado,
        total: 8000,
        motivoCancelacion: 'Sin stock',
      ),
    ]);
    final datos = fila(libro.tables[hojaPedidos]!, 1);

    expect(datos[3], 'Cancelado');
    expect(datos[5], 80);
    expect(datos[7], 0);
    expect(datos[8], '');
    expect(datos[11], 'Sin stock');
  });

  test('a crédito y con un cliente que ya no está en la lista', () {
    final libro = exportar([
      pedido('a', clienteId: 'borrado', condicion: CondicionPago.credito),
    ]);
    final datos = fila(libro.tables[hojaPedidos]!, 1);

    expect(datos[2], 'Cliente');
    expect(datos[4], 'Crédito');
  });

  test('hoja Detalle: una fila por producto de cada pedido', () {
    final libro = exportar([
      pedido('a', numero: 7, total: 10000, creadoEn: creado),
      pedido(
        'b',
        numero: 8,
        creadoEn: creado,
        items: [
          PedidoItem(
            id: 'i1',
            distribuidorId: 'd1',
            pedidoId: 'b',
            presentacionId: 'pr2',
            productoId: 'p2',
            nombreProducto: 'Ron Añejo',
            nombrePresentacion: 'Botella',
            factor: 1,
            cantidad: 3,
            precioUnitarioCentimos: 4590,
            subtotalCentimos: 13770,
            creadoEn: creado,
          ),
          PedidoItem(
            id: 'i2',
            distribuidorId: 'd1',
            pedidoId: 'b',
            presentacionId: 'pr3',
            productoId: 'p3',
            nombreProducto: 'Hielo',
            nombrePresentacion: 'Bolsa',
            factor: 1,
            cantidad: 1,
            precioUnitarioCentimos: 500,
            subtotalCentimos: 500,
            creadoEn: creado,
          ),
        ],
      ),
    ]);
    final hoja = libro.tables[hojaDetalle]!;

    expect(hoja.rows, hasLength(4));
    expect(fila(hoja, 1), [
      7,
      '2026-11-05 09:07',
      'Bodega El Roble',
      'Por confirmar',
      'Cerveza Lager',
      'Caja x12',
      2,
      50,
      100,
    ]);
    expect(fila(hoja, 2).sublist(4), ['Ron Añejo', 'Botella', 3, 45.9, 137.7]);
    expect(fila(hoja, 3).sublist(4), ['Hielo', 'Bolsa', 1, 5, 5]);
  });

  test('sin pedidos solo quedan los encabezados', () {
    final libro = exportar(const []);

    expect(libro.tables[hojaPedidos]!.rows, hasLength(1));
    expect(libro.tables[hojaDetalle]!.rows, hasLength(1));
  });
}
