import 'package:material_ui/material_ui.dart';

import '../../../shared/widgets/pantalla_placeholder.dart';

class SeleccionDistribuidorScreen extends StatelessWidget {
  const SeleccionDistribuidorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PantallaPlaceholder(
      titulo: 'Distribuidor',
      descripcion: 'Elige el distribuidor del que quieres comprar.',
    );
  }
}
