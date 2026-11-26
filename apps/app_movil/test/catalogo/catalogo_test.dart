import 'package:app_movil/src/features/catalogo/domain/catalogo.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fabricas.dart';

Catalogo _catalogo(
  List<Producto> productos, {
  List<Categoria>? categorias,
  Map<String, int> preciosLista = const {},
}) => Catalogo(
  categorias: categorias ?? [categoria('c1')],
  productos: productos,
  preciosLista: preciosLista,
);

void main() {
  group('productosDelCatalogo', () {
    test('un producto sin presentaciones activas no aparece', () {
      final productos = productosDelCatalogo(
        _catalogo([
          producto('a', nombre: 'Con'),
          producto(
            'b',
            nombre: 'Sin activas',
            presentaciones: [presentacion('b-u', activo: false)],
          ),
          producto('c', nombre: 'Vacío', presentaciones: const []),
        ]),
      );

      expect(productos.map((p) => p.producto.id), ['a']);
    });

    test('un producto inactivo no aparece', () {
      final productos = productosDelCatalogo(
        _catalogo([producto('a'), producto('b', activo: false)]),
      );

      expect(productos.map((p) => p.producto.id), ['a']);
    });

    test('un producto de una categoría que no está entre las activas no '
        'aparece (la BD no lo dejaría pedir)', () {
      final productos = productosDelCatalogo(
        _catalogo(
          [producto('a'), producto('b', categoriaId: 'inactiva')],
          categorias: [categoria('c1')],
        ),
      );

      expect(productos.map((p) => p.producto.id), ['a']);
    });

    test('un producto sin categoría aparece', () {
      final productos = productosDelCatalogo(
        _catalogo([producto('a', categoriaId: null)]),
      );

      expect(productos.map((p) => p.producto.id), ['a']);
    });

    test('la principal es la activa de menor orden; desempata el nombre', () {
      final productos = productosDelCatalogo(
        _catalogo([
          producto(
            'a',
            presentaciones: [
              presentacion('caja', nombre: 'Caja', orden: 2, factor: 12),
              presentacion('inactiva', orden: 0, activo: false),
              presentacion('six', nombre: 'Six pack', orden: 1, factor: 6),
              presentacion('botella', nombre: 'Botella', orden: 1),
            ],
          ),
        ]),
      );

      expect(productos.single.principal.id, 'botella');
    });

    test('disponible y agotado salen de la principal', () {
      final productos = productosDelCatalogo(
        _catalogo([
          producto(
            'a',
            stockFisico: 120,
            stockComprometido: 30,
            presentaciones: [presentacion('caja', factor: 12)],
          ),
          producto(
            'b',
            stockFisico: 5,
            presentaciones: [presentacion('caja-b', factor: 12)],
          ),
        ]),
      );

      expect(productos[0].disponible, 7);
      expect(productos[0].agotado, isFalse);
      expect(productos[1].disponible, 0);
      expect(productos[1].agotado, isTrue);
    });

    test('precioCentimos usa la lista cuando hay, si no el base', () {
      final productos = productosDelCatalogo(
        _catalogo(
          [
            producto(
              'a',
              presentaciones: [presentacion('a-u', precioBase: 6290)],
            ),
            producto(
              'b',
              presentaciones: [presentacion('b-u', precioBase: 4500)],
            ),
          ],
          preciosLista: {'a-u': 7000},
        ),
      );

      expect(productos[0].precioCentimos, 7000);
      expect(productos[1].precioCentimos, 4500);
    });

    test('precioCentimos aplica un volumen desde 1', () {
      final productos = productosDelCatalogo(
        _catalogo([
          producto(
            'a',
            presentaciones: [
              presentacion(
                'a-u',
                precioBase: 6290,
                preciosVolumen: [volumen(1, 6000), volumen(10, 5000)],
              ),
            ],
          ),
        ]),
      );

      expect(productos.single.precioCentimos, 6000);
    });

    test('orden inicial por nombre, sin distinguir mayúsculas ni tildes', () {
      final productos = productosDelCatalogo(
        _catalogo([
          producto('1', nombre: 'Whisky'),
          producto('2', nombre: 'anís'),
          producto('3', nombre: 'Árbol'),
          producto('4', nombre: 'Cerveza'),
        ]),
      );

      expect(productos.map((p) => p.producto.nombre), [
        'anís',
        'Árbol',
        'Cerveza',
        'Whisky',
      ]);
    });
  });

  test('presentacionesActivas: solo activas, por orden y nombre', () {
    final p = producto(
      'a',
      presentaciones: [
        presentacion('caja', nombre: 'Caja', orden: 2),
        presentacion('x', nombre: 'Inactiva', orden: 0, activo: false),
        presentacion('six', nombre: 'Six pack', orden: 1),
        presentacion('bot', nombre: 'Botella', orden: 1),
      ],
    );

    expect(presentacionesActivas(p).map((x) => x.id), ['bot', 'six', 'caja']);
  });

  group('Catalogo.desde', () {
    test('deja las categorías activas, por orden y nombre', () {
      final catalogo = Catalogo.desde(
        categorias: [
          categoria('ron', nombre: 'Ron', orden: 1),
          categoria('vino', nombre: 'Vino', orden: 0, activo: false),
          categoria('pisco', nombre: 'Pisco', orden: 1),
          categoria('cerveza', nombre: 'Cerveza', orden: 0),
        ],
        productos: const [],
        preciosLista: const [],
      );

      expect(catalogo.categorias.map((c) => c.id), ['cerveza', 'pisco', 'ron']);
    });

    test('arma el mapa presentación → precio de la lista', () {
      final catalogo = Catalogo.desde(
        categorias: const [],
        productos: const [],
        preciosLista: [
          PrecioLista(
            id: 'l1',
            distribuidorId: 'd1',
            listaPreciosId: 'lista',
            presentacionId: 'a-u',
            precioCentimos: 7000,
            creadoEn: DateTime.utc(2026),
          ),
        ],
      );

      expect(catalogo.preciosLista, {'a-u': 7000});
    });
  });
}
