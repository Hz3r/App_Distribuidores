import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panel_web/src/features/disponibilidad/domain/disponibilidad.dart';

import '../soporte/dobles.dart';

void main() {
  group('nivelDe', () {
    test('agotado cuando no queda nada, aunque haya físico reservado', () {
      expect(nivelDe(producto('p', fisico: 0)), NivelDisponibilidad.agotado);
      expect(
        nivelDe(producto('p', fisico: 50, comprometido: 50)),
        NivelDisponibilidad.agotado,
      );
    });

    test('bajo cuando queda la quinta parte o menos', () {
      expect(
        nivelDe(producto('p', fisico: 100, comprometido: 80)),
        NivelDisponibilidad.bajo,
      );
      expect(
        nivelDe(producto('p', fisico: 100, comprometido: 79)),
        NivelDisponibilidad.normal,
      );
    });

    test('normal con todo disponible', () {
      expect(nivelDe(producto('p', fisico: 5)), NivelDisponibilidad.normal);
    });
  });

  test('proporcionDisponible va de 0 a 1 y no divide entre cero', () {
    expect(proporcionDisponible(producto('p', fisico: 0)), 0);
    expect(
      proporcionDisponible(producto('p', fisico: 200, comprometido: 50)),
      0.75,
    );
    expect(proporcionDisponible(producto('p', fisico: 200)), 1);
  });

  group('calcularMovimiento', () {
    final actual = producto('p', fisico: 200, comprometido: 100);

    test('subir la cantidad es un ingreso por la diferencia', () {
      final resultado = calcularMovimiento(actual, 260);

      expect(resultado.error, isNull);
      expect(resultado.movimiento, (
        tipo: TipoMovimientoStock.ingreso,
        cantidad: 60,
      ));
    });

    test('bajarla es un ajuste negativo', () {
      expect(calcularMovimiento(actual, 150).movimiento, (
        tipo: TipoMovimientoStock.ajuste,
        cantidad: -50,
      ));
    });

    test('se puede bajar justo hasta lo reservado, no menos', () {
      expect(calcularMovimiento(actual, 100).error, isNull);

      final resultado = calcularMovimiento(actual, 99);
      expect(resultado.movimiento, isNull);
      expect(resultado.error, ErrorCantidad.bajoLoReservado);
    });

    test('la misma cantidad no registra nada', () {
      final resultado = calcularMovimiento(actual, 200);

      expect(resultado.movimiento, isNull);
      expect(resultado.error, ErrorCantidad.sinCambio);
    });
  });
}
