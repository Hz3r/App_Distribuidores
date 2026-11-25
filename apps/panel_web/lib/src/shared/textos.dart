import 'package:core/core.dart';

/// Nombre del rol para mostrar.
String rolLegible(RolMembresia rol) => switch (rol) {
  RolMembresia.admin => 'Administrador',
  RolMembresia.vendedor => 'Vendedor',
  RolMembresia.repartidor => 'Repartidor',
  RolMembresia.cliente => 'Cliente',
};

/// Estado comercial del distribuidor para mostrar.
String estadoDistribuidorLegible(EstadoDistribuidor estado) => switch (estado) {
  EstadoDistribuidor.prueba => 'En prueba',
  EstadoDistribuidor.activo => 'Activo',
  EstadoDistribuidor.suspendido => 'Suspendido',
  EstadoDistribuidor.cancelado => 'Cancelado',
};

/// Estado de un pedido para mostrar.
String estadoPedidoLegible(EstadoPedido estado) => switch (estado) {
  EstadoPedido.recibido => 'Por confirmar',
  EstadoPedido.confirmado => 'Confirmado',
  EstadoPedido.enCamino => 'En camino',
  EstadoPedido.listoRecojo => 'Listo para recoger',
  EstadoPedido.entregado => 'Entregado',
  EstadoPedido.cancelado => 'Cancelado',
};

/// Estado de cobro de un pedido para mostrar.
String estadoPagoLegible(EstadoPago estado) => switch (estado) {
  EstadoPago.pendiente => 'Sin pagar',
  EstadoPago.parcial => 'Pago parcial',
  EstadoPago.pagado => 'Pagado',
};

/// Método de pago para mostrar.
String metodoPagoLegible(MetodoPago metodo) => switch (metodo) {
  MetodoPago.efectivo => 'Efectivo',
  MetodoPago.billeteraDigital => 'Yape o Plin',
  MetodoPago.transferencia => 'Transferencia',
};
