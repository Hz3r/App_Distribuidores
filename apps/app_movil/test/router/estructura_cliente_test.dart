import 'package:app_movil/src/config/rutas.dart';
import 'package:app_movil/src/features/carrito/presentation/carrito_providers.dart';
import 'package:app_movil/src/features/sesion/domain/acceso.dart';
import 'package:app_movil/src/features/sesion/presentation/control_acceso.dart';
import 'package:app_movil/src/router/estructura_cliente.dart';
import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../catalogo/montar_cliente.dart';
import '../registro/dobles.dart';
import '../sesion/acceso_fijo.dart';
import '../soporte/dobles_cliente.dart';

void main() {
  late ProviderContainer container;
  final elegidos = <int>[];

  setUp(() {
    elegidos.clear();
    final bodega = membresia('d1');
    container = ProviderContainer(
      overrides: [
        controlAccesoProvider.overrideWith(
          () => ControlAccesoFijo(
            ConAcceso(membresias: [bodega], activa: bodega),
          ),
        ),
      ],
    );
  });

  tearDown(() => container.dispose());

  Future<void> montar(WidgetTester tester, {int lineas = 0}) async {
    final carrito = container.read(carritoActualProvider.notifier);
    for (var i = 0; i < lineas; i++) {
      carrito.agregar('pr$i', 1, disponible: 10);
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BarraCliente(
              indiceActual: 1,
              alElegir: elegidos.add,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('muestra los cinco destinos', (tester) async {
    await montar(tester);

    for (final texto in [
      'Inicio',
      'Catálogo',
      'Carrito',
      'Pedidos',
      'Perfil',
    ]) {
      expect(find.text(texto), findsOneWidget, reason: texto);
    }
  });

  testWidgets('tocar un destino avisa su índice', (tester) async {
    await montar(tester);

    await tester.tap(find.text('Pedidos'));

    expect(elegidos, [3]);
  });

  testWidgets('con 3 líneas en el carrito la insignia dice 3', (tester) async {
    await montar(tester, lineas: 3);

    expect(find.byType(Badge), findsOneWidget);
    expect(
      find.descendant(of: find.byType(Badge), matching: find.text('3')),
      findsOneWidget,
    );
  });

  testWidgets('con 12 líneas la insignia dice 9+', (tester) async {
    await montar(tester, lineas: 12);

    expect(find.text('9+'), findsOneWidget);
  });

  testWidgets('con el carrito vacío no hay insignia', (tester) async {
    await montar(tester);

    expect(find.byType(Badge), findsNothing);
  });

  testWidgets('la insignia cambia cuando cambia el carrito', (tester) async {
    await montar(tester, lineas: 1);
    expect(find.text('1'), findsOneWidget);

    container
        .read(carritoActualProvider.notifier)
        .agregar('otra', 1, disponible: 5);
    await tester.pump();

    expect(find.text('2'), findsOneWidget);
  });

  group('en el router', () {
    testWidgets('la bodega entra a inicio con la barra y cambia de pestaña', (
      tester,
    ) async {
      final repositorio = CatalogoRepositorioFijo(catalogoDePrueba());
      final (:router, :container) = await montarCliente(
        tester,
        repositorio: repositorio,
        ubicacion: AppRutas.inicio,
      );
      expect(find.byType(NavigationBar), findsOneWidget);

      await tester.tap(find.text('Catálogo'));
      await tester.pumpAndSettle();
      expect(router.state.matchedLocation, AppRutas.catalogo);
      expect(find.text('4 productos'), findsOneWidget);

      await tester.tap(find.text('Pedidos'));
      await tester.pumpAndSettle();
      expect(router.state.matchedLocation, AppRutas.pedidos);
    });

    testWidgets('un repartidor en perfil no ve la barra de la bodega', (
      tester,
    ) async {
      final repartidor = membresia('d2', rol: RolMembresia.repartidor);
      final router = await montarApp(
        tester,
        control: ControlAccesoFalso(
          ConAcceso(membresias: [repartidor], activa: repartidor),
        ),
      );
      expect(router.state.matchedLocation, AppRutas.repartidor);

      router.go(AppRutas.perfil);
      await tester.pumpAndSettle();

      expect(router.state.matchedLocation, AppRutas.perfil);
      expect(find.byType(NavigationBar), findsNothing);
    });
  });
}
