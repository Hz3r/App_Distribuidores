import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'pedido_item.dart';

part 'pedido.freezed.dart';
part 'pedido.g.dart';

/// Pedido de un cliente a un distribuidor.
@freezed
abstract class Pedido with _$Pedido {
  const factory Pedido({
    required String id,
    required String distribuidorId,
    required String clienteId,
    required EstadoPedido estado,
    required int totalCentimos,
    required DateTime creadoEn,
    @Default(<PedidoItem>[]) List<PedidoItem> items,
  }) = _Pedido;

  factory Pedido.fromJson(Map<String, dynamic> json) => _$PedidoFromJson(json);
}
