import 'package:material_ui/material_ui.dart';

import '../../../shared/widgets/pantalla_placeholder.dart';

class RepartidorScreen extends StatelessWidget {
  const RepartidorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PantallaPlaceholder(
      titulo: 'Repartidor',
      descripcion: 'Entregas asignadas y su estado. Pendiente.',
    );
  }
}
