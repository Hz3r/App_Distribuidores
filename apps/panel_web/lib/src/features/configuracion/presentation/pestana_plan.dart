import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/tema_panel.dart';
import '../../../shared/formato.dart';
import '../../../shared/textos.dart';
import '../../../shared/widgets/estados.dart';
import '../../../shared/widgets/etiqueta.dart';
import '../../../shared/widgets/tarjeta_seccion.dart';
import '../../clientes/presentation/clientes_providers.dart';
import '../domain/plan_vigente.dart';
import 'configuracion_providers.dart';

/// Plan contratado y su periodo, de solo lectura.
class PestanaPlan extends ConsumerWidget {
  const PestanaPlan({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consulta = ref.watch(planVigenteProvider);
    final ahora = ref.watch(relojProvider)();

    return switch (consulta) {
      AsyncValue(hasValue: true, :final value) => switch (value) {
        null => const EstadoAviso(
          icono: Icons.workspace_premium_outlined,
          titulo: 'Sin plan registrado',
          mensaje: 'Escríbenos para activar tu plan.',
        ),
        final plan => ContenidoAjustes(
          children: [_Plan(plan: plan, ahora: ahora)],
        ),
      },
      AsyncValue(hasError: true) => EstadoAviso.error(
        alReintentar: () => ref.invalidate(planVigenteProvider),
      ),
      _ => const EstadoCarga(),
    };
  }
}

class _Plan extends StatelessWidget {
  const _Plan({required this.plan, required this.ahora});

  final PlanVigente plan;
  final DateTime ahora;

  @override
  Widget build(BuildContext context) {
    final suscripcion = plan.suscripcion;
    final estado = suscripcion.estado;
    final vigente =
        estado == EstadoSuscripcion.prueba ||
        estado == EstadoSuscripcion.activa;
    final dias = diasRestantes(suscripcion, ahora);
    final limites = limitesDe(plan.plan);

    final (String, TonoEtiqueta)? aviso = switch (estado) {
      _ when vigente && dias < 1 => (
        'Tu periodo terminó el ${fechaCorta(suscripcion.periodoFin)}. '
            'Escríbenos para renovarlo.',
        TonoEtiqueta.peligro,
      ),
      _ when vigente && dias <= 7 => (
        dias == 1
            ? 'Tu plan vence hoy. Escríbenos para renovarlo.'
            : 'Te quedan $dias días. Escríbenos para renovarlo.',
        TonoEtiqueta.aviso,
      ),
      EstadoSuscripcion.vencida => (
        'Tu plan venció el ${fechaCorta(suscripcion.periodoFin)}. Escríbenos '
            'para renovarlo.',
        TonoEtiqueta.peligro,
      ),
      EstadoSuscripcion.cancelada => (
        'Tu plan está cancelado. Escríbenos si quieres volver a activarlo.',
        TonoEtiqueta.neutro,
      ),
      _ => null,
    };

    return TarjetaSeccion(
      titulo: 'Tu plan',
      descripcion:
          'Los pagos del plan se registran a mano. Para cambiar de plan, '
          'escríbenos.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Text(
                plan.plan.nombre,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: ColoresPanel.neutro900,
                ),
              ),
              Etiqueta(
                estadoSuscripcionLegible(estado),
                tono: switch (estado) {
                  EstadoSuscripcion.activa => TonoEtiqueta.exito,
                  EstadoSuscripcion.prueba => TonoEtiqueta.info,
                  EstadoSuscripcion.vencida => TonoEtiqueta.peligro,
                  EstadoSuscripcion.cancelada => TonoEtiqueta.neutro,
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 40,
            runSpacing: 16,
            children: [
              DatoFijo(
                etiqueta: 'Precio',
                valor: '${plan.plan.precioMensualCentimos.formatoSoles} al mes',
              ),
              DatoFijo(
                etiqueta: 'Periodo',
                valor:
                    'Del ${fechaCorta(suscripcion.periodoInicio)} al '
                    '${fechaCorta(suscripcion.periodoFin)}',
              ),
              if (vigente && dias >= 1)
                DatoFijo(
                  etiqueta: 'Quedan',
                  valor: dias == 1 ? '1 día (hoy)' : '$dias días',
                ),
            ],
          ),
          if (aviso case (final mensaje, final tono)) ...[
            const SizedBox(height: 20),
            Semantics(
              liveRegion: true,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tono.fondo,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  mensaje,
                  style: const TextStyle(
                    fontSize: 14,
                    color: ColoresPanel.neutro900,
                  ),
                ),
              ),
            ),
          ],
          if (limites.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Incluye',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ColoresPanel.neutro900,
              ),
            ),
            const SizedBox(height: 8),
            for (final (nombre, tope) in limites)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                      color: ColoresPanel.exito500,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$nombre: hasta ${_miles(tope)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: ColoresPanel.neutro700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// `2,000` con separador de miles, como los montos del panel.
String _miles(int n) {
  final texto = '$n';
  final buffer = StringBuffer();
  for (var i = 0; i < texto.length; i++) {
    if (i > 0 && (texto.length - i) % 3 == 0) buffer.write(',');
    buffer.write(texto[i]);
  }
  return buffer.toString();
}
