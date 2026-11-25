import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/tema_panel.dart';
import '../../../shared/formato.dart';
import '../../../shared/textos.dart';
import '../../../shared/widgets/estados.dart';
import '../../../shared/widgets/etiqueta.dart';
import '../../clientes/presentation/clientes_providers.dart';
import '../../sesion/presentation/control_acceso.dart';
import '../domain/flujo_pedido.dart';
import 'pedido_dialogos.dart';
import 'pedidos_providers.dart';

/// Tono de la etiqueta de cada estado de pedido.
TonoEtiqueta tonoDeEstado(EstadoPedido estado) => switch (estado) {
  EstadoPedido.recibido => TonoEtiqueta.aviso,
  EstadoPedido.confirmado ||
  EstadoPedido.enCamino ||
  EstadoPedido.listoRecojo => TonoEtiqueta.info,
  EstadoPedido.entregado => TonoEtiqueta.exito,
  EstadoPedido.cancelado => TonoEtiqueta.peligro,
};

/// Tono de la etiqueta de cada estado de cobro.
TonoEtiqueta tonoDePago(EstadoPago estado) => switch (estado) {
  EstadoPago.pendiente => TonoEtiqueta.neutro,
  EstadoPago.parcial => TonoEtiqueta.aviso,
  EstadoPago.pagado => TonoEtiqueta.exito,
};

/// Detalle de un pedido: cliente, productos, cobros, historial y las
/// acciones que admite su estado. Lee el pedido de la lista ya cargada, así
/// se actualiza solo cuando cambia.
class PedidoDetalle extends ConsumerStatefulWidget {
  const PedidoDetalle({required this.pedidoId, this.alCerrar, super.key});

  final String pedidoId;

  /// Si viene, muestra un botón para cerrar el detalle.
  final VoidCallback? alCerrar;

  @override
  ConsumerState<PedidoDetalle> createState() => _PedidoDetalleState();
}

class _PedidoDetalleState extends ConsumerState<PedidoDetalle> {
  bool _ocupado = false;

  Future<void> _avanzar(Pedido pedido, EstadoPedido estado) async {
    if (_ocupado) return;
    final avisos = ScaffoldMessenger.maybeOf(context);
    setState(() => _ocupado = true);
    try {
      await ref.read(accionesPedidosProvider).cambiarEstado(pedido, estado);
      avisos?.showSnackBar(
        SnackBar(
          content: Text(
            'Pedido #${pedido.numero}: ${estadoPedidoLegible(estado).toLowerCase()}.',
          ),
        ),
      );
    } catch (e) {
      avisos?.showSnackBar(SnackBar(content: Text(mensajeDePedidos(e))));
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _cancelar(Pedido pedido) async {
    final avisos = ScaffoldMessenger.maybeOf(context);
    final cancelado = await mostrarCancelarPedido(context, pedido);
    if (cancelado == true) {
      avisos?.showSnackBar(
        SnackBar(content: Text('Pedido #${pedido.numero} cancelado.')),
      );
    }
  }

  Future<void> _cobrar(Pedido pedido) async {
    final avisos = ScaffoldMessenger.maybeOf(context);
    final registrado = await RegistrarPagoDialogo.mostrar(context, pedido);
    if (registrado == true) {
      avisos?.showSnackBar(const SnackBar(content: Text('Pago registrado.')));
    }
  }

  Future<void> _anular(Pago pago) async {
    final avisos = ScaffoldMessenger.maybeOf(context);
    final anulado = await mostrarAnularPago(context, pago);
    if (anulado == true) {
      avisos?.showSnackBar(const SnackBar(content: Text('Pago anulado.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pedidos = ref.watch(pedidosProvider).value ?? const <Pedido>[];
    final pedido = pedidos.where((p) => p.id == widget.pedidoId).firstOrNull;
    final alCerrar = widget.alCerrar;

    if (pedido == null) {
      return EstadoAviso(
        icono: Icons.receipt_long_outlined,
        titulo: 'Este pedido ya no está en la lista',
        mensaje: 'Elige otro pedido.',
        accion: alCerrar == null
            ? null
            : OutlinedButton(onPressed: alCerrar, child: const Text('Cerrar')),
      );
    }

    final tema = Theme.of(context);
    final clientes =
        ref.watch(clientesProvider).value ?? const <ClienteNegocio>[];
    final cliente = clientes.where((c) => c.id == pedido.clienteId).firstOrNull;
    final esAdmin =
        ref.watch(membresiaActivaProvider)?.rol == RolMembresia.admin;
    final siguiente = siguienteEstado(pedido);
    final ahora = ref.watch(relojProvider)();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pedido #${pedido.numero}',
                      style: tema.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Recibido el ${fechaHoraCorta(pedido.creadoEn)}',
                      style: tema.textTheme.bodySmall?.copyWith(
                        color: ColoresPanel.neutro500,
                      ),
                    ),
                  ],
                ),
              ),
              Etiqueta(
                estadoPedidoLegible(pedido.estado),
                tono: tonoDeEstado(pedido.estado),
              ),
              if (alCerrar != null)
                IconButton(
                  tooltip: 'Cerrar detalle',
                  onPressed: alCerrar,
                  icon: const Icon(Icons.close),
                )
              else
                const SizedBox(width: 12),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Caja(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.storefront_outlined,
                        color: ColoresPanel.primario500,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cliente?.nombreNegocio ?? 'Cliente',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: ColoresPanel.neutro900,
                              ),
                            ),
                            Text(
                              pedido.direccionEntrega ??
                                  'Sin dirección de entrega',
                              style: const TextStyle(
                                fontSize: 12,
                                color: ColoresPanel.neutro500,
                              ),
                            ),
                            if (cliente?.telefono case final telefono?)
                              Text(
                                'Cel. $telefono',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: ColoresPanel.neutro500,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (pedido.notaCliente case final nota?) ...[
                  const SizedBox(height: 12),
                  _Caja(
                    color: ColoresPanel.aviso100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nota del cliente',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ColoresPanel.aviso500,
                          ),
                        ),
                        Text(
                          nota,
                          style: const TextStyle(color: ColoresPanel.neutro900),
                        ),
                      ],
                    ),
                  ),
                ],
                if (pedido.motivoCancelacion case final motivo?) ...[
                  const SizedBox(height: 12),
                  _Caja(
                    color: ColoresPanel.peligro100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Motivo de la cancelación',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ColoresPanel.peligro500,
                          ),
                        ),
                        Text(
                          motivo,
                          style: const TextStyle(color: ColoresPanel.neutro900),
                        ),
                      ],
                    ),
                  ),
                ],
                const _TituloSeccion('Productos'),
                for (final item in pedido.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.nombreProducto,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: ColoresPanel.neutro900,
                                ),
                              ),
                              Text(
                                '${item.cantidad} × ${item.nombrePresentacion} '
                                'a ${item.precioUnitarioCentimos.formatoSoles}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: ColoresPanel.neutro500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          item.subtotalCentimos.formatoSoles,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: ColoresPanel.neutro900,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Divider(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Expanded(child: Text('Total')),
                    Text(
                      pedido.totalCentimos.formatoSoles,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: ColoresPanel.primario900,
                      ),
                    ),
                  ],
                ),
                const _TituloSeccion('Cobro'),
                _Cobro(
                  pedido: pedido,
                  vencido: creditoVencido(pedido, ahora),
                  esAdmin: esAdmin,
                  alCobrar: sePuedeCobrar(pedido)
                      ? () => _cobrar(pedido)
                      : null,
                  alAnular: _anular,
                ),
                const _TituloSeccion('Historial'),
                for (final evento in pedido.eventos)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            evento.nota == null || evento.nota!.isEmpty
                                ? estadoPedidoLegible(evento.estadoNuevo)
                                : '${estadoPedidoLegible(evento.estadoNuevo)}: '
                                      '${evento.nota}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          fechaHoraCorta(evento.creadoEn),
                          style: const TextStyle(
                            fontSize: 12,
                            color: ColoresPanel.neutro500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (siguiente != null || sePuedeCancelar(pedido)) ...[
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (sePuedeCancelar(pedido))
                  // Ancho propio: en un `Expanded` angosto el texto se partía
                  // en dos líneas.
                  IntrinsicWidth(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColoresPanel.peligro500,
                        side: const BorderSide(
                          color: ColoresPanel.peligro500,
                          width: 1.5,
                        ),
                      ),
                      onPressed: _ocupado ? null : () => _cancelar(pedido),
                      child: Text(
                        pedido.estado == EstadoPedido.recibido
                            ? 'Rechazar'
                            : 'Cancelar pedido',
                      ),
                    ),
                  ),
                if (siguiente != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _ocupado
                          ? null
                          : () => _avanzar(pedido, siguiente),
                      child: _ocupado
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_accionPara(siguiente)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

String _accionPara(EstadoPedido siguiente) => switch (siguiente) {
  EstadoPedido.confirmado => 'Confirmar pedido',
  EstadoPedido.enCamino => 'Marcar en camino',
  EstadoPedido.listoRecojo => 'Marcar listo para recoger',
  EstadoPedido.entregado => 'Marcar entregado',
  EstadoPedido.recibido || EstadoPedido.cancelado => 'Continuar',
};

/// Estado del cobro del pedido, sus pagos y el botón para registrar otro.
class _Cobro extends ConsumerWidget {
  const _Cobro({
    required this.pedido,
    required this.vencido,
    required this.esAdmin,
    required this.alCobrar,
    required this.alAnular,
  });

  final Pedido pedido;
  final bool vencido;
  final bool esAdmin;
  final VoidCallback? alCobrar;
  final void Function(Pago pago) alAnular;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagos =
        ref.watch(pagosDePedidoProvider(pedido.id)).value ?? const <Pago>[];
    final alCobrar = this.alCobrar;
    final vence = pedido.venceEn;
    final condicion = pedido.condicionPago == CondicionPago.credito
        ? vence == null
              ? 'A crédito: ${pedido.plazoCreditoDias ?? 0} días desde la '
                    'entrega'
              : 'A crédito: vence el ${fechaCorta(vence)}'
        : 'Al contado';
    final metodo = pedido.metodoPago;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                metodo == null
                    ? condicion
                    : '$condicion · ${metodoPagoLegible(metodo)}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
            if (pedido.estado != EstadoPedido.cancelado)
              Etiqueta(
                vencido ? 'Vencido' : estadoPagoLegible(pedido.estadoPago),
                tono: vencido
                    ? TonoEtiqueta.peligro
                    : tonoDePago(pedido.estadoPago),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          pedido.estado == EstadoPedido.cancelado
              ? 'Pedido cancelado: no hay nada que cobrar.'
              : 'Cobrado ${pagadoCentimos(pedido).formatoSoles} · falta '
                    '${pedido.saldoPendienteCentimos.formatoSoles}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: ColoresPanel.neutro900,
          ),
        ),
        for (final pago in pagos)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${fechaHoraCorta(pago.creadoEn)} · '
                    '${metodoPagoLegible(pago.metodo)}'
                    '${pago.referencia == null ? '' : ' · ${pago.referencia}'}',
                    style: TextStyle(
                      fontSize: 13,
                      color: pago.anuladoEn == null
                          ? ColoresPanel.neutro700
                          : ColoresPanel.neutro500,
                    ),
                  ),
                ),
                if (pago.anuladoEn != null)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Etiqueta('Anulado', tono: TonoEtiqueta.neutro),
                  ),
                Text(
                  pago.montoCentimos.formatoSoles,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: pago.anuladoEn == null
                        ? ColoresPanel.neutro900
                        : ColoresPanel.neutro500,
                    decoration: pago.anuladoEn == null
                        ? null
                        : TextDecoration.lineThrough,
                  ),
                ),
                if (esAdmin && pago.anuladoEn == null)
                  IconButton(
                    tooltip:
                        'Anular pago de ${pago.montoCentimos.formatoSoles}',
                    onPressed: () => alAnular(pago),
                    icon: const Icon(Icons.undo_rounded, size: 18),
                  ),
              ],
            ),
          ),
        if (alCobrar != null) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: alCobrar,
            icon: const Icon(Icons.payments_outlined, size: 18),
            label: const Text('Registrar pago'),
          ),
        ],
      ],
    );
  }
}

class _TituloSeccion extends StatelessWidget {
  const _TituloSeccion(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        texto.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.7,
          color: ColoresPanel.neutro500,
        ),
      ),
    );
  }
}

class _Caja extends StatelessWidget {
  const _Caja({required this.child, this.color = ColoresPanel.neutro50});

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: child,
    );
  }
}
