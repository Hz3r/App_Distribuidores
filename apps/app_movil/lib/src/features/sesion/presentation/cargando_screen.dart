import 'package:material_ui/material_ui.dart';

/// Se muestra mientras se leen las membresías de la persona.
class CargandoScreen extends StatelessWidget {
  const CargandoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
