import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../sesion/presentation/control_acceso.dart';
import '../data/cuenta_repositorio_supabase.dart';
import '../domain/cuenta_repositorio.dart';

part 'cuenta_providers.g.dart';

/// Repositorio inyectable; las pruebas lo reemplazan con un doble. Único
/// lugar de `presentation` que construye la implementación de `data`.
@Riverpod(keepAlive: true)
CuentaRepositorio cuentaRepositorio(Ref ref) =>
    CuentaRepositorioSupabase(supabase);

/// Perfil de quien tiene la sesión. Se vuelve a leer si cambia el acceso
/// (otra sesión u otro distribuidor).
@riverpod
Future<Perfil> perfil(Ref ref) {
  ref.watch(membresiaActivaProvider.select((m) => m?.perfilId));
  return ref.watch(cuentaRepositorioProvider).leerPerfil();
}

/// Escrituras de la cuenta. Lanzan [ErrorCuenta]; la pantalla lo convierte
/// en mensaje con [mensajeDeCuenta].
@Riverpod(keepAlive: true)
AccionesCuenta accionesCuenta(Ref ref) => AccionesCuenta(ref);

class AccionesCuenta {
  AccionesCuenta(this._ref);

  final Ref _ref;

  CuentaRepositorio get _repositorio => _ref.read(cuentaRepositorioProvider);

  Future<void> guardarNombre(String nombre) async {
    await _repositorio.actualizarNombre(nombre);
    _ref.invalidate(perfilProvider);
  }

  Future<void> cambiarContrasena({
    required String actual,
    required String nueva,
  }) {
    return _repositorio.cambiarContrasena(actual: actual, nueva: nueva);
  }
}

/// Mensaje para la persona según por qué falló la operación.
String mensajeDeCuenta(Object error) {
  final motivo = error is ErrorCuenta
      ? error.motivo
      : MotivoErrorCuenta.desconocido;
  return switch (motivo) {
    MotivoErrorCuenta.contrasenaIncorrecta =>
      'La contraseña actual no es correcta.',
    MotivoErrorCuenta.contrasenaDebil =>
      'Esa contraseña es muy fácil de adivinar. Elige otra más larga.',
    MotivoErrorCuenta.mismaContrasena =>
      'La contraseña nueva debe ser distinta de la actual.',
    MotivoErrorCuenta.sinPermiso =>
      'Tu sesión terminó. Vuelve a ingresar e inténtalo de nuevo.',
    MotivoErrorCuenta.desconocido =>
      'No pudimos guardar. Revisa tu conexión e inténtalo de nuevo.',
  };
}
