import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'control_acceso.dart';

/// Cierra la sesión desde una pantalla y avisa si no se pudo. Al cerrarse,
/// el router lleva a la pantalla de inicio de sesión.
Future<void> cerrarSesionConAviso(BuildContext context, WidgetRef ref) async {
  final avisos = ScaffoldMessenger.maybeOf(context);
  final cerrada = await ref.read(controlAccesoProvider.notifier).cerrarSesion();
  if (!cerrada) {
    avisos?.showSnackBar(
      const SnackBar(
        content: Text('No pudimos cerrar tu sesión. Inténtalo de nuevo.'),
      ),
    );
  }
}
