import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/catalogo.dart';
import '../domain/catalogo_repositorio.dart';

/// [CatalogoRepositorio] sobre Supabase. Delgado a propósito: tres lecturas
/// y su conversión a modelos; qué se muestra y a qué precio se decide en
/// `domain`. La RLS ya oculta a la bodega lo inactivo y las listas de precios
/// inactivas.
class CatalogoRepositorioSupabase implements CatalogoRepositorio {
  CatalogoRepositorioSupabase(this._cliente);

  final SupabaseClient _cliente;

  @override
  Future<Catalogo> cargar({
    required String distribuidorId,
    required bool esCliente,
  }) async {
    final (categorias, productos, preciosLista) = await (
      _cliente
          .from('categorias')
          .select()
          .eq('distribuidor_id', distribuidorId)
          .eq('activo', true),
      _cliente
          .from('productos')
          .select('*, presentaciones(*, precios_volumen(*))')
          .eq('distribuidor_id', distribuidorId)
          .eq('activo', true),
      _preciosLista(distribuidorId, esCliente),
    ).wait;
    return Catalogo.desde(
      distribuidorId: distribuidorId,
      categorias: categorias.map(Categoria.fromJson).toList(),
      productos: productos.map(Producto.fromJson).toList(),
      preciosLista: preciosLista,
    );
  }

  /// Solo una bodega tiene lista. Sin filtrar por `lista_precios_id`: la RLS
  /// ya limita las filas a la lista vigente y activa de su bodega, así que
  /// un cambio de lista durante la sesión se ve al recargar.
  Future<List<PrecioLista>> _preciosLista(
    String distribuidorId,
    bool esCliente,
  ) async {
    if (!esCliente) return const [];
    final filas = await _cliente
        .from('precios_lista')
        .select()
        .eq('distribuidor_id', distribuidorId);
    return filas.map(PrecioLista.fromJson).toList();
  }
}
