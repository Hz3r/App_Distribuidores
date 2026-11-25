import 'package:core/core.dart';

import '../config/menu.dart';
import '../config/rutas.dart';
import '../features/sesion/domain/acceso.dart';

/// Parámetro de consulta con la sección a la que la persona quería ir antes
/// de que el panel la mandara a una ruta de paso (por ejemplo, al recargar
/// el navegador en `/pedidos`).
const parametroDesde = 'desde';

/// Lógica pura de redirección según el [Acceso] de la persona. Sin
/// dependencias de Flutter, así se prueba sin levantar la app.
///
/// [ubicacion] es la ruta actual sin consulta y [desde] el valor de
/// [parametroDesde], si viene. Devuelve la ruta (con su consulta) a la que
/// hay que redirigir, o `null` si la ubicación actual es válida. Las reglas
/// se aplican en orden.
String? destinoRedireccion({
  required Acceso acceso,
  required String ubicacion,
  String? desde,
}) {
  final ConAcceso conAcceso;
  switch (acceso) {
    case SinSesion():
      return _haciaPaso(AppRutas.auth, ubicacion, desde);
    case Cargando():
      return _haciaPaso(AppRutas.cargando, ubicacion, desde);
    case ErrorAcceso():
      return _haciaPaso(AppRutas.errorAcceso, ubicacion, desde);
    case ConAcceso():
      conAcceso = acceso;
  }

  final membresias = conAcceso.membresias;
  if (membresias.isEmpty) {
    return _haciaPaso(AppRutas.sinAcceso, ubicacion, desde);
  }

  final activa = conAcceso.activa;
  if (activa == null) {
    return _haciaPaso(AppRutas.seleccionDistribuidor, ubicacion, desde);
  }

  final rol = activa.rol;
  if (_rutasDePaso.contains(ubicacion)) {
    return inicioPara(rol, desde);
  }

  // Elegir otro distribuidor solo tiene sentido si hay más de uno.
  if (ubicacion == AppRutas.seleccionDistribuidor) {
    return membresias.length > 1 ? null : inicioPara(rol, desde);
  }

  final seccion = seccionDe(ubicacion);
  if (seccion == null || !seccion.visiblePara(rol)) {
    return AppRutas.dashboard;
  }

  return null;
}

/// Rutas que no tienen sentido con una membresía activa: se sale de ellas
/// a la sección pedida o al dashboard.
const _rutasDePaso = {
  AppRutas.auth,
  AppRutas.cargando,
  AppRutas.errorAcceso,
  AppRutas.sinAcceso,
};

/// Redirige a la ruta de paso [ruta] recordando a qué sección se quería ir.
String? _haciaPaso(String ruta, String ubicacion, String? desde) {
  if (ubicacion == ruta) return null;
  // Si se viene de una sección, se recuerda esa; si no, se conserva la que
  // ya se traía.
  final origen = seccionDe(ubicacion) != null
      ? ubicacion
      : _seccionValida(desde);
  if (origen == null) return ruta;
  return Uri(path: ruta, queryParameters: {parametroDesde: origen}).toString();
}

/// La sección a la que se entra con una membresía activa: la pedida en
/// [desde] si existe y el rol puede verla; si no, el dashboard.
String inicioPara(RolMembresia rol, String? desde) {
  final pedida = _seccionValida(desde);
  if (pedida != null && seccionDe(pedida)!.visiblePara(rol)) return pedida;
  return AppRutas.dashboard;
}

/// [desde] solo vale si es una sección del panel: nunca se redirige a una
/// dirección arbitraria que venga en la URL.
String? _seccionValida(String? desde) {
  if (desde == null || !desde.startsWith('/') || desde.contains('?')) {
    return null;
  }
  return seccionDe(desde) != null ? desde : null;
}
