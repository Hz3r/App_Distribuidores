// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'distribuidor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Distribuidor _$DistribuidorFromJson(Map<String, dynamic> json) =>
    _Distribuidor(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      configTema: json['config_tema'] == null
          ? null
          : ConfigTema.fromJson(json['config_tema'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DistribuidorToJson(_Distribuidor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'config_tema': instance.configTema?.toJson(),
    };
