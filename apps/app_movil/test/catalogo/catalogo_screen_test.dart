import 'package:app_movil/src/config/rutas.dart';
import 'package:app_movil/src/features/carrito/presentation/carrito_providers.dart';
import 'package:app_movil/src/features/catalogo/domain/catalogo.dart';
import 'package:app_movil/src/features/catalogo/presentation/detalle_producto_screen.dart';
import 'package:app_movil/src/features/catalogo/presentation/widgets/tarjeta_producto.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'fabricas.dart';
import 'montar_cliente.dart';
import '../soporte/dobles_cliente.dart';

/// Botón "+" de la tarjeta del producto [nombre]. Se busca por el icono: un
/// botón deshabilitado no muestra su tooltip.
Finder masDe(String nombre) => find.descendant(
  of: find.widgetWithText(TarjetaProducto, nombre),
  matching: find.widgetWithIcon(IconButton, Icons.add),
);

/// Toca la opción [texto] del menú abierto (la opción, no su texto, que no
/// recibe toques).
Future<void> elegirDelMenu(WidgetTester tester, String texto) async {
  await tester.tap(
    find.ancestor(
      of: find.text(texto).last,
      matching: find.byWidgetPredicate((w) => w is PopupMenuItem),
    ),
  );
  await tester.pumpAndSettle();
}

/// Desliza la cuadrícula hasta que se vea [nombre].
Future<void> desplazarHasta(WidgetTester tester, String nombre) =>
    tester.scrollUntilVisible(
      find.text(nombre),
      200,
      scrollable: find
          .descendant(
            of: find.byType(GridView),
            matching: find.byType(Scrollable),
          )
          .first,
    );

void main() {
  late CatalogoRepositorioFijo repositorio;

  setUp(() => repositorio = CatalogoRepositorioFijo(catalogoDePrueba()));

  testWidgets('muestra el catálogo con sus chips, controles y cuenta', (
    tester,
  ) async {
    await montarCliente(tester, repositorio: repositorio);

    expect(find.text('4 productos'), findsOneWidget);
    for (final chip in ['Todos', 'Cervezas', 'Rones']) {
      expect(find.text(chip), findsOneWidget, reason: chip);
    }
    expect(find.text('Ordenar'), findsOneWidget);
    expect(find.text('Marca'), findsOneWidget);
    // La tarjeta: nombre, presentación, disponibilidad, precio y unidad.
    expect(find.text('Cerveza Rubia 630 ml'), findsOneWidget);
    expect(find.text('Caja x 12'), findsOneWidget);
    expect(find.text('340 disponibles'), findsOneWidget);
    expect(find.text('S/ 62.90'), findsOneWidget);
    expect(find.text('por caja x 12'), findsOneWidget);
    // La barra inferior con el catálogo activo.
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('el agotado dice "Agotado"', (tester) async {
    await montarCliente(tester, repositorio: repositorio);
    await desplazarHasta(tester, 'Ron Blanco 1 L');

    expect(
      find.descendant(
        of: find.widgetWithText(TarjetaProducto, 'Ron Blanco 1 L'),
        matching: find.text('Agotado'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('tocar una categoría deja solo sus productos', (tester) async {
    await montarCliente(tester, repositorio: repositorio);

    await tester.tap(find.text('Rones'));
    await tester.pumpAndSettle();

    expect(find.text('2 productos'), findsOneWidget);
    expect(find.text('Ron Añejo 750 ml'), findsOneWidget);
    expect(find.text('Cerveza Rubia 630 ml'), findsNothing);

    await tester.tap(find.text('Todos'));
    await tester.pumpAndSettle();
    expect(find.text('4 productos'), findsOneWidget);
  });

  testWidgets('la lupa muestra el buscador y buscar filtra', (tester) async {
    await montarCliente(tester, repositorio: repositorio);
    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.byTooltip('Buscar'));
    await tester.pumpAndSettle();
    expect(find.text('Buscar productos o marcas'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'ron');
    await tester.pumpAndSettle();

    expect(find.text('2 productos'), findsOneWidget);
    expect(find.text('Cerveza Negra 330 ml'), findsNothing);

    // Ocultar el buscador quita la búsqueda.
    await tester.tap(find.byTooltip('Cerrar búsqueda'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
    expect(find.text('4 productos'), findsOneWidget);
  });

  testWidgets('ordenar por precio cambia el orden', (tester) async {
    await montarCliente(tester, repositorio: repositorio);
    // Por nombre: Cerveza Negra, Cerveza Rubia, Ron Añejo, Ron Blanco.
    final negra = tester.getTopLeft(find.text('Cerveza Negra 330 ml'));
    final rubia = tester.getTopLeft(find.text('Cerveza Rubia 630 ml'));
    expect(negra.dy, rubia.dy);
    expect(negra.dx, lessThan(rubia.dx));

    await tester.tap(find.text('Ordenar'));
    await tester.pumpAndSettle();
    await elegirDelMenu(tester, 'Precio: menor a mayor');

    // Ron Blanco (29.90) y Ron Añejo (39.90) pasan a la primera fila.
    final blanco = tester.getTopLeft(find.text('Ron Blanco 1 L'));
    final anejo = tester.getTopLeft(find.text('Ron Añejo 750 ml'));
    final negraDespues = tester.getTopLeft(find.text('Cerveza Negra 330 ml'));
    expect(blanco.dy, anejo.dy);
    expect(blanco.dx, lessThan(anejo.dx));
    expect(blanco.dy, lessThan(negraDespues.dy));
  });

  testWidgets('filtrar por marca y elegir "Todas" la quita', (tester) async {
    await montarCliente(tester, repositorio: repositorio);

    await tester.tap(find.text('Marca'));
    await tester.pumpAndSettle();
    await elegirDelMenu(tester, 'Cartavio');
    expect(find.text('2 productos'), findsOneWidget);

    await tester.tap(find.text('Cartavio'));
    await tester.pumpAndSettle();
    await elegirDelMenu(tester, 'Todas');
    expect(find.text('4 productos'), findsOneWidget);
  });

  testWidgets('"+" suma una línea y la segunda vez suma cantidad', (
    tester,
  ) async {
    final (:router, :container) = await montarCliente(
      tester,
      repositorio: repositorio,
    );

    await tester.tap(masDe('Cerveza Rubia 630 ml'));
    await tester.pump();
    expect(container.read(carritoActualProvider).lineas, 1);
    expect(container.read(carritoActualProvider).cantidadDe('p1-caja'), 1);

    await tester.tap(masDe('Cerveza Rubia 630 ml'));
    await tester.pump();
    expect(container.read(carritoActualProvider).lineas, 1);
    expect(container.read(carritoActualProvider).cantidadDe('p1-caja'), 2);

    // La insignia de la barra cuenta líneas.
    expect(
      find.descendant(of: find.byType(NavigationBar), matching: find.text('1')),
      findsOneWidget,
    );
    await dejarPasarAviso(tester);
  });

  testWidgets('"+" del agotado no hace nada', (tester) async {
    final (:router, :container) = await montarCliente(
      tester,
      repositorio: repositorio,
    );
    await desplazarHasta(tester, 'Ron Blanco 1 L');
    // El "+" queda más abajo que el nombre.
    await tester.ensureVisible(masDe('Ron Blanco 1 L'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<IconButton>(masDe('Ron Blanco 1 L')).onPressed,
      isNull,
    );
    await tester.tap(masDe('Ron Blanco 1 L'));
    await tester.pump();

    expect(container.read(carritoActualProvider).lineas, 0);
  });

  testWidgets('"+" se deshabilita cuando el carrito tiene todo el '
      'disponible', (tester) async {
    repositorio.catalogo = Catalogo(
      distribuidorId: 'd1',
      categorias: const [],
      productos: [
        producto(
          'pocos',
          nombre: 'Pisco Quebranta',
          categoriaId: null,
          stockFisico: 2,
        ),
      ],
      preciosLista: const {},
    );
    final (:router, :container) = await montarCliente(
      tester,
      repositorio: repositorio,
    );

    await tester.tap(masDe('Pisco Quebranta'));
    await tester.pump();
    await tester.tap(masDe('Pisco Quebranta'));
    await tester.pump();
    await tester.tap(masDe('Pisco Quebranta'));
    await tester.pump();

    expect(container.read(carritoActualProvider).cantidadDe('pocos-u'), 2);
    expect(
      tester.widget<IconButton>(masDe('Pisco Quebranta')).onPressed,
      isNull,
    );
    await dejarPasarAviso(tester);
  });

  testWidgets('tocar la tarjeta abre el detalle', (tester) async {
    final (:router, :container) = await montarCliente(
      tester,
      repositorio: repositorio,
    );

    await tester.tap(find.text('Cerveza Rubia 630 ml'));
    await tester.pumpAndSettle();

    expect(router.state.matchedLocation, AppRutas.detalleProducto('p1'));
    expect(find.byType(DetalleProductoScreen), findsOneWidget);
  });

  testWidgets('el error muestra "Reintentar" y al tocarlo vuelve a cargar', (
    tester,
  ) async {
    repositorio.error = Exception('sin red');
    await montarCliente(tester, repositorio: repositorio);

    expect(find.text('No pudimos cargar el catálogo.'), findsOneWidget);
    expect(repositorio.cargas, 1);

    repositorio.error = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(repositorio.cargas, 2);
    expect(find.text('4 productos'), findsOneWidget);
  });

  testWidgets('catálogo vacío lo dice', (tester) async {
    repositorio.catalogo = const Catalogo(
      distribuidorId: 'd1',
      categorias: [],
      productos: [],
      preciosLista: {},
    );
    await montarCliente(tester, repositorio: repositorio);

    expect(
      find.text('Tu distribuidor todavía no publicó productos.'),
      findsOneWidget,
    );
  });

  testWidgets('sin resultados muestra "Quitar filtros", que los quita', (
    tester,
  ) async {
    await montarCliente(tester, repositorio: repositorio);
    await tester.tap(find.byTooltip('Buscar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'whisky');
    await tester.pumpAndSettle();

    expect(
      find.text('No encontramos productos con esos filtros.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Quitar filtros'));
    await tester.pumpAndSettle();

    expect(find.text('4 productos'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
  });

  testWidgets('deslizar hacia abajo recarga', (tester) async {
    await montarCliente(tester, repositorio: repositorio);
    expect(repositorio.cargas, 1);

    await tester.fling(find.byType(GridView), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(repositorio.cargas, 2);
    expect(find.text('4 productos'), findsOneWidget);
  });

  testWidgets('cada "+" dice qué producto agrega', (tester) async {
    await montarCliente(tester, repositorio: repositorio);

    expect(
      find.byTooltip('Agregar Cerveza Rubia 630 ml al carrito'),
      findsOneWidget,
    );
    expect(
      find.byTooltip('Agregar Cerveza Negra 330 ml al carrito'),
      findsOneWidget,
    );
  });

  testWidgets('a 320 de ancho los controles y la cuenta no se recortan', (
    tester,
  ) async {
    await montarCliente(tester, repositorio: repositorio, ancho: 320);

    for (final texto in ['Ordenar', 'Marca', '4 productos']) {
      expectSinRecortar(tester, find.text(texto));
    }
    expect(tester.takeException(), isNull);
  });

  for (final (precio, texto) in [(6290, 'S/ 62.90'), (123490, 'S/ 1,234.90')]) {
    testWidgets('a 320 de ancho el precio $texto se ve completo', (
      tester,
    ) async {
      repositorio.catalogo = Catalogo(
        distribuidorId: 'd1',
        categorias: const [],
        productos: [
          producto(
            'p',
            nombre: 'Vino Reserva',
            categoriaId: null,
            presentaciones: [
              presentacion(
                'p-c',
                productoId: 'p',
                nombre: 'Caja x 12',
                precioBase: precio,
              ),
            ],
          ),
        ],
        preciosLista: const {},
      );
      await montarCliente(tester, repositorio: repositorio, ancho: 320);

      expectSinRecortar(tester, find.text(texto));
      // Si se achica, no por debajo de 11 puntos.
      final parrafo = tester.renderObject<RenderParagraph>(find.text(texto));
      // Lo que se ve, con cualquier escalado de un padre (FittedBox).
      final escalaVisible =
          tester.getRect(find.text(texto)).width / parrafo.size.width;
      final tamano =
          parrafo.textScaler.scale(parrafo.text.style!.fontSize!) *
          escalaVisible;
      expect(tamano, greaterThanOrEqualTo(11));
      expect(tester.takeException(), isNull);
    });
  }
}
