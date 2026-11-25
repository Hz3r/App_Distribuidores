import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:panel_web/src/features/productos/domain/catalogo_repositorio.dart';
import 'package:panel_web/src/features/productos/presentation/productos_screen.dart';

import '../soporte/dobles.dart';
import '../soporte/montar.dart';

CatalogoDoble catalogoDemo() => CatalogoDoble(
  categorias: [categoria('c1', 'Cervezas'), categoria('c2', 'Rones')],
  productos: [
    producto(
      'p1',
      nombre: 'Cerveza Lager',
      categoriaId: 'c1',
      fisico: 600,
      presentaciones: [
        presentacion('b'),
        presentacion('c', nombre: 'Caja x12', factor: 12, precio: 9600),
      ],
    ),
    producto(
      'p2',
      nombre: 'Ron Añejo',
      categoriaId: 'c2',
      sku: 'RON-750',
      fisico: 20,
      comprometido: 20,
      activo: false,
    ),
  ],
);

Finder campoCon(String etiqueta) =>
    find.widgetWithText(TextFormField, etiqueta);

/// Campo de texto cuyo contenido escrito es [valor] (no su pista).
Finder campoConValor(String valor) => find.byWidgetPredicate(
  (w) => w is EditableText && w.controller.text == valor,
);

void main() {
  testWidgets('lista los productos con precio, disponibilidad y categoría', (
    tester,
  ) async {
    await montarSeccion(
      tester,
      const ProductosScreen(),
      catalogo: catalogoDemo(),
    );

    expect(
      find.text('2 en tu catálogo · lo que ven tus clientes en la app.'),
      findsOneWidget,
    );
    expect(find.text('Cerveza Lager'), findsOneWidget);
    expect(find.text('Botella · S/ 8.50'), findsOneWidget);
    expect(find.text('+1 presentación'), findsOneWidget);
    expect(find.text('600 botellas'), findsOneWidget);
    // El ron tiene todo reservado y no tiene presentaciones.
    expect(find.text('SKU RON-750'), findsOneWidget);
    expect(find.text('Agotado'), findsOneWidget);
    expect(find.text('Sin presentaciones'), findsOneWidget);
  });

  testWidgets('buscar y filtrar por categoría; sin resultados deja quitar '
      'los filtros', (tester) async {
    await montarSeccion(
      tester,
      const ProductosScreen(),
      catalogo: catalogoDemo(),
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'Rones'));
    await tester.pump();
    expect(find.text('Cerveza Lager'), findsNothing);
    expect(find.text('Ron Añejo'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'lager');
    await tester.pump();
    expect(find.text('Ningún producto coincide'), findsOneWidget);

    await tester.tap(find.text('Quitar filtros'));
    await tester.pump();
    expect(find.text('Cerveza Lager'), findsOneWidget);
    expect(find.text('Ron Añejo'), findsOneWidget);
  });

  testWidgets('sin productos invita a crear el primero', (tester) async {
    await montarSeccion(
      tester,
      const ProductosScreen(),
      catalogo: CatalogoDoble(),
    );

    expect(find.text('Aún no tienes productos'), findsOneWidget);
    expect(find.text('Nuevo producto'), findsOneWidget);
  });

  testWidgets('si la lectura falla lo dice y Reintentar vuelve a leer', (
    tester,
  ) async {
    final catalogo = catalogoDemo()..fallarEn = 'listarProductos';
    await montarSeccion(tester, const ProductosScreen(), catalogo: catalogo);

    expect(find.text('No pudimos cargar esta sección'), findsOneWidget);

    catalogo.fallarEn = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('Cerveza Lager'), findsOneWidget);
  });

  testWidgets('el interruptor Visible oculta el producto y vuelve a leer', (
    tester,
  ) async {
    final catalogo = catalogoDemo();
    await montarSeccion(tester, const ProductosScreen(), catalogo: catalogo);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(catalogo.llamadas, ['cambiarActivoProducto p1 false']);
    expect(catalogo.lecturasProductos, 2);
  });

  testWidgets('el vendedor ve el catálogo pero no puede crear ni editar', (
    tester,
  ) async {
    await montarSeccion(
      tester,
      const ProductosScreen(),
      catalogo: catalogoDemo(),
      rol: RolMembresia.vendedor,
    );

    expect(find.text('Cerveza Lager'), findsOneWidget);
    expect(find.text('Nuevo producto'), findsNothing);
    expect(find.byType(Switch), findsNothing);
    expect(find.byTooltip('Editar Cerveza Lager'), findsNothing);
  });

  testWidgets('crear un producto: valida, guarda con su presentación y la '
      'disponibilidad inicial, y avisa', (tester) async {
    final catalogo = catalogoDemo();
    await montarSeccion(tester, const ProductosScreen(), catalogo: catalogo);

    await tester.tap(find.text('Nuevo producto'));
    await tester.pumpAndSettle();

    // Vacío: avisa qué falta y no guarda.
    await tester.tap(find.text('Crear producto'));
    await tester.pump();
    expect(find.text('Escribe el nombre del producto.'), findsOneWidget);
    expect(find.text('Ej.: 62.90'), findsOneWidget);
    expect(catalogo.llamadas, isEmpty);

    await tester.enterText(campoCon('Nombre'), 'Pisco Quebranta');
    await tester.enterText(campoCon('Se cuenta en'), 'Botella');
    await tester.enterText(campoCon('Cuánto puedes ofrecer'), '48');
    await tester.enterText(campoCon('Precio'), '35,50');
    await tester.tap(find.text('Crear producto'));
    await tester.pumpAndSettle();

    expect(catalogo.llamadas, [
      'crearProducto d1 Pisco Quebranta unidad=botella categoria=null '
          'activo=true',
      'crearPresentacion p-nuevo Unidad x1 3550 orden=0',
      'registrarMovimiento p-nuevo ingreso 48 Disponibilidad inicial',
    ]);
    expect(find.text('Producto creado.'), findsOneWidget);
    expect(find.text('Crear producto'), findsNothing);
  });

  testWidgets('editar: abre con los datos, y un SKU repetido se explica sin '
      'cerrar el formulario', (tester) async {
    final catalogo = catalogoDemo()
      ..fallarEn = 'actualizarProducto'
      ..motivo = MotivoErrorCatalogo.skuRepetido;
    await montarSeccion(tester, const ProductosScreen(), catalogo: catalogo);

    await tester.tap(find.byTooltip('Editar Cerveza Lager'));
    await tester.pumpAndSettle();

    expect(find.text('Editar producto'), findsOneWidget);
    expect(campoConValor('Caja x12'), findsOneWidget);
    expect(campoConValor('96.00'), findsOneWidget);
    // En edición la disponibilidad se cambia en su propia sección.
    expect(campoCon('Cuánto puedes ofrecer'), findsNothing);

    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    expect(
      find.text('Ya tienes otro producto con ese SKU. Usa uno distinto.'),
      findsOneWidget,
    );
    expect(find.text('Editar producto'), findsOneWidget);
  });
}
