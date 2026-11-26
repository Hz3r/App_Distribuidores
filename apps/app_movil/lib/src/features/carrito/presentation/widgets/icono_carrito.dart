import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../shared/tema_app.dart';
import '../carrito_providers.dart';

/// Icono del carrito con una insignia roja que cuenta sus líneas ("9+" si
/// pasan de 9). Sin líneas no hay insignia.
class IconoCarrito extends ConsumerWidget {
  const IconoCarrito({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineas = ref.watch(carritoActualProvider.select((c) => c.lineas));
    const icono = Icon(Icons.shopping_cart_outlined);
    if (lineas <= 0) return icono;
    return Badge(
      backgroundColor: ColoresApp.error,
      textColor: Colors.white,
      label: Text(lineas > 9 ? '9+' : '$lineas'),
      child: icono,
    );
  }
}
