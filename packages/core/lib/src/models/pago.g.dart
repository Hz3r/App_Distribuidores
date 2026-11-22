// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pago.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Pago _$PagoFromJson(Map<String, dynamic> json) => _Pago(
  id: json['id'] as String,
  distribuidorId: json['distribuidor_id'] as String,
  pedidoId: json['pedido_id'] as String,
  clienteId: json['cliente_id'] as String,
  montoCentimos: (json['monto_centimos'] as num).toInt(),
  metodo: $enumDecode(_$MetodoPagoEnumMap, json['metodo']),
  referencia: json['referencia'] as String?,
  nota: json['nota'] as String?,
  registradoPor: json['registrado_por'] as String?,
  anuladoEn: json['anulado_en'] == null
      ? null
      : DateTime.parse(json['anulado_en'] as String),
  anuladoPor: json['anulado_por'] as String?,
  creadoEn: DateTime.parse(json['creado_en'] as String),
);

Map<String, dynamic> _$PagoToJson(_Pago instance) => <String, dynamic>{
  'id': instance.id,
  'distribuidor_id': instance.distribuidorId,
  'pedido_id': instance.pedidoId,
  'cliente_id': instance.clienteId,
  'monto_centimos': instance.montoCentimos,
  'metodo': _$MetodoPagoEnumMap[instance.metodo]!,
  'referencia': instance.referencia,
  'nota': instance.nota,
  'registrado_por': instance.registradoPor,
  'anulado_en': instance.anuladoEn?.toIso8601String(),
  'anulado_por': instance.anuladoPor,
  'creado_en': instance.creadoEn.toIso8601String(),
};

const _$MetodoPagoEnumMap = {
  MetodoPago.efectivo: 'efectivo',
  MetodoPago.billeteraDigital: 'billetera_digital',
  MetodoPago.transferencia: 'transferencia',
};
