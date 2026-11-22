// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pago_suscripcion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PagoSuscripcion _$PagoSuscripcionFromJson(Map<String, dynamic> json) =>
    _PagoSuscripcion(
      id: json['id'] as String,
      distribuidorId: json['distribuidor_id'] as String,
      suscripcionId: json['suscripcion_id'] as String,
      montoCentimos: (json['monto_centimos'] as num).toInt(),
      metodo: json['metodo'] as String,
      periodoInicio: DateTime.parse(json['periodo_inicio'] as String),
      periodoFin: DateTime.parse(json['periodo_fin'] as String),
      registradoPor: json['registrado_por'] as String?,
      referenciaExterna: json['referencia_externa'] as String?,
      nota: json['nota'] as String?,
      creadoEn: DateTime.parse(json['creado_en'] as String),
    );

Map<String, dynamic> _$PagoSuscripcionToJson(_PagoSuscripcion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'distribuidor_id': instance.distribuidorId,
      'suscripcion_id': instance.suscripcionId,
      'monto_centimos': instance.montoCentimos,
      'metodo': instance.metodo,
      'periodo_inicio': instance.periodoInicio.toIso8601String(),
      'periodo_fin': instance.periodoFin.toIso8601String(),
      'registrado_por': instance.registradoPor,
      'referencia_externa': instance.referenciaExterna,
      'nota': instance.nota,
      'creado_en': instance.creadoEn.toIso8601String(),
    };
