import 'package:core/core.dart';

/// Suscripción del distribuidor con su plan.
class PlanVigente {
  const PlanVigente({required this.suscripcion, required this.plan});

  final Suscripcion suscripcion;
  final Plan plan;
}

/// La suscripción que importa mostrar: la vigente (`prueba` o `activa`; la
/// BD garantiza que hay a lo sumo una) o, si no hay, la que terminó más
/// tarde. Null si el distribuidor no tiene ninguna.
PlanVigente? elegirPlan(List<PlanVigente> todas) {
  if (todas.isEmpty) return null;
  bool vigente(PlanVigente p) =>
      p.suscripcion.estado == EstadoSuscripcion.prueba ||
      p.suscripcion.estado == EstadoSuscripcion.activa;
  final vigentes = todas.where(vigente).toList();
  final candidatas = vigentes.isEmpty ? todas : vigentes;
  return candidatas.reduce(
    (a, b) =>
        b.suscripcion.periodoFin.isAfter(a.suscripcion.periodoFin) ? b : a,
  );
}

/// Días que quedan del periodo, contando hoy (el periodo incluye su último
/// día). Negativo si ya terminó. Compara fechas, no horas.
int diasRestantes(Suscripcion suscripcion, DateTime ahora) {
  final hoy = DateTime.utc(ahora.year, ahora.month, ahora.day);
  final fin = suscripcion.periodoFin;
  final ultimo = DateTime.utc(fin.year, fin.month, fin.day);
  return ultimo.difference(hoy).inDays + 1;
}

/// Límites conocidos del plan (`limites` en `planes`), en el orden en que se
/// muestran. Los que no estén aquí no se muestran.
const nombresLimites = <String, String>{
  'max_usuarios': 'Usuarios del panel',
  'max_clientes': 'Clientes',
  'max_productos': 'Productos',
};

/// Pares (nombre, tope) de los límites conocidos que trae [plan].
List<(String, int)> limitesDe(Plan plan) => [
  for (final MapEntry(:key, :value) in nombresLimites.entries)
    if (plan.limites[key] case final num tope) (value, tope.toInt()),
];
