import 'package:flutter_test/flutter_test.dart';
import 'package:panel_web/src/features/reportes/domain/periodo.dart';

void main() {
  // Miércoles 25 de noviembre de 2026, 3 p. m., hora del dispositivo.
  final ahora = DateTime(2026, 11, 25, 15);

  group('periodoRapido', () {
    test('este mes: del día 1 a hoy inclusive', () {
      final p = periodoRapido(PeriodoRapido.esteMes, ahora);

      expect(p.desde, DateTime(2026, 11));
      expect(p.hasta, DateTime(2026, 11, 26));
      expect(p.ultimoDia, DateTime(2026, 11, 25));
      expect(p.rapido, PeriodoRapido.esteMes);
    });

    test('mes pasado: el mes anterior completo, también en enero', () {
      final p = periodoRapido(PeriodoRapido.mesPasado, ahora);
      expect(p.desde, DateTime(2026, 10));
      expect(p.hasta, DateTime(2026, 11));
      expect(p.ultimoDia, DateTime(2026, 10, 31));

      final enero = periodoRapido(
        PeriodoRapido.mesPasado,
        DateTime(2027, 1, 5),
      );
      expect(enero.desde, DateTime(2026, 12));
      expect(enero.hasta, DateTime(2027));
    });

    test('últimos 7 y 30 días cuentan hoy', () {
      final siete = periodoRapido(PeriodoRapido.ultimos7Dias, ahora);
      expect(siete.desde, DateTime(2026, 11, 19));
      expect(siete.hasta, DateTime(2026, 11, 26));
      expect(siete.hasta.difference(siete.desde).inDays, 7);

      final treinta = periodoRapido(PeriodoRapido.ultimos30Dias, ahora);
      expect(treinta.desde, DateTime(2026, 10, 27));
      expect(treinta.hasta.difference(treinta.desde).inDays, 30);
    });
  });

  test('periodoEntre incluye el último día completo y no es un atajo', () {
    final p = periodoEntre(
      DateTime(2026, 11, 3, 18),
      DateTime(2026, 11, 10, 9),
    );

    expect(p.desde, DateTime(2026, 11, 3));
    expect(p.hasta, DateTime(2026, 11, 11));
    expect(p.rapido, isNull);
  });

  test('descripción y nombre de archivo', () {
    final p = periodoEntre(DateTime(2026, 11, 3), DateTime(2026, 11, 10));
    expect(p.descripcion, '3 nov 2026 al 10 nov 2026');
    expect(p.paraArchivo, '2026-11-03_a_2026-11-10');

    final unDia = periodoEntre(DateTime(2026, 11, 3), DateTime(2026, 11, 3));
    expect(unDia.descripcion, '3 nov 2026');
    expect(unDia.paraArchivo, '2026-11-03_a_2026-11-03');
  });

  test('dos periodos con las mismas fechas y el mismo atajo son iguales', () {
    expect(
      periodoRapido(PeriodoRapido.esteMes, ahora),
      periodoRapido(PeriodoRapido.esteMes, DateTime(2026, 11, 25, 23)),
    );
    expect(
      periodoRapido(PeriodoRapido.esteMes, ahora),
      isNot(periodoEntre(DateTime(2026, 11), DateTime(2026, 11, 25))),
    );
  });
}
