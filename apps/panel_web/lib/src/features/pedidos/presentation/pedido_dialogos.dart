import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/tema_panel.dart';
import '../../../shared/formato.dart';
import '../../../shared/textos.dart';
import '../../../shared/widgets/estados.dart';
import 'pedidos_providers.dart';

/// Pide el motivo y cancela (o rechaza) el pedido. Devuelve `true` si se
/// canceló. Cancelar libera lo que el pedido tenía reservado.
Future<bool?> mostrarCancelarPedido(BuildContext context, Pedido pedido) {
  final rechazo = pedido.estado == EstadoPedido.recibido;
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _DialogoMotivo(
      titulo: rechazo ? 'Rechazar pedido' : 'Cancelar pedido',
      explicacion:
          'El pedido #${pedido.numero} quedará cancelado y sus productos '
          'vuelven a estar disponibles. Esto no se puede deshacer.',
      etiqueta: 'Motivo (lo verá tu cliente)',
      pista: 'Sin stock, pedido duplicado, fuera de ruta…',
      confirmar: rechazo ? 'Rechazar pedido' : 'Cancelar pedido',
      volver: 'Conservar pedido',
      alConfirmar: (ref, motivo) => ref
          .read(accionesPedidosProvider)
          .cambiarEstado(pedido, EstadoPedido.cancelado, nota: motivo),
    ),
  );
}

/// Pide el motivo y anula un pago. Devuelve `true` si se anuló. El monto
/// vuelve al saldo del pedido.
Future<bool?> mostrarAnularPago(BuildContext context, Pago pago) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _DialogoMotivo(
      titulo: 'Anular pago',
      explicacion:
          'El pago de ${pago.montoCentimos.formatoSoles} quedará anulado y '
          'ese monto vuelve a estar pendiente. Esto no se puede deshacer.',
      etiqueta: 'Motivo',
      pista: 'Monto equivocado, pago duplicado…',
      confirmar: 'Anular pago',
      volver: 'Conservar pago',
      alConfirmar: (ref, motivo) =>
          ref.read(accionesPedidosProvider).anularPago(pago, motivo),
    ),
  );
}

/// Diálogo de una acción destructiva que exige un motivo.
class _DialogoMotivo extends ConsumerStatefulWidget {
  const _DialogoMotivo({
    required this.titulo,
    required this.explicacion,
    required this.etiqueta,
    required this.pista,
    required this.confirmar,
    required this.volver,
    required this.alConfirmar,
  });

  final String titulo;
  final String explicacion;
  final String etiqueta;
  final String pista;
  final String confirmar;
  final String volver;
  final Future<void> Function(WidgetRef ref, String motivo) alConfirmar;

  @override
  ConsumerState<_DialogoMotivo> createState() => _DialogoMotivoState();
}

class _DialogoMotivoState extends ConsumerState<_DialogoMotivo> {
  final _formulario = GlobalKey<FormState>();
  final _motivo = TextEditingController();
  bool _guardando = false;
  String? _error;

  @override
  void dispose() {
    _motivo.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    if (_guardando) return;
    if (!(_formulario.currentState?.validate() ?? false)) return;
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await widget.alConfirmar(ref, _motivo.text.trim());
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _error = mensajeDePedidos(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    return AlertDialog(
      title: Text(widget.titulo),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formulario,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.explicacion,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _motivo,
                enabled: !_guardando,
                autofocus: true,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: widget.etiqueta,
                  hintText: widget.pista,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Escribe el motivo.'
                    : null,
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                CajaError(error),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.of(context).pop(false),
          child: Text(widget.volver),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: ColoresPanel.peligro500,
          ),
          onPressed: _guardando ? null : _confirmar,
          child: _guardando
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.confirmar),
        ),
      ],
    );
  }
}

/// Diálogo para registrar un pago total o parcial de un pedido.
class RegistrarPagoDialogo extends ConsumerStatefulWidget {
  const RegistrarPagoDialogo({required this.pedido, super.key});

  final Pedido pedido;

  /// Abre el diálogo. Devuelve `true` si se registró el pago.
  static Future<bool?> mostrar(BuildContext context, Pedido pedido) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RegistrarPagoDialogo(pedido: pedido),
    );
  }

  @override
  ConsumerState<RegistrarPagoDialogo> createState() =>
      _RegistrarPagoDialogoState();
}

class _RegistrarPagoDialogoState extends ConsumerState<RegistrarPagoDialogo> {
  final _formulario = GlobalKey<FormState>();
  late final TextEditingController _monto;
  final _referencia = TextEditingController();
  late MetodoPago _metodo;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _monto = TextEditingController(
      text: solesEditables(widget.pedido.saldoPendienteCentimos),
    );
    _metodo = widget.pedido.metodoPago ?? MetodoPago.efectivo;
  }

  @override
  void dispose() {
    _monto.dispose();
    _referencia.dispose();
    super.dispose();
  }

  String? _validarMonto(String? texto) {
    final monto = parsearSoles(texto ?? '');
    if (monto == null || monto <= 0) return 'Escribe un monto mayor a 0.';
    final saldo = widget.pedido.saldoPendienteCentimos;
    if (monto > saldo) return 'Máximo ${saldo.formatoSoles}: es lo que falta.';
    return null;
  }

  Future<void> _guardar() async {
    if (_guardando) return;
    if (!(_formulario.currentState?.validate() ?? false)) return;
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await ref
          .read(accionesPedidosProvider)
          .registrarPago(
            pedido: widget.pedido,
            montoCentimos: parsearSoles(_monto.text)!,
            metodo: _metodo,
            referencia: _referencia.text,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _error = mensajeDePedidos(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pedido = widget.pedido;
    final error = _error;
    return AlertDialog(
      title: const Text('Registrar pago'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formulario,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pedido #${pedido.numero}. Falta cobrar '
                '${pedido.saldoPendienteCentimos.formatoSoles} de '
                '${pedido.totalCentimos.formatoSoles}.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _monto,
                enabled: !_guardando,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Monto recibido',
                  prefixText: 'S/ ',
                ),
                validator: _validarMonto,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<MetodoPago>(
                initialValue: _metodo,
                decoration: const InputDecoration(labelText: 'Cómo pagó'),
                items: [
                  for (final metodo in MetodoPago.values)
                    DropdownMenuItem(
                      value: metodo,
                      child: Text(metodoPagoLegible(metodo)),
                    ),
                ],
                onChanged: _guardando
                    ? null
                    : (v) => setState(() => _metodo = v ?? _metodo),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _referencia,
                enabled: !_guardando,
                decoration: const InputDecoration(
                  labelText: 'N.º de operación (opcional)',
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                CajaError(error),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: _guardando
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Registrar pago'),
        ),
      ],
    );
  }
}
