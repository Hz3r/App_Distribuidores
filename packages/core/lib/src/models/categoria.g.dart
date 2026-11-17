// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categoria.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Categoria _$CategoriaFromJson(Map<String, dynamic> json) => _Categoria(
  id: json['id'] as String,
  distribuidorId: json['distribuidor_id'] as String,
  nombre: json['nombre'] as String,
  orden: (json['orden'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$CategoriaToJson(_Categoria instance) =>
    <String, dynamic>{
      'id': instance.id,
      'distribuidor_id': instance.distribuidorId,
      'nombre': instance.nombre,
      'orden': instance.orden,
    };
