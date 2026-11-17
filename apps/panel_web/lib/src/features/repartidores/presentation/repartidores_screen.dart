import 'package:material_ui/material_ui.dart';

import '../../../shared/widgets/pantalla_placeholder.dart';

class RepartidoresScreen extends StatelessWidget {
  const RepartidoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PantallaPlaceholder(
      titulo: 'Repartidores',
      descripcion: 'Asignación de entregas. Pendiente.',
    );
  }
}
