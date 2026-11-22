// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cliente_negocio.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClienteNegocio _$ClienteNegocioFromJson(Map<String, dynamic> json) =>
    _ClienteNegocio(
      id: json['id'] as String,
      distribuidorId: json['distribuidor_id'] as String,
      nombreNegocio: json['nombre_negocio'] as String,
      documento: json['documento'] as String?,
      direccion: json['direccion'] as String?,
      referencia: json['referencia'] as String?,
      telefono: json['telefono'] as String?,
      activo: json['activo'] as bool,
      creadoEn: DateTime.parse(json['creado_en'] as String),
      listaPreciosId: json['lista_precios_id'] as String?,
      creditoHabilitado: json['credito_habilitado'] as bool,
      limiteCreditoCentimos: (json['limite_credito_centimos'] as num?)?.toInt(),
      plazoCreditoDias: (json['plazo_credito_dias'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ClienteNegocioToJson(_ClienteNegocio instance) =>
    <String, dynamic>{
      'id': instance.id,
      'distribuidor_id': instance.distribuidorId,
      'nombre_negocio': instance.nombreNegocio,
      'documento': instance.documento,
      'direccion': instance.direccion,
      'referencia': instance.referencia,
      'telefono': instance.telefono,
      'activo': instance.activo,
      'creado_en': instance.creadoEn.toIso8601String(),
      'lista_precios_id': instance.listaPreciosId,
      'credito_habilitado': instance.creditoHabilitado,
      'limite_credito_centimos': instance.limiteCreditoCentimos,
      'plazo_credito_dias': instance.plazoCreditoDias,
    };
