import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/tema_panel.dart';
import '../../../shared/formato.dart';
import '../../../shared/widgets/estados.dart';
import '../../sesion/presentation/control_acceso.dart';
import '../domain/clientes_repositorio.dart';
import 'clientes_providers.dart';

/// Diálogo para crear o editar un cliente (bodega o tienda).
class ClienteFormulario extends ConsumerStatefulWidget {
  const ClienteFormulario({this.cliente, super.key});

  /// Cliente a editar; null para crear uno.
  final ClienteNegocio? cliente;

  /// Abre el diálogo. Devuelve `true` si se guardó.
  static Future<bool?> mostrar(
    BuildContext context, [
    ClienteNegocio? cliente,
  ]) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ClienteFormulario(cliente: cliente),
    );
  }

  @override
  ConsumerState<ClienteFormulario> createState() => _ClienteFormularioState();
}

class _ClienteFormularioState extends ConsumerState<ClienteFormulario> {
  final _formulario = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _documento;
  late final TextEditingController _telefono;
  late final TextEditingController _direccion;
  late final TextEditingController _referencia;
  late final TextEditingController _limite;
  late final TextEditingController _plazo;

  bool _activo = true;
  bool _credito = false;
  bool _guardando = false;
  String? _error;

  /// Tras el primer intento de guardar, cada campo se vuelve a revisar al
  /// corregirlo: el aviso de error desaparece apenas queda bien.
  bool _revisar = false;

  bool get _esNuevo => widget.cliente == null;

  @override
  void initState() {
    super.initState();
    final c = widget.cliente;
    _nombre = TextEditingController(text: c?.nombreNegocio ?? '');
    _documento = TextEditingController(text: c?.documento ?? '');
    _telefono = TextEditingController(text: c?.telefono ?? '');
    _direccion = TextEditingController(text: c?.direccion ?? '');
    _referencia = TextEditingController(text: c?.referencia ?? '');
    final limite = c?.limiteCreditoCentimos;
    _limite = TextEditingController(
      text: limite == null ? '' : solesEditables(limite),
    );
    _plazo = TextEditingController(text: '${c?.plazoCreditoDias ?? ''}');
    _activo = c?.activo ?? true;
    _credito = c?.creditoHabilitado ?? false;
  }

  @override
  void dispose() {
    for (final controlador in [
      _nombre,
      _documento,
      _telefono,
      _direccion,
      _referencia,
      _limite,
      _plazo,
    ]) {
      controlador.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar({required bool esAdmin}) async {
    if (_guardando) return;
    if (!_revisar) setState(() => _revisar = true);
    if (!(_formulario.currentState?.validate() ?? false)) return;

    setState(() {
      _guardando = true;
      _error = null;
    });
    // Solo el admin manda el crédito; a un vendedor la BD se lo rechaza.
    final CreditoCliente? credito;
    if (!esAdmin) {
      credito = null;
    } else if (_credito) {
      credito = CreditoCliente.con(
        limiteCentimos: parsearSoles(_limite.text)!,
        plazoDias: parsearEntero(_plazo.text)!,
      );
    } else {
      credito = const CreditoCliente.sinCredito();
    }

    try {
      await ref
          .read(accionesClientesProvider)
          .guardarCliente(
            DatosCliente(
              nombreNegocio: _nombre.text.trim(),
              documento: _documento.text,
              telefono: _telefono.text,
              direccion: _direccion.text,
              referencia: _referencia.text,
              activo: _activo,
              credito: credito,
            ),
            original: widget.cliente,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _error = mensajeDeClientes(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esAdmin =
        ref.watch(membresiaActivaProvider)?.rol == RolMembresia.admin;
    final error = _error;

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
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
                        _esNuevo ? 'Nuevo cliente' : 'Editar cliente',
                        style: tema.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Cerrar sin guardar',
                      onPressed: _guardando
                          ? null
                          : () => Navigator.of(context).pop(false),
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
                      TextFormField(
                        controller: _nombre,
                        enabled: !_guardando,
                        autofocus: _esNuevo,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del negocio',
                          hintText: 'Bodega Don Pepe',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Escribe el nombre del negocio.'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _documento,
                              enabled: !_guardando,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(11),
                              ],
                              decoration: const InputDecoration(
                                labelText: 'RUC o DNI (opcional)',
                              ),
                              validator: (v) {
                                final largo = v?.trim().length ?? 0;
                                return largo == 0 || largo == 8 || largo == 11
                                    ? null
                                    : 'DNI de 8 cifras o RUC de 11.';
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _telefono,
                              enabled: !_guardando,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Celular (opcional)',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _direccion,
                        enabled: !_guardando,
                        decoration: const InputDecoration(
                          labelText: 'Dirección de entrega (opcional)',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _referencia,
                        enabled: !_guardando,
                        decoration: const InputDecoration(
                          labelText: 'Referencia (opcional)',
                          hintText: 'Frente al mercado, portón verde',
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (esAdmin) ...[
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Puede comprar a crédito'),
                          subtitle: const Text(
                            'Con un tope de deuda y un plazo para pagar.',
                          ),
                          value: _credito,
                          onChanged: _guardando
                              ? null
                              : (v) => setState(() => _credito = v),
                        ),
                        if (_credito)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _limite,
                                    enabled: !_guardando,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: const InputDecoration(
                                      labelText: 'Tope de deuda',
                                      prefixText: 'S/ ',
                                    ),
                                    validator: (v) {
                                      if (!_credito) return null;
                                      final monto = parsearSoles(v ?? '');
                                      return (monto == null || monto <= 0)
                                          ? 'Escribe un monto mayor a 0.'
                                          : null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _plazo,
                                    enabled: !_guardando,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'Plazo para pagar',
                                      suffixText: 'días',
                                    ),
                                    validator: (v) {
                                      if (!_credito) return null;
                                      final dias = parsearEntero(v ?? '');
                                      return (dias == null || dias < 1)
                                          ? 'Mínimo 1 día.'
                                          : null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ] else
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            _credito
                                ? 'Compra a crédito. Las condiciones las '
                                      'cambia el administrador.'
                                : 'Compra al contado. El crédito lo habilita '
                                      'el administrador.',
                            style: tema.textTheme.bodySmall?.copyWith(
                              color: ColoresPanel.neutro500,
                            ),
                          ),
                        ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Activo'),
                        subtitle: const Text(
                          'Si lo apagas, este cliente no puede entrar a la '
                          'app ni hacer pedidos.',
                        ),
                        value: _activo,
                        onChanged: _guardando
                            ? null
                            : (v) => setState(() => _activo = v),
                      ),
                      if (error != null) ...[
                        const SizedBox(height: 8),
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
                          : () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _guardando
                          ? null
                          : () => _guardar(esAdmin: esAdmin),
                      child: _guardando
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _esNuevo ? 'Crear cliente' : 'Guardar cambios',
                            ),
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
}
