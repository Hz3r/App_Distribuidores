import 'package:core/core.dart';

import 'catalogo_repositorio.dart';

/// Guarda un producto con sus presentaciones.
///
/// - Sin [original]: crea el producto, sus presentaciones y, si
///   [disponibilidadInicial] es mayor a 0, registra el ingreso.
/// - Con [original]: actualiza el producto, crea las presentaciones nuevas y
///   actualiza solo las que cambiaron. Las presentaciones no se borran (los
///   pedidos las referencian): se desactivan.
///
/// No es una sola transacción: si falla a mitad, lo ya guardado queda y la
/// persona puede reintentar desde el formulario de edición.
Future<void> guardarProducto(
  CatalogoRepositorio repositorio, {
  required String distribuidorId,
  required DatosProducto datos,
  required List<DatosPresentacion> presentaciones,
  Producto? original,
  int disponibilidadInicial = 0,
}) async {
  final String productoId;
  if (original == null) {
    productoId = await repositorio.crearProducto(distribuidorId, datos);
  } else {
    productoId = original.id;
    await repositorio.actualizarProducto(productoId, datos);
  }

  final anteriores = {
    for (final p in original?.presentaciones ?? const <Presentacion>[]) p.id: p,
  };
  for (final (orden, presentacion) in presentaciones.indexed) {
    final anterior = anteriores[presentacion.id];
    if (anterior == null) {
      await repositorio.crearPresentacion(
        distribuidorId: distribuidorId,
        productoId: productoId,
        datos: presentacion,
        orden: orden,
      );
    } else if (_cambio(anterior, presentacion, orden)) {
      await repositorio.actualizarPresentacion(presentacion, orden);
    }
  }

  if (original == null && disponibilidadInicial > 0) {
    await repositorio.registrarMovimiento(
      productoId: productoId,
      tipo: TipoMovimientoStock.ingreso,
      cantidad: disponibilidadInicial,
      nota: 'Disponibilidad inicial',
    );
  }
}

bool _cambio(Presentacion anterior, DatosPresentacion nueva, int orden) =>
    anterior.nombre != nueva.nombre ||
    anterior.factor != nueva.factor ||
    anterior.precioBaseCentimos != nueva.precioBaseCentimos ||
    anterior.activo != nueva.activo ||
    anterior.orden != orden;
