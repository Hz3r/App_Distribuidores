import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/rutas.dart';
import '../../../shared/lectura_vigente.dart';
import '../../../shared/tema_app.dart';
import '../../../shared/widgets/boton_circular.dart';
import '../../../shared/widgets/texto_ajustable.dart';
import '../../catalogo/domain/catalogo.dart';
import '../../catalogo/domain/filtros_catalogo.dart';
import '../../catalogo/presentation/catalogo_providers.dart';
import '../../catalogo/presentation/widgets/tarjeta_producto.dart';
import '../../sesion/presentation/sesion_activa.dart';
import '../domain/resumen_compras.dart';
import 'inicio_providers.dart';

/// Inicio de la bodega: saludo, buscador, último pedido, lo comprado este
/// mes, categorías y lo que más pide. Solo muestra lo que la BD respalda: no
/// hay cartel de pedido mínimo, hora de corte ni promociones.
class InicioScreen extends ConsumerStatefulWidget {
  const InicioScreen({super.key});

  @override
  ConsumerState<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends ConsumerState<InicioScreen> {
  final _busqueda = TextEditingController();

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  /// Abre el catálogo con [filtros] (se conserva el orden elegido allí). Los
  /// filtros se fijan antes de ir: el catálogo los lee al mostrarse.
  void _abrirCatalogo({String? categoriaId, String busqueda = ''}) {
    final actuales = ref.read(filtrosCatalogoActualesProvider);
    ref
        .read(filtrosCatalogoActualesProvider.notifier)
        .fijar(
          FiltrosCatalogo(
            categoriaId: categoriaId,
            busqueda: busqueda,
            orden: actuales.orden,
          ),
        );
    context.go(AppRutas.catalogo);
  }

  void _buscar(String texto) {
    final busqueda = texto.trim();
    if (busqueda.isEmpty) return;
    _busqueda.clear();
    _abrirCatalogo(busqueda: busqueda);
  }

  /// Recarga para deslizar hacia abajo. No pasa por `ControlAcceso`, que
  /// vaciaría el carrito y los filtros.
  Future<void> _recargar() async {
    ref
      ..invalidate(catalogoProvider)
      ..invalidate(resumenComprasProvider);
    try {
      await Future.wait([
        ref.read(catalogoProvider.future),
        ref.read(resumenComprasProvider.future),
      ]);
    } catch (_) {
      // Se sigue mostrando lo que ya había.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pudimos actualizar el inicio.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final membresia = ref.watch(membresiaActivaProvider);
    final negocio = membresia?.clienteNegocio?.nombreNegocio;

    return Scaffold(
      backgroundColor: ColoresApp.fondoPantalla,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _recargar,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 12, bottom: 24),
            children: [
              _Margen(
                child: _Encabezado(
                  distribuidor: membresia?.distribuidor?.nombreVisible ?? '',
                  saludo: negocio == null ? 'Hola' : 'Hola, $negocio',
                ),
              ),
              const SizedBox(height: 16),
              _Margen(
                child: _Buscador(controller: _busqueda, alBuscar: _buscar),
              ),
              const SizedBox(height: 16),
              ..._contenido(),
            ],
          ),
        ),
      ),
    );
  }

  /// Resumen, categorías y productos; o cargando, o el error.
  List<Widget> _contenido() {
    final (lectura: lecturaCatalogo, :catalogo) = observarCatalogo(ref);
    final (lectura: lecturaResumen, :resumen) = observarResumen(ref);

    if (catalogo == null || resumen == null) {
      final cargando =
          (catalogo == null && !lecturaCatalogo.mostrarError) ||
          (resumen == null && !lecturaResumen.mostrarError);
      if (cargando) {
        return const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          ),
        ];
      }
      return [
        _Margen(
          child: _ErrorInicio(
            alReintentar: () {
              if (catalogo == null) ref.invalidate(catalogoProvider);
              if (resumen == null) ref.invalidate(resumenComprasProvider);
            },
          ),
        ),
      ];
    }

    final todos = productosDelCatalogo(catalogo);
    final masPedidos = productosEnOrden(todos, resumen.productosMasPedidos);
    // Sin historial (o si nada de lo pedido sigue en el catálogo), los
    // primeros del catálogo.
    final (titulo, productos) = masPedidos.isEmpty
        ? ('Productos', todos.take(maxProductosMasPedidos).toList())
        : ('Lo que más pides', masPedidos);

    return [
      _Margen(
        child: _TarjetasResumen(
          resumen: resumen,
          alTocarUltimo: () => context.go(AppRutas.pedidos),
        ),
      ),
      if (catalogo.categorias.isNotEmpty) ...[
        const SizedBox(height: 20),
        _Margen(
          child: _TituloSeccion(
            titulo: 'Categorías',
            alVerTodo: _abrirCatalogo,
          ),
        ),
        _FilaCategorias(
          categorias: catalogo.categorias,
          alElegir: (id) => _abrirCatalogo(categoriaId: id),
        ),
      ],
      const SizedBox(height: 12),
      if (productos.isEmpty)
        _Margen(
          child: Text(
            'Tu distribuidor todavía no publicó productos.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: ColoresApp.textoSuave),
          ),
        )
      else ...[
        _Margen(
          child: _TituloSeccion(titulo: titulo, alVerTodo: _abrirCatalogo),
        ),
        _FilaProductos(productos: productos),
      ],
    ];
  }
}

/// Margen lateral de la pantalla. Las filas desplazables no lo llevan, para
/// llegar hasta el borde.
class _Margen extends StatelessWidget {
  const _Margen({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: child,
  );
}

/// Avatar de la tienda, distribuidor, saludo y la campana (sin acción hasta
/// que haya notificaciones).
class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.distribuidor, required this.saludo});

  final String distribuidor;
  final String saludo;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundColor: ColoresApp.marino,
          child: Icon(Icons.storefront, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (distribuidor.isNotEmpty)
                Text(
                  distribuidor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textos.bodySmall?.copyWith(
                    color: ColoresApp.textoSuave,
                  ),
                ),
              Text(
                saludo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textos.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: ColoresApp.texto,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const BotonCircular(
          icono: Icons.notifications_none,
          tooltip: 'Notificaciones',
          onPressed: null,
        ),
      ],
    );
  }
}

class _Buscador extends StatelessWidget {
  const _Buscador({required this.controller, required this.alBuscar});

  final TextEditingController controller;
  final ValueChanged<String> alBuscar;

  @override
  Widget build(BuildContext context) {
    final borde = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radioApp),
      borderSide: const BorderSide(color: ColoresApp.borde),
    );
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: alBuscar,
      decoration: InputDecoration(
        hintText: 'Buscar productos o marcas',
        prefixIcon: const Icon(Icons.search),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        border: borde,
        enabledBorder: borde,
      ),
    );
  }
}

/// "Último pedido" y "Comprado este mes", lado a lado.
class _TarjetasResumen extends StatelessWidget {
  const _TarjetasResumen({required this.resumen, required this.alTocarUltimo});

  final ResumenCompras resumen;
  final VoidCallback alTocarUltimo;

  @override
  Widget build(BuildContext context) {
    final ultimo = resumen.ultimoPedido;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _TarjetaResumen(
            etiqueta: 'Último pedido',
            alTocar: ultimo == null ? null : alTocarUltimo,
            children: ultimo == null
                ? [
                    Text(
                      'Aún no tienes pedidos',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ]
                : [
                    _Cifra('#${ultimo.numero}'),
                    const SizedBox(height: 6),
                    _PildoraEstado(estado: ultimo.estado),
                  ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TarjetaResumen(
            etiqueta: 'Comprado este mes',
            children: [
              _Cifra(Dinero.formatear(resumen.compradoEsteMesCentimos)),
              if (_variacion(resumen) case (final texto, final color)) ...[
                const SizedBox(height: 6),
                Text(
                  texto,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: color, fontWeight: FontWeight.w700),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// "▲ 8% vs octubre" en verde, "▼ 8% vs octubre" en rojo, "Igual que en
  /// octubre" con los mismos totales; `null` si no hay con qué comparar o si
  /// la diferencia redondea a 0 % sin ser nula.
  static (String, Color)? _variacion(ResumenCompras resumen) {
    final variacion = resumen.variacionPorcentaje;
    if (variacion == null) return null;
    final mes = nombreMes(resumen.mesAnterior);
    if (variacion > 0) return ('▲ $variacion% vs $mes', ColoresApp.exito);
    if (variacion < 0) return ('▼ ${-variacion}% vs $mes', ColoresApp.error);
    // Redondea a 0: "igual" solo si los totales coinciden de verdad.
    if (resumen.compradoEsteMesCentimos ==
        resumen.compradoMesAnteriorCentimos) {
      return ('Igual que en $mes', ColoresApp.textoSuave);
    }
    return null;
  }
}

/// Tarjeta blanca con borde, una etiqueta gris y su contenido.
class _TarjetaResumen extends StatelessWidget {
  const _TarjetaResumen({
    required this.etiqueta,
    required this.children,
    this.alTocar,
  });

  final String etiqueta;
  final List<Widget> children;
  final VoidCallback? alTocar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radioApp),
        side: const BorderSide(color: ColoresApp.borde),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: alTocar,
        child: ConstrainedBox(
          // Mismo alto mínimo en las dos, para que queden parejas.
          constraints: BoxConstraints(
            minHeight: MediaQuery.textScalerOf(context).scale(72) + 28,
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etiqueta,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: ColoresApp.textoSuave),
                ),
                const SizedBox(height: 4),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Número o monto en negrita que nunca se recorta: se achica si no cabe.
class _Cifra extends StatelessWidget {
  const _Cifra(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => TextoAjustable(
    texto,
    style: Theme.of(context).textTheme.titleLarge
        ?.copyWith(fontWeight: FontWeight.w800, color: ColoresApp.texto),
  );
}

/// Píldora con un punto y el estado del pedido.
class _PildoraEstado extends StatelessWidget {
  const _PildoraEstado({required this.estado});

  final EstadoPedido estado;

  @override
  Widget build(BuildContext context) {
    final cancelado = estado == EstadoPedido.cancelado;
    final color = cancelado ? ColoresApp.error : ColoresApp.exito;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cancelado ? ColoresApp.fondoError : ColoresApp.fondoExito,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: const SizedBox.square(dimension: 7),
          ),
          const SizedBox(width: 6),
          // Puede pasar a dos líneas ("Listo para recoger" a lo angosto).
          Flexible(
            child: Text(
              etiquetaEstado(estado),
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// Título de sección con "Ver todo" a la derecha.
class _TituloSeccion extends StatelessWidget {
  const _TituloSeccion({required this.titulo, required this.alVerTodo});

  final String titulo;
  final VoidCallback alVerTodo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            titulo,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: ColoresApp.texto,
            ),
          ),
        ),
        TextButton(onPressed: alVerTodo, child: const Text('Ver todo')),
      ],
    );
  }
}

/// Categorías desplazables: un recuadro con el icono de etiqueta y el
/// nombre debajo.
class _FilaCategorias extends StatelessWidget {
  const _FilaCategorias({required this.categorias, required this.alElegir});

  final List<Categoria> categorias;
  final ValueChanged<String> alElegir;

  static const _lado = 64.0;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    // Dos líneas de nombre, con la escala de letra del sistema.
    final alto = _lado + 6 + MediaQuery.textScalerOf(context).scale(36) + 8;
    return SizedBox(
      height: alto,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categorias.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final categoria = categorias[i];
          return SizedBox(
            width: 76,
            child: InkWell(
              borderRadius: BorderRadius.circular(radioApp),
              onTap: () => alElegir(categoria.id),
              child: Column(
                children: [
                  Container(
                    width: _lado,
                    height: _lado,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: ColoresApp.borde),
                      borderRadius: BorderRadius.circular(radioApp),
                    ),
                    child: const Icon(
                      Icons.sell_outlined,
                      color: ColoresApp.azul,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    categoria.nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: textos.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: ColoresApp.texto,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Tarjetas de producto desplazables, con el mismo alto que en el catálogo.
class _FilaProductos extends StatelessWidget {
  const _FilaProductos({required this.productos});

  final List<ProductoEnCatalogo> productos;

  @override
  Widget build(BuildContext context) {
    final alto = 164 + MediaQuery.textScalerOf(context).scale(140);
    return SizedBox(
      height: alto,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: productos.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) => SizedBox(
          width: 168,
          child: TarjetaProducto(
            key: ValueKey(productos[i].producto.id),
            item: productos[i],
          ),
        ),
      ),
    );
  }
}

/// Error al cargar el inicio, con "Reintentar".
class _ErrorInicio extends StatelessWidget {
  const _ErrorInicio({required this.alReintentar});

  final VoidCallback alReintentar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 48,
            color: ColoresApp.textoSuave,
          ),
          const SizedBox(height: 12),
          Text(
            'No pudimos cargar tu resumen.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: alReintentar,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
