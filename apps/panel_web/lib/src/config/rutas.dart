/// Rutas del panel web. Única fuente de verdad para go_router.
abstract final class AppRutas {
  // Rutas de paso: no pertenecen a ninguna sección del panel.
  static const String auth = '/auth';
  static const String cargando = '/cargando';
  static const String errorAcceso = '/error-acceso';
  static const String sinAcceso = '/sin-acceso';
  static const String seleccionDistribuidor = '/seleccion-distribuidor';

  // Secciones del panel (van dentro del menú lateral).
  static const String dashboard = '/dashboard';
  static const String productos = '/productos';
  static const String disponibilidad = '/disponibilidad';
  static const String clientes = '/clientes';
  static const String invitaciones = '/invitaciones';
  static const String pedidos = '/pedidos';
  static const String reportes = '/reportes';
  static const String configuracion = '/configuracion';
}
