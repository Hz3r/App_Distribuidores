// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presentacion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Presentacion _$PresentacionFromJson(Map<String, dynamic> json) =>
    _Presentacion(
      id: json['id'] as String,
      distribuidorId: json['distribuidor_id'] as String,
      productoId: json['producto_id'] as String,
      nombre: json['nombre'] as String,
      factor: (json['factor'] as num).toInt(),
      precioBaseCentimos: (json['precio_base_centimos'] as num).toInt(),
      orden: (json['orden'] as num).toInt(),
      activo: json['activo'] as bool,
      creadoEn: DateTime.parse(json['creado_en'] as String),
      preciosVolumen:
          (json['precios_volumen'] as List<dynamic>?)
              ?.map((e) => PrecioVolumen.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <PrecioVolumen>[],
    );

Map<String, dynamic> _$PresentacionToJson(
  _Presentacion instance,
) => <String, dynamic>{
  'id': instance.id,
  'distribuidor_id': instance.distribuidorId,
  'producto_id': instance.productoId,
  'nombre': instance.nombre,
  'factor': instance.factor,
  'precio_base_centimos': instance.precioBaseCentimos,
  'orden': instance.orden,
  'activo': instance.activo,
  'creado_en': instance.creadoEn.toIso8601String(),
  'precios_volumen': instance.preciosVolumen.map((e) => e.toJson()).toList(),
};
