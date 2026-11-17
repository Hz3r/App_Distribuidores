import 'package:material_ui/material_ui.dart';

import '../../../shared/widgets/pantalla_placeholder.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PantallaPlaceholder(
      titulo: 'Perfil',
      descripcion: 'Datos de tu negocio y cuenta. Pendiente.',
    );
  }
}
