import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/tema_panel.dart';
import '../../../shared/formato.dart';
import '../../../shared/textos.dart';
import '../../../shared/widgets/estados.dart';
import '../../clientes/presentation/clientes_providers.dart';
import '../../productos/presentation/catalogo_providers.dart';
import '../domain/flujo_pedido.dart';
import '../domain/pedidos_repositorio.dart';
import 'pedidos_providers.dart';

/// Diálogo para tomar un pedido a nombre de un cliente (por teléfono o en
/// persona). El precio final, la lista y el crédito los aplica la base de
/// datos; aquí se muestra un total estimado.
class NuevoPedidoDialogo extends ConsumerStatefulWidget {
  const NuevoPedidoDialogo({super.key});

  /// Abre el diálogo. Devuelve el id del pedido creado, o null.
  static Future<String?> mostrar(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const NuevoPedidoDialogo(),
    );
  }

  @override
  ConsumerState<NuevoPedidoDialogo> createState() => _NuevoPedidoDialogoState();
}

/// Una fila editable del pedido.
class _Linea {
  String? presentacionId;
  final cantidad = TextEditingController(text: '1');

  void dispose() => cantidad.dispose();
}

/// Una presentación que se puede pedir, con su producto.
typedef _Opcion = ({Presentacion presentacion, Producto producto});

class _NuevoPedidoDialogoState extends ConsumerState<NuevoPedidoDialogo> {
  final _formulario = GlobalKey<FormState>();
  final _nota = TextEditingController();
  final _lineas = <_Linea>[_Linea()];

  /// Una sola clave por diálogo: reintentar no crea otro pedido.
  final _clave = nuevaClaveIdempotencia();

  String? _clienteId;
  CondicionPago _condicion = CondicionPago.contado;
  MetodoPago? _metodo;
  bool _guardando = false;
  String? _error;

  /// Tras el primer intento de guardar, cada campo se vuelve a revisar al
  /// corregirlo: el aviso de error desaparece apenas queda bien.
  bool _revisar = false;

  @override
  void dispose() {
    _nota.dispose();
    for (final linea in _lineas) {
      linea.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_guardando) return;
    if (!_revisar) setState(() => _revisar = true);
    if (!(_formulario.currentState?.validate() ?? false)) return;
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      final id = await ref
          .read(accionesPedidosProvider)
          .crearPedido(
            NuevoPedido(
              clienteId: _clienteId!,
              lineas: [
                for (final linea in _lineas)
                  LineaPedido(
                    presentacionId: linea.presentacionId!,
                    cantidad: parsearEntero(linea.cantidad.text)!,
                  ),
              ],
              condicionPago: _condicion,
              metodoPago: _metodo,
              nota: _nota.text,
              claveIdempotencia: _clave,
            ),
          );
      if (mounted) Navigator.of(context).pop(id);
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
    final tema = Theme.of(context);
    final clientes = [
      for (final c
          in ref.watch(clientesProvider).value ?? const <ClienteNegocio>[])
        if (c.activo) c,
    ];
    final opciones = <_Opcion>[
      for (final producto
          in ref.watch(productosProvider).value ?? const <Producto>[])
        if (producto.activo)
          for (final presentacion in producto.presentaciones)
            if (presentacion.activo)
              (presentacion: presentacion, producto: producto),
    ];
    final porId = {for (final o in opciones) o.presentacion.id: o};
    final cliente = clientes.where((c) => c.id == _clienteId).firstOrNull;
    final puedeCredito = cliente?.creditoHabilitado ?? false;
    final error = _error;

    var total = 0;
    for (final linea in _lineas) {
      final opcion = porId[linea.presentacionId];
      final cantidad = parsearEntero(linea.cantidad.text);
      if (opcion != null && cantidad != null && cantidad > 0) {
        total += precioEstimado(opcion.presentacion, cantidad) * cantidad;
      }
    }

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Form(
          key: _formulario,
          autovalidateMode: _revisar
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Nuevo pedido',
                        style: tema.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Cerrar sin guardar',
                      onPressed: _guardando
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Para cuando un cliente te pide por teléfono o en '
                        'persona. Queda como si lo hubiera hecho desde la app.',
                        style: tema.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _clienteId,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Cliente'),
                        items: [
                          for (final c in clientes)
                            DropdownMenuItem(
                              value: c.id,
                              child: Text(
                                c.nombreNegocio,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: _guardando
                            ? null
                            : (v) => setState(() {
                                _clienteId = v;
                                final elegido = clientes
                                    .where((c) => c.id == v)
                                    .firstOrNull;
                                if (!(elegido?.creditoHabilitado ?? false)) {
                                  _condicion = CondicionPago.contado;
                                }
                              }),
                        validator: (v) =>
                            v == null ? 'Elige un cliente.' : null,
                      ),
                      const SizedBox(height: 20),
                      Text('Productos', style: tema.textTheme.titleMedium),
                      const SizedBox(height: 12),
                      for (final (i, linea) in _lineas.indexed)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _filaLinea(i, linea, opciones, porId),
                        ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _guardando
                              ? null
                              : () => setState(() => _lineas.add(_Linea())),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Agregar producto'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<CondicionPago>(
                              key: ValueKey(_condicion),
                              initialValue: _condicion,
                              decoration: InputDecoration(
                                labelText: 'Forma de pago',
                                helperText: cliente == null || puedeCredito
                                    ? null
                                    : 'Este cliente no tiene crédito.',
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: CondicionPago.contado,
                                  child: Text('Al contado'),
                                ),
                                if (puedeCredito)
                                  const DropdownMenuItem(
                                    value: CondicionPago.credito,
                                    child: Text('A crédito'),
                                  ),
                              ],
                              onChanged: _guardando
                                  ? null
                                  : (v) => setState(
                                      () => _condicion = v ?? _condicion,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<MetodoPago?>(
                              initialValue: _metodo,
                              decoration: const InputDecoration(
                                labelText: 'Piensa pagar con (opcional)',
                              ),
                              items: [
                                const DropdownMenuItem<MetodoPago?>(
                                  child: Text('No lo sé'),
                                ),
                                for (final metodo in MetodoPago.values)
                                  DropdownMenuItem<MetodoPago?>(
                                    value: metodo,
                                    child: Text(metodoPagoLegible(metodo)),
                                  ),
                              ],
                              onChanged: _guardando
                                  ? null
                                  : (v) => setState(() => _metodo = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nota,
                        enabled: !_guardando,
                        decoration: const InputDecoration(
                          labelText: 'Nota (opcional)',
                          hintText: 'Entregar antes del mediodía',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: ColoresPanel.primario50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                cliente?.listaPreciosId == null
                                    ? 'Total estimado'
                                    : 'Total estimado (este cliente tiene '
                                          'lista de precios: puede ser menor)',
                                style: const TextStyle(
                                  color: ColoresPanel.primario900,
                                ),
                              ),
                            ),
                            Text(
                              total.formatoSoles,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: ColoresPanel.primario900,
                              ),
                            ),
                          ],
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
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _guardando
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _guardando ? null : _guardar,
                      child: _guardando
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Registrar pedido'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filaLinea(
    int indice,
    _Linea linea,
    List<_Opcion> opciones,
    Map<String, _Opcion> porId,
  ) {
    final numero = indice + 1;
    final elegida = porId[linea.presentacionId];
    final disponible = elegida?.presentacion.disponiblePara(elegida.producto);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: linea.presentacionId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Producto $numero',
              helperText: disponible == null
                  ? null
                  : 'Disponibles: $disponible · '
                        '${elegida!.presentacion.precioBaseCentimos.formatoSoles}'
                        ' c/u',
            ),
            items: [
              for (final o in opciones)
                DropdownMenuItem(
                  value: o.presentacion.id,
                  child: Text(
                    '${o.producto.nombre} · ${o.presentacion.nombre}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: _guardando
                ? null
                : (v) => setState(() => linea.presentacionId = v),
            validator: (v) => v == null ? 'Elige un producto.' : null,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 110,
          child: TextFormField(
            controller: linea.cantidad,
            enabled: !_guardando,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Cantidad'),
            validator: (v) {
              final cantidad = parsearEntero(v ?? '');
              if (cantidad == null || cantidad < 1) return 'Mínimo 1.';
              if (disponible != null && cantidad > disponible) {
                return 'Solo hay $disponible.';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: IconButton(
            tooltip: 'Quitar producto $numero',
            onPressed: _guardando || _lineas.length == 1
                ? null
                : () => setState(() => _lineas.removeAt(indice).dispose()),
            icon: const Icon(Icons.delete_outline),
          ),
        ),
      ],
    );
  }
}
