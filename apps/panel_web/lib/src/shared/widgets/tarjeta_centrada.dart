import 'package:material_ui/material_ui.dart';

import '../../config/tema_panel.dart';

/// Pantalla completa con una tarjeta centrada. La usan las pantallas fuera
/// del menú: ingreso, sin acceso, error y elección de distribuidor.
class TarjetaCentrada extends StatelessWidget {
  const TarjetaCentrada({
    required this.child,
    this.anchoMaximo = 420,
    super.key,
  });

  final Widget child;
  final double anchoMaximo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: anchoMaximo),
            // `Material`, no un `Container` con color: así los efectos de
            // toque de lo que va dentro (listas, botones) se ven.
            child: Material(
              color: ColoresPanel.blanco,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: ColoresPanel.neutro200),
              ),
              child: Padding(padding: const EdgeInsets.all(32), child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta centrada con un aviso: icono, título, mensaje y botones apilados.
class AvisoCentrado extends StatelessWidget {
  const AvisoCentrado({
    required this.icono,
    required this.titulo,
    required this.mensaje,
    required this.acciones,
    super.key,
  });

  final IconData icono;
  final String titulo;
  final String mensaje;
  final List<Widget> acciones;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return TarjetaCentrada(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(icono, size: 40, color: ColoresPanel.primario500),
          const SizedBox(height: 16),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: tema.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: tema.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          for (final (i, accion) in acciones.indexed) ...[
            if (i > 0) const SizedBox(height: 8),
            accion,
          ],
        ],
      ),
    );
  }
}
