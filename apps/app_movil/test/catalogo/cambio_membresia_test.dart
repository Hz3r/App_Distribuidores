import 'dart:async';

import 'package:app_movil/src/config/rutas.dart';
import 'package:app_movil/src/features/carrito/presentation/carrito_providers.dart';
import 'package:app_movil/src/features/catalogo/domain/catalogo.dart';
import 'package:app_movil/src/features/catalogo/domain/catalogo_repositorio.dart';
import 'package:app_movil/src/features/inicio/domain/pedidos_resumen_repositorio.dart';
import 'package:app_movil/src/features/sesion/domain/acceso.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../inicio/fabricas_pedidos.dart';
import '../registro/dobles.dart';
import '../sesion/acceso_fijo.dart';
import 'fabricas.dart';
import 'montar_cliente.dart';

/// Catálogo por distribuidor: el de `d1` llega al instante; el de `d2`
/// espera a que la prueba complete [d2].
class CatalogoPorDistribuidor implements CatalogoRepositorio {
  final d2 = Completer<Catalogo>();

  @override
  Future<Catalogo> cargar({
    required String distribuidorId,
    required bool esCliente,
  }) => distribuidorId == 'd1' ? Future.value(catalogoDePrueba()) : d2.future;
}

/// Pedidos por distribuidor: los de `d1` llegan al instante (el último es el
/// #1042); los de `d2` esperan a que la prueba complete [d2].
class PedidosPorDistribuidor implements PedidosResumenRepositorio {
  final d2 = Completer<void>();

  final _deD1 = [
    pedido(
      'a',
      numero: 1042,
      estado: EstadoPedido.enCamino,
      total: 100000,
      creadoEn: DateTime.utc(2026, 11, 20, 15),
      items: [linea('p3', cantidad: 10)],
    ),
  ];

  @override
  Future<List<Pedido>> recientes({
    required String distribuidorId,
    required String clienteId,
    required DateTime desde,
  }) async {
    if (distribuidorId == 'd1') return _deD1;
    await d2.future;
    return const [];
  }

  @override
  Future<Pedido?> ultimo({
    required String distribuidorId,
    required String clienteId,
  }) async {
    if (distribuidorId == 'd1') return _deD1.first;
    await d2.future;
    return null;
  }
}

/// Catálogo de `d2`: un solo producto, "Pisco del Sur".
Catalogo catalogoDeD2() => Catalogo(
  distribuidorId: 'd2',
  categorias: const [],
  productos: [
    producto(
      'q1',
      nombre: 'Pisco del Sur',
      categoriaId: null,
      presentaciones: [presentacion('q1-bot', productoId: 'q1')],
    ),
  ],
  preciosLista: const {},
);

void main() {
  final b1 = bodegaDePrueba();
  final b2 = membresia('d2').copyWith(clienteNegocioId: 'cn-d2');

  late ControlAccesoFijo control;

  // Los `Completer` de los dobles se crean dentro de cada prueba: en su zona
  // de tiempo simulado, para que `pump` entregue lo que completan.
  setUp(() {
    control = ControlAccesoFijo(ConAcceso(membresias: [b1, b2], activa: b1));
  });

  /// Pasa a la bodega de `d2` y deja correr unos cuadros sin que llegue su
  /// catálogo.
  Future<void> cambiarAD2(WidgetTester tester) async {
    control.fijar(ConAcceso(membresias: [b1, b2], activa: b2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('catálogo: al cambiar de distribuidor no se ve ni se puede '
      'agregar nada del anterior mientras carga el nuevo', (tester) async {
    final catalogos = CatalogoPorDistribuidor();
    final (router: _, :container) = await montarCliente(
      tester,
      repositorio: catalogos,
      control: control,
    );
    expect(find.text('Cerveza Rubia 630 ml'), findsOneWidget);

    await cambiarAD2(tester);

    expect(find.text('Cerveza Rubia 630 ml'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.widgetWithIcon(IconButton, Icons.add), findsNothing);

    catalogos.d2.complete(catalogoDeD2());
    await tester.pumpAndSettle();

    expect(find.text('Pisco del Sur'), findsOneWidget);
    expect(find.text('Cerveza Rubia 630 ml'), findsNothing);
    expect(container.read(carritoActualProvider).lineas, 0);
  });

  testWidgets('detalle: al cambiar de distribuidor no queda el producto del '
      'anterior ni su botón de agregar', (tester) async {
    final catalogos = CatalogoPorDistribuidor();
    final (router: _, :container) = await montarCliente(
      tester,
      repositorio: catalogos,
      control: control,
      ubicacion: AppRutas.detalleProducto('p1'),
    );
    expect(find.text('Cerveza Rubia 630 ml'), findsOneWidget);

    await cambiarAD2(tester);

    expect(find.text('Cerveza Rubia 630 ml'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);

    catalogos.d2.complete(catalogoDeD2());
    await tester.pumpAndSettle();

    expect(find.text('Este producto ya no está disponible.'), findsOneWidget);
    expect(container.read(carritoActualProvider).lineas, 0);
  });

  testWidgets('inicio: al cambiar de distribuidor no se ve el resumen ni los '
      'productos del anterior', (tester) async {
    final catalogos = CatalogoPorDistribuidor();
    final pedidos = PedidosPorDistribuidor();
    final (router: _, :container) = await montarCliente(
      tester,
      repositorio: catalogos,
      pedidos: pedidos,
      control: control,
      ubicacion: AppRutas.inicio,
    );
    expect(find.text('#1042'), findsOneWidget);
    expect(find.text('Ron Añejo 750 ml'), findsOneWidget);

    await cambiarAD2(tester);

    expect(find.text('#1042'), findsNothing);
    expect(find.text('Ron Añejo 750 ml'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.widgetWithIcon(IconButton, Icons.add), findsNothing);

    // Llega el catálogo de d2 pero no su resumen: el del anterior no vuelve.
    catalogos.d2.complete(catalogoDeD2());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('#1042'), findsNothing);
    expect(find.text('Comprado este mes'), findsNothing);

    pedidos.d2.complete();
    await tester.pumpAndSettle();

    expect(find.text('Aún no tienes pedidos'), findsOneWidget);
    expect(find.text('Pisco del Sur'), findsOneWidget);
    expect(find.text('#1042'), findsNothing);
    expect(container.read(carritoActualProvider).lineas, 0);
  });

  testWidgets('tras cerrar sesión e ingresar con otra cuenta no se ve el '
      'catálogo de la anterior', (tester) async {
    final catalogos = CatalogoPorDistribuidor();
    final (:router, :container) = await montarCliente(
      tester,
      repositorio: catalogos,
      control: control,
    );
    expect(find.text('Cerveza Rubia 630 ml'), findsOneWidget);

    control.fijar(const SinSesion());
    await tester.pumpAndSettle();
    control.fijar(ConAcceso(membresias: [b2], activa: b2));
    await tester.pump();
    router.go(AppRutas.catalogo);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(router.state.matchedLocation, AppRutas.catalogo);
    expect(find.text('Cerveza Rubia 630 ml'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    catalogos.d2.complete(catalogoDeD2());
    await tester.pumpAndSettle();

    expect(find.text('Pisco del Sur'), findsOneWidget);
    expect(container.read(carritoActualProvider).lineas, 0);
  });
}
