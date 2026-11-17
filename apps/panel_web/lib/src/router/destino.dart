import 'package:core/core.dart';

import '../config/rutas.dart';

/// Redirección por sesión y rol. El panel es exclusivo del rol admin.
/// Devuelve la ruta destino, o `null` si la ubicación actual es válida.
String? destinoRedireccion({
  required bool haySesion,
  required RolUsuario? rol,
  required String ubicacion,
}) {
  if (!haySesion) {
    return ubicacion == AppRutas.auth ? null : AppRutas.auth;
  }

  if (rol != RolUsuario.admin) {
    return ubicacion == AppRutas.sinAcceso ? null : AppRutas.sinAcceso;
  }

  if (ubicacion == AppRutas.auth || ubicacion == AppRutas.sinAcceso) {
    return AppRutas.dashboard;
  }

  return null;
}
