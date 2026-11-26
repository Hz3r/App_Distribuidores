import 'package:app_movil/src/config/rutas.dart';
import 'package:app_movil/src/features/carrito/presentation/carrito_screen.dart';
import 'package:app_movil/src/features/catalogo/presentation/detalle_producto_screen.dart';
import 'package:app_movil/src/features/inicio/presentation/inicio_screen.dart';
import 'package:app_movil/src/features/sesion/domain/acceso.dart';
import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../catalogo/montar_cliente.dart';
import '../registro/dobles.dart';
import '../soporte/dobles_cliente.dart';

/// El botón atrás del sistema (Android), por el mismo camino que la
/// plataforma: `handlePopRoute` del binding.
void main() {
  late List<String> llamadas;

  setUp(() => llamadas = []);

  /// Anota las llamadas al canal de plataforma: `SystemNavigator.pop` es
  /// salir de la app.
  void escucharPlataforma(WidgetTester tester) {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (llamada) async {
        llamadas.add(llamada.method);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
  }

  Future<void> atras(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  bool salio() => llamadas.contains('SystemNavigator.pop');

  testWidgets('en Catálogo, atrás lleva a Inicio sin salir', (tester) async {
    escucharPlataforma(tester);
    final (:router, container: _) = await montarCliente(
      tester,
      repositorio: CatalogoRepositorioFijo(catalogoDePrueba()),
      ubicacion: AppRutas.inicio,
    );
    await tester.tap(find.text('Catálogo'));
    await tester.pumpAndSettle();
    expect(router.state.matchedLocation, AppRutas.catalogo);

    await atras(tester);

    expect(router.state.matchedLocation, AppRutas.inicio);
    expect(find.byType(InicioScreen), findsOneWidget);
    expect(salio(), isFalse);
  });

  testWidgets('en Pedidos, atrás lleva a Inicio sin salir', (tester) async {
    escucharPlataforma(tester);
    final (:router, container: _) = await montarCliente(
      tester,
      repositorio: CatalogoRepositorioFijo(catalogoDePrueba()),
      ubicacion: AppRutas.pedidos,
    );

    await atras(tester);

    expect(router.state.matchedLocation, AppRutas.inicio);
    expect(salio(), isFalse);
  });

  testWidgets('en Inicio, atrás sale de la app', (tester) async {
    escucharPlataforma(tester);
    final (:router, container: _) = await montarCliente(
      tester,
      repositorio: CatalogoRepositorioFijo(catalogoDePrueba()),
      ubicacion: AppRutas.inicio,
    );

    await atras(tester);

    expect(salio(), isTrue);
    expect(router.state.matchedLocation, AppRutas.inicio);
  });

  testWidgets('catálogo → detalle → icono del carrito → atrás vuelve al '
      'detalle, y otra vez atrás al catálogo', (tester) async {
    escucharPlataforma(tester);
    final (:router, container: _) = await montarCliente(
      tester,
      repositorio: CatalogoRepositorioFijo(catalogoDePrueba()),
    );
    await tester.tap(find.text('Cerveza Rubia 630 ml'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Ver carrito'));
    await tester.pumpAndSettle();
    expect(router.state.matchedLocation, AppRutas.carritoDesdeDetalle('p1'));
    expect(find.byType(CarritoScreen), findsOneWidget);

    await atras(tester);

    expect(router.state.matchedLocation, AppRutas.detalleProducto('p1'));
    expect(find.byType(DetalleProductoScreen), findsOneWidget);
    expect(find.text('Cerveza Rubia 630 ml'), findsOneWidget);

    await atras(tester);

    expect(router.state.matchedLocation, AppRutas.catalogo);
    expect(salio(), isFalse);
  });

  testWidgets('un detalle abierto desde Inicio se cierra con atrás y vuelve '
      'a Inicio', (tester) async {
    escucharPlataforma(tester);
    final (:router, container: _) = await montarCliente(
      tester,
      repositorio: CatalogoRepositorioFijo(catalogoDePrueba()),
      ubicacion: AppRutas.inicio,
    );
    final tarjeta = find.text('Cerveza Negra 330 ml');
    await tester.ensureVisible(tarjeta);
    await tester.pumpAndSettle();
    await tester.tap(tarjeta);
    await tester.pumpAndSettle();
    expect(find.byType(DetalleProductoScreen), findsOneWidget);

    await atras(tester);

    expect(router.state.matchedLocation, AppRutas.inicio);
    expect(find.byType(DetalleProductoScreen), findsNothing);
    expect(salio(), isFalse);
  });

  testWidgets('inicio → detalle → icono del carrito → atrás, atrás vuelve a '
      'Inicio', (tester) async {
    escucharPlataforma(tester);
    final (:router, container: _) = await montarCliente(
      tester,
      repositorio: CatalogoRepositorioFijo(catalogoDePrueba()),
      ubicacion: AppRutas.inicio,
    );
    final tarjeta = find.text('Cerveza Negra 330 ml');
    await tester.ensureVisible(tarjeta);
    await tester.pumpAndSettle();
    await tester.tap(tarjeta);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Ver carrito'));
    await tester.pumpAndSettle();
    expect(find.byType(CarritoScreen), findsOneWidget);

    await atras(tester);
    expect(router.state.matchedLocation, AppRutas.detalleProducto('p2'));

    await atras(tester);
    expect(router.state.matchedLocation, AppRutas.inicio);
    expect(find.byType(InicioScreen), findsOneWidget);
    expect(salio(), isFalse);
  });

  testWidgets('un repartidor en perfil sale con atrás', (tester) async {
    escucharPlataforma(tester);
    final repartidor = membresia('d2', rol: RolMembresia.repartidor);
    final router = await montarApp(
      tester,
      control: ControlAccesoFalso(
        ConAcceso(membresias: [repartidor], activa: repartidor),
      ),
    );
    router.go(AppRutas.perfil);
    await tester.pumpAndSettle();

    await atras(tester);

    expect(salio(), isTrue);
    expect(router.state.matchedLocation, AppRutas.perfil);
  });
}
