import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/tema_panel.dart';
import '../../../router/destino.dart';
import '../../../shared/textos.dart';
import '../../../shared/widgets/tarjeta_centrada.dart';
import '../../sesion/domain/acceso.dart';
import '../../sesion/presentation/cerrar_sesion.dart';
import '../../sesion/presentation/control_acceso.dart';

/// Lista los distribuidores que la persona administra (o donde vende) y le
/// deja elegir con cuál entrar al panel.
class SeleccionDistribuidorScreen extends ConsumerWidget {
  const SeleccionDistribuidorScreen({this.desde, super.key});

  /// Sección a la que la persona quería ir, si venía de una.
  final String? desde;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acceso = ref.watch(controlAccesoProvider);
    final membresias = acceso is ConAcceso ? acceso.membresias : <Membresia>[];
    final activa = acceso is ConAcceso ? acceso.activa : null;
    final tema = Theme.of(context);

    return TarjetaCentrada(
      anchoMaximo: 480,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Elige un distribuidor',
            style: tema.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tu cuenta tiene acceso a más de uno.',
            style: tema.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          for (final m in membresias)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: m == activa
                        ? ColoresPanel.primario500
                        : ColoresPanel.neutro200,
                  ),
                ),
                leading: const Icon(Icons.storefront_outlined),
                title: Text(m.distribuidor?.nombreVisible ?? m.distribuidorId),
                subtitle: Text(rolLegible(m.rol)),
                trailing: m == activa
                    ? const Icon(Icons.check, color: ColoresPanel.primario500)
                    : const Icon(Icons.chevron_right),
                onTap: () => _elegir(context, ref, m),
              ),
            ),
          TextButton(
            onPressed: () => cerrarSesionConAviso(context, ref),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  Future<void> _elegir(
    BuildContext context,
    WidgetRef ref,
    Membresia membresia,
  ) async {
    final router = GoRouter.maybeOf(context);
    final avisos = ScaffoldMessenger.maybeOf(context);
    try {
      await ref
          .read(controlAccesoProvider.notifier)
          .elegirDistribuidor(membresia.distribuidorId);
    } catch (_) {
      // La elección ya vale en esta sesión; solo no quedó guardada.
      avisos?.showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar tu elección para la próxima vez.'),
        ),
      );
    }
    router?.go(inicioPara(membresia.rol, desde));
  }
}
