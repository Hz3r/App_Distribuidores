import 'package:app_movil/src/features/carrito/domain/carrito.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('vacío por defecto', () {
    const carrito = Carrito();
    expect(carrito.lineas, 0);
    expect(carrito.cantidadDe('a'), 0);
  });

  test('agregar 1 dos veces deja 2', () {
    final carrito = const Carrito()
        .agregar('a', 1, disponible: 10)
        .agregar('a', 1, disponible: 10);

    expect(carrito.cantidadDe('a'), 2);
    expect(carrito.lineas, 1);
  });

  test('agregar por encima del disponible queda en el disponible', () {
    final carrito = const Carrito()
        .agregar('a', 3, disponible: 5)
        .agregar('a', 4, disponible: 5);

    expect(carrito.cantidadDe('a'), 5);
  });

  test('con disponible 0 no cambia', () {
    const vacio = Carrito();
    expect(vacio.agregar('a', 1, disponible: 0), same(vacio));

    final conUno = vacio.agregar('b', 1, disponible: 3);
    expect(conUno.agregar('a', 2, disponible: 0).cantidades, {'b': 1});
  });

  test('agregar una cantidad no positiva no cambia', () {
    final carrito = const Carrito().agregar('a', 2, disponible: 5);
    expect(carrito.agregar('a', 0, disponible: 5).cantidadDe('a'), 2);
    expect(carrito.agregar('a', -1, disponible: 5).cantidadDe('a'), 2);
  });

  test('es inmutable: agregar devuelve otro carrito', () {
    const vacio = Carrito();
    final conUno = vacio.agregar('a', 1, disponible: 5);

    expect(vacio.cantidadDe('a'), 0);
    expect(conUno.cantidadDe('a'), 1);
    expect(() => conUno.cantidades['a'] = 9, throwsUnsupportedError);
  });

  test('fijar reemplaza la cantidad, limitada al disponible', () {
    final carrito = const Carrito().agregar('a', 2, disponible: 10);

    expect(carrito.fijar('a', 7, disponible: 10).cantidadDe('a'), 7);
    expect(carrito.fijar('a', 20, disponible: 10).cantidadDe('a'), 10);
  });

  test('fijar 0 quita la línea', () {
    final carrito = const Carrito()
        .agregar('a', 2, disponible: 10)
        .fijar('a', 0, disponible: 10);

    expect(carrito.lineas, 0);
    expect(carrito.cantidades.containsKey('a'), isFalse);
  });

  test('quitar y vaciar', () {
    final carrito = const Carrito()
        .agregar('a', 2, disponible: 10)
        .agregar('b', 1, disponible: 10);

    expect(carrito.quitar('a').cantidades, {'b': 1});
    expect(carrito.vaciar().lineas, 0);
  });

  test('lineas cuenta presentaciones distintas', () {
    final carrito = const Carrito()
        .agregar('a', 5, disponible: 10)
        .agregar('b', 1, disponible: 10)
        .agregar('a', 1, disponible: 10);

    expect(carrito.lineas, 2);
  });

  test('igualdad por contenido', () {
    expect(
      const Carrito().agregar('a', 1, disponible: 2),
      const Carrito().agregar('a', 1, disponible: 2),
    );
    expect(const Carrito().vaciar(), const Carrito());
  });
}
