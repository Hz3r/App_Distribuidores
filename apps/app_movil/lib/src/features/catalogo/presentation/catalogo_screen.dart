import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/lectura_vigente.dart';
import '../../../shared/tema_app.dart';
import '../../../shared/widgets/boton_circular.dart';
import '../domain/catalogo.dart';
import '../domain/filtros_catalogo.dart';
import 'catalogo_providers.dart';
import 'widgets/mensaje_estado.dart';
import 'widgets/tarjeta_producto.dart';

/// Catálogo del distribuidor: búsqueda, categorías, orden, marca y una
/// cuadrícula de productos. Los filtros viven en
/// [filtrosCatalogoActualesProvider], así que se conservan al salir y volver.
class CatalogoScreen extends ConsumerStatefulWidget {
  const CatalogoScreen({super.key});

  @override
  ConsumerState<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends ConsumerState<CatalogoScreen> {
  late final TextEditingController _busqueda;

  /// El campo de búsqueda está a la vista.
  late bool _buscando;

  @override
  void initState() {
    super.initState();
    // Si se llega con una búsqueda ya elegida (desde el inicio), se muestra.
    final busqueda = ref.read(filtrosCatalogoActualesProvider).busqueda;
    _busqueda = TextEditingController(text: busqueda);
    _buscando = busqueda.isNotEmpty;
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  FiltrosCatalogo get _filtros => ref.read(filtrosCatalogoActualesProvider);

  void _fijar(FiltrosCatalogo filtros) =>
      ref.read(filtrosCatalogoActualesProvider.notifier).fijar(filtros);

  void _alternarBusqueda() {
    setState(() => _buscando = !_buscando);
    // Un buscador oculto no debe seguir filtrando.
    if (!_buscando) _fijar(_filtros.copyWith(busqueda: ''));
  }

  void _quitarFiltros() => _fijar(FiltrosCatalogo(orden: _filtros.orden));

  /// Recarga para deslizar hacia abajo. No pasa por `ControlAcceso`, que
  /// vaciaría el carrito y los filtros.
  Future<void> _recargar() async {
    ref.invalidate(catalogoProvider);
    try {
      await ref.read(catalogoProvider.future);
    } catch (_) {
      // Se sigue mostrando lo que ya había.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pudimos actualizar el catálogo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // El campo sigue a los filtros cuando cambian desde fuera ("Quitar
    // filtros", el inicio). Una búsqueda puesta desde el inicio abre el
    // buscador aunque esta pantalla ya existiera con él cerrado.
    ref.listen(filtrosCatalogoActualesProvider.select((f) => f.busqueda), (
      _,
      busqueda,
    ) {
      if (_busqueda.text != busqueda) _busqueda.text = busqueda;
      if (busqueda.isNotEmpty && !_buscando) setState(() => _buscando = true);
    });

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Catálogo',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  BotonCircular(
                    icono: _buscando ? Icons.close : Icons.search,
                    tooltip: _buscando ? 'Cerrar búsqueda' : 'Buscar',
                    onPressed: _alternarBusqueda,
                  ),
                ],
              ),
            ),
            if (_buscando)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _busqueda,
                  autofocus: _busqueda.text.isEmpty,
                  textInputAction: TextInputAction.search,
                  onChanged: (texto) =>
                      _fijar(_filtros.copyWith(busqueda: texto)),
                  decoration: InputDecoration(
                    hintText: 'Buscar productos o marcas',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(radioApp),
                      borderSide: const BorderSide(color: ColoresApp.borde),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(radioApp),
                      borderSide: const BorderSide(color: ColoresApp.borde),
                    ),
                  ),
                ),
              ),
            Expanded(child: _contenido()),
          ],
        ),
      ),
    );
  }

  Widget _contenido() {
    final (:lectura, :catalogo) = observarCatalogo(ref);
    if (catalogo == null) {
      if (!lectura.mostrarError) {
        return const Center(child: CircularProgressIndicator());
      }
      return MensajeEstado(
        icono: Icons.cloud_off_outlined,
        mensaje: 'No pudimos cargar el catálogo.',
        accion: 'Reintentar',
        alAccion: () => ref.invalidate(catalogoProvider),
      );
    }

    final todos = productosDelCatalogo(catalogo);
    if (todos.isEmpty) {
      return RefreshIndicator(
        onRefresh: _recargar,
        child: const MensajeEstado(
          icono: Icons.inventory_2_outlined,
          mensaje: 'Tu distribuidor todavía no publicó productos.',
        ),
      );
    }

    final filtros = ref.watch(filtrosCatalogoActualesProvider);
    final visibles = aplicarFiltros(todos, filtros);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FilaCategorias(
          categorias: catalogo.categorias,
          elegida: filtros.categoriaId,
          alElegir: (id) => _fijar(
            id == null
                ? filtros.copyWith(limpiarCategoria: true)
                : filtros.copyWith(categoriaId: id),
          ),
        ),
        _FilaControles(
          filtros: filtros,
          marcas: marcasDisponibles(todos),
          cuenta: visibles.length,
          alCambiar: _fijar,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _recargar,
            child: visibles.isEmpty
                ? MensajeEstado(
                    icono: Icons.search_off,
                    mensaje: 'No encontramos productos con esos filtros.',
                    accion: 'Quitar filtros',
                    alAccion: _quitarFiltros,
                  )
                : _Cuadricula(productos: visibles),
          ),
        ),
      ],
    );
  }
}

/// Chips desplazables: "Todos" y una por categoría.
class _FilaCategorias extends StatelessWidget {
  const _FilaCategorias({
    required this.categorias,
    required this.elegida,
    required this.alElegir,
  });

  final List<Categoria> categorias;
  final String? elegida;

  /// `null`: "Todos".
  final ValueChanged<String?> alElegir;

  @override
  Widget build(BuildContext context) {
    final opciones = <(String?, String)>[
      (null, 'Todos'),
      for (final c in categorias) (c.id, c.nombre),
    ];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: opciones.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (id, nombre) = opciones[i];
          final elegido = id == elegida;
          return ChoiceChip(
            label: Text(nombre),
            selected: elegido,
            showCheckmark: false,
            onSelected: (_) => alElegir(id),
            backgroundColor: Colors.white,
            selectedColor: ColoresApp.azul,
            labelStyle: TextStyle(
              color: elegido ? Colors.white : ColoresApp.texto,
              fontWeight: FontWeight.w600,
            ),
            side: BorderSide(
              color: elegido ? ColoresApp.azul : ColoresApp.borde,
            ),
            shape: const StadiumBorder(),
          );
        },
      ),
    );
  }
}

/// "Ordenar" y "Marca" como menús, y a la derecha cuántos productos se ven.
class _FilaControles extends StatelessWidget {
  const _FilaControles({
    required this.filtros,
    required this.marcas,
    required this.cuenta,
    required this.alCambiar,
  });

  final FiltrosCatalogo filtros;
  final List<String> marcas;
  final int cuenta;
  final ValueChanged<FiltrosCatalogo> alCambiar;

  /// Valor del menú de marcas para "Todas" (ninguna marca es vacía).
  static const _todas = '';

  @override
  Widget build(BuildContext context) {
    final ordenar = PopupMenuButton<OrdenCatalogo>(
      tooltip: 'Ordenar',
      initialValue: filtros.orden,
      onSelected: (orden) => alCambiar(filtros.copyWith(orden: orden)),
      itemBuilder: (_) => [
        for (final (orden, texto) in const [
          (OrdenCatalogo.nombre, 'Nombre'),
          (OrdenCatalogo.precioMenor, 'Precio: menor a mayor'),
          (OrdenCatalogo.precioMayor, 'Precio: mayor a menor'),
        ])
          CheckedPopupMenuItem(
            value: orden,
            checked: filtros.orden == orden,
            child: Text(texto),
          ),
      ],
      child: const _BotonMenu(texto: 'Ordenar'),
    );
    final marca = PopupMenuButton<String>(
      tooltip: 'Marca',
      onSelected: (marca) => alCambiar(
        marca == _todas
            ? filtros.copyWith(limpiarMarca: true)
            : filtros.copyWith(marca: marca),
      ),
      itemBuilder: (_) => [
        CheckedPopupMenuItem(
          value: _todas,
          checked: filtros.marca == null,
          child: const Text('Todas'),
        ),
        for (final marca in marcas)
          CheckedPopupMenuItem(
            value: marca,
            checked: filtros.marca == marca,
            child: Text(marca),
          ),
      ],
      // La marca elegida queda a la vista en el botón.
      child: _BotonMenu(
        texto: filtros.marca ?? 'Marca',
        activo: filtros.marca != null,
      ),
    );

    // En una línea: los menús a la izquierda y la cuenta a la derecha. Si
    // no caben, pasan a otra línea en vez de recortarse.
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 8,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [ordenar, if (marcas.isNotEmpty) marca],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              cuenta == 1 ? '1 producto' : '$cuenta productos',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: ColoresApp.textoSuave),
            ),
          ),
        ],
      ),
    );
  }
}

/// Aspecto de los botones de menú: borde fino, texto y una flecha.
class _BotonMenu extends StatelessWidget {
  const _BotonMenu({required this.texto, this.activo = false});

  final String texto;
  final bool activo;

  @override
  Widget build(BuildContext context) {
    final color = activo ? ColoresApp.azul : ColoresApp.texto;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: activo ? ColoresApp.azul : ColoresApp.borde),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 2),
          Icon(Icons.keyboard_arrow_down, size: 18, color: color),
        ],
      ),
    );
  }
}

/// Dos columnas de [TarjetaProducto], con filas de [altoFilaTarjetaProducto].
class _Cuadricula extends StatelessWidget {
  const _Cuadricula({required this.productos});

  final List<ProductoEnCatalogo> productos;

  @override
  Widget build(BuildContext context) {
    final alto = altoFilaTarjetaProducto(MediaQuery.textScalerOf(context));
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: alto,
      ),
      itemCount: productos.length,
      itemBuilder: (_, i) => TarjetaProducto(
        key: ValueKey(productos[i].producto.id),
        item: productos[i],
      ),
    );
  }
}
