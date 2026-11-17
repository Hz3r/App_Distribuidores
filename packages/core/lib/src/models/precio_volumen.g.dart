// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'precio_volumen.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PrecioVolumen _$PrecioVolumenFromJson(Map<String, dynamic> json) =>
    _PrecioVolumen(
      id: json['id'] as String,
      presentacionId: json['presentacion_id'] as String,
      cantidadMinima: (json['cantidad_minima'] as num).toInt(),
      precioCentimos: (json['precio_centimos'] as num).toInt(),
    );

Map<String, dynamic> _$PrecioVolumenToJson(_PrecioVolumen instance) =>
    <String, dynamic>{
      'id': instance.id,
      'presentacion_id': instance.presentacionId,
      'cantidad_minima': instance.cantidadMinima,
      'precio_centimos': instance.precioCentimos,
    };
