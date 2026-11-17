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

/// Rol del usuario dentro de un distribuidor.
enum RolUsuario {
  @JsonValue('admin')
  admin,
  @JsonValue('cliente')
  cliente,
  @JsonValue('repartidor')
  repartidor,
}

/// Forma de venta de una presentación de producto.
enum TipoPresentacion {
  @JsonValue('botella')
  botella,
  @JsonValue('six_pack')
  sixPack,
  @JsonValue('caja')
  caja,
}
