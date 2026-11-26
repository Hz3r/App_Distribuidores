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
    String? listaPreciosId,
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
      _preciosLista(distribuidorId, listaPreciosId),
    ).wait;
    return Catalogo.desde(
      categorias: categorias.map(Categoria.fromJson).toList(),
      productos: productos.map(Producto.fromJson).toList(),
      preciosLista: preciosLista,
    );
  }

  Future<List<PrecioLista>> _preciosLista(
    String distribuidorId,
    String? listaPreciosId,
  ) async {
    if (listaPreciosId == null) return const [];
    final filas = await _cliente
        .from('precios_lista')
        .select()
        .eq('distribuidor_id', distribuidorId)
        .eq('lista_precios_id', listaPreciosId);
    return filas.map(PrecioLista.fromJson).toList();
  }
}
