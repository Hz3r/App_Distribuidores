// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movimiento_stock.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MovimientoStock _$MovimientoStockFromJson(Map<String, dynamic> json) =>
    _MovimientoStock(
      id: json['id'] as String,
      distribuidorId: json['distribuidor_id'] as String,
      productoId: json['producto_id'] as String,
      tipo: $enumDecode(_$TipoMovimientoStockEnumMap, json['tipo']),
      deltaFisico: (json['delta_fisico'] as num).toInt(),
      deltaComprometido: (json['delta_comprometido'] as num).toInt(),
      pedidoId: json['pedido_id'] as String?,
      hechoPor: json['hecho_por'] as String?,
      nota: json['nota'] as String?,
      creadoEn: DateTime.parse(json['creado_en'] as String),
    );

Map<String, dynamic> _$MovimientoStockToJson(_MovimientoStock instance) =>
    <String, dynamic>{
      'id': instance.id,
      'distribuidor_id': instance.distribuidorId,
      'producto_id': instance.productoId,
      'tipo': _$TipoMovimientoStockEnumMap[instance.tipo]!,
      'delta_fisico': instance.deltaFisico,
      'delta_comprometido': instance.deltaComprometido,
      'pedido_id': instance.pedidoId,
      'hecho_por': instance.hechoPor,
      'nota': instance.nota,
      'creado_en': instance.creadoEn.toIso8601String(),
    };

const _$TipoMovimientoStockEnumMap = {
  TipoMovimientoStock.ingreso: 'ingreso',
  TipoMovimientoStock.ajuste: 'ajuste',
  TipoMovimientoStock.reserva: 'reserva',
  TipoMovimientoStock.liberacion: 'liberacion',
  TipoMovimientoStock.salida: 'salida',
};
