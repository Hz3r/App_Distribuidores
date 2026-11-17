import 'package:material_ui/material_ui.dart';

import '../../../shared/widgets/pantalla_placeholder.dart';

class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PantallaPlaceholder(
      titulo: 'Carrito',
      descripcion: 'Resumen de tu pedido antes de confirmar. Pendiente.',
    );
  }
}
