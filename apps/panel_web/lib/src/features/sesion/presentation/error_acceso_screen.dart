import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/widgets/tarjeta_centrada.dart';
import '../domain/acceso.dart';
import 'cerrar_sesion.dart';
import 'control_acceso.dart';

/// Se muestra si no se pudieron leer las membresías.
class ErrorAccesoScreen extends ConsumerWidget {
  const ErrorAccesoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acceso = ref.watch(controlAccesoProvider);
    final mensaje = acceso is ErrorAcceso
        ? acceso.mensaje
        : 'No pudimos cargar tu acceso.';

    return AvisoCentrado(
      icono: Icons.cloud_off_rounded,
      titulo: 'Algo salió mal',
      mensaje: mensaje,
      acciones: [
        FilledButton(
          onPressed: () => ref.read(controlAccesoProvider.notifier).recargar(),
          child: const Text('Reintentar'),
        ),
        TextButton(
          onPressed: () => cerrarSesionConAviso(context, ref),
          child: const Text('Cerrar sesión'),
        ),
      ],
    );
  }
}
