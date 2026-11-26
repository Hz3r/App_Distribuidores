import 'package:app_movil/src/config/rutas.dart';
import 'package:app_movil/src/features/carrito/presentation/carrito_providers.dart';
import 'package:app_movil/src/features/catalogo/domain/catalogo.dart';
import 'package:app_movil/src/features/catalogo/presentation/detalle_producto_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'fabricas.dart';
import 'montar_cliente.dart';

/// Cantidad elegida en la barra inferior del detalle.
String cantidad(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(DetalleProductoScreen.claveCantidad)).data!;

Future<void> tocarMas(WidgetTester tester, [int veces = 1]) async {
  for (var i = 0; i < veces; i++) {
    await tester.tap(find.widgetWithIcon(IconButton, Icons.add));
    await tester.pump();
  }
}

/// Fila de tramo resaltada.
Finder tramoResaltado() =>
    find.byWidgetPredicate((w) => w is FilaTramo && w.resaltada);

/// Un producto con dos presentaciones que comparten 24 unidades: "Unidad"
/// (24 disponibles) y "Caja x 12" (2 disponibles).
Catalogo catalogoConDosPresentaciones() => Catalogo(
  categorias: [categoria('c2', nombre: 'Piscos')],
  productos: [
    producto(
      'px',
      nombre: 'Pisco Quebranta',
      marca: 'Tabernero',
      categoriaId: 'c2',
      stockFisico: 24,
      presentaciones: [
        presentacion(
          'px-u',
          productoId: 'px',
          nombre: 'Unidad',
          precioBase: 2500,
        ),
        presentacion(
          'px-c',
          productoId: 'px',
          nombre: 'Caja x 12',
          factor: 12,
          precioBase: 27000,
          orden: 1,
        ),
      ],
    ),
  ],
  preciosLista: const {},
);

void main() {
  late CatalogoRepositorioFijo repositorio;

  setUp(() => repositorio = CatalogoRepositorioFijo(catalogoDePrueba()));

  testWidgets('muestra el producto, sus tramos y cubre la barra inferior', (
    tester,
  ) async {
    await montarCliente(
      tester,
      repositorio: repositorio,
      ubicacion: AppRutas.detalleProducto('p1'),
    );

    expect(find.text('Detalle'), findsOneWidget);
    expect(find.text('CERVEZAS · RUBIA'), findsOneWidget);
    expect(find.text('Cerveza Rubia 630 ml'), findsOneWidget);
    expect(find.text('340 disponibles'), findsOneWidget);
    expect(find.text('Precio mayorista por volumen'), findsOneWidget);
    expect(find.text('1 – 9'), findsOneWidget);
    expect(find.text('10 – 49'), findsOneWidget);
    expect(find.text('50 o más'), findsOneWidget);
    expect(find.text('S/ 62.90'), findsOneWidget);
    expect(find.text('S/ 60.50'), findsOneWidget);
    expect(find.text('S/ 58.00'), findsOneWidget);
    expect(find.text('Agregar · S/ 62.90'), findsOneWidget);
    // Una sola presentación: no hay selector.
    expect(find.byType(ChoiceChip), findsNothing);
    // El detalle se abre por encima de la barra.
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('con 3 el botón dice S/ 188.70 y con 10 usa el segundo tramo', (
    tester,
  ) async {
    await montarCliente(
      tester,
      repositorio: repositorio,
      ubicacion: AppRutas.detalleProducto('p1'),
    );
    expect(tester.widget<FilaTramo>(tramoResaltado()).tramo.desde, 1);

    await tocarMas(tester, 2);
    expect(cantidad(tester), '3');
    expect(find.text('Agregar · S/ 188.70'), findsOneWidget);

    await tocarMas(tester, 7);
    expect(cantidad(tester), '10');
    // 10 × 60.50
    expect(find.text('Agregar · S/ 605.00'), findsOneWidget);
    expect(tramoResaltado(), findsOneWidget);
    expect(tester.widget<FilaTramo>(tramoResaltado()).tramo.desde, 10);

    await tester.tap(find.widgetWithIcon(IconButton, Icons.remove));
    await tester.pump();
    expect(cantidad(tester), '9');
    expect(tester.widget<FilaTramo>(tramoResaltado()).tramo.desde, 1);
  });

  testWidgets('"+" no pasa del disponible y "−" no baja de 1', (tester) async {
    repositorio.catalogo = Catalogo(
      categorias: const [],
      productos: [
        producto('p', nombre: 'Vino Tinto', categoriaId: null, stockFisico: 3),
      ],
      preciosLista: const {},
    );
    await montarCliente(
      tester,
      repositorio: repositorio,
      ubicacion: AppRutas.detalleProducto('p'),
    );

    await tocarMas(tester, 5);
    expect(cantidad(tester), '3');

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.widgetWithIcon(IconButton, Icons.remove));
      await tester.pump();
    }
    expect(cantidad(tester), '1');
  });

  testWidgets('cambiar a una presentación con menos disponible ajusta la '
      'cantidad', (tester) async {
    repositorio.catalogo = catalogoConDosPresentaciones();
    await montarCliente(
      tester,
      repositorio: repositorio,
      ubicacion: AppRutas.detalleProducto('px'),
    );
    expect(find.text('24 disponibles'), findsOneWidget);

    await tocarMas(tester, 4);
    expect(cantidad(tester), '5');

    await tester.tap(find.widgetWithText(ChoiceChip, 'Caja x 12'));
    await tester.pumpAndSettle();

    expect(find.text('2 disponibles'), findsOneWidget);
    expect(cantidad(tester), '2');
    expect(find.text('Agregar · S/ 540.00'), findsOneWidget);
  });

  testWidgets('el stock es del producto: lo que hay de una presentación '
      'reduce lo que se puede agregar de la otra', (tester) async {
    repositorio.catalogo = catalogoConDosPresentaciones();
    final (:router, :container) = await montarCliente(
      tester,
      repositorio: repositorio,
      ubicacion: AppRutas.detalleProducto('px'),
    );
    // Una caja (12 unidades) en el carrito: quedan 12 unidades sueltas.
    container
        .read(carritoActualProvider.notifier)
        .agregar('px-c', 1, disponible: 2);
    await tester.pump();

    await tocarMas(tester, 20);
    expect(cantidad(tester), '12');

    // Con 12 unidades sueltas más en el carrito ya no cabe otra caja.
    await tester.tap(find.textContaining('Agregar ·'));
    await tester.pump();
    expect(container.read(carritoActualProvider).cantidadDe('px-u'), 12);
    await dejarPasarAviso(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Caja x 12'));
    await tester.pumpAndSettle();
    // La disponibilidad mostrada es la de la presentación sola.
    expect(find.text('2 disponibles'), findsOneWidget);
    final boton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Ya tienes todo lo disponible'),
    );
    expect(boton.onPressed, isNull);
  });

  testWidgets('agregar suma al carrito, avisa y vuelve la cantidad a 1', (
    tester,
  ) async {
    final (:router, :container) = await montarCliente(
      tester,
      repositorio: repositorio,
      ubicacion: AppRutas.detalleProducto('p1'),
    );

    await tocarMas(tester, 2);
    await tester.tap(find.text('Agregar · S/ 188.70'));
    await tester.pump();

    expect(container.read(carritoActualProvider).cantidadDe('p1-caja'), 3);
    expect(find.text('Agregado al carrito'), findsOneWidget);
    expect(cantidad(tester), '1');
    await dejarPasarAviso(tester);
  });

  testWidgets('agotado: el botón dice "Agotado" y no agrega', (tester) async {
    await montarCliente(
      tester,
      repositorio: repositorio,
      ubicacion: AppRutas.detalleProducto('p4'),
    );

    expect(find.text('Agotado'), findsWidgets);
    final boton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Agotado'),
    );
    expect(boton.onPressed, isNull);
  });

  testWidgets('el icono del carrito lleva al carrito', (tester) async {
    final (:router, :container) = await montarCliente(
      tester,
      repositorio: repositorio,
      ubicacion: AppRutas.detalleProducto('p1'),
    );

    await tester.tap(find.byTooltip('Ver carrito'));
    await tester.pumpAndSettle();

    expect(router.state.matchedLocation, AppRutas.carrito);
  });

  testWidgets('producto inexistente: mensaje y vuelta al catálogo', (
    tester,
  ) async {
    final (:router, :container) = await montarCliente(
      tester,
      repositorio: repositorio,
      ubicacion: AppRutas.detalleProducto('no-existe'),
    );

    expect(find.text('Este producto ya no está disponible.'), findsOneWidget);

    await tester.tap(find.text('Volver al catálogo'));
    await tester.pumpAndSettle();

    expect(router.state.matchedLocation, AppRutas.catalogo);
  });
}
