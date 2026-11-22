import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/rutas.dart';
import '../../sesion/domain/acceso.dart';
import '../../sesion/presentation/control_acceso.dart';

/// Lista los distribuidores en los que la persona tiene una membresía útil y
/// le deja elegir con cuál entrar.
class SeleccionDistribuidorScreen extends ConsumerWidget {
  const SeleccionDistribuidorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acceso = ref.watch(controlAccesoProvider);
    final membresias = acceso is ConAcceso ? acceso.membresias : <Membresia>[];
    final activa = acceso is ConAcceso ? acceso.activa : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Elige un distribuidor')),
      body: ListView(
        children: [
          for (final m in membresias)
            ListTile(
              title: Text(m.distribuidor?.nombreVisible ?? m.distribuidorId),
              subtitle: Text(_rolLegible(m.rol)),
              trailing: m == activa ? const Icon(Icons.check) : null,
              selected: m == activa,
              onTap: () => _elegir(context, ref, m.distribuidorId),
            ),
        ],
      ),
    );
  }

  Future<void> _elegir(
    BuildContext context,
    WidgetRef ref,
    String distribuidorId,
  ) async {
    final router = GoRouter.maybeOf(context);
    final avisos = ScaffoldMessenger.maybeOf(context);
    try {
      await ref
          .read(controlAccesoProvider.notifier)
          .elegirDistribuidor(distribuidorId);
    } catch (_) {
      // La elección ya vale en esta sesión; solo no quedó guardada.
      avisos?.showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar tu elección para la próxima vez.'),
        ),
      );
    }
    // El router lleva desde el catálogo al inicio que corresponda al rol.
    router?.go(AppRutas.catalogo);
  }
}

String _rolLegible(RolMembresia rol) => switch (rol) {
  RolMembresia.cliente => 'Cliente',
  RolMembresia.repartidor => 'Repartidor',
  RolMembresia.admin => 'Administrador',
  RolMembresia.vendedor => 'Vendedor',
};
