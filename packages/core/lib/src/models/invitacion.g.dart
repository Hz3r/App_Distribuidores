// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitacion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Invitacion _$InvitacionFromJson(Map<String, dynamic> json) => _Invitacion(
  id: json['id'] as String,
  distribuidorId: json['distribuidor_id'] as String,
  codigo: json['codigo'] as String,
  rol: $enumDecode(_$RolMembresiaEnumMap, json['rol']),
  clienteNegocioId: json['cliente_negocio_id'] as String?,
  creadaPor: json['creada_por'] as String?,
  venceEn: DateTime.parse(json['vence_en'] as String),
  usadaPor: json['usada_por'] as String?,
  usadaEn: json['usada_en'] == null
      ? null
      : DateTime.parse(json['usada_en'] as String),
  revocadaEn: json['revocada_en'] == null
      ? null
      : DateTime.parse(json['revocada_en'] as String),
  creadoEn: DateTime.parse(json['creado_en'] as String),
);

Map<String, dynamic> _$InvitacionToJson(_Invitacion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'distribuidor_id': instance.distribuidorId,
      'codigo': instance.codigo,
      'rol': _$RolMembresiaEnumMap[instance.rol]!,
      'cliente_negocio_id': instance.clienteNegocioId,
      'creada_por': instance.creadaPor,
      'vence_en': instance.venceEn.toIso8601String(),
      'usada_por': instance.usadaPor,
      'usada_en': instance.usadaEn?.toIso8601String(),
      'revocada_en': instance.revocadaEn?.toIso8601String(),
      'creado_en': instance.creadoEn.toIso8601String(),
    };

const _$RolMembresiaEnumMap = {
  RolMembresia.admin: 'admin',
  RolMembresia.vendedor: 'vendedor',
  RolMembresia.repartidor: 'repartidor',
  RolMembresia.cliente: 'cliente',
};
