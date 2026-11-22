// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'distribuidor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Distribuidor _$DistribuidorFromJson(Map<String, dynamic> json) =>
    _Distribuidor(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      slug: json['slug'] as String,
      rubro: json['rubro'] as String?,
      documento: json['documento'] as String?,
      telefono: json['telefono'] as String?,
      estado: $enumDecode(_$EstadoDistribuidorEnumMap, json['estado']),
      moneda: json['moneda'] as String,
      zonaHoraria: json['zona_horaria'] as String,
      configTema: ConfigTema.fromJson(
        json['config_tema'] as Map<String, dynamic>,
      ),
      creadoEn: DateTime.parse(json['creado_en'] as String),
    );

Map<String, dynamic> _$DistribuidorToJson(_Distribuidor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'slug': instance.slug,
      'rubro': instance.rubro,
      'documento': instance.documento,
      'telefono': instance.telefono,
      'estado': _$EstadoDistribuidorEnumMap[instance.estado]!,
      'moneda': instance.moneda,
      'zona_horaria': instance.zonaHoraria,
      'config_tema': instance.configTema.toJson(),
      'creado_en': instance.creadoEn.toIso8601String(),
    };

const _$EstadoDistribuidorEnumMap = {
  EstadoDistribuidor.prueba: 'prueba',
  EstadoDistribuidor.activo: 'activo',
  EstadoDistribuidor.suspendido: 'suspendido',
  EstadoDistribuidor.cancelado: 'cancelado',
};
