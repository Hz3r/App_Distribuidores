import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panel_web/src/features/sesion/domain/acceso.dart';

import '../soporte/dobles.dart';

void main() {
  group('membresiasUtiles (panel)', () {
    test('se queda con admin y vendedor activos, en el mismo orden', () {
      final admin = membresia('d1');
      final vendedor = membresia('d2', rol: RolMembresia.vendedor);

      expect(membresiasUtiles([admin, vendedor]), [admin, vendedor]);
    });

    test('descarta cliente y repartidor: usan la app móvil', () {
      expect(
        membresiasUtiles([
          membresia('d1', rol: RolMembresia.cliente),
          membresia('d2', rol: RolMembresia.repartidor),
        ]),
        isEmpty,
      );
    });

    test('descarta la membresía suspendida', () {
      expect(
        membresiasUtiles([membresia('d1', estado: EstadoMembresia.suspendida)]),
        isEmpty,
      );
    });

    test('descarta la que no trae distribuidor visible', () {
      expect(
        membresiasUtiles([membresia('d1', conDistribuidor: false)]),
        isEmpty,
      );
    });
  });

  group('elegirActiva', () {
    test('con una sola, esa, aunque la preferencia sea otra', () {
      final unica = membresia('d1');

      expect(elegirActiva([unica], 'd9'), unica);
    });

    test('con varias y sin preferencia, ninguna', () {
      expect(elegirActiva([membresia('d1'), membresia('d2')], null), isNull);
    });

    test('con varias, la del distribuidor preferido', () {
      final d2 = membresia('d2');

      expect(elegirActiva([membresia('d1'), d2], 'd2'), d2);
    });

    test('si la preferida ya no está entre las útiles, ninguna', () {
      expect(elegirActiva([membresia('d1'), membresia('d2')], 'd9'), isNull);
    });

    test('sin membresías, ninguna', () {
      expect(elegirActiva([], 'd1'), isNull);
    });
  });

  test('accesoDesde filtra y elige: la preferida de cliente no cuenta', () {
    final admin = membresia('d1');
    final cliente = membresia('d2', rol: RolMembresia.cliente);

    final acceso = accesoDesde([cliente, admin], 'd2');

    expect(acceso.membresias, [admin]);
    expect(acceso.activa, admin);
  });
}
