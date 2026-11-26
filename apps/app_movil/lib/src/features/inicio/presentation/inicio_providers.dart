import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../sesion/presentation/sesion_activa.dart';
import '../data/pedidos_resumen_repositorio_supabase.dart';
import '../domain/pedidos_resumen_repositorio.dart';
import '../domain/resumen_compras.dart';

part 'inicio_providers.g.dart';

/// Repositorio inyectable; las pruebas lo reemplazan con un doble.
///
/// Es el único lugar de `presentation` del inicio que construye la
/// implementación de `data`.
@Riverpod(keepAlive: true)
PedidosResumenRepositorio pedidosResumenRepositorio(Ref ref) =>
    PedidosResumenRepositorioSupabase(supabase);

/// Hora actual en UTC. Las pruebas la fijan para que el resumen no dependa
/// del día en que corren.
@Riverpod(keepAlive: true)
DateTime Function() reloj(Ref ref) =>
    () => DateTime.now().toUtc();

/// Resumen de compras de la bodega activa para el inicio.
///
/// Se recalcula al cambiar de distribuidor o de bodega;
/// `ref.invalidate(resumenComprasProvider)` lo refresca. Sin una membresía de
/// bodega activa falla con [StateError].
@riverpod
Future<ResumenCompras> resumenCompras(Ref ref) async {
  final (:distribuidorId, :clienteId) = ref.watch(
    membresiaActivaProvider.select(
      (m) =>
          (distribuidorId: m?.distribuidorId, clienteId: m?.clienteNegocioId),
    ),
  );
  if (distribuidorId == null || clienteId == null) {
    throw StateError('No hay una bodega activa para leer sus pedidos.');
  }
  final ahora = ref.read(relojProvider)();
  final repositorio = ref.watch(pedidosResumenRepositorioProvider);
  // El último pedido va aparte: puede tener más de 90 días.
  final (recientes, ultimo) = await (
    repositorio.recientes(
      distribuidorId: distribuidorId,
      clienteId: clienteId,
      desde: desdeParaResumen(
        ahora: ahora,
        desfaseZona: desfaseZonaDistribuidor,
      ),
    ),
    repositorio.ultimo(distribuidorId: distribuidorId, clienteId: clienteId),
  ).wait;
  return resumirCompras(
    recientes,
    ultimoPedido: ultimo,
    ahora: ahora,
    desfaseZona: desfaseZonaDistribuidor,
  );
}
