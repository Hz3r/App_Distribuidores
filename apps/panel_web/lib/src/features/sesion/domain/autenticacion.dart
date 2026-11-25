/// Cómo terminó un intento de inicio de sesión.
enum ResultadoIngreso {
  /// Sesión iniciada.
  ok,

  /// Correo o contraseña incorrectos.
  credencialesInvalidas,

  /// Otro fallo (red, servicio caído, cuenta sin confirmar).
  fallo,
}

/// Inicio y cierre de sesión del panel (correo y contraseña).
abstract interface class Autenticacion {
  /// Correo de la cuenta con sesión, o null.
  String? get correoActual;

  /// No lanza: el resultado dice qué pasó.
  Future<ResultadoIngreso> iniciarSesion({
    required String correo,
    required String contrasena,
  });

  /// Lanza si no se pudo cerrar la sesión.
  Future<void> cerrarSesion();
}
