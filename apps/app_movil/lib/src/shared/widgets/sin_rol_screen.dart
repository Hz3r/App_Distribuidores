import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../config/rutas.dart';
import '../../features/sesion/domain/acceso.dart';
import '../../features/sesion/presentation/cerrar_sesion.dart';
import '../../features/sesion/presentation/control_acceso.dart';
import '../tema_app.dart';

/// Se muestra si la persona inició sesión pero no tiene ninguna membresía
/// útil en la app móvil: admin o vendedor (usan el panel web), cliente con la
/// bodega desactivada, membresía suspendida o cuenta sin vincular. Si el
/// código del registro no vinculó, lo avisa.
class SinRolScreen extends ConsumerWidget {
  const SinRolScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acceso = ref.watch(controlAccesoProvider);
    final aviso = acceso is ConAcceso ? acceso.aviso : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Sin acceso en la app')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (aviso != null) ...[
                // `liveRegion`: el lector de pantalla lo anuncia al llegar.
                Semantics(
                  liveRegion: true,
                  child: Text(
                    aviso,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: ColoresApp.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const Text(
                'No tienes acceso activo en la app móvil. Si administras o '
                'vendes, usa el panel web. Si eres cliente o repartidor, pide '
                'a tu distribuidor un código de invitación o que revise tu '
                'cuenta.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    ref.read(controlAccesoProvider.notifier).recargar(),
                child: const Text('Reintentar'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(altoBoton),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radioApp),
                  ),
                ),
                onPressed: () => context.push(AppRutas.codigo),
                child: const Text('Tengo un código'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => cerrarSesionConAviso(context, ref),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
