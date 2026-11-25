import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/tema_panel.dart';
import '../../../shared/formato.dart';
import '../../../shared/widgets/estados.dart';
import '../../productos/presentation/catalogo_providers.dart';
import '../domain/disponibilidad.dart';

/// Diálogo para decir cuánto se ofrece ahora de un producto. La persona
/// escribe el total nuevo y el panel registra la diferencia.
class ActualizarDisponibilidadDialogo extends ConsumerStatefulWidget {
  const ActualizarDisponibilidadDialogo({required this.producto, super.key});

  final Producto producto;

  /// Abre el diálogo. Devuelve `true` si se guardó.
  static Future<bool?> mostrar(BuildContext context, Producto producto) {
    return showDialog<bool>(
      context: context,
      // Un toque fuera no debe botar lo que la persona ya escribió.
      barrierDismissible: false,
      builder: (_) => ActualizarDisponibilidadDialogo(producto: producto),
    );
  }

  @override
  ConsumerState<ActualizarDisponibilidadDialogo> createState() =>
      _ActualizarDisponibilidadDialogoState();
}

class _ActualizarDisponibilidadDialogoState
    extends ConsumerState<ActualizarDisponibilidadDialogo> {
  final _formulario = GlobalKey<FormState>();
  late final TextEditingController _total;
  final _nota = TextEditingController();

  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _total = TextEditingController(text: '${widget.producto.stockFisico}');
  }

  @override
  void dispose() {
    _total.dispose();
    _nota.dispose();
    super.dispose();
  }

  String? _validar(String? texto) {
    final total = parsearEntero(texto ?? '');
    if (total == null) return 'Escribe un número entero.';
    return switch (calcularMovimiento(widget.producto, total).error) {
      ErrorCantidad.sinCambio => 'Es la cantidad que ya tienes.',
      ErrorCantidad.bajoLoReservado =>
        'Mínimo ${widget.producto.stockComprometido}: ya está reservado en '
            'pedidos.',
      null => null,
    };
  }

  /// Qué va a pasar con la cantidad escrita, o null si aún no es válida.
  String? _resumen() {
    final total = parsearEntero(_total.text);
    if (total == null) return null;
    final movimiento = calcularMovimiento(widget.producto, total).movimiento;
    if (movimiento == null) return null;
    final unidades = cantidadConUnidad(
      movimiento.cantidad.abs(),
      widget.producto.unidadBase,
    );
    final disponible = total - widget.producto.stockComprometido;
    final verbo = movimiento.cantidad > 0 ? 'Sumas' : 'Quitas';
    return '$verbo $unidades. Quedarán $disponible para pedir.';
  }

  Future<void> _guardar() async {
    if (_guardando) return;
    if (!(_formulario.currentState?.validate() ?? false)) return;
    final movimiento = calcularMovimiento(
      widget.producto,
      parsearEntero(_total.text)!,
    ).movimiento!;

    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      final nota = _nota.text.trim();
      await ref
          .read(accionesCatalogoProvider)
          .registrarMovimiento(
            productoId: widget.producto.id,
            tipo: movimiento.tipo,
            cantidad: movimiento.cantidad,
            nota: nota.isEmpty ? null : nota,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _error = mensajeDe(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final producto = widget.producto;
    final tema = Theme.of(context);
    final resumen = _resumen();
    final error = _error;

    return AlertDialog(
      title: const Text('Actualizar disponibilidad'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formulario,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(producto.nombre, style: tema.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Hoy ofreces '
                '${cantidadConUnidad(producto.stockFisico, producto.unidadBase)}'
                '; hay ${producto.stockComprometido} en pedidos sin entregar.',
                style: tema.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _total,
                enabled: !_guardando,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
                onFieldSubmitted: (_) => _guardar(),
                decoration: InputDecoration(
                  labelText: 'Cuánto tienes ahora en total',
                  suffixText: pluralDe(producto.unidadBase),
                ),
                validator: _validar,
              ),
              if (resumen != null) ...[
                const SizedBox(height: 8),
                Text(
                  resumen,
                  style: tema.textTheme.bodySmall?.copyWith(
                    color: ColoresPanel.primario700,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _nota,
                enabled: !_guardando,
                decoration: const InputDecoration(
                  labelText: 'Nota (opcional)',
                  hintText: 'Llegó mercadería, conteo, merma…',
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
              : const Text('Guardar cantidad'),
        ),
      ],
    );
  }
}
