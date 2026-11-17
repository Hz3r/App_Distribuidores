// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'producto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Producto _$ProductoFromJson(Map<String, dynamic> json) => _Producto(
  id: json['id'] as String,
  distribuidorId: json['distribuidor_id'] as String,
  categoriaId: json['categoria_id'] as String,
  nombre: json['nombre'] as String,
  descripcion: json['descripcion'] as String?,
  imagenUrl: json['imagen_url'] as String?,
  activo: json['activo'] as bool? ?? true,
);

Map<String, dynamic> _$ProductoToJson(_Producto instance) => <String, dynamic>{
  'id': instance.id,
  'distribuidor_id': instance.distribuidorId,
  'categoria_id': instance.categoriaId,
  'nombre': instance.nombre,
  'descripcion': instance.descripcion,
  'imagen_url': instance.imagenUrl,
  'activo': instance.activo,
};
