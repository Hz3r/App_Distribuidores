import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../productos/presentation/catalogo_providers.dart';
import '../../sesion/presentation/control_acceso.dart';
import '../data/pedidos_repositorio_supabase.dart';
import '../domain/pedidos_repositorio.dart';

part 'pedidos_providers.g.dart';

/// Repositorio inyectable; las pruebas lo reemplazan con un doble. Único
/// lugar de `presentation` que construye la implementación de `data`.
@Riverpod(keepAlive: true)
PedidosRepositorio pedidosRepositorio(Ref ref) =>
    PedidosRepositorioSupabase(supabase);

/// Pedidos recientes del distribuidor activo, del más nuevo al más antiguo.
@riverpod
Future<List<Pedido>> pedidos(Ref ref) async {
  final membresia = ref.watch(membresiaActivaProvider);
  if (membresia == null) return const [];
  return ref
      .watch(pedidosRepositorioProvider)
      .listarPedidos(membresia.distribuidorId);
}

/// Pagos de un pedido.
@riverpod
Future<List<Pago>> pagosDePedido(Ref ref, String pedidoId) {
  return ref.watch(pedidosRepositorioProvider).listarPagos(pedidoId);
}

/// Escrituras de pedidos y pagos. Cada una vuelve a leer lo que cambió.
/// Lanzan [ErrorPedidos]; la pantalla lo convierte en mensaje con
/// [mensajeDePedidos].
///
/// `keepAlive`: las pantallas lo leen sin escucharlo y sus métodos siguen
/// usando el `ref` después de esperar a la red.
@Riverpod(keepAlive: true)
AccionesPedidos accionesPedidos(Ref ref) => AccionesPedidos(ref);

class AccionesPedidos {
  AccionesPedidos(this._ref);

  final Ref _ref;

  PedidosRepositorio get _repositorio => _ref.read(pedidosRepositorioProvider);

  /// Toma un pedido a nombre de un cliente. Devuelve el id del pedido.
  Future<String> crearPedido(NuevoPedido pedido) async {
    final membresia = _ref.read(membresiaActivaProvider);
    if (membresia == null) {
      throw const ErrorPedidos(MotivoErrorPedidos.sinPermiso);
    }
    final id = await _repositorio.crearPedido(membresia.distribuidorId, pedido);
    _ref.invalidate(pedidosProvider);
    // El pedido reserva disponibilidad.
    _ref.invalidate(productosProvider);
    return id;
  }

  Future<void> cambiarEstado(
    Pedido pedido,
    EstadoPedido estado, {
    String? nota,
  }) async {
    try {
      await _repositorio.cambiarEstado(pedido.id, estado, nota: nota);
    } finally {
      // Si falló porque otro ya lo movió, la lista en pantalla estaba vieja.
      _ref.invalidate(pedidosProvider);
      // Entregar y cancelar mueven la disponibilidad.
      _ref.invalidate(productosProvider);
    }
  }

  Future<void> registrarPago({
    required Pedido pedido,
    required int montoCentimos,
    required MetodoPago metodo,
    String? referencia,
  }) async {
    try {
      await _repositorio.registrarPago(
        pedidoId: pedido.id,
        montoCentimos: montoCentimos,
        metodo: metodo,
        referencia: referencia,
      );
    } finally {
      _ref.invalidate(pedidosProvider);
      _ref.invalidate(pagosDePedidoProvider(pedido.id));
    }
  }

  Future<void> anularPago(Pago pago, String motivo) async {
    try {
      await _repositorio.anularPago(pago.id, motivo);
    } finally {
      _ref.invalidate(pedidosProvider);
      _ref.invalidate(pagosDePedidoProvider(pago.pedidoId));
    }
  }
}

/// Mensaje para la persona según por qué falló la operación.
String mensajeDePedidos(Object error) {
  final motivo = error is ErrorPedidos
      ? error.motivo
      : MotivoErrorPedidos.desconocido;
  final detalle = error is ErrorPedidos ? error.detalle : null;
  return switch (motivo) {
    MotivoErrorPedidos.sinPermiso =>
      'Tu cuenta no puede hacer este cambio. Pídeselo al administrador.',
    MotivoErrorPedidos.noEncontrado =>
      'Ese pedido ya no está disponible. Actualiza la lista.',
    MotivoErrorPedidos.sinDisponibilidad =>
      detalle == null || detalle.isEmpty
          ? 'No hay disponibilidad suficiente de un producto.'
          : 'No hay disponibilidad suficiente. $detalle',
    MotivoErrorPedidos.noPuedePedir =>
      'No se pueden registrar pedidos: tu cuenta está suspendida o el '
          'cliente está inactivo.',
    MotivoErrorPedidos.credito =>
      'Este cliente no puede comprar a crédito ahora: no lo tiene '
          'habilitado, supera su tope o tiene una deuda vencida.',
    MotivoErrorPedidos.estadoNoPermite =>
      'El pedido cambió y ya no admite esta acción. Si quieres cancelarlo, '
          'primero anula sus pagos.',
    MotivoErrorPedidos.datoInvalido =>
      'Hay un dato que no es válido. Revísalo e inténtalo de nuevo.',
    MotivoErrorPedidos.desconocido =>
      'No pudimos guardar. Revisa tu conexión e inténtalo de nuevo.',
  };
}
