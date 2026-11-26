import 'package:core/core.dart';

import 'disponibilidad.dart';
import 'precios.dart';

/// Catálogo de un distribuidor tal como lo ve la bodega. Lógica pura: sin
/// Flutter ni Supabase.
class Catalogo {
  const Catalogo({
    required this.categorias,
    required this.productos,
    required this.preciosLista,
  });

  /// Arma el catálogo con lo leído de la BD: deja las categorías activas,
  /// ordenadas por `orden` y nombre, y pasa [preciosLista] a un mapa por
  /// presentación.
  factory Catalogo.desde({
    required List<Categoria> categorias,
    required List<Producto> productos,
    required List<PrecioLista> preciosLista,
  }) {
    final activas = [
      for (final c in categorias)
        if (c.activo) c,
    ]..sort((a, b) => _porOrdenYNombre(a.orden, a.nombre, b.orden, b.nombre));
    return Catalogo(
      categorias: activas,
      productos: productos,
      preciosLista: {
        for (final p in preciosLista) p.presentacionId: p.precioCentimos,
      },
    );
  }

  /// Activas, por `orden` y nombre.
  final List<Categoria> categorias;

  /// Con `presentaciones` y sus `preciosVolumen`.
  final List<Producto> productos;

  /// presentacionId → céntimos, de la lista de precios de la bodega. Vacío
  /// si no tiene lista (o si está inactiva: la BD no deja leerla).
  final Map<String, int> preciosLista;
}

/// Un producto listo para mostrar en el catálogo con su presentación
/// principal.
class ProductoEnCatalogo {
  const ProductoEnCatalogo({
    required this.producto,
    required this.principal,
    required this.disponible,
    required this.precioCentimos,
  });

  final Producto producto;

  /// Activa de menor `orden` (desempate por nombre).
  final Presentacion principal;

  /// Presentaciones completas disponibles de la principal.
  final int disponible;

  /// Precio unitario de la principal para cantidad 1.
  final int precioCentimos;

  bool get agotado => disponible <= 0;
}

/// Productos con al menos una presentación activa. Orden inicial: por nombre.
///
/// Además de lo que ya oculta la BD a una bodega, descarta los productos
/// inactivos y los de una categoría que no está entre las activas del
/// catálogo: `crear_pedido` los rechazaría.
List<ProductoEnCatalogo> productosDelCatalogo(Catalogo catalogo) {
  final categoriasActivas = {for (final c in catalogo.categorias) c.id};
  final resultado = <ProductoEnCatalogo>[];
  for (final producto in catalogo.productos) {
    if (!producto.activo) continue;
    final categoriaId = producto.categoriaId;
    if (categoriaId != null && !categoriasActivas.contains(categoriaId)) {
      continue;
    }
    final principal = presentacionesActivas(producto).firstOrNull;
    if (principal == null) continue;
    resultado.add(
      ProductoEnCatalogo(
        producto: producto,
        principal: principal,
        disponible: disponiblePresentacion(
          stockFisico: producto.stockFisico,
          stockComprometido: producto.stockComprometido,
          factor: principal.factor,
        ),
        precioCentimos: precioUnitario(
          precioBase: principal.precioBaseCentimos,
          precioLista: catalogo.preciosLista[principal.id],
          preciosVolumen: principal.preciosVolumen,
          cantidad: 1,
        ),
      ),
    );
  }
  resultado.sort((a, b) => compararTexto(a.producto.nombre, b.producto.nombre));
  return resultado;
}

/// Presentaciones activas del producto, por `orden` y nombre.
List<Presentacion> presentacionesActivas(Producto producto) => [
  for (final p in producto.presentaciones)
    if (p.activo) p,
]..sort((a, b) => _porOrdenYNombre(a.orden, a.nombre, b.orden, b.nombre));

/// Texto en minúsculas y sin tildes (también `ñ` → `n`), para buscar y
/// ordenar sin que importen. Acepta las tildes como letra única o como
/// marca combinada aparte (`a` + U+0301).
String normalizarTexto(String texto) {
  final salida = StringBuffer();
  for (final codigo in texto.toLowerCase().runes) {
    // Marcas diacríticas combinadas (U+0300–U+036F): se descartan.
    if (codigo >= 0x300 && codigo <= 0x36F) continue;
    final caracter = String.fromCharCode(codigo);
    salida.write(_sinTilde[caracter] ?? caracter);
  }
  return salida.toString();
}

/// Compara sin distinguir mayúsculas ni tildes; si así empatan, por el
/// texto original, para que el orden sea estable.
int compararTexto(String a, String b) {
  final porNormalizado = normalizarTexto(a).compareTo(normalizarTexto(b));
  return porNormalizado != 0 ? porNormalizado : a.compareTo(b);
}

int _porOrdenYNombre(int ordenA, String nombreA, int ordenB, String nombreB) {
  final porOrden = ordenA.compareTo(ordenB);
  return porOrden != 0 ? porOrden : compararTexto(nombreA, nombreB);
}

const _sinTilde = {
  'á': 'a', 'à': 'a', 'ä': 'a', 'â': 'a', //
  'é': 'e', 'è': 'e', 'ë': 'e', 'ê': 'e', //
  'í': 'i', 'ì': 'i', 'ï': 'i', 'î': 'i', //
  'ó': 'o', 'ò': 'o', 'ö': 'o', 'ô': 'o', //
  'ú': 'u', 'ù': 'u', 'ü': 'u', 'û': 'u', //
  'ñ': 'n', 'ç': 'c',
};
