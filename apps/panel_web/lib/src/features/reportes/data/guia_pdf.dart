import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../shared/formato.dart';
import '../../../shared/textos.dart';

/// Aviso que va al pie de cada página de la guía.
const avisoGuia =
    'Documento interno de despacho. No es un comprobante de pago ni tiene '
    'validez tributaria.';

const _azul = PdfColor.fromInt(0xFF0B2A5B);
const _gris = PdfColor.fromInt(0xFF64748B);
const _borde = PdfColor.fromInt(0xFFE2E8F0);

/// Arma la guía del pedido en PDF (A4). Si el pedido tiene muchas líneas,
/// la tabla sigue en las páginas siguientes.
///
/// [comprimir] en `false` deja el contenido legible; solo lo usan las
/// pruebas.
Future<Uint8List> armarGuiaPdf({
  required Pedido pedido,
  required Distribuidor distribuidor,
  ClienteNegocio? cliente,
  bool comprimir = true,
}) {
  final documento = pw.Document(
    compress: comprimir,
    title: 'Guía de pedido ${pedido.numero}',
    author: distribuidor.nombreVisible,
  );
  final documentoCliente = cliente?.documento;
  final telefonoCliente = cliente?.telefono;
  final vence = pedido.venceEn;
  final cobrado = pedido.totalCentimos - pedido.saldoPendienteCentimos;
  // Un pedido cancelado no deja nada por cobrar.
  final porCobrar = pedido.estado == EstadoPedido.cancelado
      ? 0
      : pedido.saldoPendienteCentimos;

  documento.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      footer: (contexto) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Divider(color: _borde, height: 16),
          pw.Row(
            children: [
              pw.Expanded(child: pw.Text(avisoGuia, style: _chico)),
              pw.Text(
                'Página ${contexto.pageNumber} de ${contexto.pagesCount}',
                style: _chico,
              ),
            ],
          ),
        ],
      ),
      build: (contexto) => [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    distribuidor.nombreVisible,
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: _azul,
                    ),
                  ),
                  if (distribuidor.documento case final ruc?)
                    pw.Text('RUC $ruc', style: _chico),
                  if (distribuidor.telefono case final telefono?)
                    pw.Text('Tel. $telefono', style: _chico),
                ],
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Guía de pedido',
                  style: pw.TextStyle(fontSize: 11, color: _gris),
                ),
                pw.Text(
                  'N.º ${pedido.numero}',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(fechaHoraCorta(pedido.creadoEn), style: _chico),
                pw.Text(estadoPedidoLegible(pedido.estado), style: _chico),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: _borde),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('ENTREGAR A', style: _rotulo),
              pw.SizedBox(height: 4),
              pw.Text(
                cliente?.nombreNegocio ?? 'Cliente',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (documentoCliente != null)
                pw.Text(
                  '${documentoCliente.length == 8 ? 'DNI' : 'RUC'} '
                  '$documentoCliente',
                  style: _normal,
                ),
              pw.Text(
                pedido.direccionEntrega ?? 'Sin dirección de entrega',
                style: _normal,
              ),
              if (cliente?.referencia case final referencia?)
                pw.Text('Referencia: $referencia', style: _normal),
              if (telefonoCliente != null)
                pw.Text('Cel. $telefonoCliente', style: _normal),
            ],
          ),
        ),
        if (pedido.notaCliente case final nota?) ...[
          pw.SizedBox(height: 10),
          pw.Text('NOTA DEL CLIENTE', style: _rotulo),
          pw.Text(nota, style: _normal),
        ],
        pw.SizedBox(height: 16),
        pw.TableHelper.fromTextArray(
          headers: const [
            'Producto',
            'Presentación',
            'Cant.',
            'P. unit.',
            'Subtotal',
          ],
          data: [
            for (final item in pedido.items)
              [
                item.nombreProducto,
                item.nombrePresentacion,
                '${item.cantidad}',
                item.precioUnitarioCentimos.formatoSoles,
                item.subtotalCentimos.formatoSoles,
              ],
          ],
          border: null,
          headerStyle: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: _gris,
          ),
          headerDecoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: _borde)),
          ),
          rowDecoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: _borde, width: 0.5)),
          ),
          cellStyle: _normal,
          cellPadding: const pw.EdgeInsets.symmetric(
            vertical: 6,
            horizontal: 4,
          ),
          columnWidths: const {
            0: pw.FlexColumnWidth(4),
            1: pw.FlexColumnWidth(2.2),
            2: pw.FlexColumnWidth(1),
            3: pw.FlexColumnWidth(1.6),
            4: pw.FlexColumnWidth(1.8),
          },
          cellAlignments: const {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerLeft,
            2: pw.Alignment.centerRight,
            3: pw.Alignment.centerRight,
            4: pw.Alignment.centerRight,
          },
        ),
        pw.SizedBox(height: 12),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.SizedBox(
            width: 220,
            child: pw.Column(
              children: [
                _renglon(
                  'Total',
                  pedido.totalCentimos.formatoSoles,
                  destacado: true,
                ),
                _renglon('Cobrado', cobrado.formatoSoles),
                _renglon('Por cobrar', porCobrar.formatoSoles),
              ],
            ),
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Text(
          pedido.condicionPago == CondicionPago.credito
              ? vence == null
                    ? 'Pago a crédito: ${pedido.plazoCreditoDias ?? 0} días '
                          'desde la entrega.'
                    : 'Pago a crédito: vence el ${fechaCorta(vence)}.'
              : 'Pago al contado.',
          style: _normal,
        ),
        pw.SizedBox(height: 44),
        pw.Row(
          children: [
            pw.Expanded(child: _firma('Entregado por')),
            pw.SizedBox(width: 40),
            pw.Expanded(child: _firma('Recibido por (nombre y firma)')),
          ],
        ),
      ],
    ),
  );
  return documento.save();
}

const _normal = pw.TextStyle(fontSize: 10);
const _chico = pw.TextStyle(fontSize: 8, color: _gris);
final _rotulo = pw.TextStyle(
  fontSize: 8,
  fontWeight: pw.FontWeight.bold,
  color: _gris,
);

pw.Widget _renglon(String etiqueta, String valor, {bool destacado = false}) {
  final estilo = destacado
      ? pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)
      : _normal;
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(etiqueta, style: estilo),
        pw.Text(valor, style: estilo),
      ],
    ),
  );
}

pw.Widget _firma(String rotulo) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.Divider(color: _gris, height: 8),
      pw.Text(rotulo, style: _chico),
    ],
  );
}
