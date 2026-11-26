import 'catalogo.dart';

/// Cómo se ordena el catálogo.
enum OrdenCatalogo { nombre, precioMenor, precioMayor }

/// Filtros que la persona eligió en el catálogo. Inmutable.
class FiltrosCatalogo {
  const FiltrosCatalogo({
    this.categoriaId,
    this.marca,
    this.busqueda = '',
    this.orden = OrdenCatalogo.nombre,
  });

  /// `null`: todas las categorías.
  final String? categoriaId;

  /// `null`: todas las marcas.
  final String? marca;

  /// Texto tal como lo escribió la persona.
  final String busqueda;

  final OrdenCatalogo orden;

  /// Hay algo que deja productos fuera (el orden no cuenta).
  bool get hayFiltros =>
      categoriaId != null || marca != null || busqueda.trim().isNotEmpty;

  /// Copia con los cambios dados. [categoriaId] y [marca] no se pueden
  /// volver `null` pasándolos: para eso, [limpiarCategoria] y [limpiarMarca].
  FiltrosCatalogo copyWith({
    String? categoriaId,
    bool limpiarCategoria = false,
    String? marca,
    bool limpiarMarca = false,
    String? busqueda,
    OrdenCatalogo? orden,
  }) => FiltrosCatalogo(
    categoriaId: limpiarCategoria ? null : (categoriaId ?? this.categoriaId),
    marca: limpiarMarca ? null : (marca ?? this.marca),
    busqueda: busqueda ?? this.busqueda,
    orden: orden ?? this.orden,
  );

  @override
  bool operator ==(Object other) =>
      other is FiltrosCatalogo &&
      other.categoriaId == categoriaId &&
      other.marca == marca &&
      other.busqueda == busqueda &&
      other.orden == orden;

  @override
  int get hashCode => Object.hash(categoriaId, marca, busqueda, orden);

  @override
  String toString() =>
      'FiltrosCatalogo(categoriaId: $categoriaId, marca: $marca, '
      'busqueda: "$busqueda", orden: ${orden.name})';
}

/// Filtra por categoría, marca y texto (en nombre o marca, sin distinguir
/// mayúsculas ni tildes) y ordena.
///
/// El texto se parte en palabras y cada una debe ser el comienzo de alguna
/// palabra del nombre o de la marca ("ron" encuentra "Ron Añejo" pero no
/// "Portón"). Devuelve una lista nueva.
List<ProductoEnCatalogo> aplicarFiltros(
  List<ProductoEnCatalogo> productos,
  FiltrosCatalogo filtros,
) {
  final marca = filtros.marca == null
      ? null
      : normalizarTexto(filtros.marca!.trim());
  final buscadas = _palabras(filtros.busqueda);

  final resultado = [
    for (final p in productos)
      if ((filtros.categoriaId == null ||
              p.producto.categoriaId == filtros.categoriaId) &&
          (marca == null ||
              normalizarTexto(p.producto.marca?.trim() ?? '') == marca) &&
          _coincide(p, buscadas))
        p,
  ];

  int porNombre(ProductoEnCatalogo a, ProductoEnCatalogo b) =>
      compararTexto(a.producto.nombre, b.producto.nombre);
  resultado.sort(switch (filtros.orden) {
    OrdenCatalogo.nombre => porNombre,
    OrdenCatalogo.precioMenor => (a, b) {
      final c = a.precioCentimos.compareTo(b.precioCentimos);
      return c != 0 ? c : porNombre(a, b);
    },
    OrdenCatalogo.precioMayor => (a, b) {
      final c = b.precioCentimos.compareTo(a.precioCentimos);
      return c != 0 ? c : porNombre(a, b);
    },
  });
  return resultado;
}

/// Marcas distintas no vacías, ordenadas. Dos marcas que solo difieren en
/// mayúsculas, tildes o espacios a los lados cuentan como una (la primera
/// que aparece).
List<String> marcasDisponibles(List<ProductoEnCatalogo> productos) {
  final porClave = <String, String>{};
  for (final p in productos) {
    final marca = p.producto.marca?.trim() ?? '';
    if (marca.isEmpty) continue;
    porClave.putIfAbsent(normalizarTexto(marca), () => marca);
  }
  return porClave.values.toList()..sort(compararTexto);
}

/// Palabras normalizadas de [texto], sin vacías.
List<String> _palabras(String texto) =>
    normalizarTexto(texto)
        .split(RegExp(r'[^a-z0-9]+'))
        .where((w) => w.isNotEmpty)
        .toList();

bool _coincide(ProductoEnCatalogo p, List<String> buscadas) {
  if (buscadas.isEmpty) return true;
  final palabras = [
    ..._palabras(p.producto.nombre),
    ..._palabras(p.producto.marca ?? ''),
  ];
  return buscadas.every((b) => palabras.any((w) => w.startsWith(b)));
}
