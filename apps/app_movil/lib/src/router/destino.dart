import 'package:core/core.dart';

import '../config/rutas.dart';

/// Lógica pura de redirección por sesión y rol. Sin dependencias de Flutter,
/// así se prueba sin levantar la app.
///
/// Devuelve la ruta a la que hay que redirigir, o `null` si la ubicación actual es válida.
String? destinoRedireccion({
  required bool haySesion,
  required RolUsuario? rol,
  required String ubicacion,
}) {
  if (!haySesion) {
    return ubicacion == AppRutas.auth ? null : AppRutas.auth;
  }

  if (rol == null) {
    return ubicacion == AppRutas.sinRol ? null : AppRutas.sinRol;
  }

  if (ubicacion == AppRutas.auth || ubicacion == AppRutas.sinRol) {
    return _inicioPara(rol);
  }

  final esZonaRepartidor = ubicacion.startsWith(AppRutas.repartidor);
  if (rol == RolUsuario.repartidor && !esZonaRepartidor) {
    return ubicacion == AppRutas.perfil ? null : AppRutas.repartidor;
  }
  if (rol != RolUsuario.repartidor && esZonaRepartidor) {
    return AppRutas.catalogo;
  }

  return null;
}

String _inicioPara(RolUsuario rol) => switch (rol) {
  RolUsuario.repartidor => AppRutas.repartidor,
  RolUsuario.cliente || RolUsuario.admin => AppRutas.catalogo,
};
