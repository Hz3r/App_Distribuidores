// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'producto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Producto _$ProductoFromJson(Map<String, dynamic> json) => _Producto(
  id: json['id'] as String,
  distribuidorId: json['distribuidor_id'] as String,
  categoriaId: json['categoria_id'] as String?,
  nombre: json['nombre'] as String,
  descripcion: json['descripcion'] as String?,
  marca: json['marca'] as String?,
  sku: json['sku'] as String?,
  imagenUrl: json['imagen_url'] as String?,
  unidadBase: json['unidad_base'] as String,
  stockFisico: (json['stock_fisico'] as num).toInt(),
  stockComprometido: (json['stock_comprometido'] as num).toInt(),
  activo: json['activo'] as bool,
  creadoEn: DateTime.parse(json['creado_en'] as String),
  presentaciones:
      (json['presentaciones'] as List<dynamic>?)
          ?.map((e) => Presentacion.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Presentacion>[],
);

Map<String, dynamic> _$ProductoToJson(_Producto instance) => <String, dynamic>{
  'id': instance.id,
  'distribuidor_id': instance.distribuidorId,
  'categoria_id': instance.categoriaId,
  'nombre': instance.nombre,
  'descripcion': instance.descripcion,
  'marca': instance.marca,
  'sku': instance.sku,
  'imagen_url': instance.imagenUrl,
  'unidad_base': instance.unidadBase,
  'stock_fisico': instance.stockFisico,
  'stock_comprometido': instance.stockComprometido,
  'activo': instance.activo,
  'creado_en': instance.creadoEn.toIso8601String(),
  'presentaciones': instance.presentaciones.map((e) => e.toJson()).toList(),
};
