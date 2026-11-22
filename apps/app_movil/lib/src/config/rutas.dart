/// Rutas de la app móvil. Única fuente de verdad para go_router.
abstract final class AppRutas {
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
