import 'dart:developer' as developer;

import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../sesion/presentation/control_acceso.dart';
import '../data/invitaciones_repositorio_supabase.dart';
import '../domain/codigo_invitacion.dart';
import '../domain/invitacion_previa.dart';
import '../domain/invitaciones_repositorio.dart';

part 'registro_providers.g.dart';

/// Repositorio inyectable; las pruebas lo reemplazan con un doble.
///
/// Es el único lugar de `presentation` que construye la implementación de
/// `data`: las pantallas dependen solo de este provider y de `domain`.
@Riverpod(keepAlive: true)
InvitacionesRepositorio invitacionesRepositorio(Ref ref) =>
    InvitacionesRepositorioSupabase(supabase);

/// Por qué no se completó el canje.
enum FalloCanje {
  /// La BD respondió que el código no vincula (usado, vencido, ya es miembro).
  noVinculado,

  /// No hubo respuesta de la BD (red, freno o sesión vencida).
  sinRespuesta,
}

/// Estado de la pantalla de código.
final class EstadoIngresoCodigo {
  const EstadoIngresoCodigo({
    this.codigo = '',
    this.consulta,
    this.canjeando = false,
    this.falloCanje,
  });

  /// Código ya normalizado.
  final String codigo;

  /// Respuesta de la consulta de [codigo]; `null` si está incompleto o la
  /// respuesta aún no llega.
  final ResultadoConsulta? consulta;

  /// Hay un canje en curso.
  final bool canjeando;

  /// Por qué falló el último canje; `null` si no falló.
  final FalloCanje? falloCanje;

  bool get consultando => codigoCompleto(codigo) && consulta == null;

  /// La invitación, solo si el código es válido.
  InvitacionPrevia? get invitacion => switch (consulta) {
    CodigoValido(:final invitacion) => invitacion,
    _ => null,
  };

  bool get puedeContinuar => invitacion != null && !canjeando;

  /// La consulta falló por algo que puede cambiar al reintentar (red, freno
  /// o error de la BD), no porque el código no sirva.
  bool get puedeReintentar => switch (consulta) {
    ConsultaFrenada() || ConsultaSinConexion() || ConsultaConError() => true,
    CodigoValido() || CodigoNoValido() || null => false,
  };
}

/// Lógica de la pantalla de código: consulta el código cuando se completa y
/// canjea cuando ya hay sesión. Sin Flutter, para probarla con un doble del
/// repositorio.
@riverpod
class IngresoCodigo extends _$IngresoCodigo {
  /// Identifica la consulta en curso; una respuesta de una consulta vieja
  /// se descarta.
  int _consulta = 0;

  @override
  EstadoIngresoCodigo build() => const EstadoIngresoCodigo();

  /// Recibe lo que hay en el campo. Consulta una vez cuando el código
  /// normalizado llega a [largoCodigo] y otra vez solo si cambia.
  void cambiarCodigo(String entrada) {
    final codigo = normalizarCodigo(entrada);
    if (codigo == state.codigo || state.canjeando) return;

    final consulta = ++_consulta;
    state = EstadoIngresoCodigo(codigo: codigo);
    if (codigoCompleto(codigo)) _consultar(codigo, consulta);
  }

  /// Vuelve a consultar el mismo código tras un fallo que se puede
  /// reintentar. Es la única forma de consultar dos veces el mismo código;
  /// un segundo toque no hace nada porque la consulta ya está en curso.
  void reintentar() {
    if (!state.puedeReintentar) return;
    final codigo = state.codigo;
    final consulta = ++_consulta;
    state = EstadoIngresoCodigo(codigo: codigo);
    _consultar(codigo, consulta);
  }

  /// Canjea el código válido con la sesión actual. Si vincula, recarga el
  /// acceso: el control pasa a `Cargando` y el router sale de esta pantalla.
  /// Ignora los toques mientras hay un canje en curso.
  Future<void> canjear() async {
    final actual = state;
    if (!actual.puedeContinuar) return;
    state = EstadoIngresoCodigo(
      codigo: actual.codigo,
      consulta: actual.consulta,
      canjeando: true,
    );

    FalloCanje? fallo;
    try {
      final vinculada = await ref
          .read(invitacionesRepositorioProvider)
          .canjear(actual.codigo);
      if (!vinculada) fallo = FalloCanje.noVinculado;
    } catch (e, st) {
      // Red, freno (`P0005`) o sesión vencida: se registra la causa y a la
      // persona se le pide reintentar.
      fallo = FalloCanje.sinRespuesta;
      developer.log(
        'No se pudo canjear el código de invitación.',
        name: 'ingreso_codigo',
        error: e,
        stackTrace: st,
      );
    }
    if (!ref.mounted) return;

    if (fallo == null) {
      // Se deja `canjeando`: el código ya se usó y Continuar no debe volver
      // a habilitarse mientras el router cambia de pantalla.
      await ref.read(controlAccesoProvider.notifier).recargar();
      return;
    }
    state = EstadoIngresoCodigo(
      codigo: actual.codigo,
      consulta: actual.consulta,
      falloCanje: fallo,
    );
  }

  Future<void> _consultar(String codigo, int consulta) async {
    ResultadoConsulta resultado;
    try {
      resultado = await ref
          .read(invitacionesRepositorioProvider)
          .consultar(codigo);
    } catch (e, st) {
      // El repositorio no debería lanzar; si lo hace, cuenta como sin red.
      developer.log(
        'Falló la consulta del código de invitación.',
        name: 'ingreso_codigo',
        error: e,
        stackTrace: st,
      );
      resultado = const ConsultaSinConexion();
    }
    // Si el código cambió mientras tanto, esta respuesta ya no vale.
    if (!ref.mounted || consulta != _consulta) return;
    state = EstadoIngresoCodigo(codigo: codigo, consulta: resultado);
  }
}
