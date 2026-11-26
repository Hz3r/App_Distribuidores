import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/rutas.dart';
import '../../../shared/tema_app.dart';
import '../../sesion/domain/acceso.dart';
import '../../sesion/presentation/control_acceso.dart';
import '../domain/argumentos_registro.dart';
import '../domain/invitacion_previa.dart';
import '../domain/invitaciones_repositorio.dart';
import 'registro_providers.dart';
import 'widgets/casillas_codigo.dart';

/// Ingreso del código de invitación. Sin sesión lleva al registro; con
/// sesión canjea el código directamente (para sumar otro distribuidor).
class CodigoScreen extends ConsumerStatefulWidget {
  const CodigoScreen({super.key});

  @override
  ConsumerState<CodigoScreen> createState() => _CodigoScreenState();
}

class _CodigoScreenState extends ConsumerState<CodigoScreen> {
  /// El registro está abierto encima: evita apilarlo dos veces con dos
  /// toques rápidos en Continuar.
  var _abriendoRegistro = false;

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(ingresoCodigoProvider);
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton.outlined(
                      tooltip: 'Volver',
                      style: IconButton.styleFrom(
                        side: const BorderSide(color: ColoresApp.borde),
                      ),
                      onPressed: () => _volver(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: ColoresApp.azulSuave,
                        borderRadius: BorderRadius.circular(radioApp),
                      ),
                      child: const Icon(
                        Icons.key_outlined,
                        color: ColoresApp.azul,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Ingresa tu código', style: textos.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Tu distribuidor te entregó un código único para '
                      'vincular tu negocio con su catálogo.',
                      style: textos.bodyLarge?.copyWith(
                        color: ColoresApp.textoSuave,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CasillasCodigo(
                      habilitado: !estado.canjeando,
                      onChanged: ref
                          .read(ingresoCodigoProvider.notifier)
                          .cambiarCodigo,
                    ),
                    const SizedBox(height: 20),
                    _EstadoConsulta(
                      estado: estado,
                      onReintentar: ref
                          .read(ingresoCodigoProvider.notifier)
                          .reintentar,
                    ),
                    const Spacer(),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: estado.puedeContinuar ? _continuar : null,
                      child: const Text('Continuar'),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        '¿No tienes código? Pídelo a tu distribuidor.',
                        textAlign: TextAlign.center,
                        style: textos.bodySmall?.copyWith(
                          color: ColoresApp.textoSuave,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Vuelve a la pantalla anterior; si se llegó directo, a la bienvenida
  /// (con sesión, el router la cambia por el inicio que corresponda).
  void _volver(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRutas.bienvenida);
    }
  }

  Future<void> _continuar() async {
    final estado = ref.read(ingresoCodigoProvider);
    final invitacion = estado.invitacion;
    if (invitacion == null) return;

    if (ref.read(controlAccesoProvider) is SinSesion) {
      if (_abriendoRegistro) return;
      _abriendoRegistro = true;
      try {
        // El futuro termina cuando se vuelve del registro.
        await context.push(
          AppRutas.registro,
          extra: ArgumentosRegistro(
            codigo: estado.codigo,
            invitacion: invitacion,
          ),
        );
      } finally {
        _abriendoRegistro = false;
      }
      return;
    }
    await ref.read(ingresoCodigoProvider.notifier).canjear();
  }
}

/// Lo que se sabe del código: consultando, el resultado o el fallo del canje.
class _EstadoConsulta extends StatelessWidget {
  const _EstadoConsulta({required this.estado, required this.onReintentar});

  final EstadoIngresoCodigo estado;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    if (estado.consultando) {
      return const Center(
        child: SizedBox.square(
          dimension: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            semanticsLabel: 'Comprobando el código',
          ),
        ),
      );
    }

    final aviso = switch (estado.consulta) {
      null => null,
      CodigoValido(:final invitacion) => _TarjetaValido(invitacion: invitacion),
      CodigoNoValido() => const _Error(
        'Este código no es válido o ya fue usado.',
      ),
      ConsultaFrenada() => const _Error(
        'Demasiados intentos. Espera unos minutos y vuelve a probar.',
      ),
      ConsultaSinConexion() => const _Error(
        'No pudimos comprobar el código. Revisa tu conexión.',
      ),
      ConsultaConError() => const _Error(
        'No pudimos comprobar el código. Inténtalo de nuevo.',
      ),
    };
    final fallo = switch (estado.falloCanje) {
      null => null,
      FalloCanje.noVinculado => const _Error(
        'No pudimos vincular este código. Pide uno nuevo a tu distribuidor.',
      ),
      FalloCanje.sinRespuesta => const _Error(
        'No pudimos vincular el código. Revisa tu conexión e inténtalo de '
        'nuevo.',
      ),
    };

    // `liveRegion`: el lector de pantalla anuncia el resultado al llegar.
    return Semantics(
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?aviso,
          if (estado.puedeReintentar)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: onReintentar,
                child: const Text('Reintentar'),
              ),
            ),
          if (fallo != null) ...[const SizedBox(height: 12), fallo],
        ],
      ),
    );
  }
}

class _TarjetaValido extends StatelessWidget {
  const _TarjetaValido({required this.invitacion});

  final InvitacionPrevia invitacion;

  @override
  Widget build(BuildContext context) {
    final negocio = invitacion.negocio;
    final detalle = negocio == null
        ? '${invitacion.distribuidorNombre} te invita a su equipo'
        : '${invitacion.distribuidorNombre} te invita como '
              '${negocio.nombreNegocio}';
    final textos = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.fondoExito,
        borderRadius: BorderRadius.circular(radioApp),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: ColoresApp.exito),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Código válido',
                  style: textos.titleSmall?.copyWith(
                    color: ColoresApp.exito,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(detalle, style: textos.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error(this.mensaje);

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Text(
      mensaje,
      style: Theme.of(context).textTheme.bodyMedium
          ?.copyWith(color: ColoresApp.error),
    );
  }
}
