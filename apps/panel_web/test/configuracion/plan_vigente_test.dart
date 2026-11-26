import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panel_web/src/features/configuracion/domain/plan_vigente.dart';

import '../soporte/dobles_configuracion.dart';

void main() {
  group('elegirPlan', () {
    test('sin suscripciones no hay plan', () {
      expect(elegirPlan(const []), isNull);
    });

    test('prefiere la vigente aunque otra termine después', () {
      final vigente = suscripcionDePrueba(
        inicio: DateTime(2026, 11),
        fin: DateTime(2026, 11, 30),
      );
      final cancelada = suscripcionDePrueba(
        estado: EstadoSuscripcion.cancelada,
        inicio: DateTime(2026, 12),
        fin: DateTime(2026, 12, 31),
      );

      expect(elegirPlan([cancelada, vigente]), same(vigente));
    });

    test('la prueba también cuenta como vigente', () {
      final prueba = suscripcionDePrueba(
        estado: EstadoSuscripcion.prueba,
        inicio: DateTime(2026, 11),
        fin: DateTime(2026, 11, 30),
      );
      final vencida = suscripcionDePrueba(
        estado: EstadoSuscripcion.vencida,
        inicio: DateTime(2027),
        fin: DateTime(2027, 1, 31),
      );

      expect(elegirPlan([vencida, prueba]), same(prueba));
    });

    test('sin vigente, la que terminó más tarde', () {
      final vieja = suscripcionDePrueba(
        estado: EstadoSuscripcion.vencida,
        inicio: DateTime(2026, 9),
        fin: DateTime(2026, 9, 30),
      );
      final reciente = suscripcionDePrueba(
        estado: EstadoSuscripcion.vencida,
        inicio: DateTime(2026, 10),
        fin: DateTime(2026, 10, 31),
      );

      expect(elegirPlan([reciente, vieja]), same(reciente));
      expect(elegirPlan([vieja, reciente]), same(reciente));
    });
  });

  group('diasRestantes', () {
    final fin = suscripcionDePrueba(
      inicio: DateTime(2026, 11),
      fin: DateTime(2026, 11, 30),
    ).suscripcion;

    test('cuenta hoy y el último día, sin importar la hora', () {
      expect(diasRestantes(fin, DateTime(2026, 11, 26, 23, 59)), 5);
      expect(diasRestantes(fin, DateTime(2026, 11, 26, 0, 1)), 5);
    });

    test('el último día queda 1; después, cero o negativo', () {
      expect(diasRestantes(fin, DateTime(2026, 11, 30, 18)), 1);
      expect(diasRestantes(fin, DateTime(2026, 12, 1)), 0);
      expect(diasRestantes(fin, DateTime(2026, 12, 5)), -4);
    });
  });

  test('limitesDe muestra solo los conocidos, en orden', () {
    final plan = planDePrueba(
      limites: const {
        'max_productos': 200,
        'max_clientes': 50.0,
        'otra_cosa': 9,
        'max_usuarios': 'muchos',
      },
    );

    expect(limitesDe(plan), [('Clientes', 50), ('Productos', 200)]);
    expect(limitesDe(planDePrueba(limites: const {})), isEmpty);
  });
}
