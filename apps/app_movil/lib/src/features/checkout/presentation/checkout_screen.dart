import 'package:material_ui/material_ui.dart';

import '../../../shared/widgets/pantalla_placeholder.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PantallaPlaceholder(
      titulo: 'Confirmar pedido',
      descripcion: 'Confirmación y envío del pedido. Pendiente.',
    );
  }
}
