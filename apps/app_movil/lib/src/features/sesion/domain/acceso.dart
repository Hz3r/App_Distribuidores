import 'package:core/core.dart';

/// Situación de acceso de la persona en la app móvil. Lógica pura: sin
/// Flutter ni Supabase, para probarla sin levantar la app.
sealed class Acceso {
  const Acceso();
}

/// No hay sesión iniciada.
final class SinSesion extends Acceso {
  const SinSesion();
}

/// Hay sesión y se están leyendo las membresías.
final class Cargando extends Acceso {
  const Cargando();
}

/// No se pudieron leer las membresías.
final class ErrorAcceso extends Acceso {
  const ErrorAcceso(this.mensaje);

  final String mensaje;
}

/// Membresías leídas. Puede no haber ninguna útil.
final class ConAcceso extends Acceso {
  const ConAcceso({required this.membresias, required this.activa, this.aviso});

  /// Solo las membresías útiles para la app móvil.
  final List<Membresia> membresias;

  /// `null` si hay varias y aún no se eligió.
  final Membresia? activa;

  /// Algo que la persona debe saber de esta carga (por ejemplo, que el
  /// código de su registro no se pudo vincular). `null` si no hay nada.
  final String? aviso;
}

/// Roles que entran en la app móvil. `admin` y `vendedor` usan el panel web.
const _rolesMovil = {RolMembresia.cliente, RolMembresia.repartidor};

/// Membresías que dan acceso en la app móvil: estado activa, rol cliente o
/// repartidor, y distribuidor visible (no nulo). Conserva el orden de entrada.
List<Membresia> membresiasUtiles(List<Membresia> todas) => [
  for (final m in todas)
    if (m.estaActiva && _rolesMovil.contains(m.rol) && m.distribuidor != null)
      m,
];

/// La membresía con la que se entra. Si hay una sola, esa. Si hay varias, la
/// del distribuidor preferido cuando sigue entre las útiles; si no, null.
Membresia? elegirActiva(List<Membresia> utiles, String? distribuidorPreferido) {
  if (utiles.length == 1) return utiles.single;
  if (distribuidorPreferido == null) return null;
  for (final m in utiles) {
    if (m.distribuidorId == distribuidorPreferido) return m;
  }
  return null;
}

/// Arma el acceso a partir de todas las membresías de la persona.
ConAcceso accesoDesde(
  List<Membresia> todas,
  String? distribuidorPreferido, {
  String? aviso,
}) {
  final utiles = membresiasUtiles(todas);
  return ConAcceso(
    membresias: utiles,
    activa: elegirActiva(utiles, distribuidorPreferido),
    aviso: aviso,
  );
}
