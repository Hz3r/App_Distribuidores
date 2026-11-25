import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:excel/excel.dart';

import '../../../shared/textos.dart';

/// Nombre de la hoja con un pedido por fila.
const hojaPedidos = 'Pedidos';

/// Nombre de la hoja con una fila por producto pedido.
const hojaDetalle = 'Detalle';

/// Arma el `.xlsx` de [pedidos] (en el orden recibido), cancelados
/// incluidos: la columna Estado los distingue.
///
/// Los montos van como número en soles con decimales para que se puedan
/// sumar en Excel. Es el único lugar donde un monto deja de ser céntimos
/// enteros, y solo al escribir la celda.
Uint8List armarExcelPedidos(
  List<Pedido> pedidos, {
  required Map<String, String> nombreCliente,
}) {
  final libro = Excel.createExcel();
  final predeterminada = libro.getDefaultSheet();

  final hoja = libro[hojaPedidos];
  _encabezado(hoja, const [
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
  for (final pedido in pedidos) {
    final cancelado = pedido.estado == EstadoPedido.cancelado;
    hoja.appendRow([
      IntCellValue(pedido.numero),
      TextCellValue(_fecha(pedido.creadoEn)),
      TextCellValue(nombreCliente[pedido.clienteId] ?? 'Cliente'),
      TextCellValue(estadoPedidoLegible(pedido.estado)),
      TextCellValue(
        pedido.condicionPago == CondicionPago.credito ? 'Crédito' : 'Contado',
      ),
      _soles(pedido.totalCentimos),
      _soles(pedido.totalCentimos - pedido.saldoPendienteCentimos),
      // Un pedido cancelado no deja nada por cobrar.
      _soles(cancelado ? 0 : pedido.saldoPendienteCentimos),
      TextCellValue(cancelado ? '' : estadoPagoLegible(pedido.estadoPago)),
      TextCellValue(pedido.direccionEntrega ?? ''),
      TextCellValue(pedido.notaCliente ?? ''),
      TextCellValue(pedido.motivoCancelacion ?? ''),
    ]);
  }
  _dosDecimales(hoja, const [5, 6, 7]);
  _anchos(hoja, const [8, 18, 30, 18, 14, 12, 12, 12, 14, 34, 30, 30]);

  final detalle = libro[hojaDetalle];
  _encabezado(detalle, const [
    'N.º',
    'Fecha',
    'Cliente',
    'Estado',
    'Producto',
    'Presentación',
    'Cantidad',
    'Precio unitario (S/)',
    'Subtotal (S/)',
  ]);
  for (final pedido in pedidos) {
    for (final item in pedido.items) {
      detalle.appendRow([
        IntCellValue(pedido.numero),
        TextCellValue(_fecha(pedido.creadoEn)),
        TextCellValue(nombreCliente[pedido.clienteId] ?? 'Cliente'),
        TextCellValue(estadoPedidoLegible(pedido.estado)),
        TextCellValue(item.nombreProducto),
        TextCellValue(item.nombrePresentacion),
        IntCellValue(item.cantidad),
        _soles(item.precioUnitarioCentimos),
        _soles(item.subtotalCentimos),
      ]);
    }
  }
  _dosDecimales(detalle, const [7, 8]);
  _anchos(detalle, const [8, 18, 30, 18, 34, 18, 10, 18, 14]);

  // `createExcel` trae una hoja vacía de más.
  if (predeterminada != null &&
      predeterminada != hojaPedidos &&
      predeterminada != hojaDetalle) {
    libro.setDefaultSheet(hojaPedidos);
    libro.delete(predeterminada);
  }

  final bytes = libro.encode();
  if (bytes == null) {
    throw StateError('No se pudo generar el archivo de Excel.');
  }
  return Uint8List.fromList(bytes);
}

void _encabezado(Sheet hoja, List<String> titulos) {
  hoja.appendRow([for (final titulo in titulos) TextCellValue(titulo)]);
  final negrita = CellStyle(bold: true);
  for (var columna = 0; columna < titulos.length; columna++) {
    hoja
            .cell(CellIndex.indexByColumnRow(columnIndex: columna, rowIndex: 0))
            .cellStyle =
        negrita;
  }
}

/// Muestra las columnas de montos siempre con dos decimales (`150.50`).
void _dosDecimales(Sheet hoja, List<int> columnas) {
  final monto = CellStyle(numberFormat: NumFormat.standard_2);
  for (var fila = 1; fila < hoja.maxRows; fila++) {
    for (final columna in columnas) {
      hoja
              .cell(
                CellIndex.indexByColumnRow(
                  columnIndex: columna,
                  rowIndex: fila,
                ),
              )
              .cellStyle =
          monto;
    }
  }
}

void _anchos(Sheet hoja, List<double> anchos) {
  for (final (columna, ancho) in anchos.indexed) {
    hoja.setColumnWidth(columna, ancho);
  }
}

CellValue _soles(int centimos) => DoubleCellValue(centimos / 100);

/// `2026-11-25 10:24`, en la hora del dispositivo: se ordena bien como texto.
String _fecha(DateTime fecha) {
  final l = fecha.toLocal();
  String dos(int n) => '$n'.padLeft(2, '0');
  return '${l.year}-${dos(l.month)}-${dos(l.day)} '
      '${dos(l.hour)}:${dos(l.minute)}';
}
