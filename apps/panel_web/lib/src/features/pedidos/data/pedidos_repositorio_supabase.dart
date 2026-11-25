import 'dart:developer' as developer;

import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/pedidos_repositorio.dart';

/// [PedidosRepositorio] sobre Supabase. Lee con `select` y escribe solo con
/// las funciones del contrato (sección 3), pasando los parámetros por nombre.
class PedidosRepositorioSupabase implements PedidosRepositorio {
  PedidosRepositorioSupabase(this._cliente);

  final SupabaseClient _cliente;

  // `order` de supabase-dart ordena de mayor a menor si no se le dice.

  @override
  Future<List<Pedido>> listarPedidos(
    String distribuidorId, {
    int limite = 300,
  }) {
    return _intentar(() async {
      final filas = await _cliente
          .from('pedidos')
          .select('*, items:pedido_items(*), eventos:pedido_eventos(*)')
          .eq('distribuidor_id', distribuidorId)
          .order('creado_en', ascending: false)
          .limit(limite);
      return [for (final fila in filas) _ordenado(Pedido.fromJson(fila))];
    });
  }

  @override
  Future<List<Pedido>> listarPedidosDesde(
    String distribuidorId,
    DateTime desde,
  ) {
    return _intentar(() async {
      final filas = await _cliente
          .from('pedidos')
          .select()
          .eq('distribuidor_id', distribuidorId)
          .gte('creado_en', desde.toUtc().toIso8601String())
          .order('creado_en', ascending: false)
          .limit(1000);
      return filas.map(Pedido.fromJson).toList();
    });
  }

  @override
  Future<List<Pago>> listarPagos(String pedidoId) {
    return _intentar(() async {
      final filas = await _cliente
          .from('pagos')
          .select()
          .eq('pedido_id', pedidoId)
          .order('creado_en', ascending: true);
      return filas.map(Pago.fromJson).toList();
    });
  }

  @override
  Future<String> crearPedido(String distribuidorId, NuevoPedido pedido) {
    return _intentar(() async {
      final id = await _cliente.rpc<String>(
        'crear_pedido',
        params: {
          'p_distribuidor_id': distribuidorId,
          'p_items': [
            for (final linea in pedido.lineas)
              {
                'presentacion_id': linea.presentacionId,
                'cantidad': linea.cantidad,
              },
          ],
          'p_clave_idempotencia': pedido.claveIdempotencia,
          // El MVP solo reparte a la tienda (decisión de producto).
          'p_despacho': 'reparto',
          'p_condicion_pago': _condicion(pedido.condicionPago),
          'p_cliente_id': pedido.clienteId,
          'p_metodo_pago': switch (pedido.metodoPago) {
            null => null,
            final metodo => _metodo(metodo),
          },
          'p_nota': _oNulo(pedido.nota),
        },
      );
      return id;
    });
  }

  @override
  Future<void> cambiarEstado(
    String pedidoId,
    EstadoPedido estado, {
    String? nota,
  }) {
    return _intentar(() async {
      await _cliente.rpc<void>(
        'cambiar_estado_pedido',
        params: {
          'p_pedido_id': pedidoId,
          'p_estado': _estado(estado),
          'p_nota': _oNulo(nota),
        },
      );
    });
  }

  @override
  Future<void> registrarPago({
    required String pedidoId,
    required int montoCentimos,
    required MetodoPago metodo,
    String? referencia,
  }) {
    return _intentar(() async {
      await _cliente.rpc<void>(
        'registrar_pago',
        params: {
          'p_pedido_id': pedidoId,
          'p_monto_centimos': montoCentimos,
          'p_metodo': _metodo(metodo),
          'p_referencia': _oNulo(referencia),
        },
      );
    });
  }

  @override
  Future<void> anularPago(String pagoId, String motivo) {
    return _intentar(() async {
      await _cliente.rpc<void>(
        'anular_pago',
        params: {'p_pago_id': pagoId, 'p_nota': motivo.trim()},
      );
    });
  }

  // Valores de los enums tal como están en la BD (snake_case).

  String _estado(EstadoPedido estado) => switch (estado) {
    EstadoPedido.recibido => 'recibido',
    EstadoPedido.confirmado => 'confirmado',
    EstadoPedido.enCamino => 'en_camino',
    EstadoPedido.listoRecojo => 'listo_recojo',
    EstadoPedido.entregado => 'entregado',
    EstadoPedido.cancelado => 'cancelado',
  };

  String _metodo(MetodoPago metodo) => switch (metodo) {
    MetodoPago.efectivo => 'efectivo',
    MetodoPago.billeteraDigital => 'billetera_digital',
    MetodoPago.transferencia => 'transferencia',
  };

  String _condicion(CondicionPago condicion) => switch (condicion) {
    CondicionPago.contado => 'contado',
    CondicionPago.credito => 'credito',
  };

  String? _oNulo(String? texto) {
    final limpio = texto?.trim() ?? '';
    return limpio.isEmpty ? null : limpio;
  }

  /// Líneas por nombre de producto y eventos del más antiguo al más nuevo:
  /// las relaciones embebidas llegan sin orden garantizado.
  Pedido _ordenado(Pedido pedido) {
    return pedido.copyWith(
      items: [...pedido.items]
        ..sort((a, b) => a.nombreProducto.compareTo(b.nombreProducto)),
      eventos: [...pedido.eventos]
        ..sort((a, b) => a.creadoEn.compareTo(b.creadoEn)),
    );
  }

  Future<T> _intentar<T>(Future<T> Function() operacion) async {
    try {
      return await operacion();
    } on ErrorPedidos {
      rethrow;
    } on PostgrestException catch (e, st) {
      // Contrato, sección 3, "Códigos de error".
      final motivo = switch (e.code) {
        '42501' => MotivoErrorPedidos.sinPermiso,
        'P0002' => MotivoErrorPedidos.noEncontrado,
        'P0001' => MotivoErrorPedidos.sinDisponibilidad,
        'P0003' => MotivoErrorPedidos.noPuedePedir,
        'P0004' => MotivoErrorPedidos.credito,
        'P0006' => MotivoErrorPedidos.estadoNoPermite,
        '22023' => MotivoErrorPedidos.datoInvalido,
        _ => MotivoErrorPedidos.desconocido,
      };
      _registrar(e, st);
      throw ErrorPedidos(motivo, detalle: e.message);
    } catch (e, st) {
      _registrar(e, st);
      throw const ErrorPedidos(MotivoErrorPedidos.desconocido);
    }
  }

  void _registrar(Object error, StackTrace pila) {
    developer.log(
      'Falló una operación de pedidos.',
      name: 'pedidos',
      error: error,
      stackTrace: pila,
    );
  }
}
