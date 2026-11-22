import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'pedido_evento.dart';
import 'pedido_item.dart';

part 'pedido.freezed.dart';
part 'pedido.g.dart';

/// Pedido de un cliente a un distribuidor, tabla `pedidos`. Montos en céntimos.
///
/// [items] y [eventos] solo vienen llenos si la consulta los embebe con este alias:
/// `select('*, items:pedido_items(*), eventos:pedido_eventos(*)')`.
@freezed
abstract class Pedido with _$Pedido {
  const factory Pedido({
    required String id,
    required String distribuidorId,
    required int numero,
    required String clienteId,
    String? creadoPor,
    String? repartidorId,
    required EstadoPedido estado,
    required DespachoPedido despacho,
    String? direccionEntrega,
    String? notaCliente,
    required int totalCentimos,
    required CondicionPago condicionPago,
    MetodoPago? metodoPago,
    required EstadoPago estadoPago,
    required int saldoPendienteCentimos,
    int? plazoCreditoDias,
    DateTime? venceEn,
    String? motivoCancelacion,
    required String claveIdempotencia,
    DateTime? entregadoEn,
    required DateTime creadoEn,
    @Default(<PedidoItem>[]) List<PedidoItem> items,
    @Default(<PedidoEvento>[]) List<PedidoEvento> eventos,
  }) = _Pedido;

  factory Pedido.fromJson(Map<String, dynamic> json) => _$PedidoFromJson(json);
}
