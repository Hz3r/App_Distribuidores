import 'package:freezed_annotation/freezed_annotation.dart';

part 'pedido_item.freezed.dart';
part 'pedido_item.g.dart';

/// Línea de un pedido. Guarda el precio vigente al momento de la compra.
@freezed
abstract class PedidoItem with _$PedidoItem {
  const factory PedidoItem({
    required String id,
    required String pedidoId,
    required String presentacionId,
    required int cantidad,
    required int precioUnitarioCentimos,
  }) = _PedidoItem;

  factory PedidoItem.fromJson(Map<String, dynamic> json) =>
      _$PedidoItemFromJson(json);
}
