import 'package:core/core.dart';

/// Lectura de los pedidos recientes de una bodega para el resumen del
/// inicio. Solo lee; el resumen se calcula en `resumirCompras`.
abstract interface class PedidosResumenRepositorio {
  /// Pedidos de la bodega [clienteId] en [distribuidorId] creados desde
  /// [desde] (inclusive), con sus líneas en `items`, del más reciente al más
  /// antiguo.
  Future<List<Pedido>> recientes({
    required String distribuidorId,
    required String clienteId,
    required DateTime desde,
  });

  /// El pedido más reciente de la bodega, de cualquier estado y sin límite
  /// de fecha, sin sus líneas; `null` si nunca hizo uno.
  Future<Pedido?> ultimo({
    required String distribuidorId,
    required String clienteId,
  });
}
