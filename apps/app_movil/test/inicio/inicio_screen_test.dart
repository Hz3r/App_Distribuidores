import 'package:app_movil/src/config/rutas.dart';
import 'package:app_movil/src/features/carrito/presentation/carrito_providers.dart';
import 'package:app_movil/src/features/catalogo/domain/filtros_catalogo.dart';
import 'package:app_movil/src/features/catalogo/presentation/catalogo_providers.dart';
import 'package:app_movil/src/features/catalogo/presentation/catalogo_screen.dart';
import 'package:app_movil/src/features/catalogo/presentation/detalle_producto_screen.dart';
import 'package:app_movil/src/features/catalogo/presentation/widgets/tarjeta_producto.dart';
import 'package:app_movil/src/features/inicio/presentation/inicio_screen.dart';
import 'package:app_movil/src/features/sesion/presentation/control_acceso.dart';
import 'package:app_movil/src/shared/tema_app.dart';
import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../catalogo/montar_cliente.dart';
import '../registro/dobles.dart';
import 'fabricas_pedidos.dart';

/// Pedidos de la bodega: noviembre 234000 (sin el cancelado), octubre
/// 216667; el último es el #1042, en camino. Más pedidos: Ron Añejo (30
/// unidades) y Cerveza Rubia (2 cajas de 12 = 24).
List<Pedido> pedidosDePrueba() => [
  pedido(
    'a',
    numero: 1042,
    estado: EstadoPedido.enCamino,
    total: 100000,
    creadoEn: DateTime.utc(2026, 11, 20, 15),
    items: [linea('p3', cantidad: 10), linea('p1', cantidad: 2, factor: 12)],
  ),
  pedido(
    'b',
    numero: 1041,
    total: 134000,
    creadoEn: DateTime.utc(2026, 11, 5, 15),
    items: [linea('p3', cantidad: 20)],
  ),
  pedido(
    'c',
    numero: 1040,
    estado: EstadoPedido.cancelado,
    total: 50000,
    creadoEn: DateTime.utc(2026, 11, 4, 15),
    items: [linea('p2', cantidad: 500)],
  ),
  pedido(
    'd',
    numero: 1030,
    total: 216667,
    creadoEn: DateTime.utc(2026, 10, 10, 15),
  ),
];

/// Tarjetas de producto del inicio, de izquierda a derecha.
List<String> tarjetasDelInicio(WidgetTester tester) {
  final tarjetas = find.descendant(
    of: find.byType(InicioScreen),
    matching: find.byType(TarjetaProducto),
  );
  final lista = tarjetas.evaluate().map((e) => e.widget as TarjetaProducto);
  final ordenadas = lista.toList()
    ..sort(
      (a, b) => tester
          .getTopLeft(find.byWidget(a))
          .dx
          .compareTo(tester.getTopLeft(find.byWidget(b)).dx),
    );
  return [for (final t in ordenadas) t.item.producto.nombre];
}

/// Chip elegido del catálogo.
String? chipElegido(WidgetTester tester) {
  final elegidos = tester
      .widgetList<ChoiceChip>(find.byType(ChoiceChip))
      .where((c) => c.selected);
  if (elegidos.isEmpty) return null;
  return (elegidos.single.label as Text).data;
}

void main() {
  late CatalogoRepositorioFijo catalogo;
  late PedidosResumenRepositorioFijo pedidos;

  setUp(() {
    catalogo = CatalogoRepositorioFijo(catalogoDePrueba());
    pedidos = PedidosResumenRepositorioFijo(pedidosDePrueba());
  });

  Future<({GoRouter router, ProviderContainer container})> montar(
    WidgetTester tester, {
    double ancho = 390,
  }) => montarCliente(
    tester,
    repositorio: catalogo,
    pedidos: pedidos,
    ubicacion: AppRutas.inicio,
    ancho: ancho,
  );

  testWidgets('saluda a la bodega y muestra su distribuidor', (tester) async {
    await montar(tester);

    expect(find.byType(InicioScreen), findsOneWidget);
    expect(find.text('Hola, Bodega Don Pepe'), findsOneWidget);
    expect(find.text('Licores del Norte'), findsOneWidget);
    expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    expect(find.text('Buscar productos o marcas'), findsOneWidget);
  });

  testWidgets('lee los pedidos de su bodega desde hace 90 días', (
    tester,
  ) async {
    await montar(tester);

    expect(pedidos.lecturas, hasLength(1));
    final lectura = pedidos.lecturas.single;
    expect(lectura.distribuidorId, 'd1');
    expect(lectura.clienteId, 'cn-d1');
    expect(lectura.desde, ahoraDePrueba.subtract(const Duration(days: 90)));
  });

  testWidgets('con pedidos: último pedido, comprado este mes y variación', (
    tester,
  ) async {
    await montar(tester);

    expect(find.text('Último pedido'), findsOneWidget);
    expect(find.text('#1042'), findsOneWidget);
    expect(find.text('En camino'), findsOneWidget);
    expect(find.text('Comprado este mes'), findsOneWidget);
    expect(find.text('S/ 2,340.00'), findsOneWidget);
    expect(find.text('▲ 8% vs octubre'), findsOneWidget);
  });

  testWidgets('si bajó, la variación va con ▼ y en rojo', (tester) async {
    pedidos.pedidos = [
      pedido('a', total: 100000, creadoEn: DateTime.utc(2026, 11, 20)),
      pedido('b', total: 120000, creadoEn: DateTime.utc(2026, 10, 20)),
    ];
    await montar(tester);

    final texto = tester.widget<Text>(find.text('▼ 17% vs octubre'));
    expect(texto.style?.color, ColoresApp.error);
  });

  testWidgets('sin pedidos: "Aún no tienes pedidos", S/ 0.00 y sin variación', (
    tester,
  ) async {
    pedidos.pedidos = [];
    await montar(tester);

    expect(find.text('Aún no tienes pedidos'), findsOneWidget);
    expect(find.text('S/ 0.00'), findsOneWidget);
    expect(find.textContaining('vs '), findsNothing);
    expect(find.textContaining('#'), findsNothing);
  });

  testWidgets('no hay cartel de pedido mínimo, hora de corte ni promociones', (
    tester,
  ) async {
    await montar(tester);

    for (final texto in ['Pedido mínimo', 'mínimo', 'Pide antes', 'Promo']) {
      expect(find.textContaining(texto), findsNothing, reason: texto);
    }
  });

  testWidgets('a 320 de ancho las dos tarjetas se leen completas', (
    tester,
  ) async {
    pedidos.pedidos = [
      pedido(
        'a',
        numero: 104200,
        estado: EstadoPedido.listoRecojo,
        total: 12345678,
        creadoEn: DateTime.utc(2026, 11, 20),
      ),
      pedido('b', total: 1000000, creadoEn: DateTime.utc(2026, 10, 20)),
    ];
    await montar(tester, ancho: 320);

    for (final texto in [
      'Último pedido',
      '#104200',
      'Listo para recoger',
      'Comprado este mes',
      'S/ 123,456.78',
      '▲ 1135% vs octubre',
    ]) {
      expect(find.text(texto), findsOneWidget, reason: texto);
      expectSinRecortar(tester, find.text(texto));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('tocar el último pedido lleva a Pedidos', (tester) async {
    final (:router, container: _) = await montar(tester);

    await tester.tap(find.text('#1042'));
    await tester.pumpAndSettle();

    expect(router.state.matchedLocation, AppRutas.pedidos);
  });

  testWidgets('muestra las categorías del catálogo', (tester) async {
    await montar(tester);

    expect(find.text('Categorías'), findsOneWidget);
    expect(find.text('Cervezas'), findsOneWidget);
    expect(find.text('Rones'), findsOneWidget);
    expect(find.byIcon(Icons.sell_outlined), findsNWidgets(2));
  });

  testWidgets('tocar una categoría abre el catálogo con ese chip elegido', (
    tester,
  ) async {
    final (:router, :container) = await montar(tester);

    await tester.tap(find.text('Rones'));
    await tester.pumpAndSettle();

    expect(router.state.matchedLocation, AppRutas.catalogo);
    expect(find.byType(CatalogoScreen), findsOneWidget);
    expect(chipElegido(tester), 'Rones');
    expect(find.text('2 productos'), findsOneWidget);
    expect(container.read(filtrosCatalogoActualesProvider).categoriaId, 'c2');
  });

  testWidgets('"Ver todo" de categorías abre el catálogo sin filtros', (
    tester,
  ) async {
    final (:router, :container) = await montar(tester);
    container
        .read(filtrosCatalogoActualesProvider.notifier)
        .fijar(const FiltrosCatalogo(categoriaId: 'c2', busqueda: 'ron'));

    await tester.tap(find.text('Ver todo').first);
    await tester.pumpAndSettle();

    expect(router.state.matchedLocation, AppRutas.catalogo);
    expect(chipElegido(tester), 'Todos');
    expect(find.text('4 productos'), findsOneWidget);
    expect(container.read(filtrosCatalogoActualesProvider).hayFiltros, isFalse);
  });

  group('buscar desde el inicio', () {
    Future<void> buscar(WidgetTester tester, String texto) async {
      final campo = find.descendant(
        of: find.byType(InicioScreen),
        matching: find.byType(TextField),
      );
      await tester.enterText(campo, texto);
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
    }

    testWidgets('abre el catálogo con ese texto en su buscador', (
      tester,
    ) async {
      final (:router, container: _) = await montar(tester);

      await buscar(tester, 'ron');

      expect(router.state.matchedLocation, AppRutas.catalogo);
      final campo = tester.widget<TextField>(
        find.descendant(
          of: find.byType(CatalogoScreen),
          matching: find.byType(TextField),
        ),
      );
      expect(campo.controller?.text, 'ron');
      expect(find.text('2 productos'), findsOneWidget);
    });

    testWidgets('también si el catálogo ya estaba abierto con el buscador '
        'cerrado', (tester) async {
      final (:router, container: _) = await montar(tester);
      // Se visita el catálogo y se vuelve al inicio: su pantalla sigue viva.
      await tester.tap(find.text('Catálogo'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(CatalogoScreen),
          matching: find.byType(TextField),
        ),
        findsNothing,
      );
      await tester.tap(find.text('Inicio'));
      await tester.pumpAndSettle();

      await buscar(tester, 'cerveza');

      expect(router.state.matchedLocation, AppRutas.catalogo);
      final campo = tester.widget<TextField>(
        find.descendant(
          of: find.byType(CatalogoScreen),
          matching: find.byType(TextField),
        ),
      );
      expect(campo.controller?.text, 'cerveza');
      expect(find.text('2 productos'), findsOneWidget);
    });

    testWidgets('al volver, el buscador del inicio queda vacío', (
      tester,
    ) async {
      await montar(tester);

      await buscar(tester, 'ron');
      await tester.tap(find.text('Inicio'));
      await tester.pumpAndSettle();

      final campo = tester.widget<TextField>(
        find.descendant(
          of: find.byType(InicioScreen),
          matching: find.byType(TextField),
        ),
      );
      expect(campo.controller?.text, isEmpty);
    });

    testWidgets('sin texto no navega', (tester) async {
      final (:router, container: _) = await montar(tester);

      await buscar(tester, '   ');

      expect(router.state.matchedLocation, AppRutas.inicio);
    });
  });

  testWidgets('"Lo que más pides" muestra los productos en el orden del '
      'resumen', (tester) async {
    await montar(tester);

    expect(find.text('Lo que más pides'), findsOneWidget);
    expect(tarjetasDelInicio(tester), [
      'Ron Añejo 750 ml',
      'Cerveza Rubia 630 ml',
    ]);
  });

  testWidgets('sin historial la sección se llama "Productos" y muestra los del '
      'catálogo', (tester) async {
    pedidos.pedidos = [];
    await montar(tester);

    expect(find.text('Lo que más pides'), findsNothing);
    expect(find.text('Productos'), findsOneWidget);
    // Los del catálogo, por nombre; el último se alcanza deslizando.
    expect(tarjetasDelInicio(tester).take(2), [
      'Cerveza Negra 330 ml',
      'Cerveza Rubia 630 ml',
    ]);
    await tester.scrollUntilVisible(
      find.text('Ron Blanco 1 L'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(InicioScreen),
            matching: find.byType(Scrollable),
          )
          .last,
    );
    expect(find.text('Ron Blanco 1 L'), findsOneWidget);
  });

  testWidgets('abrir un producto desde el inicio y volver regresa al inicio', (
    tester,
  ) async {
    final (:router, container: _) = await montar(tester);

    await tester.tap(find.text('Ron Añejo 750 ml'));
    await tester.pumpAndSettle();
    expect(find.byType(DetalleProductoScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(find.byTooltip('Volver'));
    await tester.pumpAndSettle();

    expect(find.byType(DetalleProductoScreen), findsNothing);
    expect(router.state.matchedLocation, AppRutas.inicio);
    expect(find.text('Hola, Bodega Don Pepe'), findsOneWidget);
  });

  testWidgets('"+" en una tarjeta del inicio agrega al carrito', (
    tester,
  ) async {
    final (router: _, :container) = await montar(tester);
    final mas = find.descendant(
      of: find.widgetWithText(TarjetaProducto, 'Ron Añejo 750 ml'),
      matching: find.widgetWithIcon(IconButton, Icons.add),
    );
    await tester.ensureVisible(mas);
    await tester.pumpAndSettle();

    await tester.tap(mas);
    await tester.pump();

    expect(container.read(carritoActualProvider).cantidadDe('p3-bot'), 1);
    expect(find.text('Agregado al carrito'), findsOneWidget);
    await dejarPasarAviso(tester);
  });

  testWidgets('si falla la lectura muestra "Reintentar" y reintentar carga', (
    tester,
  ) async {
    pedidos.error = Exception('sin red');
    await montar(tester);

    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.text('Comprado este mes'), findsNothing);
    // El encabezado sigue a la vista.
    expect(find.text('Hola, Bodega Don Pepe'), findsOneWidget);

    pedidos.error = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('Reintentar'), findsNothing);
    expect(find.text('#1042'), findsOneWidget);
  });

  testWidgets('si falla el catálogo también muestra "Reintentar"', (
    tester,
  ) async {
    catalogo.error = Exception('sin red');
    await montar(tester);

    expect(find.text('Reintentar'), findsOneWidget);

    catalogo.error = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('Categorías'), findsOneWidget);
  });

  testWidgets('deslizar hacia abajo recarga catálogo y resumen sin recargar '
      'el acceso', (tester) async {
    final (router: _, :container) = await montar(tester);
    final cargas = catalogo.cargas;
    final lecturas = pedidos.lecturas.length;

    await tester.fling(
      find.text('Hola, Bodega Don Pepe'),
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();

    expect(catalogo.cargas, cargas + 1);
    expect(pedidos.lecturas, hasLength(lecturas + 1));
    final control =
        container.read(controlAccesoProvider.notifier) as ControlAccesoFalso;
    expect(control.recargas, 0);
  });
}
