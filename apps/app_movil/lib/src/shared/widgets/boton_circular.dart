import 'package:material_ui/material_ui.dart';

import '../tema_app.dart';

/// Botón redondo con borde fino y un icono, como el de la lupa o el de
/// volver de las maquetas. [child] reemplaza al icono (por ejemplo, un icono
/// con insignia).
class BotonCircular extends StatelessWidget {
  const BotonCircular({
    required this.icono,
    required this.tooltip,
    required this.onPressed,
    this.child,
    super.key,
  });

  final IconData icono;
  final String tooltip;
  final VoidCallback? onPressed;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        foregroundColor: ColoresApp.texto,
        side: const BorderSide(color: ColoresApp.borde),
        shape: const CircleBorder(),
        fixedSize: const Size.square(44),
      ),
      icon: child ?? Icon(icono, size: 22),
    );
  }
}
