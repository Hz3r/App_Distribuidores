// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedido_evento.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PedidoEvento _$PedidoEventoFromJson(Map<String, dynamic> json) =>
    _PedidoEvento(
      id: json['id'] as String,
      distribuidorId: json['distribuidor_id'] as String,
      pedidoId: json['pedido_id'] as String,
      estadoAnterior: $enumDecodeNullable(
        _$EstadoPedidoEnumMap,
        json['estado_anterior'],
      ),
      estadoNuevo: $enumDecode(_$EstadoPedidoEnumMap, json['estado_nuevo']),
      hechoPor: json['hecho_por'] as String?,
      nota: json['nota'] as String?,
      creadoEn: DateTime.parse(json['creado_en'] as String),
    );

Map<String, dynamic> _$PedidoEventoToJson(_PedidoEvento instance) =>
    <String, dynamic>{
      'id': instance.id,
      'distribuidor_id': instance.distribuidorId,
      'pedido_id': instance.pedidoId,
      'estado_anterior': _$EstadoPedidoEnumMap[instance.estadoAnterior],
      'estado_nuevo': _$EstadoPedidoEnumMap[instance.estadoNuevo]!,
      'hecho_por': instance.hechoPor,
      'nota': instance.nota,
      'creado_en': instance.creadoEn.toIso8601String(),
    };

const _$EstadoPedidoEnumMap = {
  EstadoPedido.recibido: 'recibido',
  EstadoPedido.confirmado: 'confirmado',
  EstadoPedido.enCamino: 'en_camino',
  EstadoPedido.listoRecojo: 'listo_recojo',
  EstadoPedido.entregado: 'entregado',
  EstadoPedido.cancelado: 'cancelado',
};
