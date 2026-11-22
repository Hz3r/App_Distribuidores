import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'pedido_evento.freezed.dart';
part 'pedido_evento.g.dart';

/// Cambio de estado de un pedido, tabla `pedido_eventos`. El primero no tiene
/// [estadoAnterior].
@freezed
abstract class PedidoEvento with _$PedidoEvento {
  const factory PedidoEvento({
    required String id,
    required String distribuidorId,
    required String pedidoId,
    EstadoPedido? estadoAnterior,
    required EstadoPedido estadoNuevo,
    String? hechoPor,
    String? nota,
    required DateTime creadoEn,
  }) = _PedidoEvento;

  factory PedidoEvento.fromJson(Map<String, dynamic> json) =>
      _$PedidoEventoFromJson(json);
}
