import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/rutas.dart';
import '../../../shared/lectura_vigente.dart';
import '../../../shared/tema_app.dart';
import '../../../shared/widgets/boton_circular.dart';
import '../../../shared/widgets/texto_ajustable.dart';
import '../../carrito/domain/carrito.dart';
import '../../carrito/presentation/carrito_providers.dart';
import '../../carrito/presentation/widgets/icono_carrito.dart';
import '../domain/catalogo.dart';
import '../domain/disponibilidad.dart';
import '../domain/precios.dart';
import 'catalogo_providers.dart';
import 'widgets/imagen_producto.dart';
import 'widgets/mensaje_estado.dart';
import 'widgets/tarjeta_producto.dart';

/// Detalle de un producto: presentaciones, precios por volumen y una barra
/// fija para elegir la cantidad y agregarla al carrito. Lee el mismo
/// catálogo en memoria que la lista.
class DetalleProductoScreen extends ConsumerStatefulWidget {
  const DetalleProductoScreen({required this.productoId, super.key});

  final String productoId;

  /// Texto con la cantidad elegida, para las pruebas.
  static const claveCantidad = ValueKey('detalle-cantidad');

  @override
  ConsumerState<DetalleProductoScreen> createState() =>
      _DetalleProductoScreenState();
}

class _DetalleProductoScreenState extends ConsumerState<DetalleProductoScreen> {
  /// `null`: la principal.
  String? _presentacionId;

  /// Lo que la persona eligió; se muestra limitado a lo que cabe.
  int _cantidad = 1;

  @override
  Widget build(BuildContext context) {
    final (:lectura, :catalogo) = observarCatalogo(ref);
    final Widget cuerpo;
    Widget? barra;
    if (catalogo == null) {
      cuerpo = !lectura.mostrarError
          ? const Center(child: CircularProgressIndicator())
          : MensajeEstado(
              icono: Icons.cloud_off_outlined,
              mensaje: 'No pudimos cargar el producto.',
              accion: 'Reintentar',
              alAccion: () => ref.invalidate(catalogoProvider),
            );
    } else {
      // Solo lo que el catálogo muestra: un producto oculto, inactivo o sin
      // presentaciones activas ya no se puede pedir.
      final item = productosDelCatalogo(catalogo)
          .where((p) => p.producto.id == widget.productoId)
          .firstOrNull;
      if (item == null) {
        cuerpo = MensajeEstado(
          icono: Icons.inventory_2_outlined,
          mensaje: 'Este producto ya no está disponible.',
          accion: 'Volver al catálogo',
          alAccion: () => context.go(AppRutas.catalogo),
        );
      } else {
        final vista = _armarVista(
          catalogo,
          item,
          ref.watch(carritoActualProvider),
        );
        cuerpo = _Contenido(
          vista: vista,
          alElegirPresentacion: (p) => _elegirPresentacion(item.producto, p),
        );
        barra = _BarraAgregar(
          vista: vista,
          alCambiarCantidad: (n) => setState(() => _cantidad = n),
          alAgregar: () => _agregar(vista),
        );
      }
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Encabezado(),
            Expanded(child: cuerpo),
          ],
        ),
      ),
      bottomNavigationBar: barra,
    );
  }

  _Vista _armarVista(
    Catalogo catalogo,
    ProductoEnCatalogo item,
    Carrito carrito,
  ) {
    final producto = item.producto;
    final presentaciones = presentacionesActivas(producto);
    final elegida =
        presentaciones.where((p) => p.id == _presentacionId).firstOrNull ??
        item.principal;
    final maximo = _maximoPara(producto, elegida, carrito);
    final cantidad = maximo <= 0 ? 0 : _cantidad.clamp(1, maximo);
    final precioLista = catalogo.preciosLista[elegida.id];
    final enCarrito = carrito.cantidadDe(elegida.id);
    int unitario(int n) => precioUnitario(
      precioBase: elegida.precioBaseCentimos,
      precioLista: precioLista,
      preciosVolumen: elegida.preciosVolumen,
      cantidad: n,
    );
    // La base cobra la línea ya sumada, con el tramo de esa cantidad.
    final linea = math.max(enCarrito + cantidad, 1);
    return _Vista(
      producto: producto,
      categoria: catalogo.categorias
          .where((c) => c.id == producto.categoriaId)
          .firstOrNull
          ?.nombre,
      presentaciones: presentaciones,
      elegida: elegida,
      disponible: disponiblePresentacion(
        stockFisico: producto.stockFisico,
        stockComprometido: producto.stockComprometido,
        factor: elegida.factor,
      ),
      tope: disponibleEnCarrito(
        producto: producto,
        presentacion: elegida,
        carrito: carrito,
      ),
      maximo: maximo,
      cantidad: cantidad,
      enCarrito: enCarrito,
      montoCantidad: cantidad * unitario(math.max(cantidad, 1)),
      precioLinea: unitario(linea),
      tramos: tramosDePrecio(
        precioBase: elegida.precioBaseCentimos,
        precioLista: precioLista,
        preciosVolumen: elegida.preciosVolumen,
      ),
    );
  }

  /// Cuánto más se puede agregar de [presentacion]: el tope del stock
  /// compartido menos lo que el carrito ya tiene de ella.
  int _maximoPara(
    Producto producto,
    Presentacion presentacion,
    Carrito carrito,
  ) {
    final tope = disponibleEnCarrito(
      producto: producto,
      presentacion: presentacion,
      carrito: carrito,
    );
    return math.max(0, tope - carrito.cantidadDe(presentacion.id));
  }

  void _elegirPresentacion(Producto producto, Presentacion presentacion) {
    final maximo = _maximoPara(
      producto,
      presentacion,
      ref.read(carritoActualProvider),
    );
    setState(() {
      _presentacionId = presentacion.id;
      _cantidad = maximo <= 0 ? 1 : _cantidad.clamp(1, maximo);
    });
  }

  void _agregar(_Vista vista) {
    ref
        .read(carritoActualProvider.notifier)
        .agregar(vista.elegida.id, vista.cantidad, disponible: vista.tope);
    avisarAgregadoAlCarrito(context);
    setState(() => _cantidad = 1);
  }
}

/// Todo lo que el detalle muestra de la presentación elegida.
class _Vista {
  const _Vista({
    required this.producto,
    required this.categoria,
    required this.presentaciones,
    required this.elegida,
    required this.disponible,
    required this.tope,
    required this.maximo,
    required this.cantidad,
    required this.enCarrito,
    required this.montoCantidad,
    required this.precioLinea,
    required this.tramos,
  });

  final Producto producto;

  /// Nombre de la categoría, si tiene.
  final String? categoria;

  /// Activas, por `orden`.
  final List<Presentacion> presentaciones;
  final Presentacion elegida;

  /// De la presentación sola, para mostrar.
  final int disponible;

  /// Máximo que el carrito puede tener de [elegida] (stock compartido).
  final int tope;

  /// Cuánto más se puede agregar de [elegida]; 0 si nada.
  final int maximo;

  /// Entre 1 y [maximo]; 0 si [maximo] es 0.
  final int cantidad;

  /// Lo que el carrito ya tiene de [elegida].
  final int enCarrito;

  /// [cantidad] × su precio unitario, para el botón con el carrito vacío
  /// de [elegida].
  final int montoCantidad;

  /// Precio unitario de la línea sumada ([cantidadLinea]).
  final int precioLinea;

  /// Cantidad con la que se cobrará la línea; decide el tramo resaltado.
  int get cantidadLinea => math.max(enCarrito + cantidad, 1);
  final List<TramoPrecio> tramos;
}

class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          BotonCircular(
            icono: Icons.arrow_back,
            tooltip: 'Volver',
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(AppRutas.catalogo),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Detalle',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          BotonCircular(
            icono: Icons.shopping_cart_outlined,
            tooltip: 'Ver carrito',
            onPressed: () => context.go(AppRutas.carrito),
            child: const IconoCarrito(),
          ),
        ],
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.vista, required this.alElegirPresentacion});

  final _Vista vista;
  final ValueChanged<Presentacion> alElegirPresentacion;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final producto = vista.producto;
    final linea = [
      ?vista.categoria,
      ?producto.marca,
    ].where((t) => t.trim().isNotEmpty).join(' · ').toUpperCase();
    final descripcion = producto.descripcion?.trim() ?? '';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        AspectRatio(
          aspectRatio: 1.4,
          child: ImagenProducto(url: producto.imagenUrl, tamanoIcono: 72),
        ),
        const SizedBox(height: 16),
        if (linea.isNotEmpty) ...[
          Text(
            linea,
            style: textos.labelMedium?.copyWith(
              color: ColoresApp.azul,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          producto.nombre,
          style: textos.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: ColoresApp.texto,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              vista.elegida.nombre,
              style: textos.bodyMedium?.copyWith(color: ColoresApp.textoSuave),
            ),
            IndicadorDisponibilidad(disponible: vista.disponible),
          ],
        ),
        if (vista.presentaciones.length > 1) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in vista.presentaciones)
                ChoiceChip(
                  label: Text(p.nombre),
                  selected: p.id == vista.elegida.id,
                  showCheckmark: false,
                  onSelected: (_) => alElegirPresentacion(p),
                  backgroundColor: Colors.white,
                  selectedColor: ColoresApp.azul,
                  labelStyle: TextStyle(
                    color: p.id == vista.elegida.id
                        ? Colors.white
                        : ColoresApp.texto,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                    color: p.id == vista.elegida.id
                        ? ColoresApp.azul
                        : ColoresApp.borde,
                  ),
                  shape: const StadiumBorder(),
                ),
            ],
          ),
        ],
        if (vista.tramos.length > 1) ...[
          const SizedBox(height: 20),
          _TarjetaTramos(vista: vista),
        ],
        if (descripcion.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Descripción',
            style: textos.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            descripcion,
            style: textos.bodyMedium?.copyWith(color: ColoresApp.textoSuave),
          ),
        ],
      ],
    );
  }
}

class _TarjetaTramos extends StatelessWidget {
  const _TarjetaTramos({required this.vista});

  final _Vista vista;

  @override
  Widget build(BuildContext context) {
    // El tramo es el de la línea sumada: lo que ya hay más lo elegido.
    final cantidad = vista.cantidadLinea;
    final unidad = vista.elegida.nombre.toLowerCase();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: ColoresApp.borde),
        borderRadius: BorderRadius.circular(radioApp),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Precio mayorista por volumen',
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          for (final tramo in vista.tramos) ...[
            const SizedBox(height: 8),
            FilaTramo(
              tramo: tramo,
              unidad: unidad,
              resaltada:
                  cantidad >= tramo.desde &&
                  (tramo.hasta == null || cantidad <= tramo.hasta!),
            ),
          ],
        ],
      ),
    );
  }
}

/// Una fila de la tarjeta de precios por volumen: el rango y el precio por
/// [unidad]. [resaltada] marca el tramo con el que se cobrará la línea.
class FilaTramo extends StatelessWidget {
  const FilaTramo({
    required this.tramo,
    required this.unidad,
    required this.resaltada,
    super.key,
  });

  final TramoPrecio tramo;
  final String unidad;
  final bool resaltada;

  @override
  Widget build(BuildContext context) {
    final peso = resaltada ? FontWeight.w700 : FontWeight.w500;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: resaltada ? ColoresApp.azulSuave : Colors.white,
        border: Border.all(
          color: resaltada ? ColoresApp.azul : ColoresApp.borde,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              textoTramo(tramo),
              style: TextStyle(fontWeight: peso, color: ColoresApp.texto),
            ),
          ),
          Text(
            Dinero.formatear(tramo.precioCentimos),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: ColoresApp.texto,
            ),
          ),
          Flexible(
            child: Text(
              ' / $unidad',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: ColoresApp.textoSuave),
            ),
          ),
        ],
      ),
    );
  }
}

/// "1 – 9", "50 o más", o "Desde 1" si es el único tramo.
String textoTramo(TramoPrecio tramo) {
  final hasta = tramo.hasta;
  if (hasta == null) {
    return tramo.desde <= 1 ? 'Desde 1' : '${tramo.desde} o más';
  }
  return hasta == tramo.desde ? '$hasta' : '${tramo.desde} – $hasta';
}

class _BarraAgregar extends StatelessWidget {
  const _BarraAgregar({
    required this.vista,
    required this.alCambiarCantidad,
    required this.alAgregar,
  });

  final _Vista vista;
  final ValueChanged<int> alCambiarCantidad;
  final VoidCallback alAgregar;

  @override
  Widget build(BuildContext context) {
    final cantidad = vista.cantidad;
    final puede = vista.maximo > 0;
    final Widget etiqueta;
    if (vista.disponible <= 0) {
      etiqueta = const Text('Agotado');
    } else if (!puede) {
      etiqueta = const Text(
        'Ya tienes en el carrito todo lo disponible de este producto.',
        textAlign: TextAlign.center,
      );
    } else if (vista.enCarrito > 0) {
      // Sin monto: el total de la línea va en el texto de arriba. Restar
      // totales podría dar negativo al pasar a un tramo más barato.
      etiqueta = Text('Agregar $cantidad más', textAlign: TextAlign.center);
    } else {
      etiqueta = _EtiquetaAgregar(monto: Dinero.formatear(vista.montoCantidad));
    }
    final linea = vista.cantidadLinea;
    final aviso = vista.enCarrito <= 0
        ? null
        : cantidad <= 0
        ? 'Ya tienes ${vista.enCarrito} en el carrito.'
        : 'Ya tienes ${vista.enCarrito} en el carrito. Quedarán $linea a '
              '${Dinero.formatear(vista.precioLinea)} c/u: '
              '${Dinero.formatear(linea * vista.precioLinea)}.';

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: ColoresApp.borde)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (aviso != null) ...[
                Text(
                  aviso,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: ColoresApp.textoSuave),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  if (puede) ...[
                    _SelectorCantidad(
                      cantidad: cantidad,
                      alRestar: cantidad > 1
                          ? () => alCambiarCantidad(cantidad - 1)
                          : null,
                      alSumar: cantidad < vista.maximo
                          ? () => alCambiarCantidad(cantidad + 1)
                          : null,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: FilledButton(
                      onPressed: puede ? alAgregar : null,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                      child: etiqueta,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Agregar · S/ X" en una línea si cabe; si no, "Agregar" arriba y el monto
/// abajo, que se achica (hasta 11 puntos) o pasa a otra línea antes que
/// cortarse.
class _EtiquetaAgregar extends StatelessWidget {
  const _EtiquetaAgregar({required this.monto});

  final String monto;

  @override
  Widget build(BuildContext context) {
    final enUnaLinea = 'Agregar · $monto';
    return LayoutBuilder(
      builder: (context, restricciones) {
        final medida = TextPainter(
          text: TextSpan(
            text: enUnaLinea,
            style: DefaultTextStyle.of(context).style,
          ),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
        )..layout();
        final cabe = medida.width <= restricciones.maxWidth;
        medida.dispose();
        if (cabe) return Text(enUnaLinea, maxLines: 1);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [const Text('Agregar', maxLines: 1), TextoAjustable(monto)],
        );
      },
    );
  }
}

/// Píldora con "−", la cantidad y "+".
class _SelectorCantidad extends StatelessWidget {
  const _SelectorCantidad({
    required this.cantidad,
    required this.alRestar,
    required this.alSumar,
  });

  final int cantidad;
  final VoidCallback? alRestar;
  final VoidCallback? alSumar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: ColoresApp.borde),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Restar uno',
            visualDensity: VisualDensity.compact,
            onPressed: alRestar,
            icon: const Icon(Icons.remove),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 28),
            child: Text(
              '$cantidad',
              key: DetalleProductoScreen.claveCantidad,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          IconButton.filled(
            tooltip: 'Sumar uno',
            visualDensity: VisualDensity.compact,
            onPressed: alSumar,
            style: IconButton.styleFrom(
              backgroundColor: ColoresApp.azul,
              foregroundColor: Colors.white,
              disabledBackgroundColor: ColoresApp.azulSuave,
              disabledForegroundColor: ColoresApp.azul.withValues(alpha: 0.45),
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
