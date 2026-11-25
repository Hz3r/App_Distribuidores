import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/tema_panel.dart';
import '../../../shared/formato.dart';
import '../../../shared/widgets/estados.dart';
import '../domain/catalogo_repositorio.dart';
import 'catalogo_providers.dart';

/// Diálogo para crear o editar un producto con sus presentaciones.
class ProductoFormulario extends ConsumerStatefulWidget {
  const ProductoFormulario({this.producto, super.key});

  /// Producto a editar; null para crear uno.
  final Producto? producto;

  /// Abre el diálogo. Devuelve `true` si se guardó.
  static Future<bool?> mostrar(BuildContext context, [Producto? producto]) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ProductoFormulario(producto: producto),
    );
  }

  @override
  ConsumerState<ProductoFormulario> createState() => _ProductoFormularioState();
}

/// Una fila editable de presentación.
class _FilaPresentacion {
  _FilaPresentacion({
    this.id,
    String nombre = '',
    String factor = '',
    String precio = '',
    this.activo = true,
  }) : nombre = TextEditingController(text: nombre),
       factor = TextEditingController(text: factor),
       precio = TextEditingController(text: precio);

  /// Null si aún no existe en la base de datos.
  final String? id;
  final TextEditingController nombre;
  final TextEditingController factor;
  final TextEditingController precio;
  bool activo;

  void dispose() {
    nombre.dispose();
    factor.dispose();
    precio.dispose();
  }
}

class _ProductoFormularioState extends ConsumerState<ProductoFormulario> {
  final _formulario = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _marca;
  late final TextEditingController _sku;
  late final TextEditingController _unidad;
  late final TextEditingController _descripcion;
  final _disponibilidad = TextEditingController();
  late final List<_FilaPresentacion> _presentaciones;

  String? _categoriaId;
  bool _activo = true;
  bool _guardando = false;
  String? _error;

  /// Tras el primer intento de guardar, cada campo se vuelve a revisar al
  /// corregirlo: el aviso de error desaparece apenas queda bien.
  bool _revisar = false;

  bool get _esNuevo => widget.producto == null;

  @override
  void initState() {
    super.initState();
    final producto = widget.producto;
    _nombre = TextEditingController(text: producto?.nombre ?? '');
    _marca = TextEditingController(text: producto?.marca ?? '');
    _sku = TextEditingController(text: producto?.sku ?? '');
    _unidad = TextEditingController(text: producto?.unidadBase ?? 'unidad');
    _descripcion = TextEditingController(text: producto?.descripcion ?? '');
    _categoriaId = producto?.categoriaId;
    _activo = producto?.activo ?? true;
    _presentaciones = [
      for (final p in producto?.presentaciones ?? const <Presentacion>[])
        _FilaPresentacion(
          id: p.id,
          nombre: p.nombre,
          factor: '${p.factor}',
          precio: solesEditables(p.precioBaseCentimos),
          activo: p.activo,
        ),
    ];
    if (_presentaciones.isEmpty) {
      _presentaciones.add(_FilaPresentacion(nombre: 'Unidad', factor: '1'));
    }
  }

  @override
  void dispose() {
    for (final controlador in [
      _nombre,
      _marca,
      _sku,
      _unidad,
      _descripcion,
      _disponibilidad,
    ]) {
      controlador.dispose();
    }
    for (final fila in _presentaciones) {
      fila.dispose();
    }
    super.dispose();
  }

  Future<void> _nuevaCategoria() async {
    final nombre = await showDialog<String>(
      context: context,
      builder: (_) => const _DialogoCategoria(),
    );
    if (nombre == null || !mounted) return;
    try {
      final categoria = await ref
          .read(accionesCatalogoProvider)
          .crearCategoria(nombre);
      if (mounted) setState(() => _categoriaId = categoria.id);
    } catch (e) {
      if (mounted) setState(() => _error = mensajeDe(e));
    }
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
      await ref
          .read(accionesCatalogoProvider)
          .guardarProducto(
            original: widget.producto,
            datos: DatosProducto(
              nombre: _nombre.text.trim(),
              unidadBase: _unidad.text.trim().toLowerCase(),
              categoriaId: _categoriaId,
              marca: _marca.text,
              sku: _sku.text,
              descripcion: _descripcion.text,
              activo: _activo,
            ),
            presentaciones: [
              for (final fila in _presentaciones)
                DatosPresentacion(
                  id: fila.id,
                  nombre: fila.nombre.text.trim(),
                  factor: parsearEntero(fila.factor.text)!,
                  precioBaseCentimos: parsearSoles(fila.precio.text)!,
                  activo: fila.activo,
                ),
            ],
            disponibilidadInicial: parsearEntero(_disponibilidad.text) ?? 0,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _error = _esNuevo && e is ErrorCatalogo
            ? '${mensajeDe(e)} Si el producto ya aparece en la lista, '
                  'ábrelo para completarlo.'
            : mensajeDe(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final categorias =
        ref.watch(categoriasProvider).value ?? const <Categoria>[];
    final error = _error;
    final unidad = _unidad.text.trim().isEmpty ? 'unidad' : _unidad.text.trim();

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
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
                        _esNuevo ? 'Nuevo producto' : 'Editar producto',
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
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          hintText: 'Cerveza Lager 650 ml',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Escribe el nombre del producto.'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              key: ValueKey(_categoriaId),
                              initialValue:
                                  categorias.any((c) => c.id == _categoriaId)
                                  ? _categoriaId
                                  : null,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Categoría',
                              ),
                              items: [
                                const DropdownMenuItem<String?>(
                                  child: Text('Sin categoría'),
                                ),
                                for (final c in categorias)
                                  DropdownMenuItem<String?>(
                                    value: c.id,
                                    child: Text(
                                      c.activo
                                          ? c.nombre
                                          : '${c.nombre} (oculta)',
                                    ),
                                  ),
                              ],
                              onChanged: _guardando
                                  ? null
                                  : (v) => setState(() => _categoriaId = v),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: TextButton.icon(
                              onPressed: _guardando ? null : _nuevaCategoria,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Nueva categoría'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _marca,
                              enabled: !_guardando,
                              decoration: const InputDecoration(
                                labelText: 'Marca (opcional)',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _sku,
                              enabled: !_guardando,
                              decoration: const InputDecoration(
                                labelText: 'SKU o código (opcional)',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descripcion,
                        enabled: !_guardando,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Descripción (opcional)',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _unidad,
                              enabled: !_guardando,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                labelText: 'Se cuenta en',
                                helperText: 'botella, unidad, kg…',
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Escribe en qué se cuenta.'
                                  : null,
                            ),
                          ),
                          if (_esNuevo) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _disponibilidad,
                                enabled: !_guardando,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: InputDecoration(
                                  labelText: 'Cuánto puedes ofrecer',
                                  helperText:
                                      'En ${pluralDe(unidad)}. '
                                      'Puedes dejarlo vacío.',
                                ),
                                validator: (v) =>
                                    (v != null &&
                                        v.trim().isNotEmpty &&
                                        parsearEntero(v) == null)
                                    ? 'Escribe un número entero.'
                                    : null,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text('Presentaciones', style: tema.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Cómo lo vendes. “Trae” es cuántas '
                        '${pluralDe(unidad)} incluye: '
                        'una caja x12 trae 12.',
                        style: tema.textTheme.bodySmall?.copyWith(
                          color: ColoresPanel.neutro500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final (i, fila) in _presentaciones.indexed)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _filaPresentacion(i, fila),
                        ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _guardando
                              ? null
                              : () => setState(
                                  () =>
                                      _presentaciones.add(_FilaPresentacion()),
                                ),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Agregar presentación'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Visible para tus clientes'),
                        subtitle: const Text(
                          'Si lo apagas, no aparece en la app ni se puede '
                          'pedir.',
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
                      onPressed: _guardando ? null : _guardar,
                      child: _guardando
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _esNuevo ? 'Crear producto' : 'Guardar cambios',
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

  Widget _filaPresentacion(int indice, _FilaPresentacion fila) {
    final numero = indice + 1;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: fila.nombre,
            enabled: !_guardando,
            decoration: InputDecoration(
              labelText: 'Presentación $numero',
              hintText: 'Caja x12',
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Ponle un nombre.' : null,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 96,
          child: TextFormField(
            controller: fila.factor,
            enabled: !_guardando,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(labelText: 'Trae'),
            validator: (v) {
              final valor = parsearEntero(v ?? '');
              return (valor == null || valor < 1) ? 'Mínimo 1.' : null;
            },
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 132,
          child: TextFormField(
            controller: fila.precio,
            enabled: !_guardando,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Precio',
              prefixText: 'S/ ',
            ),
            validator: (v) =>
                parsearSoles(v ?? '') == null ? 'Ej.: 62.90' : null,
          ),
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: fila.id == null
              ? IconButton(
                  tooltip: 'Quitar presentación $numero',
                  onPressed: _guardando || _presentaciones.length == 1
                      ? null
                      : () => setState(() {
                          _presentaciones.removeAt(indice).dispose();
                        }),
                  icon: const Icon(Icons.delete_outline),
                )
              : Tooltip(
                  message: fila.activo
                      ? 'Se vende. Apágala para dejar de venderla.'
                      : 'No se vende. Enciéndela para volver a venderla.',
                  child: Switch(
                    value: fila.activo,
                    onChanged: _guardando
                        ? null
                        : (v) => setState(() => fila.activo = v),
                  ),
                ),
        ),
      ],
    );
  }
}

/// Pide el nombre de una categoría nueva. Devuelve el nombre o null.
class _DialogoCategoria extends StatefulWidget {
  const _DialogoCategoria();

  @override
  State<_DialogoCategoria> createState() => _DialogoCategoriaState();
}

class _DialogoCategoriaState extends State<_DialogoCategoria> {
  final _formulario = GlobalKey<FormState>();
  final _nombre = TextEditingController();

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  void _aceptar() {
    if (!(_formulario.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(_nombre.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva categoría'),
      content: Form(
        key: _formulario,
        child: SizedBox(
          width: 320,
          child: TextFormField(
            controller: _nombre,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              hintText: 'Cervezas',
            ),
            onFieldSubmitted: (_) => _aceptar(),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Escribe el nombre de la categoría.'
                : null,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _aceptar, child: const Text('Crear categoría')),
      ],
    );
  }
}
