import 'package:app_movil/src/features/catalogo/domain/precios.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fabricas.dart';

/// Tramo como texto (`1–9: 6290`, `50–: 5800`) para comparar listas.
String _texto(TramoPrecio t) =>
    '${t.desde}–${t.hasta ?? ''}: ${t.precioCentimos}';

void main() {
  group('precioUnitario', () {
    test('base 6290, sin lista ni volumen, cantidad 1 → 6290', () {
      expect(
        precioUnitario(precioBase: 6290, preciosVolumen: const [], cantidad: 1),
        6290,
      );
    });

    test('base 6290 con volumen [10→6050, 50→5800]', () {
      final tramos = [volumen(10, 6050), volumen(50, 5800)];
      int precio(int cantidad) => precioUnitario(
        precioBase: 6290,
        preciosVolumen: tramos,
        cantidad: cantidad,
      );

      expect(precio(9), 6290);
      expect(precio(10), 6050);
      expect(precio(49), 6050);
      expect(precio(50), 5800);
    });

    test('lista 6000, base 6290, volumen [10→6050], cantidad 10 → 6000 '
        '(el menor)', () {
      expect(
        precioUnitario(
          precioBase: 6290,
          precioLista: 6000,
          preciosVolumen: [volumen(10, 6050)],
          cantidad: 10,
        ),
        6000,
      );
    });

    test('lista 7000, base 6290, cantidad 1 → 7000 (la lista sustituye al '
        'base)', () {
      expect(
        precioUnitario(
          precioBase: 6290,
          precioLista: 7000,
          preciosVolumen: const [],
          cantidad: 1,
        ),
        7000,
      );
    });

    test('volumen mayor que el base (base 6290, [10→6500]), cantidad 10 → '
        '6290', () {
      expect(
        precioUnitario(
          precioBase: 6290,
          preciosVolumen: [volumen(10, 6500)],
          cantidad: 10,
        ),
        6290,
      );
    });

    test('el orden de los precios por volumen no importa', () {
      expect(
        precioUnitario(
          precioBase: 6290,
          preciosVolumen: [volumen(50, 5800), volumen(10, 6050)],
          cantidad: 60,
        ),
        5800,
      );
    });
  });

  group('tramosDePrecio', () {
    test('base 6290 y volumen [10→6050, 50→5800] → 1–9, 10–49, 50–', () {
      final tramos = tramosDePrecio(
        precioBase: 6290,
        preciosVolumen: [volumen(10, 6050), volumen(50, 5800)],
      );

      expect(tramos.map(_texto), ['1–9: 6290', '10–49: 6050', '50–: 5800']);
    });

    test('lista 6000 y volumen [10→6050, 50→5800] → 1–49, 50– (tramos de '
        'igual precio fundidos)', () {
      final tramos = tramosDePrecio(
        precioBase: 6290,
        precioLista: 6000,
        preciosVolumen: [volumen(10, 6050), volumen(50, 5800)],
      );

      expect(tramos.map(_texto), ['1–49: 6000', '50–: 5800']);
    });

    test('sin volumen → un tramo 1– con el precio de partida', () {
      expect(
        tramosDePrecio(precioBase: 6290, preciosVolumen: const []).map(_texto),
        ['1–: 6290'],
      );
      expect(
        tramosDePrecio(
          precioBase: 6290,
          precioLista: 7000,
          preciosVolumen: const [],
        ).map(_texto),
        ['1–: 7000'],
      );
    });

    test('volumen con cantidadMinima 1 (base 6290, [1→6000]) → un tramo '
        '1–: 6000', () {
      expect(
        tramosDePrecio(
          precioBase: 6290,
          preciosVolumen: [volumen(1, 6000)],
        ).map(_texto),
        ['1–: 6000'],
      );
    });

    test('cada tramo coincide con precioUnitario en sus extremos', () {
      final preciosVolumen = [
        volumen(50, 5800),
        volumen(10, 6050),
        volumen(24, 6100),
      ];
      final tramos = tramosDePrecio(
        precioBase: 6290,
        precioLista: 6080,
        preciosVolumen: preciosVolumen,
      );
      for (final t in tramos) {
        for (final cantidad in [t.desde, t.hasta ?? t.desde + 100]) {
          expect(
            precioUnitario(
              precioBase: 6290,
              precioLista: 6080,
              preciosVolumen: preciosVolumen,
              cantidad: cantidad,
            ),
            t.precioCentimos,
            reason: 'cantidad $cantidad',
          );
        }
      }
    });
  });
}
