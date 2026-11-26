import 'package:app_movil/src/features/carrito/domain/carrito.dart';
import 'package:app_movil/src/features/carrito/presentation/carrito_providers.dart';
import 'package:app_movil/src/features/sesion/domain/acceso.dart';
import 'package:app_movil/src/features/sesion/presentation/control_acceso.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../registro/dobles.dart';
import '../sesion/acceso_fijo.dart';

void main() {
  late ControlAccesoFijo control;
  late ProviderContainer container;

  final d1 = membresia('d1');
  final d2 = membresia('d2');

  setUp(() {
    control = ControlAccesoFijo(ConAcceso(membresias: [d1, d2], activa: d1));
    container = ProviderContainer(
      overrides: [controlAccesoProvider.overrideWith(() => control)],
    );
    // Como la barra: el carrito queda escuchado durante toda la prueba.
    container.listen(carritoActualProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  Carrito carrito() => container.read(carritoActualProvider);
  CarritoActual notifier() => container.read(carritoActualProvider.notifier);

  test('agrega, fija y quita a través del provider', () {
    notifier().agregar('a', 2, disponible: 5);
    notifier().agregar('b', 1, disponible: 5);
    notifier().fijar('a', 4, disponible: 5);
    expect(carrito().cantidades, {'a': 4, 'b': 1});

    notifier().quitar('b');
    expect(carrito().cantidades, {'a': 4});

    notifier().vaciar();
    expect(carrito().lineas, 0);
  });

  test('al cambiar la membresía activa de un distribuidor a otro, el '
      'carrito queda vacío', () {
    notifier().agregar('a', 2, disponible: 5);
    expect(carrito().lineas, 1);

    control.fijar(ConAcceso(membresias: [d1, d2], activa: d2));

    expect(carrito().lineas, 0);
  });

  test('al cerrar la sesión el carrito queda vacío', () {
    notifier().agregar('a', 2, disponible: 5);

    control.fijar(const SinSesion());

    expect(carrito().lineas, 0);
  });

  test('si la membresía activa no cambia (misma membresía releída), el '
      'carrito se conserva', () {
    notifier().agregar('a', 2, disponible: 5);

    control.fijar(ConAcceso(membresias: [d1, d2], activa: membresia('d1')));

    expect(carrito().cantidades, {'a': 2});
  });
}
