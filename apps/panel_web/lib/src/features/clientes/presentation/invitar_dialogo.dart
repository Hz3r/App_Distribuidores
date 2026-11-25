import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/tema_panel.dart';
import '../../../shared/formato.dart';
import '../../../shared/widgets/estados.dart';
import '../../sesion/presentation/control_acceso.dart';
import 'clientes_providers.dart';

/// Diálogo para generar el código con el que un cliente entra a la app.
/// Primero pide para quién y por cuánto tiempo; al generarlo, muestra el
/// código para copiarlo o compartirlo.
class InvitarDialogo extends ConsumerStatefulWidget {
  const InvitarDialogo({required this.clientes, this.cliente, super.key});

  /// Clientes entre los que se puede elegir (los activos).
  final List<ClienteNegocio> clientes;

  /// Cliente ya elegido; null para elegirlo en el diálogo.
  final ClienteNegocio? cliente;

  /// Abre el diálogo. Devuelve `true` si se generó un código.
  static Future<bool?> mostrar(
    BuildContext context, {
    required List<ClienteNegocio> clientes,
    ClienteNegocio? cliente,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => InvitarDialogo(clientes: clientes, cliente: cliente),
    );
  }

  @override
  ConsumerState<InvitarDialogo> createState() => _InvitarDialogoState();
}

class _InvitarDialogoState extends ConsumerState<InvitarDialogo> {
  static const _vigencias = [3, 7, 15, 30];

  final _formulario = GlobalKey<FormState>();
  String? _clienteId;
  int _dias = 7;
  bool _generando = false;
  String? _error;
  Invitacion? _invitacion;

  @override
  void initState() {
    super.initState();
    _clienteId = widget.cliente?.id;
  }

  ClienteNegocio? get _cliente {
    for (final c in widget.clientes) {
      if (c.id == _clienteId) return c;
    }
    return widget.cliente;
  }

  Future<void> _generar() async {
    if (_generando) return;
    if (!(_formulario.currentState?.validate() ?? false)) return;
    setState(() {
      _generando = true;
      _error = null;
    });
    try {
      final invitacion = await ref
          .read(accionesClientesProvider)
          .invitar(_clienteId!, diasVigencia: _dias);
      if (mounted) {
        setState(() {
          _generando = false;
          _invitacion = invitacion;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _generando = false;
        _error = mensajeDeClientes(e);
      });
    }
  }

  Future<void> _copiar(String texto, String aviso) async {
    final avisos = ScaffoldMessenger.maybeOf(context);
    await Clipboard.setData(ClipboardData(text: texto));
    avisos?.showSnackBar(SnackBar(content: Text(aviso)));
  }

  @override
  Widget build(BuildContext context) {
    final invitacion = _invitacion;
    return invitacion == null ? _pedir(context) : _mostrar(context, invitacion);
  }

  Widget _pedir(BuildContext context) {
    final error = _error;
    final fijo = widget.cliente;

    return AlertDialog(
      title: const Text('Invitar a la app'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formulario,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Genera un código de un solo uso. Tu cliente lo escribe en la '
                'app y queda vinculado a tu negocio.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              if (fijo != null)
                InputDecorator(
                  decoration: const InputDecoration(labelText: 'Cliente'),
                  child: Text(fijo.nombreNegocio),
                )
              else
                DropdownButtonFormField<String>(
                  initialValue: _clienteId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Cliente'),
                  items: [
                    for (final c in widget.clientes)
                      DropdownMenuItem(
                        value: c.id,
                        child: Text(
                          c.nombreNegocio,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: _generando
                      ? null
                      : (v) => setState(() => _clienteId = v),
                  validator: (v) => v == null ? 'Elige un cliente.' : null,
                ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _dias,
                decoration: const InputDecoration(
                  labelText: 'El código vence en',
                ),
                items: [
                  for (final dias in _vigencias)
                    DropdownMenuItem(value: dias, child: Text('$dias días')),
                ],
                onChanged: _generando
                    ? null
                    : (v) => setState(() => _dias = v ?? _dias),
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
          onPressed: _generando ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _generando ? null : _generar,
          child: _generando
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Generar código'),
        ),
      ],
    );
  }

  Widget _mostrar(BuildContext context, Invitacion invitacion) {
    final tema = Theme.of(context);
    final negocio = _cliente?.nombreNegocio ?? 'tu cliente';
    final distribuidor =
        ref.watch(membresiaActivaProvider)?.distribuidor?.nombreVisible ??
        'tu distribuidor';
    final vence = fechaCorta(invitacion.venceEn);
    final mensaje =
        'Hola. Ya puedes hacer tus pedidos a $distribuidor desde la app. '
        'Crea tu cuenta y escribe este código: ${invitacion.codigo}. '
        'Vence el $vence.';

    return AlertDialog(
      title: const Text('Código generado'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: ColoresPanel.primario900,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    negocio,
                    style: const TextStyle(
                      fontSize: 13,
                      color: ColoresPanel.primario100,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    invitacion.codigo,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4,
                      color: ColoresPanel.blanco,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sirve una sola vez · vence el $vence',
                    style: const TextStyle(
                      fontSize: 12,
                      color: ColoresPanel.acento500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Envíaselo a tu cliente. Puedes volver a verlo en Invitaciones.',
              style: tema.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _copiar(invitacion.codigo, 'Código copiado.'),
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('Copiar código'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _copiar(mensaje, 'Mensaje copiado.'),
              icon: const Icon(Icons.chat_outlined, size: 18),
              label: const Text('Copiar mensaje para WhatsApp'),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Listo'),
        ),
      ],
    );
  }
}
