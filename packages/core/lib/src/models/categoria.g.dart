// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categoria.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Categoria _$CategoriaFromJson(Map<String, dynamic> json) => _Categoria(
  id: json['id'] as String,
  distribuidorId: json['distribuidor_id'] as String,
  nombre: json['nombre'] as String,
  orden: (json['orden'] as num).toInt(),
  activo: json['activo'] as bool,
  creadoEn: DateTime.parse(json['creado_en'] as String),
);

Map<String, dynamic> _$CategoriaToJson(_Categoria instance) =>
    <String, dynamic>{
      'id': instance.id,
      'distribuidor_id': instance.distribuidorId,
      'nombre': instance.nombre,
      'orden': instance.orden,
      'activo': instance.activo,
      'creado_en': instance.creadoEn.toIso8601String(),
    };
