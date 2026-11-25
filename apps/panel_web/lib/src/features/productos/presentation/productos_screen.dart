import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/tema_panel.dart';
import '../../../shared/formato.dart';
import '../../../shared/widgets/estados.dart';
import '../../../shared/widgets/pagina_panel.dart';
import '../../../shared/widgets/tabla_panel.dart';
import '../../disponibilidad/domain/disponibilidad.dart';
import '../../sesion/presentation/control_acceso.dart';
import '../domain/filtro_productos.dart';
import 'catalogo_providers.dart';
import 'producto_formulario.dart';

/// Catálogo del distribuidor: lo que sus clientes ven en la app.
class ProductosScreen extends ConsumerStatefulWidget {
  const ProductosScreen({super.key});

  @override
  ConsumerState<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends ConsumerState<ProductosScreen> {
  final _busqueda = TextEditingController();
  String? _categoriaId;

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  void _limpiarFiltros() {
    setState(() {
      _busqueda.clear();
      _categoriaId = null;
    });
  }

  Future<void> _abrirFormulario([Producto? producto]) async {
    final guardado = await ProductoFormulario.mostrar(context, producto);
    if (guardado == true && mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(
            producto == null ? 'Producto creado.' : 'Cambios guardados.',
          ),
        ),
      );
    }
  }

  Future<void> _cambiarVisible(Producto producto, bool visible) async {
    final avisos = ScaffoldMessenger.maybeOf(context);
    try {
      await ref
          .read(accionesCatalogoProvider)
          .cambiarVisible(producto, visible: visible);
    } catch (e) {
      avisos?.showSnackBar(SnackBar(content: Text(mensajeDe(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final consulta = ref.watch(productosProvider);
    final categorias =
        ref.watch(categoriasProvider).value ?? const <Categoria>[];
    final esAdmin =
        ref.watch(membresiaActivaProvider)?.rol == RolMembresia.admin;
    final productos = consulta.value;

    final Widget cuerpo;
    if (productos == null) {
      cuerpo = consulta.hasError
          ? EstadoAviso.error(
              alReintentar: () => ref.invalidate(productosProvider),
            )
          : const EstadoCarga();
    } else if (productos.isEmpty) {
      cuerpo = EstadoAviso(
        icono: Icons.sell_outlined,
        titulo: 'Aún no tienes productos',
        mensaje: esAdmin
            ? 'Crea el primero para que tus clientes puedan pedirlo desde la '
                  'app.'
            : 'El administrador todavía no cargó el catálogo.',
        accion: esAdmin
            ? FilledButton.icon(
                onPressed: _abrirFormulario,
                icon: const Icon(Icons.add),
                label: const Text('Nuevo producto'),
              )
            : null,
      );
    } else {
      cuerpo = _lista(productos, categorias, esAdmin);
    }

    return PaginaPanel(
      titulo: 'Productos',
      descripcion: productos == null || productos.isEmpty
          ? 'Lo que ven tus clientes en la app.'
          : '${productos.length} en tu catálogo · lo que ven tus clientes en '
                'la app.',
      acciones: [
        if (esAdmin && productos != null && productos.isNotEmpty)
          FilledButton.icon(
            onPressed: _abrirFormulario,
            icon: const Icon(Icons.add),
            label: const Text('Nuevo producto'),
          ),
      ],
      child: cuerpo,
    );
  }

  Widget _lista(
    List<Producto> productos,
    List<Categoria> categorias,
    bool esAdmin,
  ) {
    final nombreCategoria = {for (final c in categorias) c.id: c.nombre};
    final filtrados = filtrarProductos(
      productos,
      busqueda: _busqueda.text,
      categoriaId: _categoriaId,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 280,
              child: TextField(
                controller: _busqueda,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Buscar por nombre, marca o SKU',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
              ),
            ),
            ChoiceChip(
              label: Text('Todos (${productos.length})'),
              selected: _categoriaId == null,
              onSelected: (_) => setState(() => _categoriaId = null),
            ),
            for (final categoria in categorias)
              ChoiceChip(
                label: Text(categoria.nombre),
                selected: _categoriaId == categoria.id,
                onSelected: (_) => setState(() => _categoriaId = categoria.id),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: filtrados.isEmpty
              ? EstadoAviso(
                  icono: Icons.search_off_rounded,
                  titulo: 'Ningún producto coincide',
                  mensaje: 'Prueba con otra palabra o quita los filtros.',
                  accion: OutlinedButton(
                    onPressed: _limpiarFiltros,
                    child: const Text('Quitar filtros'),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, limites) => _tabla(
                    filtrados,
                    nombreCategoria,
                    esAdmin: esAdmin,
                    amplia: limites.maxWidth >= 820,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _tabla(
    List<Producto> productos,
    Map<String, String> nombreCategoria, {
    required bool esAdmin,
    required bool amplia,
  }) {
    return TablaPanel(
      columnas: [
        const ColumnaTabla('Producto', flex: 4),
        if (amplia) const ColumnaTabla('Categoría', ancho: 130),
        if (amplia) const ColumnaTabla('Precio base', ancho: 190),
        const ColumnaTabla('Disponible', ancho: 120, aLaDerecha: true),
        const ColumnaTabla('Visible', ancho: 64),
        if (esAdmin) const ColumnaTabla('', ancho: 40),
      ],
      cantidadFilas: productos.length,
      celdasDeFila: (context, indice) {
        final producto = productos[indice];
        return [
          _CeldaProducto(producto),
          if (amplia)
            Text(
              nombreCategoria[producto.categoriaId] ?? 'Sin categoría',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (amplia) _CeldaPrecio(producto),
          _CeldaDisponible(producto),
          if (esAdmin)
            Switch(
              value: producto.activo,
              onChanged: (valor) => _cambiarVisible(producto, valor),
            )
          else
            Text(producto.activo ? 'Sí' : 'No'),
          if (esAdmin)
            IconButton(
              tooltip: 'Editar ${producto.nombre}',
              onPressed: () => _abrirFormulario(producto),
              icon: const Icon(Icons.edit_outlined, size: 20),
            ),
        ];
      },
    );
  }
}

class _CeldaProducto extends StatelessWidget {
  const _CeldaProducto(this.producto);

  final Producto producto;

  @override
  Widget build(BuildContext context) {
    final detalle = [
      ?producto.marca,
      if (producto.sku case final sku?) 'SKU $sku',
    ].join(' · ');

    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: ColoresPanel.primario50,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(
            Icons.inventory_2_outlined,
            size: 18,
            color: ColoresPanel.primario500,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                producto.nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: ColoresPanel.neutro900,
                ),
              ),
              if (detalle.isNotEmpty)
                Text(
                  detalle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ColoresPanel.neutro500,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CeldaPrecio extends StatelessWidget {
  const _CeldaPrecio(this.producto);

  final Producto producto;

  @override
  Widget build(BuildContext context) {
    final activas = [
      for (final p in producto.presentaciones)
        if (p.activo) p,
    ];
    if (activas.isEmpty) {
      return const Text(
        'Sin presentaciones',
        style: TextStyle(color: ColoresPanel.aviso500),
      );
    }
    final primera = activas.first;
    final otras = activas.length - 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${primera.nombre} · ${primera.precioBaseCentimos.formatoSoles}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (otras > 0)
          Text(
            otras == 1 ? '+1 presentación' : '+$otras presentaciones',
            style: const TextStyle(fontSize: 12, color: ColoresPanel.neutro500),
          ),
      ],
    );
  }
}

class _CeldaDisponible extends StatelessWidget {
  const _CeldaDisponible(this.producto);

  final Producto producto;

  @override
  Widget build(BuildContext context) {
    final color = switch (nivelDe(producto)) {
      NivelDisponibilidad.agotado => ColoresPanel.peligro500,
      NivelDisponibilidad.bajo => ColoresPanel.aviso500,
      NivelDisponibilidad.normal => ColoresPanel.neutro900,
    };
    return Text(
      producto.stockDisponible <= 0
          ? 'Agotado'
          : cantidadConUnidad(producto.stockDisponible, producto.unidadBase),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontWeight: FontWeight.w600, color: color),
    );
  }
}
