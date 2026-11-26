import 'package:app_movil/src/features/inicio/domain/pedidos_resumen_repositorio.dart';
import 'package:core/core.dart';

/// Constructores auxiliares de pedidos para las pruebas del inicio.

Pedido pedido(
  String id, {
  int numero = 1,
  EstadoPedido estado = EstadoPedido.entregado,
  int total = 10000,
  required DateTime creadoEn,
  List<PedidoItem> items = const [],
}) => Pedido(
  id: id,
  distribuidorId: 'd1',
  numero: numero,
  clienteId: 'cn-d1',
  estado: estado,
  despacho: DespachoPedido.reparto,
  totalCentimos: total,
  condicionPago: CondicionPago.contado,
  estadoPago: EstadoPago.pendiente,
  saldoPendienteCentimos: total,
  claveIdempotencia: 'clave-$id',
  creadoEn: creadoEn,
  items: items,
);

PedidoItem linea(
  String productoId, {
  required int cantidad,
  int factor = 1,
  String pedidoId = 'x',
}) => PedidoItem(
  id: 'l-$pedidoId-$productoId-$factor',
  distribuidorId: 'd1',
  pedidoId: pedidoId,
  presentacionId: '$productoId-$factor',
  productoId: productoId,
  nombreProducto: 'Producto $productoId',
  nombrePresentacion: 'x $factor',
  factor: factor,
  cantidad: cantidad,
  precioUnitarioCentimos: 100,
  subtotalCentimos: 100 * cantidad,
  creadoEn: DateTime.utc(2026),
);

/// Doble de [PedidosResumenRepositorio]: devuelve [pedidos], o lanza
/// [error] si no es null. Anota los parámetros de cada lectura.
class PedidosResumenRepositorioFijo implements PedidosResumenRepositorio {
  PedidosResumenRepositorioFijo([this.pedidos = const []]);

  List<Pedido> pedidos;
  Object? error;
  final lecturas =
      <({String distribuidorId, String clienteId, DateTime desde})>[];

  @override
  Future<List<Pedido>> recientes({
    required String distribuidorId,
    required String clienteId,
    required DateTime desde,
  }) async {
    lecturas.add((
      distribuidorId: distribuidorId,
      clienteId: clienteId,
      desde: desde,
    ));
    final fallo = error;
    if (fallo != null) throw fallo;
    return pedidos;
  }
}
