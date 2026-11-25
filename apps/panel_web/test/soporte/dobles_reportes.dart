import 'package:core/core.dart';
import 'package:panel_web/src/features/reportes/domain/exportador.dart';
import 'package:panel_web/src/features/reportes/domain/periodo.dart';

/// Doble de [Exportador]: no genera archivos, solo anota qué se pidió.
/// Con [fallar] en `true`, lanza como si el archivo no se pudiera generar.
class ExportadorDoble implements Exportador {
  final llamadas = <String>[];
  bool fallar = false;

  @override
  Future<void> exportarPedidos({
    required List<Pedido> pedidos,
    required Map<String, String> nombreCliente,
    required Periodo periodo,
  }) async {
    if (fallar) throw StateError('sin disco');
    llamadas.add(
      'excel ${periodo.paraArchivo} '
      'pedidos=${pedidos.map((p) => p.numero).join(',')} '
      'clientes=${nombreCliente.length}',
    );
  }

  @override
  Future<void> descargarGuia({
    required Pedido pedido,
    required Distribuidor distribuidor,
    ClienteNegocio? cliente,
  }) async {
    if (fallar) throw StateError('sin disco');
    llamadas.add(
      'guia #${pedido.numero} de ${distribuidor.nombre} '
      'para ${cliente?.nombreNegocio}',
    );
  }
}
