/// Rutas de la app móvil. Única fuente de verdad para go_router.
abstract final class AppRutas {
  /// Primera pantalla sin sesión.
  static const String bienvenida = '/bienvenida';

  /// Ingreso del código de invitación; también con sesión, para sumar otro
  /// distribuidor.
  static const String codigo = '/codigo';

  /// Registro de la cuenta; recibe el código y la invitación por `extra`.
  static const String registro = '/registro';
  static const String revisaCorreo = '/revisa-correo';

  /// Ingreso con una cuenta existente; desde el registro recibe por `extra`
  /// el código por canjear al ingresar (nunca la contraseña).
  static const String auth = '/auth';
  static const String cargando = '/cargando';
  static const String errorAcceso = '/error-acceso';
  static const String sinRol = '/sin-rol';
  static const String seleccionDistribuidor = '/seleccion-distribuidor';
  static const String catalogo = '/catalogo';
  static const String carrito = '/carrito';
  static const String checkout = '/checkout';
  static const String pedidos = '/pedidos';
  static const String perfil = '/perfil';

  /// Zona exclusiva del rol repartidor.
  static const String repartidor = '/repartidor';
}
