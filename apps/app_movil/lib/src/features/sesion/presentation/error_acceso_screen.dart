import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/acceso.dart';
import 'control_acceso.dart';

/// Se muestra si no se pudieron leer las membresías.
class ErrorAccesoScreen extends ConsumerWidget {
  const ErrorAccesoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acceso = ref.watch(controlAccesoProvider);
    final mensaje = acceso is ErrorAcceso
        ? acceso.mensaje
        : 'No se pudieron leer tus accesos.';

    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(mensaje, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    ref.read(controlAccesoProvider.notifier).recargar(),
                child: const Text('Reintentar'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => supabase.auth.signOut(),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
