import 'catalogo.dart';

/// Lectura del catálogo de un distribuidor. Solo lee; las decisiones (qué se
/// muestra, a qué precio) están en las funciones puras de `domain`.
abstract interface class CatalogoRepositorio {
  /// Categorías, productos con sus presentaciones y precios por volumen, y,
  /// si [listaPreciosId] no es null, los precios de esa lista.
  Future<Catalogo> cargar({
    required String distribuidorId,
    String? listaPreciosId,
  });
}
