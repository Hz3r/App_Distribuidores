import 'package:core/core.dart';

import '../config/rutas.dart';
import '../features/sesion/domain/acceso.dart';

/// Lógica pura de redirección según el [Acceso] de la persona. Sin
/// dependencias de Flutter, así se prueba sin levantar la app.
///
/// Devuelve la ruta a la que hay que redirigir, o `null` si la ubicación
/// actual es válida. Las reglas se aplican en orden.
String? destinoRedireccion({
  required Acceso acceso,
  required String ubicacion,
}) {
  final ConAcceso conAcceso;
  switch (acceso) {
    case SinSesion():
      return _salvoQueYaEste(AppRutas.auth, ubicacion);
    case Cargando():
      return _salvoQueYaEste(AppRutas.cargando, ubicacion);
    case ErrorAcceso():
      return _salvoQueYaEste(AppRutas.errorAcceso, ubicacion);
    case ConAcceso():
      conAcceso = acceso;
  }

  final membresias = conAcceso.membresias;
  if (membresias.isEmpty) {
    return _salvoQueYaEste(AppRutas.sinRol, ubicacion);
  }

  final activa = conAcceso.activa;
  if (activa == null) {
    return _salvoQueYaEste(AppRutas.seleccionDistribuidor, ubicacion);
  }

  final rol = activa.rol;
  if (_rutasDePaso.contains(ubicacion)) {
    return _inicioPara(rol);
  }

  // Elegir otro distribuidor solo tiene sentido si hay más de uno.
  if (ubicacion == AppRutas.seleccionDistribuidor) {
    return membresias.length > 1 ? null : _inicioPara(rol);
  }

  final esZonaRepartidor = ubicacion.startsWith(AppRutas.repartidor);
  if (rol == RolMembresia.repartidor && !esZonaRepartidor) {
    return ubicacion == AppRutas.perfil ? null : AppRutas.repartidor;
  }
  if (rol == RolMembresia.cliente && esZonaRepartidor) {
    return AppRutas.catalogo;
  }

  return null;
}

/// Rutas que no tienen sentido con una membresía activa: se sale de ellas
/// al inicio del rol.
const _rutasDePaso = {
  AppRutas.auth,
  AppRutas.cargando,
  AppRutas.errorAcceso,
  AppRutas.sinRol,
};

String? _salvoQueYaEste(String ruta, String ubicacion) =>
    ubicacion == ruta ? null : ruta;

/// Ruta de inicio de cada rol de la app móvil. `admin` y `vendedor` nunca
/// llegan aquí (los descarta `membresiasUtiles`); si llegaran, van al catálogo.
String _inicioPara(RolMembresia rol) => switch (rol) {
  RolMembresia.repartidor => AppRutas.repartidor,
  RolMembresia.cliente ||
  RolMembresia.admin ||
  RolMembresia.vendedor => AppRutas.catalogo,
};
