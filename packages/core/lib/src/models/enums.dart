import 'package:json_annotation/json_annotation.dart';

/// Estados del ciclo de vida de un pedido. Valores en BD: snake_case.
enum EstadoPedido {
  @JsonValue('recibido')
  recibido,
  @JsonValue('confirmado')
  confirmado,
  @JsonValue('en_camino')
  enCamino,
  @JsonValue('listo_recojo')
  listoRecojo,
  @JsonValue('entregado')
  entregado,
  @JsonValue('cancelado')
  cancelado,
}

/// Rol de una membresía o invitación (`rol_membresia` en la BD).
enum RolMembresia {
  @JsonValue('admin')
  admin,
  @JsonValue('vendedor')
  vendedor,
  @JsonValue('repartidor')
  repartidor,
  @JsonValue('cliente')
  cliente,
}

/// Estado de una membresía (`estado_membresia` en la BD).
enum EstadoMembresia {
  @JsonValue('activa')
  activa,
  @JsonValue('suspendida')
  suspendida,
}

/// Estado comercial del distribuidor (`estado_distribuidor` en la BD).
enum EstadoDistribuidor {
  @JsonValue('prueba')
  prueba,
  @JsonValue('activo')
  activo,
  @JsonValue('suspendido')
  suspendido,
  @JsonValue('cancelado')
  cancelado,
}

/// Tipo de movimiento del kardex (`tipo_movimiento_stock` en la BD).
enum TipoMovimientoStock {
  @JsonValue('ingreso')
  ingreso,
  @JsonValue('ajuste')
  ajuste,
  @JsonValue('reserva')
  reserva,
  @JsonValue('liberacion')
  liberacion,
  @JsonValue('salida')
  salida,
}

/// Forma de entrega de un pedido (`despacho_pedido` en la BD).
enum DespachoPedido {
  @JsonValue('recojo')
  recojo,
  @JsonValue('reparto')
  reparto,
}

/// Condición de pago de un pedido (`condicion_pago` en la BD).
enum CondicionPago {
  @JsonValue('contado')
  contado,
  @JsonValue('credito')
  credito,
}

/// Método con el que se paga (`metodo_pago` en la BD).
enum MetodoPago {
  @JsonValue('efectivo')
  efectivo,
  @JsonValue('billetera_digital')
  billeteraDigital,
  @JsonValue('transferencia')
  transferencia,
}

/// Estado de cobro de un pedido (`estado_pago` en la BD).
enum EstadoPago {
  @JsonValue('pendiente')
  pendiente,
  @JsonValue('parcial')
  parcial,
  @JsonValue('pagado')
  pagado,
}

/// Estado de la suscripción del distribuidor (`estado_suscripcion` en la BD).
enum EstadoSuscripcion {
  @JsonValue('prueba')
  prueba,
  @JsonValue('activa')
  activa,
  @JsonValue('vencida')
  vencida,
  @JsonValue('cancelada')
  cancelada,
}
