import 'package:app_movil/src/features/carrito/domain/carrito.dart';
import 'package:app_movil/src/features/catalogo/domain/disponibilidad.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fabricas.dart';

void main() {
  int disponible(int fisico, int comprometido, int factor) =>
      disponiblePresentacion(
        stockFisico: fisico,
        stockComprometido: comprometido,
        factor: factor,
      );

  test('(120, 30, 12) → 7', () => expect(disponible(120, 30, 12), 7));
  test('(5, 0, 12) → 0', () => expect(disponible(5, 0, 12), 0));
  test('(12, 0, 12) → 1', () => expect(disponible(12, 0, 12), 1));
  test('(10, 10, 1) → 0', () => expect(disponible(10, 10, 1), 0));
  test('comprometido mayor que físico → 0', () {
    expect(disponible(5, 20, 1), 0);
    expect(disponible(5, 40, 12), 0);
  });

  group('disponibleEnCarrito (el stock es del producto)', () {
    final botella = presentacion('botella', productoId: 'ron');
    final caja = presentacion('caja', productoId: 'ron', factor: 12);
    final ron = producto(
      'ron',
      stockFisico: 120,
      presentaciones: [botella, caja],
    );

    int maximo(Carrito carrito, {required bool deCaja}) => disponibleEnCarrito(
      producto: ron,
      presentacion: deCaja ? caja : botella,
      carrito: carrito,
    );

    test('carrito vacío → Botella 120 y Caja 10', () {
      const vacio = Carrito.vacio();
      expect(maximo(vacio, deCaja: false), 120);
      expect(maximo(vacio, deCaja: true), 10);
    });

    test('con 5 cajas en el carrito → Botella 60, Caja 10', () {
      final carrito = const Carrito.vacio().agregar('caja', 5, disponible: 10);
      expect(maximo(carrito, deCaja: false), 60);
      expect(maximo(carrito, deCaja: true), 10);
    });

    test('con 100 botellas → Caja 1', () {
      final carrito = const Carrito.vacio().agregar(
        'botella',
        100,
        disponible: 120,
      );
      expect(maximo(carrito, deCaja: true), 1);
    });

    test('con 120 botellas → Caja 0', () {
      final carrito = const Carrito.vacio().agregar(
        'botella',
        120,
        disponible: 120,
      );
      expect(maximo(carrito, deCaja: true), 0);
    });

    test('presentaciones de otro producto en el carrito no afectan', () {
      final carrito = const Carrito.vacio()
          .agregar('pisco-u', 50, disponible: 100)
          .agregar('pisco-caja', 3, disponible: 10);
      expect(maximo(carrito, deCaja: false), 120);
      expect(maximo(carrito, deCaja: true), 10);
    });

    test('descuenta lo comprometido y nunca es negativo', () {
      final comprometido = ron.copyWith(stockComprometido: 115);
      final carrito = const Carrito.vacio().agregar(
        'botella',
        5,
        disponible: 5,
      );
      expect(
        disponibleEnCarrito(
          producto: comprometido,
          presentacion: caja,
          carrito: carrito,
        ),
        0,
      );
      expect(
        disponibleEnCarrito(
          producto: comprometido,
          presentacion: botella,
          carrito: carrito,
        ),
        5,
      );
    });
  });
}
