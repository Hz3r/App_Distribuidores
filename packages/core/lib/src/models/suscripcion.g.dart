// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suscripcion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Suscripcion _$SuscripcionFromJson(Map<String, dynamic> json) => _Suscripcion(
  id: json['id'] as String,
  distribuidorId: json['distribuidor_id'] as String,
  planId: json['plan_id'] as String,
  estado: $enumDecode(_$EstadoSuscripcionEnumMap, json['estado']),
  periodoInicio: DateTime.parse(json['periodo_inicio'] as String),
  periodoFin: DateTime.parse(json['periodo_fin'] as String),
  proveedorPago: json['proveedor_pago'] as String?,
  referenciaExterna: json['referencia_externa'] as String?,
  creadoEn: DateTime.parse(json['creado_en'] as String),
);

Map<String, dynamic> _$SuscripcionToJson(_Suscripcion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'distribuidor_id': instance.distribuidorId,
      'plan_id': instance.planId,
      'estado': _$EstadoSuscripcionEnumMap[instance.estado]!,
      'periodo_inicio': instance.periodoInicio.toIso8601String(),
      'periodo_fin': instance.periodoFin.toIso8601String(),
      'proveedor_pago': instance.proveedorPago,
      'referencia_externa': instance.referenciaExterna,
      'creado_en': instance.creadoEn.toIso8601String(),
    };

const _$EstadoSuscripcionEnumMap = {
  EstadoSuscripcion.prueba: 'prueba',
  EstadoSuscripcion.activa: 'activa',
  EstadoSuscripcion.vencida: 'vencida',
  EstadoSuscripcion.cancelada: 'cancelada',
};
