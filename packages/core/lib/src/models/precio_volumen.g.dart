// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'precio_volumen.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PrecioVolumen _$PrecioVolumenFromJson(Map<String, dynamic> json) =>
    _PrecioVolumen(
      id: json['id'] as String,
      distribuidorId: json['distribuidor_id'] as String,
      presentacionId: json['presentacion_id'] as String,
      cantidadMinima: (json['cantidad_minima'] as num).toInt(),
      precioCentimos: (json['precio_centimos'] as num).toInt(),
      creadoEn: DateTime.parse(json['creado_en'] as String),
    );

Map<String, dynamic> _$PrecioVolumenToJson(_PrecioVolumen instance) =>
    <String, dynamic>{
      'id': instance.id,
      'distribuidor_id': instance.distribuidorId,
      'presentacion_id': instance.presentacionId,
      'cantidad_minima': instance.cantidadMinima,
      'precio_centimos': instance.precioCentimos,
      'creado_en': instance.creadoEn.toIso8601String(),
    };
