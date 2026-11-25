import 'package:core/core.dart';

/// Qué tanto queda de un producto para pedir.
enum NivelDisponibilidad {
  /// No queda nada disponible.
  agotado,

  /// Queda la quinta parte o menos de lo ofrecido.
  bajo,

  normal,
}

/// Nivel de [producto] según lo disponible frente a lo ofrecido.
NivelDisponibilidad nivelDe(Producto producto) {
  final disponible = producto.stockDisponible;
  if (disponible <= 0) return NivelDisponibilidad.agotado;
  if (disponible * 5 <= producto.stockFisico) return NivelDisponibilidad.bajo;
  return NivelDisponibilidad.normal;
}

/// Parte de lo ofrecido que sigue disponible, entre 0 y 1.
double proporcionDisponible(Producto producto) {
  if (producto.stockFisico <= 0) return 0;
  final proporcion = producto.stockDisponible / producto.stockFisico;
  return proporcion.clamp(0, 1).toDouble();
}

/// Por qué una nueva cantidad no se puede registrar.
enum ErrorCantidad {
  /// Es la misma que ya tiene.
  sinCambio,

  /// Queda por debajo de lo reservado en pedidos.
  bajoLoReservado,
}

/// Movimiento que lleva la cantidad ofrecida de un producto a un nuevo total.
typedef MovimientoCalculado = ({TipoMovimientoStock tipo, int cantidad});

/// Calcula el movimiento para que [producto] pase a ofrecer [nuevoTotal]
/// unidades base. Si sube, es un `ingreso`; si baja, un `ajuste` negativo.
/// Devuelve el error si no hay nada que registrar o si no se puede.
({MovimientoCalculado? movimiento, ErrorCantidad? error}) calcularMovimiento(
  Producto producto,
  int nuevoTotal,
) {
  final diferencia = nuevoTotal - producto.stockFisico;
  if (diferencia == 0) {
    return (movimiento: null, error: ErrorCantidad.sinCambio);
  }
  if (nuevoTotal < producto.stockComprometido) {
    return (movimiento: null, error: ErrorCantidad.bajoLoReservado);
  }
  return (
    movimiento: (
      tipo: diferencia > 0
          ? TipoMovimientoStock.ingreso
          : TipoMovimientoStock.ajuste,
      cantidad: diferencia,
    ),
    error: null,
  );
}
