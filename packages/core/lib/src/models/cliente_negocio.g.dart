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
      usuarioId: json['usuario_id'] as String?,
      direccion: json['direccion'] as String?,
    );

Map<String, dynamic> _$ClienteNegocioToJson(_ClienteNegocio instance) =>
    <String, dynamic>{
      'id': instance.id,
      'distribuidor_id': instance.distribuidorId,
      'nombre_negocio': instance.nombreNegocio,
      'usuario_id': instance.usuarioId,
      'direccion': instance.direccion,
    };
