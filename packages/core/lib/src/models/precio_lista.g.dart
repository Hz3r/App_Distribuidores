// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'precio_lista.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PrecioLista _$PrecioListaFromJson(Map<String, dynamic> json) => _PrecioLista(
  id: json['id'] as String,
  distribuidorId: json['distribuidor_id'] as String,
  listaPreciosId: json['lista_precios_id'] as String,
  presentacionId: json['presentacion_id'] as String,
  precioCentimos: (json['precio_centimos'] as num).toInt(),
  creadoEn: DateTime.parse(json['creado_en'] as String),
);

Map<String, dynamic> _$PrecioListaToJson(_PrecioLista instance) =>
    <String, dynamic>{
      'id': instance.id,
      'distribuidor_id': instance.distribuidorId,
      'lista_precios_id': instance.listaPreciosId,
      'presentacion_id': instance.presentacionId,
      'precio_centimos': instance.precioCentimos,
      'creado_en': instance.creadoEn.toIso8601String(),
    };
