// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedido_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PedidoItem _$PedidoItemFromJson(Map<String, dynamic> json) => _PedidoItem(
  id: json['id'] as String,
  distribuidorId: json['distribuidor_id'] as String,
  pedidoId: json['pedido_id'] as String,
  presentacionId: json['presentacion_id'] as String,
  productoId: json['producto_id'] as String,
  nombreProducto: json['nombre_producto'] as String,
  nombrePresentacion: json['nombre_presentacion'] as String,
  factor: (json['factor'] as num).toInt(),
  cantidad: (json['cantidad'] as num).toInt(),
  precioUnitarioCentimos: (json['precio_unitario_centimos'] as num).toInt(),
  subtotalCentimos: (json['subtotal_centimos'] as num).toInt(),
  creadoEn: DateTime.parse(json['creado_en'] as String),
);

Map<String, dynamic> _$PedidoItemToJson(_PedidoItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'distribuidor_id': instance.distribuidorId,
      'pedido_id': instance.pedidoId,
      'presentacion_id': instance.presentacionId,
      'producto_id': instance.productoId,
      'nombre_producto': instance.nombreProducto,
      'nombre_presentacion': instance.nombrePresentacion,
      'factor': instance.factor,
      'cantidad': instance.cantidad,
      'precio_unitario_centimos': instance.precioUnitarioCentimos,
      'subtotal_centimos': instance.subtotalCentimos,
      'creado_en': instance.creadoEn.toIso8601String(),
    };
