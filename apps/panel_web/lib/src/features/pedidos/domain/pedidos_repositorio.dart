import 'package:core/core.dart';

/// Una línea de un pedido nuevo.
class LineaPedido {
  const LineaPedido({required this.presentacionId, required this.cantidad});

  final String presentacionId;
  final int cantidad;
}

/// Pedido que el distribuidor toma a nombre de un cliente (por teléfono o
/// en persona). Los precios, la lista y el crédito los aplica la BD según
/// el cliente, no según quién lo registra.
class NuevoPedido {
  const NuevoPedido({
    required this.clienteId,
    required this.lineas,
    required this.condicionPago,
    required this.claveIdempotencia,
    this.metodoPago,
    this.nota,
  });

  final String clienteId;
  final List<LineaPedido> lineas;
  final CondicionPago condicionPago;

  /// Se genera una vez por intento de pedido y se reutiliza al reintentar:
  /// así un doble clic o un reintento no crea dos pedidos.
  final String claveIdempotencia;

  /// Cómo piensa pagar el cliente (solo informativo).
  final MetodoPago? metodoPago;
  final String? nota;
}

/// Por qué falló una operación de pedidos o pagos.
enum MotivoErrorPedidos {
  /// El rol no puede hacerlo, o el recurso es de otro distribuidor.
  sinPermiso,

  /// El pedido o el pago ya no existe o no se puede ver.
  noEncontrado,

  /// No alcanza la disponibilidad de algún producto.
  sinDisponibilidad,

  /// El distribuidor está suspendido o el cliente está inactivo.
  noPuedePedir,

  /// Crédito no habilitado, tope excedido o deuda vencida.
  credito,

  /// La operación no vale para el estado actual: transición inválida,
  /// cancelar con pagos sin anular, pagar un pedido cancelado, pago ya
  /// anulado.
  estadoNoPermite,

  /// Dato que la base de datos rechazó (por ejemplo, un pago mayor al
  /// saldo).
  datoInvalido,

  /// Red, servicio caído u otro fallo.
  desconocido,
}

class ErrorPedidos implements Exception {
  const ErrorPedidos(this.motivo, {this.detalle});

  final MotivoErrorPedidos motivo;

  /// Mensaje de la base de datos, si ayuda (nombra el producto sin stock).
  final String? detalle;

  @override
  String toString() => 'ErrorPedidos(${motivo.name})';
}

/// Pedidos y pagos de un distribuidor. Todo se escribe con las funciones
/// del contrato. Las operaciones que fallan lanzan [ErrorPedidos].
abstract interface class PedidosRepositorio {
  /// Los pedidos más recientes (hasta [limite]) con sus líneas y eventos.
  Future<List<Pedido>> listarPedidos(String distribuidorId, {int limite = 300});

  /// Todos los pedidos creados desde [desde], del más nuevo al más antiguo,
  /// **sin** líneas ni eventos (para resúmenes). Tope: 1000 pedidos.
  Future<List<Pedido>> listarPedidosDesde(
    String distribuidorId,
    DateTime desde,
  );

  /// Pedidos creados en `[desde, hasta)` **con sus líneas**, del más antiguo
  /// al más nuevo (para reportes y exportaciones). Los trae por páginas, así
  /// que no se corta en el tope de filas de la API; tope total: 10 000.
  Future<List<Pedido>> listarPedidosEntre(
    String distribuidorId,
    DateTime desde,
    DateTime hasta,
  );

  /// Pagos de un pedido, anulados incluidos, del más antiguo al más nuevo.
  Future<List<Pago>> listarPagos(String pedidoId);

  /// `crear_pedido` a nombre del cliente. Devuelve el id del pedido.
  Future<String> crearPedido(String distribuidorId, NuevoPedido pedido);

  /// `cambiar_estado_pedido`. Cancelar exige [nota].
  Future<void> cambiarEstado(
    String pedidoId,
    EstadoPedido estado, {
    String? nota,
  });

  /// `registrar_pago`: pago total o parcial, hasta el saldo.
  Future<void> registrarPago({
    required String pedidoId,
    required int montoCentimos,
    required MetodoPago metodo,
    String? referencia,
  });

  /// `anular_pago` (solo admin). Devuelve el monto al saldo.
  Future<void> anularPago(String pagoId, String motivo);
}
