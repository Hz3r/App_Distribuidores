// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membresia.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Membresia _$MembresiaFromJson(Map<String, dynamic> json) => _Membresia(
  id: json['id'] as String,
  perfilId: json['perfil_id'] as String,
  distribuidorId: json['distribuidor_id'] as String,
  rol: $enumDecode(_$RolMembresiaEnumMap, json['rol']),
  estado: $enumDecode(_$EstadoMembresiaEnumMap, json['estado']),
  clienteNegocioId: json['cliente_negocio_id'] as String?,
  creadoEn: DateTime.parse(json['creado_en'] as String),
  distribuidor: json['distribuidor'] == null
      ? null
      : Distribuidor.fromJson(json['distribuidor'] as Map<String, dynamic>),
  clienteNegocio: json['cliente_negocio'] == null
      ? null
      : ClienteNegocio.fromJson(
          json['cliente_negocio'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$MembresiaToJson(_Membresia instance) =>
    <String, dynamic>{
      'id': instance.id,
      'perfil_id': instance.perfilId,
      'distribuidor_id': instance.distribuidorId,
      'rol': _$RolMembresiaEnumMap[instance.rol]!,
      'estado': _$EstadoMembresiaEnumMap[instance.estado]!,
      'cliente_negocio_id': instance.clienteNegocioId,
      'creado_en': instance.creadoEn.toIso8601String(),
      'distribuidor': instance.distribuidor?.toJson(),
      'cliente_negocio': instance.clienteNegocio?.toJson(),
    };

const _$RolMembresiaEnumMap = {
  RolMembresia.admin: 'admin',
  RolMembresia.vendedor: 'vendedor',
  RolMembresia.repartidor: 'repartidor',
  RolMembresia.cliente: 'cliente',
};

const _$EstadoMembresiaEnumMap = {
  EstadoMembresia.activa: 'activa',
  EstadoMembresia.suspendida: 'suspendida',
};
