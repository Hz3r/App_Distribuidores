// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lista_precios.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ListaPrecios _$ListaPreciosFromJson(Map<String, dynamic> json) =>
    _ListaPrecios(
      id: json['id'] as String,
      distribuidorId: json['distribuidor_id'] as String,
      nombre: json['nombre'] as String,
      activo: json['activo'] as bool,
      creadoEn: DateTime.parse(json['creado_en'] as String),
    );

Map<String, dynamic> _$ListaPreciosToJson(_ListaPrecios instance) =>
    <String, dynamic>{
      'id': instance.id,
      'distribuidor_id': instance.distribuidorId,
      'nombre': instance.nombre,
      'activo': instance.activo,
      'creado_en': instance.creadoEn.toIso8601String(),
    };
