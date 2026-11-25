import 'package:flutter_test/flutter_test.dart';
import 'package:panel_web/src/features/productos/domain/catalogo_repositorio.dart';
import 'package:panel_web/src/features/productos/domain/filtro_productos.dart';
import 'package:panel_web/src/features/productos/domain/guardar_producto.dart';

import '../soporte/dobles.dart';

void main() {
  group('filtrarProductos', () {
    final lager = producto('p1', nombre: 'Cerveza Lager', categoriaId: 'c1');
    final anejo = producto(
      'p2',
      nombre: 'Ron Añejo',
      categoriaId: 'c2',
      marca: 'Cartavio',
      sku: 'RON-750',
    );
    final suelto = producto('p3', nombre: 'Hielo');
    final todos = [lager, anejo, suelto];

    test('sin filtros devuelve todo en el mismo orden', () {
      expect(filtrarProductos(todos), todos);
    });

    test('busca por nombre sin importar mayúsculas ni tildes', () {
      expect(filtrarProductos(todos, busqueda: 'anejo'), [anejo]);
      expect(filtrarProductos(todos, busqueda: '  CERVEZA '), [lager]);
    });

    test('busca también por marca y por SKU', () {
      expect(filtrarProductos(todos, busqueda: 'cartav'), [anejo]);
      expect(filtrarProductos(todos, busqueda: 'ron-750'), [anejo]);
    });

    test('filtra por categoría y la combina con la búsqueda', () {
      expect(filtrarProductos(todos, categoriaId: 'c1'), [lager]);
      expect(
        filtrarProductos(todos, categoriaId: 'c1', busqueda: 'ron'),
        isEmpty,
      );
    });
  });

  group('guardarProducto', () {
    const datos = DatosProducto(
      nombre: 'Cerveza Lager',
      unidadBase: 'botella',
      categoriaId: 'c1',
    );

    test('producto nuevo: lo crea, crea sus presentaciones en orden y '
        'registra la disponibilidad inicial', () async {
      final repositorio = CatalogoDoble();

      await guardarProducto(
        repositorio,
        distribuidorId: 'd1',
        datos: datos,
        presentaciones: const [
          DatosPresentacion(
            nombre: 'Botella',
            factor: 1,
            precioBaseCentimos: 850,
          ),
          DatosPresentacion(
            nombre: 'Caja x12',
            factor: 12,
            precioBaseCentimos: 9600,
          ),
        ],
        disponibilidadInicial: 240,
      );

      expect(repositorio.llamadas, [
        'crearProducto d1 Cerveza Lager unidad=botella categoria=c1 activo=true',
        'crearPresentacion p-nuevo Botella x1 850 orden=0',
        'crearPresentacion p-nuevo Caja x12 x12 9600 orden=1',
        'registrarMovimiento p-nuevo ingreso 240 Disponibilidad inicial',
      ]);
    });

    test('producto nuevo sin disponibilidad inicial no registra '
        'movimiento', () async {
      final repositorio = CatalogoDoble();

      await guardarProducto(
        repositorio,
        distribuidorId: 'd1',
        datos: datos,
        presentaciones: const [
          DatosPresentacion(
            nombre: 'Botella',
            factor: 1,
            precioBaseCentimos: 850,
          ),
        ],
      );

      expect(
        repositorio.llamadas.where((l) => l.startsWith('registrarMovimiento')),
        isEmpty,
      );
    });

    test('edición: actualiza el producto, solo las presentaciones que '
        'cambiaron, y crea las nuevas', () async {
      final repositorio = CatalogoDoble();
      final original = producto(
        'p1',
        presentaciones: [
          presentacion('b', nombre: 'Botella'),
          presentacion(
            'c',
            nombre: 'Caja x12',
            factor: 12,
            precio: 9600,
            orden: 1,
          ),
        ],
      );

      await guardarProducto(
        repositorio,
        distribuidorId: 'd1',
        original: original,
        datos: datos,
        presentaciones: const [
          // Igual que antes: no se toca.
          DatosPresentacion(
            id: 'b',
            nombre: 'Botella',
            factor: 1,
            precioBaseCentimos: 850,
          ),
          // Sube de precio y se deja de vender.
          DatosPresentacion(
            id: 'c',
            nombre: 'Caja x12',
            factor: 12,
            precioBaseCentimos: 9900,
            activo: false,
          ),
          DatosPresentacion(
            nombre: 'Six pack',
            factor: 6,
            precioBaseCentimos: 4900,
          ),
        ],
        // En una edición la disponibilidad no se toca desde aquí.
        disponibilidadInicial: 500,
      );

      expect(repositorio.llamadas, [
        'actualizarProducto p1 Cerveza Lager',
        'actualizarPresentacion c Caja x12 x12 9900 activo=false orden=1',
        'crearPresentacion p1 Six pack x6 4900 orden=2',
      ]);
    });

    test(
      'si falla al crear una presentación, el error sale y no sigue',
      () async {
        final repositorio = CatalogoDoble()
          ..fallarEn = 'crearPresentacion'
          ..motivo = MotivoErrorCatalogo.datoInvalido;

        await expectLater(
          guardarProducto(
            repositorio,
            distribuidorId: 'd1',
            datos: datos,
            presentaciones: const [
              DatosPresentacion(
                nombre: 'Botella',
                factor: 1,
                precioBaseCentimos: 850,
              ),
            ],
            disponibilidadInicial: 10,
          ),
          throwsA(
            isA<ErrorCatalogo>().having(
              (e) => e.motivo,
              'motivo',
              MotivoErrorCatalogo.datoInvalido,
            ),
          ),
        );
        expect(repositorio.llamadas, [
          'crearProducto d1 Cerveza Lager unidad=botella categoria=c1 activo=true',
        ]);
      },
    );
  });
}
