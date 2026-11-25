import 'dart:math';

import 'package:core/core.dart';

import '../../../shared/formato.dart';

/// Pestañas de la pantalla Pedidos, en el orden en que se trabaja un pedido.
enum GrupoPedidos {
  /// Recibidos: falta que el distribuidor los acepte.
  porConfirmar,

  /// Aceptados: se están preparando.
  confirmados,

  /// Van hacia el cliente o esperan que los recoja.
  enCamino,

  entregados,
  cancelados,
}

GrupoPedidos grupoDe(EstadoPedido estado) => switch (estado) {
  EstadoPedido.recibido => GrupoPedidos.porConfirmar,
  EstadoPedido.confirmado => GrupoPedidos.confirmados,
  EstadoPedido.enCamino || EstadoPedido.listoRecojo => GrupoPedidos.enCamino,
  EstadoPedido.entregado => GrupoPedidos.entregados,
  EstadoPedido.cancelado => GrupoPedidos.cancelados,
};

/// El siguiente estado al que avanza [pedido], o null si ya terminó
/// (contrato, sección 4).
EstadoPedido? siguienteEstado(Pedido pedido) => switch (pedido.estado) {
  EstadoPedido.recibido => EstadoPedido.confirmado,
  EstadoPedido.confirmado =>
    pedido.despacho == DespachoPedido.reparto
        ? EstadoPedido.enCamino
        : EstadoPedido.listoRecojo,
  EstadoPedido.enCamino || EstadoPedido.listoRecojo => EstadoPedido.entregado,
  EstadoPedido.entregado || EstadoPedido.cancelado => null,
};

/// Un pedido se puede cancelar mientras no esté entregado ni cancelado.
bool sePuedeCancelar(Pedido pedido) =>
    pedido.estado != EstadoPedido.entregado &&
    pedido.estado != EstadoPedido.cancelado;

/// Lo ya cobrado de [pedido].
int pagadoCentimos(Pedido pedido) =>
    pedido.totalCentimos - pedido.saldoPendienteCentimos;

/// Se puede registrar un pago si no está cancelado y queda saldo.
bool sePuedeCobrar(Pedido pedido) =>
    pedido.estado != EstadoPedido.cancelado &&
    pedido.saldoPendienteCentimos > 0;

/// `true` si el pedido es a crédito, sigue con saldo y ya pasó su fecha.
bool creditoVencido(Pedido pedido, DateTime ahora) {
  final vence = pedido.venceEn;
  if (vence == null || pedido.saldoPendienteCentimos <= 0) return false;
  if (pedido.estado == EstadoPedido.cancelado) return false;
  final hoy = DateTime(ahora.year, ahora.month, ahora.day);
  return DateTime(vence.year, vence.month, vence.day).isBefore(hoy);
}

/// Pedidos que coinciden con la búsqueda: número (con o sin `#`) o nombre
/// del cliente. Conserva el orden.
List<Pedido> filtrarPedidos(
  List<Pedido> pedidos,
  String busqueda,
  Map<String, String> nombreCliente,
) {
  final buscado = normalizarBusqueda(busqueda).replaceFirst('#', '');
  if (buscado.isEmpty) return pedidos;
  return [
    for (final p in pedidos)
      if ('${p.numero}'.contains(buscado) ||
          normalizarBusqueda(nombreCliente[p.clienteId] ?? '')
              .contains(buscado))
        p,
  ];
}

/// Precio unitario que se cobraría por [cantidad] de [presentacion] a un
/// cliente sin lista de precios: el menor entre el precio base y el precio
/// por volumen que le toque (contrato, "Regla de precio"). Es una vista
/// previa: el precio final lo calcula la base de datos.
int precioEstimado(Presentacion presentacion, int cantidad) {
  var precio = presentacion.precioBaseCentimos;
  PrecioVolumen? mejor;
  for (final escala in presentacion.preciosVolumen) {
    if (escala.cantidadMinima <= cantidad &&
        (mejor == null || escala.cantidadMinima > mejor.cantidadMinima)) {
      mejor = escala;
    }
  }
  if (mejor != null && mejor.precioCentimos < precio) {
    precio = mejor.precioCentimos;
  }
  return precio;
}

/// Identificador único (UUID v4) para la clave de idempotencia de un pedido.
String nuevaClaveIdempotencia([Random? aleatorio]) {
  final azar = aleatorio ?? Random.secure();
  final bytes = List<int>.generate(16, (_) => azar.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = [for (final b in bytes) b.toRadixString(16).padLeft(2, '0')];
  return '${hex.sublist(0, 4).join()}-${hex.sublist(4, 6).join()}-'
      '${hex.sublist(6, 8).join()}-${hex.sublist(8, 10).join()}-'
      '${hex.sublist(10).join()}';
}
