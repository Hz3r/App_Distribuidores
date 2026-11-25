import 'package:core/core.dart';

import '../../../shared/formato.dart';

/// Productos que coinciden con la búsqueda (nombre, marca o SKU) y con la
/// categoría elegida. [categoriaId] nulo = todas. Conserva el orden.
List<Producto> filtrarProductos(
  List<Producto> productos, {
  String busqueda = '',
  String? categoriaId,
}) {
  final buscado = normalizarBusqueda(busqueda);
  return [
    for (final p in productos)
      if ((categoriaId == null || p.categoriaId == categoriaId) &&
          (buscado.isEmpty || _coincide(p, buscado)))
        p,
  ];
}

bool _coincide(Producto producto, String buscado) {
  for (final campo in [producto.nombre, producto.marca, producto.sku]) {
    if (campo != null && normalizarBusqueda(campo).contains(buscado)) {
      return true;
    }
  }
  return false;
}
