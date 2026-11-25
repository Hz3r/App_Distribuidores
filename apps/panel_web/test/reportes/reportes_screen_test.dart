import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:panel_web/src/features/reportes/domain/periodo.dart';
import 'package:panel_web/src/features/reportes/presentation/reportes_screen.dart';

import '../soporte/dobles.dart';
import '../soporte/dobles_clientes.dart';
import '../soporte/dobles_pedidos.dart';
import '../soporte/dobles_reportes.dart';
import '../soporte/montar.dart';

PedidoItem linea(
  String productoId,
  String nombre, {
  required int cantidad,
  required int factor,
  required int subtotal,
}) {
  return PedidoItem(
    id: 'i-$productoId-$cantidad',
    distribuidorId: 'd1',
    pedidoId: 'x',
    presentacionId: 'pr-$productoId',
    productoId: productoId,
    nombreProducto: nombre,
    nombrePresentacion: factor == 1 ? 'Botella' : 'Caja x$factor',
    factor: factor,
    cantidad: cantidad,
    precioUnitarioCentimos: subtotal ~/ cantidad,
    subtotalCentimos: subtotal,
    creadoEn: ahoraDePrueba,
  );
}

/// Tres pedidos de este mes: dos ventas (S/ 150 y S/ 90) y un cancelado.
PedidosDoble pedidosDemo() => PedidosDoble(
  pedidos: [
    pedido(
      'c',
      numero: 1043,
      estado: EstadoPedido.cancelado,
      total: 99900,
      items: [
        linea('p1', 'Cerveza Lager', cantidad: 9, factor: 12, subtotal: 99900),
      ],
    ),
    pedido(
      'b',
      numero: 1042,
      clienteId: 'c2',
      estado: EstadoPedido.entregado,
      total: 9000,
      saldo: 0,
      items: [
        linea('p1', 'Cerveza Lager', cantidad: 6, factor: 1, subtotal: 3000),
        linea('p3', 'Hielo', cantidad: 3, factor: 1, subtotal: 6000),
      ],
    ),
    pedido(
      'a',
      numero: 1041,
      total: 15000,
      saldo: 5000,
      items: [
        linea('p1', 'Cerveza Lager', cantidad: 2, factor: 12, subtotal: 10000),
        linea('p2', 'Cerveza Negra', cantidad: 5, factor: 1, subtotal: 5000),
      ],
    ),
  ],
);

Future<(PedidosDoble, ExportadorDoble)> montar(
  WidgetTester tester, {
  PedidosDoble? pedidos,
  Size tamano = const Size(1280, 900),
}) async {
  final doble = pedidos ?? pedidosDemo();
  final exportador = ExportadorDoble();
  await montarSeccion(
    tester,
    const ReportesScreen(),
    pedidos: doble,
    exportador: exportador,
    clientes: ClientesDoble(
      clientes: [
        cliente('c1', nombre: 'Bodega El Roble'),
        cliente('c2', nombre: 'Licorería La Esquina'),
      ],
    ),
    catalogo: CatalogoDoble(
      productos: [
        producto('p1', nombre: 'Cerveza Lager', categoriaId: 'cat1'),
        producto('p2', nombre: 'Cerveza Negra', categoriaId: 'cat1'),
        producto('p3', nombre: 'Hielo', unidadBase: 'bolsa'),
      ],
      categorias: [categoria('cat1', 'Cervezas')],
    ),
    tamano: tamano,
  );
  return (doble, exportador);
}

void main() {
  final esteMes = periodoRapido(PeriodoRapido.esteMes, ahoraDePrueba);

  testWidgets('abre en "Este mes" con los indicadores y el desglose por '
      'producto', (tester) async {
    final (pedidos, _) = await montar(tester);

    expect(pedidos.ultimoRango, (esteMes.desde, esteMes.hasta));
    expect(find.text('Ventas del ${esteMes.descripcion}.'), findsOneWidget);
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Este mes'))
          .selected,
      isTrue,
    );

    expect(find.text('S/ 240.00'), findsOneWidget);
    expect(find.text('Falta cobrar S/ 50.00.'), findsOneWidget);
    expect(find.text('1 cancelado, que no cuenta.'), findsOneWidget);
    expect(find.text('S/ 120.00'), findsOneWidget);
    expect(find.text('Con al menos un pedido.'), findsOneWidget);

    expect(find.text('PRODUCTO'), findsOneWidget);
    expect(find.text('UNIDADES'), findsOneWidget);
    expect(find.text('Cerveza Lager'), findsOneWidget);
    expect(find.text('30 botellas'), findsOneWidget);
    expect(find.text('S/ 130.00'), findsOneWidget);
    expect(find.text('54%'), findsOneWidget);
    expect(find.text('3 bolsas'), findsOneWidget);
    expect(find.text('Cerveza Negra'), findsOneWidget);
  });

  testWidgets('cambia el desglose a cliente y a categoría', (tester) async {
    await montar(tester);

    await tester.tap(find.text('Por cliente'));
    await tester.pumpAndSettle();
    expect(find.text('CLIENTE'), findsOneWidget);
    expect(find.text('PEDIDOS'), findsOneWidget);
    expect(find.text('Bodega El Roble'), findsOneWidget);
    expect(find.text('S/ 150.00'), findsOneWidget);
    expect(find.text('63%'), findsOneWidget);
    expect(find.text('Licorería La Esquina'), findsOneWidget);
    expect(find.text('Cerveza Lager'), findsNothing);

    await tester.tap(find.text('Por categoría'));
    await tester.pumpAndSettle();
    expect(find.text('CATEGORÍA'), findsOneWidget);
    expect(find.text('Cervezas'), findsOneWidget);
    expect(find.text('S/ 180.00'), findsOneWidget);
    expect(find.text('Sin categoría'), findsOneWidget);
    expect(find.text('25%'), findsOneWidget);
  });

  testWidgets('otro periodo vuelve a pedir los pedidos; sin ventas lo dice y '
      'no deja exportar', (tester) async {
    final (pedidos, exportador) = await montar(tester);
    final mesPasado = periodoRapido(PeriodoRapido.mesPasado, ahoraDePrueba);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Mes pasado'));
    await tester.pumpAndSettle();

    expect(pedidos.ultimoRango, (mesPasado.desde, mesPasado.hasta));
    expect(find.text('Ventas del ${mesPasado.descripcion}.'), findsOneWidget);
    expect(find.text('Sin ventas en este periodo'), findsOneWidget);
    expect(find.text('S/ 0.00'), findsNWidgets(2));
    expect(find.text('Todo cobrado.'), findsOneWidget);
    expect(find.text('Ninguno cancelado.'), findsOneWidget);

    await tester.tap(find.text('Exportar a Excel'));
    await tester.pumpAndSettle();
    expect(exportador.llamadas, isEmpty);
  });

  testWidgets('exportar manda todos los pedidos del periodo, del más antiguo '
      'al más nuevo, y avisa', (tester) async {
    final (_, exportador) = await montar(tester);

    await tester.tap(find.text('Exportar a Excel'));
    await tester.pumpAndSettle();

    expect(exportador.llamadas, [
      'excel ${esteMes.paraArchivo} pedidos=1041,1042,1043 clientes=2',
    ]);
    expect(find.text('Se descargó el Excel con 3 pedidos.'), findsOneWidget);
  });

  testWidgets('si el Excel no se puede generar, lo dice', (tester) async {
    final (_, exportador) = await montar(tester);
    exportador.fallar = true;

    await tester.tap(find.text('Exportar a Excel'));
    await tester.pumpAndSettle();

    expect(
      find.text('No pudimos generar el Excel. Inténtalo de nuevo.'),
      findsOneWidget,
    );
    // El botón vuelve a quedar disponible.
    exportador.fallar = false;
    await tester.tap(find.text('Exportar a Excel'));
    await tester.pumpAndSettle();
    expect(exportador.llamadas, hasLength(1));
  });

  testWidgets('si falla la lectura ofrece reintentar', (tester) async {
    final pedidos = pedidosDemo()..fallarEn = 'listarPedidosEntre';
    await montar(tester, pedidos: pedidos);

    expect(find.text('No pudimos cargar esta sección'), findsOneWidget);
    expect(find.text('S/ 240.00'), findsNothing);

    pedidos.fallarEn = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('S/ 240.00'), findsOneWidget);
  });

  testWidgets('elegir fechas abre el calendario en español y aplica el '
      'rango', (tester) async {
    final (pedidos, _) = await montar(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Elegir fechas'));
    await tester.pumpAndSettle();
    expect(find.text('Elige el periodo del reporte'), findsOneWidget);
    expect(find.textContaining('noviembre'), findsWidgets);

    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();

    // Mismas fechas, pero ya no es el atajo "Este mes".
    expect(pedidos.ultimoRango, (esteMes.desde, esteMes.hasta));
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Este mes'))
          .selected,
      isFalse,
    );
    expect(
      find.widgetWithText(ChoiceChip, esteMes.descripcion),
      findsOneWidget,
    );
    expect(find.text('S/ 240.00'), findsOneWidget);
  });

  testWidgets('en pantalla angosta no se desborda y oculta la barra', (
    tester,
  ) async {
    await montar(tester, tamano: const Size(480, 800));

    expect(find.text('S/ 240.00'), findsOneWidget);
    expect(find.text('PARTE DEL TOTAL'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
