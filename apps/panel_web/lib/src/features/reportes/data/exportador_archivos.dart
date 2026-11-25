import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:file_picker/file_picker.dart';

import '../domain/exportador.dart';
import '../domain/periodo.dart';
import 'excel_pedidos.dart';
import 'guia_pdf.dart';

/// Entrega un archivo a la persona. En la web lo descarga con ese nombre.
typedef GuardarArchivo = Future<void> Function({
  required String nombre,
  required Uint8List bytes,
  required String tipoMime,
});

/// Guarda con `file_picker`: en la web dispara la descarga del navegador.
Future<void> guardarConNavegador({
  required String nombre,
  required Uint8List bytes,
  required String tipoMime,
}) async {
  await FilePicker.saveFile(fileName: nombre, bytes: bytes, mimeType: tipoMime);
}

const tipoXlsx =
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
const tipoPdf = 'application/pdf';

/// [Exportador] que arma los archivos en el propio navegador y los descarga.
class ExportadorArchivos implements Exportador {
  /// [_guardar] se reemplaza en las pruebas para capturar el archivo.
  ExportadorArchivos([this._guardar = guardarConNavegador]);

  final GuardarArchivo _guardar;

  @override
  Future<void> exportarPedidos({
    required List<Pedido> pedidos,
    required Map<String, String> nombreCliente,
    required Periodo periodo,
  }) {
    return _guardar(
      nombre: 'pedidos_${periodo.paraArchivo}.xlsx',
      bytes: armarExcelPedidos(pedidos, nombreCliente: nombreCliente),
      tipoMime: tipoXlsx,
    );
  }

  @override
  Future<void> descargarGuia({
    required Pedido pedido,
    required Distribuidor distribuidor,
    ClienteNegocio? cliente,
  }) async {
    return _guardar(
      nombre: 'guia_pedido_${pedido.numero}.pdf',
      bytes: await armarGuiaPdf(
        pedido: pedido,
        distribuidor: distribuidor,
        cliente: cliente,
      ),
      tipoMime: tipoPdf,
    );
  }
}
