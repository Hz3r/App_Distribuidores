import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:panel_web/src/features/dashboard/presentation/dashboard_screen.dart';

import '../soporte/dobles.dart';
import '../soporte/dobles_clientes.dart';
import '../soporte/dobles_pedidos.dart';
import '../soporte/montar.dart';

ClientesDoble clientesDemo() => ClientesDoble(
  clientes: [
    cliente('c1', nombre: 'Bodega El Roble'),
    cliente('c2', nombre: 'Licorería La Esquina'),
    cliente('c3', nombre: 'Tienda Vieja', activo: false),
  ],
);

CatalogoDoble catalogoDemo() => CatalogoDoble(
  productos: [
    producto('p1', nombre: 'Cerveza Lager', fisico: 600),
    producto('p2', nombre: 'Vodka', fisico: 50, comprometido: 50),
    producto('p3', nombre: 'Ron Añejo', fisico: 100, comprometido: 90),
    // Oculto a clientes: no se avisa que se acabó.
    producto('p4', nombre: 'Descontinuado', fisico: 0, activo: false),
  ],
);

PedidosDoble pedidosDemo() => PedidosDoble(
  pedidos: [
    pedido('a', numero: 12, total: 15000),
    pedido(
      'b',
      numero: 11,
      clienteId: 'c2',
      estado: EstadoPedido.entregado,
      total: 5000,
      creadoEn: ahoraDePrueba.subtract(const Duration(hours: 3)),
    ),
    // Hace 40 días: entra en la comparación con el mes anterior.
    pedido(
      'c',
      numero: 3,
      estado: EstadoPedido.entregado,
      total: 10000,
      creadoEn: ahoraDePrueba.subtract(const Duration(days: 40)),
    ),
  ],
);

Future<PedidosDoble> montar(
  WidgetTester tester, {
  PedidosDoble? pedidos,
  CatalogoDoble? catalogo,
  Size tamano = const Size(1440, 1000),
}) async {
  final doble = pedidos ?? pedidosDemo();
  await montarSeccion(
    tester,
    const DashboardScreen(),
    pedidos: doble,
    clientes: clientesDemo(),
    catalogo: catalogo ?? catalogoDemo(),
    tamano: tamano,
  );
  return doble;
}

void main() {
  testWidgets('muestra los cuatro indicadores con su explicación', (
    tester,
  ) async {
    final pedidos = await montar(tester);

    // Pide los pedidos desde el día 1 del mes anterior.
    final desde = pedidos.ultimoDesde!;
    expect((desde.year, desde.month, desde.day), (2026, 10, 1));

    expect(find.text('Ventas de noviembre'), findsOneWidget);
    expect(find.text('S/ 200.00'), findsWidgets);
    expect(
      find.text('100% más que en los mismos días de octubre.'),
      findsOneWidget,
    );
    expect(find.text('Pedidos por confirmar'), findsOneWidget);
    expect(find.text('1 llegó hoy. Toca para atenderlos.'), findsOneWidget);
    // Dos clientes compraron, de dos activos (el inactivo no cuenta).
    expect(find.text('2 de 2'), findsOneWidget);
    expect(find.text('2 pedidos este mes.'), findsOneWidget);
    expect(find.text('Productos agotados'), findsOneWidget);
    expect(find.text('1 más con poca disponibilidad.'), findsOneWidget);
  });

  testWidgets('gráfico de 7 días: rotula solo el día de más venta y cada '
      'barra explica su valor', (tester) async {
    await montar(tester);

    expect(find.text('Ventas de los últimos 7 días'), findsOneWidget);
    for (final dia in ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom']) {
      expect(find.text(dia), findsOneWidget, reason: dia);
    }
    expect(find.byTooltip('mié 25: S/ 200.00 · 2 pedidos'), findsOneWidget);
    expect(find.byTooltip('mar 24: S/ 0.00 · 0 pedidos'), findsOneWidget);
  });

  testWidgets('top de clientes, últimos pedidos y productos que se acaban', (
    tester,
  ) async {
    await montar(tester);

    expect(find.text('Quién compró más en noviembre'), findsOneWidget);
    expect(find.text('Bodega El Roble'), findsOneWidget);
    expect(find.text('S/ 150.00'), findsOneWidget);

    expect(find.text('#12 · Bodega El Roble'), findsOneWidget);
    expect(find.text('#11 · Licorería La Esquina'), findsOneWidget);
    expect(find.text('Por confirmar'), findsOneWidget);

    expect(find.text('Se están acabando'), findsOneWidget);
    expect(find.text('Vodka'), findsOneWidget);
    expect(find.text('Agotado'), findsOneWidget);
    expect(find.text('Quedan 10 botellas'), findsOneWidget);
    expect(find.text('Descontinuado'), findsNothing);
  });

  testWidgets('distribuidor nuevo, sin pedidos: ceros y mensajes en vez de '
      'gráficos vacíos', (tester) async {
    await montar(
      tester,
      pedidos: PedidosDoble(),
      catalogo: CatalogoDoble(productos: [producto('p1', fisico: 100)]),
    );

    expect(find.text('S/ 0.00'), findsOneWidget);
    expect(find.text('Sin ventas en octubre para comparar.'), findsOneWidget);
    expect(find.text('Estás al día.'), findsOneWidget);
    expect(find.text('Todavía no hay ventas en estos 7 días.'), findsOneWidget);
    expect(find.text('Aún no hay ventas este mes.'), findsOneWidget);
    expect(
      find.text('Cuando tus clientes pidan, sus pedidos aparecen aquí.'),
      findsOneWidget,
    );
    expect(
      find.text('Todos tus productos tienen disponibilidad.'),
      findsOneWidget,
    );
  });

  testWidgets('si la lectura falla lo dice y Reintentar vuelve a leer', (
    tester,
  ) async {
    final pedidos = pedidosDemo()..fallarEn = 'listarPedidosDesde';
    await montar(tester, pedidos: pedidos);

    expect(find.text('No pudimos cargar esta sección'), findsOneWidget);

    pedidos.fallarEn = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('Ventas de noviembre'), findsOneWidget);
  });

  testWidgets('en pantalla angosta todo se apila sin desbordarse', (
    tester,
  ) async {
    await montar(tester, tamano: const Size(390, 844));

    expect(find.text('Ventas de noviembre'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Se están acabando'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Se están acabando'), findsOneWidget);
  });
}
