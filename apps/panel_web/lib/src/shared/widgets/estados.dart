import 'package:material_ui/material_ui.dart';

import '../../config/tema_panel.dart';

/// Se muestra mientras una sección lee sus datos por primera vez.
class EstadoCarga extends StatelessWidget {
  const EstadoCarga({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/// Aviso centrado dentro de una sección: sin datos, sin resultados o error.
class EstadoAviso extends StatelessWidget {
  const EstadoAviso({
    required this.icono,
    required this.titulo,
    required this.mensaje,
    this.accion,
    super.key,
  });

  /// No se pudieron leer los datos; [alReintentar] vuelve a pedirlos.
  factory EstadoAviso.error({required VoidCallback alReintentar}) {
    return EstadoAviso(
      icono: Icons.cloud_off_rounded,
      titulo: 'No pudimos cargar esta sección',
      mensaje: 'Revisa tu conexión e inténtalo de nuevo.',
      accion: FilledButton(
        onPressed: alReintentar,
        child: const Text('Reintentar'),
      ),
    );
  }

  final IconData icono;
  final String titulo;
  final String mensaje;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final accion = this.accion;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 40, color: ColoresPanel.neutro300),
            const SizedBox(height: 12),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: tema.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: tema.textTheme.bodyMedium,
            ),
            if (accion != null) ...[const SizedBox(height: 16), accion],
          ],
        ),
      ),
    );
  }
}

/// Caja roja con el motivo por el que no se pudo guardar un formulario.
class CajaError extends StatelessWidget {
  const CajaError(this.mensaje, {super.key});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: ColoresPanel.peligro100,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Text(
          mensaje,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: ColoresPanel.peligro500),
        ),
      ),
    );
  }
}
