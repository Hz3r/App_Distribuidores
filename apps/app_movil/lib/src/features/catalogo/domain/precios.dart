import 'dart:math' as math;

import 'package:core/core.dart';

/// Regla de precio de la BD (`privado.precio_para`, ver `docs/contrato.md`),
/// repetida aquí solo para mostrar el mismo precio que la BD cobrará al crear
/// el pedido. Lógica pura: sin Flutter ni Supabase.

/// Precio unitario que se cobra por [cantidad] de una presentación: parte de
/// [precioLista] si no es null, o de [precioBase]; el tramo por volumen es
/// el de mayor cantidadMinima que no supere [cantidad]; se cobra el menor.
///
/// La lista sustituye al base (no se toma el menor entre ambos): con lista,
/// el base no cuenta.
int precioUnitario({
  required int precioBase,
  int? precioLista,
  required List<PrecioVolumen> preciosVolumen,
  required int cantidad,
}) {
  final partida = precioLista ?? precioBase;
  PrecioVolumen? tramo;
  for (final v in preciosVolumen) {
    if (v.cantidadMinima <= cantidad &&
        (tramo == null || v.cantidadMinima > tramo.cantidadMinima)) {
      tramo = v;
    }
  }
  return tramo == null ? partida : math.min(partida, tramo.precioCentimos);
}

/// Un rango de cantidades con el mismo precio unitario.
class TramoPrecio {
  const TramoPrecio({
    required this.desde,
    this.hasta,
    required this.precioCentimos,
  });

  /// Cantidad mínima del tramo.
  final int desde;

  /// Cantidad máxima del tramo; `null` en el último (sin tope).
  final int? hasta;

  /// Precio unitario en céntimos para cualquier cantidad del tramo.
  final int precioCentimos;

  @override
  bool operator ==(Object other) =>
      other is TramoPrecio &&
      other.desde == desde &&
      other.hasta == hasta &&
      other.precioCentimos == precioCentimos;

  @override
  int get hashCode => Object.hash(desde, hasta, precioCentimos);

  @override
  String toString() => 'TramoPrecio($desde–${hasta ?? ''}: $precioCentimos)';
}

/// Tramos para mostrar, empezando en 1. Tramos contiguos con el mismo
/// precio efectivo se funden en uno. Sin precios por volumen: un solo tramo.
///
/// El precio de cada tramo sale de [precioUnitario], así que coincide con lo
/// que se cobra por cualquier cantidad dentro de él.
List<TramoPrecio> tramosDePrecio({
  required int precioBase,
  int? precioLista,
  required List<PrecioVolumen> preciosVolumen,
}) {
  // El precio solo puede cambiar donde empieza un precio por volumen.
  final inicios = <int>{
    1,
    for (final v in preciosVolumen)
      if (v.cantidadMinima > 1) v.cantidadMinima,
  }.toList()..sort();

  final tramos = <TramoPrecio>[];
  for (var i = 0; i < inicios.length; i++) {
    final desde = inicios[i];
    final hasta = i + 1 < inicios.length ? inicios[i + 1] - 1 : null;
    final precio = precioUnitario(
      precioBase: precioBase,
      precioLista: precioLista,
      preciosVolumen: preciosVolumen,
      cantidad: desde,
    );
    if (tramos.isNotEmpty && tramos.last.precioCentimos == precio) {
      // Mismo precio que el anterior: se extiende ese tramo.
      final anterior = tramos.removeLast();
      tramos.add(
        TramoPrecio(
          desde: anterior.desde,
          hasta: hasta,
          precioCentimos: precio,
        ),
      );
    } else {
      tramos.add(
        TramoPrecio(desde: desde, hasta: hasta, precioCentimos: precio),
      );
    }
  }
  return tramos;
}
