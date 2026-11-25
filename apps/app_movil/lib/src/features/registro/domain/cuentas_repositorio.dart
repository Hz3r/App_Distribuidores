import 'datos_registro.dart';
import 'registro_pendiente.dart';

/// Resultado de crear la cuenta.
enum ResultadoCrearCuenta {
  /// La cuenta quedó creada con sesión: el control de acceso canjea el
  /// pendiente y el router entra solo.
  conSesion,

  /// El proyecto exige confirmar el correo: la sesión llega al ingresar.
  requiereConfirmarCorreo,

  correoYaRegistrado,
  sinConexion,
  error,
}

/// Resultado de ingresar con correo y contraseña.
enum ResultadoIngreso {
  /// Hay sesión: el router entra solo.
  ok,
  credencialesIncorrectas,
  correoSinConfirmar,
  sinConexion,
  error,
}

/// Cuenta de la persona: crearla, ingresar y el registro pendiente. Las
/// decisiones (qué mostrar, cuándo canjear) están en `presentation`, no aquí.
abstract interface class CuentasRepositorio {
  /// Crea la cuenta y guarda [pendiente] en ella. No lanza.
  Future<ResultadoCrearCuenta> crearCuenta(
    DatosRegistro datos,
    RegistroPendiente pendiente,
  );

  /// No lanza.
  Future<ResultadoIngreso> ingresar(String correo, String contrasena);

  /// Registro pendiente de la cuenta con sesión, o `null`.
  RegistroPendiente? pendienteActual();

  /// Borra el registro pendiente de la cuenta con sesión.
  Future<void> limpiarPendiente();

  /// Pasa los datos de [pendiente] a la bodega de la persona en
  /// [distribuidorId] (`completar_datos_negocio`).
  Future<void> completarDatosNegocio(
    String distribuidorId,
    RegistroPendiente pendiente,
  );
}
