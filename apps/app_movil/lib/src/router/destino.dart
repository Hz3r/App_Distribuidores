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
      return _rutasSinSesion.contains(ubicacion) ? null : AppRutas.bienvenida;
    case Cargando():
      return _salvoQueYaEste(AppRutas.cargando, ubicacion);
    case ErrorAcceso():
      return _salvoQueYaEste(AppRutas.errorAcceso, ubicacion);
    case ConAcceso():
      conAcceso = acceso;
  }

  // Con sesión se puede canjear un código para sumar un distribuidor, sea
  // cual sea el rol, sin membresías o sin una elegida todavía.
  if (ubicacion == AppRutas.codigo) return null;

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

  // Todo lo demás (inicio, catálogo y su detalle, carrito, pedidos) es zona
  // de la bodega.
  final esZonaRepartidor = ubicacion.startsWith(AppRutas.repartidor);
  if (rol == RolMembresia.repartidor && !esZonaRepartidor) {
    return ubicacion == AppRutas.perfil ? null : AppRutas.repartidor;
  }
  if (rol == RolMembresia.cliente && esZonaRepartidor) {
    return AppRutas.inicio;
  }

  return null;
}

/// Rutas válidas sin sesión. Cualquier otra lleva a la bienvenida.
const _rutasSinSesion = {
  AppRutas.bienvenida,
  AppRutas.codigo,
  AppRutas.registro,
  AppRutas.revisaCorreo,
  AppRutas.auth,
};

/// Rutas que no tienen sentido con una membresía activa: se sale de ellas
/// al inicio del rol. `codigo` no está: con sesión sirve para sumar otro
/// distribuidor.
const _rutasDePaso = {
  AppRutas.bienvenida,
  AppRutas.registro,
  AppRutas.revisaCorreo,
  AppRutas.auth,
  AppRutas.cargando,
  AppRutas.errorAcceso,
  AppRutas.sinRol,
};

String? _salvoQueYaEste(String ruta, String ubicacion) =>
    ubicacion == ruta ? null : ruta;

/// Ruta de inicio de cada rol de la app móvil. `admin` y `vendedor` nunca
/// llegan aquí (los descarta `membresiasUtiles`); si llegaran, van al inicio
/// de la bodega.
String _inicioPara(RolMembresia rol) => switch (rol) {
  RolMembresia.repartidor => AppRutas.repartidor,
  RolMembresia.cliente ||
  RolMembresia.admin ||
  RolMembresia.vendedor => AppRutas.inicio,
};
