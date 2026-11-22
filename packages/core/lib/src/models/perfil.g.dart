// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'perfil.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Perfil _$PerfilFromJson(Map<String, dynamic> json) => _Perfil(
  id: json['id'] as String,
  nombre: json['nombre'] as String,
  telefono: json['telefono'] as String?,
  esSuperAdmin: json['es_super_admin'] as bool,
  creadoEn: DateTime.parse(json['creado_en'] as String),
);

Map<String, dynamic> _$PerfilToJson(_Perfil instance) => <String, dynamic>{
  'id': instance.id,
  'nombre': instance.nombre,
  'telefono': instance.telefono,
  'es_super_admin': instance.esSuperAdmin,
  'creado_en': instance.creadoEn.toIso8601String(),
};
