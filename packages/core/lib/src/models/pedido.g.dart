// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedido.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Pedido _$PedidoFromJson(Map<String, dynamic> json) => _Pedido(
  id: json['id'] as String,
  distribuidorId: json['distribuidor_id'] as String,
  numero: (json['numero'] as num).toInt(),
  clienteId: json['cliente_id'] as String,
  creadoPor: json['creado_por'] as String?,
  repartidorId: json['repartidor_id'] as String?,
  estado: $enumDecode(_$EstadoPedidoEnumMap, json['estado']),
  despacho: $enumDecode(_$DespachoPedidoEnumMap, json['despacho']),
  direccionEntrega: json['direccion_entrega'] as String?,
  notaCliente: json['nota_cliente'] as String?,
  totalCentimos: (json['total_centimos'] as num).toInt(),
  condicionPago: $enumDecode(_$CondicionPagoEnumMap, json['condicion_pago']),
  metodoPago: $enumDecodeNullable(_$MetodoPagoEnumMap, json['metodo_pago']),
  estadoPago: $enumDecode(_$EstadoPagoEnumMap, json['estado_pago']),
  saldoPendienteCentimos: (json['saldo_pendiente_centimos'] as num).toInt(),
  plazoCreditoDias: (json['plazo_credito_dias'] as num?)?.toInt(),
  venceEn: json['vence_en'] == null
      ? null
      : DateTime.parse(json['vence_en'] as String),
  motivoCancelacion: json['motivo_cancelacion'] as String?,
  claveIdempotencia: json['clave_idempotencia'] as String,
  entregadoEn: json['entregado_en'] == null
      ? null
      : DateTime.parse(json['entregado_en'] as String),
  creadoEn: DateTime.parse(json['creado_en'] as String),
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => PedidoItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <PedidoItem>[],
  eventos:
      (json['eventos'] as List<dynamic>?)
          ?.map((e) => PedidoEvento.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <PedidoEvento>[],
);

Map<String, dynamic> _$PedidoToJson(_Pedido instance) => <String, dynamic>{
  'id': instance.id,
  'distribuidor_id': instance.distribuidorId,
  'numero': instance.numero,
  'cliente_id': instance.clienteId,
  'creado_por': instance.creadoPor,
  'repartidor_id': instance.repartidorId,
  'estado': _$EstadoPedidoEnumMap[instance.estado]!,
  'despacho': _$DespachoPedidoEnumMap[instance.despacho]!,
  'direccion_entrega': instance.direccionEntrega,
  'nota_cliente': instance.notaCliente,
  'total_centimos': instance.totalCentimos,
  'condicion_pago': _$CondicionPagoEnumMap[instance.condicionPago]!,
  'metodo_pago': _$MetodoPagoEnumMap[instance.metodoPago],
  'estado_pago': _$EstadoPagoEnumMap[instance.estadoPago]!,
  'saldo_pendiente_centimos': instance.saldoPendienteCentimos,
  'plazo_credito_dias': instance.plazoCreditoDias,
  'vence_en': instance.venceEn?.toIso8601String(),
  'motivo_cancelacion': instance.motivoCancelacion,
  'clave_idempotencia': instance.claveIdempotencia,
  'entregado_en': instance.entregadoEn?.toIso8601String(),
  'creado_en': instance.creadoEn.toIso8601String(),
  'items': instance.items.map((e) => e.toJson()).toList(),
  'eventos': instance.eventos.map((e) => e.toJson()).toList(),
};

const _$EstadoPedidoEnumMap = {
  EstadoPedido.recibido: 'recibido',
  EstadoPedido.confirmado: 'confirmado',
  EstadoPedido.enCamino: 'en_camino',
  EstadoPedido.listoRecojo: 'listo_recojo',
  EstadoPedido.entregado: 'entregado',
  EstadoPedido.cancelado: 'cancelado',
};

const _$DespachoPedidoEnumMap = {
  DespachoPedido.recojo: 'recojo',
  DespachoPedido.reparto: 'reparto',
};

const _$CondicionPagoEnumMap = {
  CondicionPago.contado: 'contado',
  CondicionPago.credito: 'credito',
};

const _$MetodoPagoEnumMap = {
  MetodoPago.efectivo: 'efectivo',
  MetodoPago.billeteraDigital: 'billetera_digital',
  MetodoPago.transferencia: 'transferencia',
};

const _$EstadoPagoEnumMap = {
  EstadoPago.pendiente: 'pendiente',
  EstadoPago.parcial: 'parcial',
  EstadoPago.pagado: 'pagado',
};
