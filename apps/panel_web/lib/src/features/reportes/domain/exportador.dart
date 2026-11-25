import 'package:core/core.dart';

import 'periodo.dart';

/// Genera y descarga los archivos del panel. Lanza si el archivo no se pudo
/// generar o guardar.
abstract interface class Exportador {
  /// Excel con los pedidos del periodo: una hoja con un pedido por fila y
  /// otra con el detalle por producto.
  Future<void> exportarPedidos({
    required List<Pedido> pedidos,
    required Map<String, String> nombreCliente,
    required Periodo periodo,
  });

  /// Guía del pedido en PDF, para imprimir o enviar. Es un documento
  /// interno, no un comprobante de pago.
  Future<void> descargarGuia({
    required Pedido pedido,
    required Distribuidor distribuidor,
    ClienteNegocio? cliente,
  });
}
