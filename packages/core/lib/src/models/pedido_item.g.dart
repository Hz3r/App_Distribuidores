// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedido_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PedidoItem _$PedidoItemFromJson(Map<String, dynamic> json) => _PedidoItem(
  id: json['id'] as String,
  pedidoId: json['pedido_id'] as String,
  presentacionId: json['presentacion_id'] as String,
  cantidad: (json['cantidad'] as num).toInt(),
  precioUnitarioCentimos: (json['precio_unitario_centimos'] as num).toInt(),
);

Map<String, dynamic> _$PedidoItemToJson(_PedidoItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pedido_id': instance.pedidoId,
      'presentacion_id': instance.presentacionId,
      'cantidad': instance.cantidad,
      'precio_unitario_centimos': instance.precioUnitarioCentimos,
    };
