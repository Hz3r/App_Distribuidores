import 'package:freezed_annotation/freezed_annotation.dart';

part 'pedido_item.freezed.dart';
part 'pedido_item.g.dart';

/// Línea de un pedido, tabla `pedido_items`. Guarda nombres y precio vigentes
/// al momento de la compra.
@freezed
abstract class PedidoItem with _$PedidoItem {
  const factory PedidoItem({
    required String id,
    required String distribuidorId,
    required String pedidoId,
    required String presentacionId,
    required String productoId,
    required String nombreProducto,
    required String nombrePresentacion,
    required int factor,
    required int cantidad,
    required int precioUnitarioCentimos,
    required int subtotalCentimos,
    required DateTime creadoEn,
  }) = _PedidoItem;

  factory PedidoItem.fromJson(Map<String, dynamic> json) =>
      _$PedidoItemFromJson(json);
}
