import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/sesion/presentation/cerrar_sesion.dart';
import '../../features/sesion/presentation/control_acceso.dart';
import 'tarjeta_centrada.dart';

/// Se muestra si la cuenta no administra ni vende en ningún distribuidor.
class SinAccesoScreen extends ConsumerWidget {
  const SinAccesoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AvisoCentrado(
      icono: Icons.lock_outline_rounded,
      titulo: 'Sin acceso al panel',
      mensaje:
          'Esta cuenta no administra ningún distribuidor. Si eres cliente, '
          'usa la app móvil. Si deberías tener acceso, pide que revisen tu '
          'cuenta.',
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
