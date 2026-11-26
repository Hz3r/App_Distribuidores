import 'package:material_ui/material_ui.dart';

import '../../../../shared/tema_app.dart';

/// Mensaje centrado para un estado sin productos (error, vacío, sin
/// resultados), con una acción opcional. Se puede deslizar, para que un
/// `RefreshIndicator` que lo envuelva funcione.
class MensajeEstado extends StatelessWidget {
  const MensajeEstado({
    required this.icono,
    required this.mensaje,
    this.accion,
    this.alAccion,
    super.key,
  });

  final IconData icono;
  final String mensaje;

  /// Texto del botón; sin él, o sin [alAccion], no hay botón.
  final String? accion;
  final VoidCallback? alAccion;

  @override
  Widget build(BuildContext context) {
    final accion = this.accion;
    return LayoutBuilder(
      builder: (context, restricciones) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: restricciones.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icono, size: 48, color: ColoresApp.textoSuave),
                  const SizedBox(height: 12),
                  Text(
                    mensaje,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (accion != null && alAccion != null) ...[
                    const SizedBox(height: 16),
                    OutlinedButton(onPressed: alAccion, child: Text(accion)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
