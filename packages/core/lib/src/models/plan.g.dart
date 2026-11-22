// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Plan _$PlanFromJson(Map<String, dynamic> json) => _Plan(
  id: json['id'] as String,
  codigo: json['codigo'] as String,
  nombre: json['nombre'] as String,
  precioMensualCentimos: (json['precio_mensual_centimos'] as num).toInt(),
  moneda: json['moneda'] as String,
  limites: json['limites'] as Map<String, dynamic>,
  activo: json['activo'] as bool,
  creadoEn: DateTime.parse(json['creado_en'] as String),
);

Map<String, dynamic> _$PlanToJson(_Plan instance) => <String, dynamic>{
  'id': instance.id,
  'codigo': instance.codigo,
  'nombre': instance.nombre,
  'precio_mensual_centimos': instance.precioMensualCentimos,
  'moneda': instance.moneda,
  'limites': instance.limites,
  'activo': instance.activo,
  'creado_en': instance.creadoEn.toIso8601String(),
};
