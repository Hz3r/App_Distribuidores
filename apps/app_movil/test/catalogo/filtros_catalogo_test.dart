import 'package:app_movil/src/features/catalogo/domain/catalogo.dart';
import 'package:app_movil/src/features/catalogo/domain/filtros_catalogo.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fabricas.dart';

void main() {
  // Cuatro productos en dos categorías y tres marcas (una vacía).
  final productos = productosDelCatalogo(
    Catalogo(
      categorias: [categoria('ron'), categoria('pisco')],
      productos: [
        producto(
          'anejo',
          nombre: 'Ron Añejo 750 ml',
          marca: 'Cartavio',
          categoriaId: 'ron',
          presentaciones: [presentacion('anejo-u', precioBase: 6290)],
        ),
        producto(
          'blanco',
          nombre: 'Blanco 1 L',
          marca: 'RON CARTAVIO',
          categoriaId: 'ron',
          presentaciones: [presentacion('blanco-u', precioBase: 3500)],
        ),
        producto(
          'quebranta',
          nombre: 'Pisco Quebranta',
          marca: 'Portón',
          categoriaId: 'pisco',
          presentaciones: [presentacion('quebranta-u', precioBase: 8900)],
        ),
        producto(
          'acholado',
          nombre: 'Pisco Acholado',
          marca: '  ',
          categoriaId: 'pisco',
          presentaciones: [presentacion('acholado-u', precioBase: 4200)],
        ),
      ],
      preciosLista: const {},
    ),
  );

  List<String> ids(FiltrosCatalogo filtros) =>
      aplicarFiltros(productos, filtros).map((p) => p.producto.id).toList();

  test('sin filtros quedan todos, por nombre', () {
    expect(ids(const FiltrosCatalogo()), [
      'blanco',
      'acholado',
      'quebranta',
      'anejo',
    ]);
  });

  test('por categoría', () {
    expect(ids(const FiltrosCatalogo(categoriaId: 'pisco')), [
      'acholado',
      'quebranta',
    ]);
  });

  test('por marca', () {
    expect(ids(const FiltrosCatalogo(marca: 'Portón')), ['quebranta']);
    expect(ids(const FiltrosCatalogo(marca: 'Cartavio')), ['anejo']);
  });

  test('la búsqueda "ron" encuentra "Ron Añejo" y la marca "RON CARTAVIO"', () {
    // "Portón" contiene "ron" pero no empieza por ella: no cuenta.
    expect(ids(const FiltrosCatalogo(busqueda: 'ron')), ['blanco', 'anejo']);
  });

  test('la búsqueda busca palabras que empiecen por lo escrito', () {
    expect(ids(const FiltrosCatalogo(busqueda: 'quebr')), ['quebranta']);
    expect(ids(const FiltrosCatalogo(busqueda: '750')), ['anejo']);
  });

  test('la búsqueda "anejo" encuentra "Añejo"', () {
    expect(ids(const FiltrosCatalogo(busqueda: 'anejo')), ['anejo']);
    expect(ids(const FiltrosCatalogo(busqueda: '  AÑEJO ')), ['anejo']);
  });

  test('normalizarTexto quita mayúsculas y tildes, también combinadas', () {
    expect(normalizarTexto('ÁÉÍÓÚ Ñandú'), 'aeiou nandu');
    expect(normalizarTexto('An\u0303ejo'), 'anejo');
  });

  test('la búsqueda con varias palabras exige todas', () {
    expect(ids(const FiltrosCatalogo(busqueda: 'pisco porton')), ['quebranta']);
  });

  test('categoría y búsqueda se combinan', () {
    expect(ids(const FiltrosCatalogo(categoriaId: 'ron', busqueda: 'blanco')), [
      'blanco',
    ]);
    expect(
      ids(const FiltrosCatalogo(categoriaId: 'pisco', busqueda: 'ron')),
      isEmpty,
    );
  });

  test('orden por precio menor y mayor', () {
    expect(ids(const FiltrosCatalogo(orden: OrdenCatalogo.precioMenor)), [
      'blanco',
      'acholado',
      'anejo',
      'quebranta',
    ]);
    expect(ids(const FiltrosCatalogo(orden: OrdenCatalogo.precioMayor)), [
      'quebranta',
      'anejo',
      'acholado',
      'blanco',
    ]);
  });

  test('aplicarFiltros no modifica la lista recibida', () {
    final antes = productos.map((p) => p.producto.id).toList();
    aplicarFiltros(
      productos,
      const FiltrosCatalogo(orden: OrdenCatalogo.precioMayor),
    );
    expect(productos.map((p) => p.producto.id), antes);
  });

  test('marcasDisponibles sin vacíos ni repetidos, ordenadas', () {
    final conRepetida = [
      ...productos,
      ...productosDelCatalogo(
        Catalogo(
          categorias: const [],
          productos: [
            producto('otro', marca: 'Portón', categoriaId: null),
            producto('sin', categoriaId: null),
          ],
          preciosLista: const {},
        ),
      ),
    ];

    expect(marcasDisponibles(conRepetida), [
      'Cartavio',
      'Portón',
      'RON CARTAVIO',
    ]);
  });

  group('FiltrosCatalogo.copyWith', () {
    const base = FiltrosCatalogo(
      categoriaId: 'ron',
      marca: 'Cartavio',
      busqueda: 'añejo',
      orden: OrdenCatalogo.precioMayor,
    );

    test('sin argumentos conserva todo', () {
      expect(base.copyWith(), base);
    });

    test('cambia lo que se pasa', () {
      expect(
        base.copyWith(categoriaId: 'pisco', busqueda: ''),
        const FiltrosCatalogo(
          categoriaId: 'pisco',
          marca: 'Cartavio',
          orden: OrdenCatalogo.precioMayor,
        ),
      );
    });

    test('limpia categoría y marca', () {
      expect(
        base.copyWith(limpiarCategoria: true, limpiarMarca: true),
        const FiltrosCatalogo(
          busqueda: 'añejo',
          orden: OrdenCatalogo.precioMayor,
        ),
      );
    });

    test('hayFiltros solo con categoría, marca o búsqueda', () {
      expect(const FiltrosCatalogo().hayFiltros, isFalse);
      expect(
        const FiltrosCatalogo(orden: OrdenCatalogo.precioMenor).hayFiltros,
        isFalse,
      );
      expect(const FiltrosCatalogo(busqueda: '  ').hayFiltros, isFalse);
      expect(base.hayFiltros, isTrue);
    });
  });

  test('Producto sin marca no rompe la búsqueda', () {
    final sinMarca = productosDelCatalogo(
      Catalogo(
        categorias: const [],
        productos: [producto('x', nombre: 'Vino Tinto', categoriaId: null)],
        preciosLista: const <String, int>{},
      ),
    );
    expect(
      aplicarFiltros(sinMarca, const FiltrosCatalogo(busqueda: 'tinto')),
      hasLength(1),
    );
  });
}
