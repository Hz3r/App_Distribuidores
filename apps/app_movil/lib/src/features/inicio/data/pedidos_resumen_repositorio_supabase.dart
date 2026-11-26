import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/pedidos_resumen_repositorio.dart';

/// [PedidosResumenRepositorio] sobre Supabase. Una lectura de `pedidos` con
/// sus líneas embebidas. La RLS ya limita a la bodega a sus propios pedidos;
/// igual se filtra por distribuidor y bodega.
class PedidosResumenRepositorioSupabase implements PedidosResumenRepositorio {
  PedidosResumenRepositorioSupabase(this._cliente);

  final SupabaseClient _cliente;

  @override
  Future<List<Pedido>> recientes({
    required String distribuidorId,
    required String clienteId,
    required DateTime desde,
  }) async {
    final filas = await _cliente
        .from('pedidos')
        .select('*, items:pedido_items(*)')
        .eq('distribuidor_id', distribuidorId)
        .eq('cliente_id', clienteId)
        .gte('creado_en', desde.toUtc().toIso8601String())
        .order('creado_en', ascending: false);
    return filas.map(Pedido.fromJson).toList();
  }
}
