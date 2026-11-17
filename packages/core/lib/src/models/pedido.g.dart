// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedido.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Pedido _$PedidoFromJson(Map<String, dynamic> json) => _Pedido(
  id: json['id'] as String,
  distribuidorId: json['distribuidor_id'] as String,
  clienteId: json['cliente_id'] as String,
  estado: $enumDecode(_$EstadoPedidoEnumMap, json['estado']),
  totalCentimos: (json['total_centimos'] as num).toInt(),
  creadoEn: DateTime.parse(json['creado_en'] as String),
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => PedidoItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <PedidoItem>[],
);

Map<String, dynamic> _$PedidoToJson(_Pedido instance) => <String, dynamic>{
  'id': instance.id,
  'distribuidor_id': instance.distribuidorId,
  'cliente_id': instance.clienteId,
  'estado': _$EstadoPedidoEnumMap[instance.estado]!,
  'total_centimos': instance.totalCentimos,
  'creado_en': instance.creadoEn.toIso8601String(),
  'items': instance.items.map((e) => e.toJson()).toList(),
};

const _$EstadoPedidoEnumMap = {
  EstadoPedido.recibido: 'recibido',
  EstadoPedido.confirmado: 'confirmado',
  EstadoPedido.enCamino: 'en_camino',
  EstadoPedido.listoRecojo: 'listo_recojo',
  EstadoPedido.entregado: 'entregado',
  EstadoPedido.cancelado: 'cancelado',
};
