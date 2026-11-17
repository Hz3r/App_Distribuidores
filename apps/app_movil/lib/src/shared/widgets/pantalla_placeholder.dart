import 'package:material_ui/material_ui.dart';

/// Pantalla base para features aún no implementadas.
class PantallaPlaceholder extends StatelessWidget {
  const PantallaPlaceholder({
    required this.titulo,
    required this.descripcion,
    super.key,
  });

  final String titulo;
  final String descripcion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            descripcion,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
