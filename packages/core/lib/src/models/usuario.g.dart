// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Usuario _$UsuarioFromJson(Map<String, dynamic> json) => _Usuario(
  id: json['id'] as String,
  distribuidorId: json['distribuidor_id'] as String,
  rol: $enumDecode(_$RolUsuarioEnumMap, json['rol']),
  nombre: json['nombre'] as String,
  telefono: json['telefono'] as String?,
);

Map<String, dynamic> _$UsuarioToJson(_Usuario instance) => <String, dynamic>{
  'id': instance.id,
  'distribuidor_id': instance.distribuidorId,
  'rol': _$RolUsuarioEnumMap[instance.rol]!,
  'nombre': instance.nombre,
  'telefono': instance.telefono,
};

const _$RolUsuarioEnumMap = {
  RolUsuario.admin: 'admin',
  RolUsuario.cliente: 'cliente',
  RolUsuario.repartidor: 'repartidor',
};
