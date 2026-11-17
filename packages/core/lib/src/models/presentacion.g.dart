// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presentacion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Presentacion _$PresentacionFromJson(Map<String, dynamic> json) =>
    _Presentacion(
      id: json['id'] as String,
      productoId: json['producto_id'] as String,
      tipo: $enumDecode(_$TipoPresentacionEnumMap, json['tipo']),
      nombre: json['nombre'] as String,
      precioBaseCentimos: (json['precio_base_centimos'] as num).toInt(),
      stock: (json['stock'] as num).toInt(),
      unidadesPorPresentacion:
          (json['unidades_por_presentacion'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$PresentacionToJson(_Presentacion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'producto_id': instance.productoId,
      'tipo': _$TipoPresentacionEnumMap[instance.tipo]!,
      'nombre': instance.nombre,
      'precio_base_centimos': instance.precioBaseCentimos,
      'stock': instance.stock,
      'unidades_por_presentacion': instance.unidadesPorPresentacion,
    };

const _$TipoPresentacionEnumMap = {
  TipoPresentacion.botella: 'botella',
  TipoPresentacion.sixPack: 'six_pack',
  TipoPresentacion.caja: 'caja',
};
