import 'package:core/core.dart';
import 'package:panel_web/src/features/pedidos/domain/pedidos_repositorio.dart';

import 'dobles_clientes.dart';

/// Pedido de prueba del distribuidor `d1`, con una línea si no se pasan
/// [items]. Por defecto: recibido, reparto, contado y sin cobrar.
Pedido pedido(
  String id, {
  int numero = 1,
  String clienteId = 'c1',
  EstadoPedido estado = EstadoPedido.recibido,
  DespachoPedido despacho = DespachoPedido.reparto,
  CondicionPago condicion = CondicionPago.contado,
  int total = 10000,
  int? saldo,
  DateTime? venceEn,
  String? nota,
  String? motivoCancelacion,
  DateTime? creadoEn,
  List<PedidoItem>? items,
}) {
  final pendiente = saldo ?? total;
  return Pedido(
    id: id,
    distribuidorId: 'd1',
    numero: numero,
    clienteId: clienteId,
    estado: estado,
    despacho: despacho,
    direccionEntrega: 'Av. Los Olivos 123',
    notaCliente: nota,
    totalCentimos: total,
    condicionPago: condicion,
    estadoPago: pendiente == 0
        ? EstadoPago.pagado
        : pendiente == total
        ? EstadoPago.pendiente
        : EstadoPago.parcial,
    saldoPendienteCentimos: pendiente,
    plazoCreditoDias: condicion == CondicionPago.credito ? 15 : null,
    venceEn: venceEn,
    motivoCancelacion: motivoCancelacion,
    claveIdempotencia: 'clave-$id',
    creadoEn: creadoEn ?? ahoraDePrueba.subtract(const Duration(hours: 2)),
    items:
        items ??
        [
          PedidoItem(
            id: 'i-$id',
            distribuidorId: 'd1',
            pedidoId: id,
            presentacionId: 'pr1',
            productoId: 'p1',
            nombreProducto: 'Cerveza Lager',
            nombrePresentacion: 'Caja x12',
            factor: 12,
            cantidad: 2,
            precioUnitarioCentimos: total ~/ 2,
            subtotalCentimos: total,
            creadoEn: ahoraDePrueba,
          ),
        ],
    eventos: [
      PedidoEvento(
        id: 'e-$id',
        distribuidorId: 'd1',
        pedidoId: id,
        estadoNuevo: EstadoPedido.recibido,
        creadoEn: ahoraDePrueba.subtract(const Duration(hours: 2)),
      ),
    ],
  );
}

Pago pago(
  String id, {
  required String pedidoId,
  int monto = 4000,
  MetodoPago metodo = MetodoPago.efectivo,
  bool anulado = false,
}) {
  return Pago(
    id: id,
    distribuidorId: 'd1',
    pedidoId: pedidoId,
    clienteId: 'c1',
    montoCentimos: monto,
    metodo: metodo,
    anuladoEn: anulado ? ahoraDePrueba : null,
    creadoEn: ahoraDePrueba.subtract(const Duration(hours: 1)),
  );
}

/// Doble de [PedidosRepositorio]: devuelve listas fijas y anota cada
/// escritura en [llamadas], en orden. [fallarEn] hace fallar la operación
/// con ese nombre. Un cambio de estado se refleja en [pedidos].
class PedidosDoble implements PedidosRepositorio {
  PedidosDoble({List<Pedido>? pedidos, Map<String, List<Pago>>? pagos})
    : pedidos = pedidos ?? [],
      pagos = pagos ?? {};

  List<Pedido> pedidos;
  Map<String, List<Pago>> pagos;
  final llamadas = <String>[];
  String? fallarEn;
  MotivoErrorPedidos motivo = MotivoErrorPedidos.desconocido;
  int lecturas = 0;

  void _anotar(String operacion, String detalle) {
    if (fallarEn == operacion) throw ErrorPedidos(motivo);
    llamadas.add('$operacion $detalle');
  }

  @override
  Future<List<Pedido>> listarPedidos(
    String distribuidorId, {
    int limite = 300,
  }) async {
    lecturas++;
    if (fallarEn == 'listarPedidos') throw ErrorPedidos(motivo);
    return pedidos;
  }

  /// Fecha con la que se pidió el último resumen.
  DateTime? ultimoDesde;

  @override
  Future<List<Pedido>> listarPedidosDesde(
    String distribuidorId,
    DateTime desde,
  ) async {
    ultimoDesde = desde;
    if (fallarEn == 'listarPedidosDesde') throw ErrorPedidos(motivo);
    return [
      for (final p in pedidos)
        if (!p.creadoEn.isBefore(desde)) p,
    ];
  }

  @override
  Future<List<Pago>> listarPagos(String pedidoId) async =>
      pagos[pedidoId] ?? const [];

  @override
  Future<String> crearPedido(String distribuidorId, NuevoPedido nuevo) async {
    _anotar(
      'crearPedido',
      '$distribuidorId cliente=${nuevo.clienteId} '
          '${nuevo.lineas.map((l) => '${l.presentacionId}x${l.cantidad}').join(',')} '
          '${nuevo.condicionPago.name} metodo=${nuevo.metodoPago?.name} '
          'nota=${nuevo.nota}',
    );
    pedidos = [
      pedido('nuevo', numero: 99, clienteId: nuevo.clienteId),
      ...pedidos,
    ];
    return 'nuevo';
  }

  @override
  Future<void> cambiarEstado(
    String pedidoId,
    EstadoPedido estado, {
    String? nota,
  }) async {
    _anotar('cambiarEstado', '$pedidoId ${estado.name} nota=$nota');
    pedidos = [
      for (final p in pedidos)
        if (p.id == pedidoId)
          p.copyWith(estado: estado, motivoCancelacion: nota)
        else
          p,
    ];
  }

  @override
  Future<void> registrarPago({
    required String pedidoId,
    required int montoCentimos,
    required MetodoPago metodo,
    String? referencia,
  }) async {
    _anotar(
      'registrarPago',
      '$pedidoId $montoCentimos ${metodo.name} ref=$referencia',
    );
  }

  @override
  Future<void> anularPago(String pagoId, String motivo) async {
    _anotar('anularPago', '$pagoId $motivo');
  }
}
