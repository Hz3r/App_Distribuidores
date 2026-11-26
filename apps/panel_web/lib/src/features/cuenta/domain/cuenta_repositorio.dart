import 'package:core/core.dart';

/// Largo mínimo de una contraseña nueva.
const largoMinimoContrasena = 8;

/// Null si [nueva] sirve como contraseña; si no, el motivo para mostrar.
String? validarContrasenaNueva(String nueva) {
  if (nueva.isEmpty) return 'Escribe la contraseña nueva.';
  if (nueva.length < largoMinimoContrasena) {
    return 'Usa al menos $largoMinimoContrasena caracteres.';
  }
  if (!RegExp('[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]').hasMatch(nueva) ||
      !RegExp('[0-9]').hasMatch(nueva)) {
    return 'Combina letras y números.';
  }
  return null;
}

/// Por qué falló una operación de la cuenta.
enum MotivoErrorCuenta {
  /// La contraseña actual no es la correcta.
  contrasenaIncorrecta,

  /// El servicio rechazó la contraseña nueva por débil.
  contrasenaDebil,

  /// La contraseña nueva es igual a la actual.
  mismaContrasena,

  /// Sin sesión o sin permiso.
  sinPermiso,

  /// Red, servicio caído u otro fallo.
  desconocido,
}

class ErrorCuenta implements Exception {
  const ErrorCuenta(this.motivo);

  final MotivoErrorCuenta motivo;

  @override
  String toString() => 'ErrorCuenta(${motivo.name})';
}

/// Datos de la persona con sesión. Las operaciones que fallan lanzan
/// [ErrorCuenta].
abstract interface class CuentaRepositorio {
  /// Perfil de quien tiene la sesión.
  Future<Perfil> leerPerfil();

  /// Cambia el nombre del perfil (lo único que la BD deja editar) y
  /// devuelve el perfil como quedó.
  Future<Perfil> actualizarNombre(String nombre);

  /// Verifica [actual] y, si es la correcta, guarda [nueva].
  Future<void> cambiarContrasena({
    required String actual,
    required String nueva,
  });
}
