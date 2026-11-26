import 'dart:math' as math;

import 'package:core/core.dart';

import '../../carrito/domain/carrito.dart';

/// Cuántas presentaciones completas se pueden vender: (físico − comprometido)
/// ÷ [factor], hacia abajo, nunca negativo (ver `docs/contrato.md`).
int disponiblePresentacion({
  required int stockFisico,
  required int stockComprometido,
  required int factor,
}) => math.max(0, (stockFisico - stockComprometido) ~/ factor);

/// Máximo de [presentacion] que el carrito puede tener (incluido lo que ya
/// tiene de ella). El stock es del producto: `crear_pedido` suma las unidades
/// base de todas sus presentaciones, así que se descuenta lo que el carrito
/// ya reserva con las OTRAS presentaciones de [producto]. Nunca negativo.
int disponibleEnCarrito({
  required Producto producto,
  required Presentacion presentacion,
  required Carrito carrito,
}) {
  var enOtras = 0;
  for (final otra in producto.presentaciones) {
    if (otra.id == presentacion.id) continue;
    enOtras += carrito.cantidadDe(otra.id) * otra.factor;
  }
  return math.max(
    0,
    (producto.stockFisico - producto.stockComprometido - enOtras) ~/
        presentacion.factor,
  );
}
