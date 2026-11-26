import 'catalogo.dart';

/// Lectura del catálogo de un distribuidor. Solo lee; las decisiones (qué se
/// muestra, a qué precio) están en las funciones puras de `domain`.
abstract interface class CatalogoRepositorio {
  /// Categorías, productos con sus presentaciones y precios por volumen, y,
  /// si [esCliente], los precios de la lista vigente de su bodega. La lista
  /// no se pide por id: la RLS da a la bodega solo su lista actual y activa,
  /// aunque el admin la haya cambiado durante la sesión. El catálogo lleva
  /// [distribuidorId] en `Catalogo.distribuidorId`.
  Future<Catalogo> cargar({
    required String distribuidorId,
    required bool esCliente,
  });
}
