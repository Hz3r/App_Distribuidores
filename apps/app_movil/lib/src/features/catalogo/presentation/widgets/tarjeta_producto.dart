import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../config/rutas.dart';
import '../../../../shared/tema_app.dart';
import '../../../carrito/presentation/carrito_providers.dart';
import '../../domain/catalogo.dart';
import '../../domain/disponibilidad.dart';
import 'imagen_producto.dart';

/// Tarjeta de un producto con su presentación principal: imagen, nombre,
/// disponibilidad, precio y un "+" que agrega una unidad al carrito. Tocarla
/// abre el detalle.
///
/// Ocupa lo que le den: en una cuadrícula o en una lista horizontal (con un
/// ancho dado por quien la usa). Con alto acotado la imagen se estira para
/// llenarlo; sin él, la imagen es casi cuadrada.
class TarjetaProducto extends ConsumerWidget {
  const TarjetaProducto({required this.item, super.key});

  final ProductoEnCatalogo item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final producto = item.producto;
    final principal = item.principal;
    // El tope es el del stock compartido por todas las presentaciones.
    final (:tope, :enCarrito) = ref.watch(
      carritoActualProvider.select(
        (carrito) => (
          tope: disponibleEnCarrito(
            producto: producto,
            presentacion: principal,
            carrito: carrito,
          ),
          enCarrito: carrito.cantidadDe(principal.id),
        ),
      ),
    );
    final puedeAgregar = enCarrito < tope;

    void agregar() {
      ref
          .read(carritoActualProvider.notifier)
          .agregar(principal.id, 1, disponible: tope);
      avisarAgregadoAlCarrito(context);
    }

    final textos = Theme.of(context).textTheme;
    return Opacity(
      opacity: item.agotado ? 0.5 : 1,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radioApp),
          side: const BorderSide(color: ColoresApp.borde),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(AppRutas.detalleProducto(producto.id)),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: LayoutBuilder(
              builder: (context, restricciones) {
                final imagen = ImagenProducto(url: producto.imagenUrl);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (restricciones.hasBoundedHeight)
                      Expanded(child: imagen)
                    else
                      AspectRatio(aspectRatio: 1.25, child: imagen),
                    const SizedBox(height: 10),
                    Text(
                      producto.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textos.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      principal.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textos.bodySmall?.copyWith(
                        color: ColoresApp.textoSuave,
                      ),
                    ),
                    const SizedBox(height: 4),
                    IndicadorDisponibilidad(disponible: item.disponible),
                    const SizedBox(height: 8),
                    // El precio va solo en su línea y se achica si no cabe:
                    // un precio recortado se leería como otro número.
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        Dinero.formatear(item.precioCentimos),
                        maxLines: 1,
                        style: textos.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'por ${principal.nombre.toLowerCase()}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textos.bodySmall?.copyWith(
                              color: ColoresApp.textoSuave,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _BotonMas(
                          tooltip: 'Agregar ${producto.nombre} al carrito',
                          onPressed: puedeAgregar ? agregar : null,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Punto y texto de disponibilidad: "340 disponibles" en verde, o "Agotado"
/// en rojo.
class IndicadorDisponibilidad extends StatelessWidget {
  const IndicadorDisponibilidad({required this.disponible, super.key});

  final int disponible;

  @override
  Widget build(BuildContext context) {
    final agotado = disponible <= 0;
    final color = agotado ? ColoresApp.error : ColoresApp.exito;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: const SizedBox.square(dimension: 7),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            textoDisponibilidad(disponible),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

/// "Agotado", "1 disponible" o "N disponibles".
String textoDisponibilidad(int disponible) => switch (disponible) {
  <= 0 => 'Agotado',
  1 => '1 disponible',
  _ => '$disponible disponibles',
};

/// Avisa "Agregado al carrito" con el mensajero raíz de la app, el mismo de
/// los avisos de acceso, para que se vea por encima de la barra inferior.
void avisarAgregadoAlCarrito(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(
        content: Text('Agregado al carrito'),
        duration: Duration(seconds: 2),
      ),
    );
}

class _BotonMas extends StatelessWidget {
  const _BotonMas({required this.tooltip, required this.onPressed});

  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: ColoresApp.azul,
        foregroundColor: Colors.white,
        disabledBackgroundColor: ColoresApp.azulSuave,
        disabledForegroundColor: ColoresApp.azul.withValues(alpha: 0.45),
        fixedSize: const Size.square(40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: const Icon(Icons.add),
    );
  }
}
