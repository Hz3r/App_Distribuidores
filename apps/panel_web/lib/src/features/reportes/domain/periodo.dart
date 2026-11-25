import '../../../shared/formato.dart';

/// Periodos de un toque de la pantalla Reportes.
enum PeriodoRapido { esteMes, mesPasado, ultimos7Dias, ultimos30Dias }

/// Rango de fechas de un reporte, en la hora del dispositivo: desde las
/// 00:00 de [desde] hasta las 00:00 de [hasta], sin incluir ese último
/// instante.
class Periodo {
  const Periodo({required this.desde, required this.hasta, this.rapido});

  final DateTime desde;

  /// Exclusivo: la medianoche siguiente al último día del periodo.
  final DateTime hasta;

  /// De qué atajo salió, o null si la persona eligió las fechas.
  final PeriodoRapido? rapido;

  /// Último día incluido en el periodo.
  DateTime get ultimoDia => DateTime(hasta.year, hasta.month, hasta.day - 1);

  /// `1 nov 2026 al 25 nov 2026`, o un solo día si empieza y termina igual.
  String get descripcion => desde == ultimoDia
      ? fechaCorta(desde)
      : '${fechaCorta(desde)} al ${fechaCorta(ultimoDia)}';

  /// Para el nombre del archivo exportado: `2026-11-01_a_2026-11-25`.
  String get paraArchivo => '${_iso(desde)}_a_${_iso(ultimoDia)}';

  @override
  bool operator ==(Object other) =>
      other is Periodo &&
      other.desde == desde &&
      other.hasta == hasta &&
      other.rapido == rapido;

  @override
  int get hashCode => Object.hash(desde, hasta, rapido);
}

String _iso(DateTime dia) =>
    '${dia.year}-${'${dia.month}'.padLeft(2, '0')}-'
    '${'${dia.day}'.padLeft(2, '0')}';

/// El rango de un atajo en el momento [ahora]. Los que llegan "hasta hoy"
/// incluyen el día de hoy completo.
Periodo periodoRapido(PeriodoRapido rapido, DateTime ahora) {
  final local = ahora.toLocal();
  // Con `DateTime(año, mes, día ± n)` y no sumando 24 h: así un cambio de
  // hora no descuadra los días.
  final manana = DateTime(local.year, local.month, local.day + 1);
  return switch (rapido) {
    PeriodoRapido.esteMes => Periodo(
      desde: DateTime(local.year, local.month),
      hasta: manana,
      rapido: rapido,
    ),
    PeriodoRapido.mesPasado => Periodo(
      desde: DateTime(local.year, local.month - 1),
      hasta: DateTime(local.year, local.month),
      rapido: rapido,
    ),
    PeriodoRapido.ultimos7Dias => Periodo(
      desde: DateTime(local.year, local.month, local.day - 6),
      hasta: manana,
      rapido: rapido,
    ),
    PeriodoRapido.ultimos30Dias => Periodo(
      desde: DateTime(local.year, local.month, local.day - 29),
      hasta: manana,
      rapido: rapido,
    ),
  };
}

/// Periodo elegido a mano: del día [primero] al día [ultimo], ambos
/// incluidos.
Periodo periodoEntre(DateTime primero, DateTime ultimo) => Periodo(
  desde: DateTime(primero.year, primero.month, primero.day),
  hasta: DateTime(ultimo.year, ultimo.month, ultimo.day + 1),
);
