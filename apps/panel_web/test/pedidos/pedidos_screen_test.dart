import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:panel_web/src/features/pedidos/domain/pedidos_repositorio.dart';
import 'package:panel_web/src/features/pedidos/presentation/pedidos_screen.dart';

import '../soporte/dobles.dart';
import '../soporte/dobles_clientes.dart';
import '../soporte/dobles_pedidos.dart';
import '../soporte/montar.dart';

ClientesDoble clientesDemo() => ClientesDoble(
  clientes: [
    cliente(
      'c1',
      nombre: 'Bodega El Roble',
      telefono: '987654321',
      limiteCentimos: 500000,
      plazoDias: 15,
    ),
    cliente('c2', nombre: 'Licorería La Esquina'),
    cliente('c3', nombre: 'Tienda Vieja', activo: false),
  ],
);

CatalogoDoble catalogoDemo() => CatalogoDoble(
  productos: [
    producto(
      'p1',
      nombre: 'Cerveza Lager',
      fisico: 120,
      presentaciones: [
        presentacion('bot', nombre: 'Botella', precio: 450),
        presentacion('caja', nombre: 'Caja x12', factor: 12, precio: 5000),
      ],
    ),
    producto(
      'p2',
      nombre: 'Ron Oculto',
      activo: false,
      presentaciones: [presentacion('ron', productoId: 'p2')],
    ),
  ],
);

PedidosDoble pedidosDemo() => PedidosDoble(
  pedidos: [
    pedido('a', numero: 1043, nota: 'Tocar el timbre'),
    pedido(
      'b',
      numero: 1042,
      clienteId: 'c2',
      estado: EstadoPedido.confirmado,
      total: 20000,
    ),
    pedido(
      'c',
      numero: 1041,
      estado: EstadoPedido.entregado,
      condicion: CondicionPago.credito,
      saldo: 6000,
      venceEn: ahoraDePrueba.subtract(const Duration(days: 2)),
    ),
  ],
  pagos: {
    'c': [pago('pg1', pedidoId: 'c')],
  },
);

Future<PedidosDoble> montar(
  WidgetTester tester, {
  PedidosDoble? pedidos,
  RolMembresia rol = RolMembresia.admin,
  Size tamano = const Size(1440, 900),
}) async {
  final doble = pedidos ?? pedidosDemo();
  await montarSeccion(
    tester,
    const PedidosScreen(),
    pedidos: doble,
    clientes: clientesDemo(),
    catalogo: catalogoDemo(),
    rol: rol,
    tamano: tamano,
  );
  return doble;
}

Future<void> abrir(WidgetTester tester, String numero) async {
  await tester.tap(find.text(numero));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('abre en "Por confirmar", con el conteo de cada etapa', (
    tester,
  ) async {
    await montar(tester);

    expect(find.text('Por confirmar (1)'), findsOneWidget);
    expect(find.text('Confirmados (1)'), findsOneWidget);
    expect(find.text('En camino (0)'), findsOneWidget);
    expect(find.text('Entregados (1)'), findsOneWidget);
    expect(find.text('#1043'), findsOneWidget);
    expect(find.text('Bodega El Roble'), findsOneWidget);
    expect(find.text('#1042'), findsNothing);
    expect(find.text('Elige un pedido'), findsOneWidget);
  });

  testWidgets('cambiar de etapa y buscar; una etapa vacía lo dice', (
    tester,
  ) async {
    await montar(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Confirmados (1)'));
    await tester.pump();
    expect(find.text('#1042'), findsOneWidget);
    expect(find.text('Licorería La Esquina'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'roble');
    await tester.pump();
    expect(find.text('Ningún pedido coincide'), findsOneWidget);
    await tester.tap(find.text('Quitar búsqueda'));
    await tester.pump();
    expect(find.text('#1042'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'En camino (0)'));
    await tester.pump();
    expect(find.text('No hay pedidos en camino'), findsOneWidget);
  });

  testWidgets('el detalle muestra cliente, nota, productos, total y cobro', (
    tester,
  ) async {
    await montar(tester);
    await abrir(tester, '#1043');

    expect(find.text('Pedido #1043'), findsOneWidget);
    expect(find.text('Av. Los Olivos 123'), findsOneWidget);
    expect(find.text('Cel. 987654321'), findsOneWidget);
    expect(find.text('Tocar el timbre'), findsOneWidget);
    expect(find.text('Cerveza Lager'), findsOneWidget);
    expect(find.text('2 × Caja x12 a S/ 50.00'), findsOneWidget);
    expect(find.text('Al contado'), findsOneWidget);
    expect(find.text('Cobrado S/ 0.00 · falta S/ 100.00'), findsOneWidget);
    expect(find.text('Confirmar pedido'), findsOneWidget);
    expect(find.text('Rechazar'), findsOneWidget);
  });

  testWidgets('confirmar avanza el pedido, avisa y lo saca de la etapa', (
    tester,
  ) async {
    final pedidos = await montar(tester);
    await abrir(tester, '#1043');

    await tester.tap(find.text('Confirmar pedido'));
    await tester.pumpAndSettle();

    expect(pedidos.llamadas, ['cambiarEstado a confirmado nota=null']);
    expect(find.text('Pedido #1043: confirmado.'), findsOneWidget);
    expect(find.text('Por confirmar (0)'), findsOneWidget);
    expect(find.text('Confirmados (2)'), findsOneWidget);
    // El detalle sigue abierto y ya ofrece el paso siguiente.
    expect(find.text('Marcar en camino'), findsOneWidget);
    expect(find.text('Cancelar pedido'), findsOneWidget);
  });

  testWidgets('rechazar exige un motivo y lo manda como nota', (tester) async {
    final pedidos = await montar(tester);
    await abrir(tester, '#1043');

    await tester.tap(find.text('Rechazar'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Rechazar pedido'));
    await tester.pump();
    expect(find.text('Escribe el motivo.'), findsOneWidget);
    expect(pedidos.llamadas, isEmpty);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Motivo (lo verá tu cliente)'),
      ' Sin stock ',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Rechazar pedido'));
    await tester.pumpAndSettle();

    expect(pedidos.llamadas, ['cambiarEstado a cancelado nota=Sin stock']);
    expect(find.text('Pedido #1043 cancelado.'), findsOneWidget);
    expect(find.text('Motivo de la cancelación'), findsOneWidget);
    expect(
      find.text('Pedido cancelado: no hay nada que cobrar.'),
      findsOneWidget,
    );
    // Un pedido cancelado ya no admite acciones.
    expect(find.text('Confirmar pedido'), findsNothing);
    expect(find.text('Registrar pago'), findsNothing);
  });

  testWidgets('si no se puede cancelar por tener pagos, lo explica en el '
      'diálogo', (tester) async {
    final pedidos = pedidosDemo()
      ..fallarEn = 'cambiarEstado'
      ..motivo = MotivoErrorPedidos.estadoNoPermite;
    await montar(tester, pedidos: pedidos);
    await abrir(tester, '#1043');

    await tester.tap(find.text('Rechazar'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Motivo (lo verá tu cliente)'),
      'Duplicado',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Rechazar pedido'));
    await tester.pumpAndSettle();

    expect(find.textContaining('primero anula sus pagos'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'Rechazar pedido'),
      findsOneWidget,
    );
  });

  testWidgets('pedido a crédito vencido: lo marca y muestra sus pagos', (
    tester,
  ) async {
    await montar(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Entregados (1)'));
    await tester.pump();
    await abrir(tester, '#1041');

    expect(find.text('A crédito: vence el 23 nov 2026'), findsOneWidget);
    expect(find.text('Vencido'), findsOneWidget);
    expect(find.text('Cobrado S/ 40.00 · falta S/ 60.00'), findsOneWidget);
    expect(find.textContaining('Efectivo'), findsOneWidget);
    // Entregado: ya no avanza ni se cancela, pero se sigue cobrando.
    expect(find.text('Marcar entregado'), findsNothing);
    expect(find.text('Cancelar pedido'), findsNothing);
    expect(find.text('Registrar pago'), findsOneWidget);
  });

  testWidgets('registrar pago: propone el saldo, no deja pasarse y guarda', (
    tester,
  ) async {
    final pedidos = await montar(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Entregados (1)'));
    await tester.pump();
    await abrir(tester, '#1041');

    await tester.tap(find.text('Registrar pago'));
    await tester.pumpAndSettle();
    expect(
      find.text('Pedido #1041. Falta cobrar S/ 60.00 de S/ 100.00.'),
      findsOneWidget,
    );
    final monto = find.widgetWithText(TextFormField, 'Monto recibido');
    expect(
      find.descendant(of: monto, matching: find.text('60.00')),
      findsOneWidget,
    );

    await tester.enterText(monto, '60.01');
    await tester.tap(find.widgetWithText(FilledButton, 'Registrar pago'));
    await tester.pump();
    expect(find.text('Máximo S/ 60.00: es lo que falta.'), findsOneWidget);
    expect(pedidos.llamadas, isEmpty);

    await tester.enterText(monto, '25,50');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'N.º de operación (opcional)'),
      'YAPE-123',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Registrar pago'));
    await tester.pumpAndSettle();

    expect(pedidos.llamadas, ['registrarPago c 2550 efectivo ref=YAPE-123']);
    expect(find.text('Pago registrado.'), findsOneWidget);
  });

  testWidgets('anular un pago pide motivo; el vendedor no puede anular', (
    tester,
  ) async {
    final pedidos = await montar(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Entregados (1)'));
    await tester.pump();
    await abrir(tester, '#1041');

    await tester.tap(find.byTooltip('Anular pago de S/ 40.00'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Motivo'),
      'Monto equivocado',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Anular pago'));
    await tester.pumpAndSettle();

    expect(pedidos.llamadas, ['anularPago pg1 Monto equivocado']);
    expect(find.text('Pago anulado.'), findsOneWidget);
  });

  testWidgets('el vendedor cobra pero no ve el botón de anular pagos', (
    tester,
  ) async {
    await montar(tester, rol: RolMembresia.vendedor);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Entregados (1)'));
    await tester.pump();
    await abrir(tester, '#1041');

    expect(find.text('Registrar pago'), findsOneWidget);
    expect(find.byTooltip('Anular pago de S/ 40.00'), findsNothing);
  });

  testWidgets('nuevo pedido: valida, ofrece solo clientes y productos '
      'activos, estima el total y registra', (tester) async {
    final pedidos = await montar(tester);

    await tester.tap(find.text('Nuevo pedido'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Registrar pedido'));
    await tester.pump();
    expect(find.text('Elige un cliente.'), findsOneWidget);
    expect(find.text('Elige un producto.'), findsOneWidget);
    expect(pedidos.llamadas, isEmpty);

    await tester.tap(
      find.widgetWithText(DropdownButtonFormField<String>, 'Cliente'),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(DropdownMenuItem<String>),
        matching: find.text('Tienda Vieja'),
      ),
      findsNothing,
    );
    await tester.tap(find.text('Licorería La Esquina').last);
    await tester.pumpAndSettle();
    expect(find.text('Este cliente no tiene crédito.'), findsOneWidget);

    await tester.tap(
      find.widgetWithText(DropdownButtonFormField<String>, 'Producto 1'),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Ron Oculto'), findsNothing);
    await tester.tap(find.text('Cerveza Lager · Caja x12').last);
    await tester.pumpAndSettle();
    expect(find.text('Disponibles: 10 · S/ 50.00 c/u'), findsOneWidget);

    final cantidad = find.widgetWithText(TextFormField, 'Cantidad');
    await tester.enterText(cantidad, '11');
    await tester.tap(find.text('Registrar pedido'));
    await tester.pump();
    expect(find.text('Solo hay 10.'), findsOneWidget);

    await tester.enterText(cantidad, '3');
    await tester.pump();
    expect(find.text('S/ 150.00'), findsOneWidget);

    await tester.tap(find.text('Registrar pedido'));
    await tester.pumpAndSettle();

    expect(pedidos.llamadas, [
      'crearPedido d1 cliente=c2 cajax3 contado metodo=null nota=',
    ]);
    expect(find.text('Pedido registrado.'), findsOneWidget);
    // Queda elegido el pedido nuevo.
    expect(find.text('Pedido #99'), findsOneWidget);
  });

  testWidgets('nuevo pedido: si la base de datos lo rechaza por crédito, lo '
      'explica sin cerrar', (tester) async {
    final pedidos = pedidosDemo()
      ..fallarEn = 'crearPedido'
      ..motivo = MotivoErrorPedidos.credito;
    await montar(tester, pedidos: pedidos);

    await tester.tap(find.text('Nuevo pedido'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(DropdownButtonFormField<String>, 'Cliente'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bodega El Roble').last);
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(DropdownButtonFormField<String>, 'Producto 1'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cerveza Lager · Botella').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Registrar pedido'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('no puede comprar a crédito ahora'),
      findsOneWidget,
    );
    expect(find.text('Nuevo pedido'), findsWidgets);
  });

  testWidgets('sin pedidos invita a registrar uno', (tester) async {
    await montar(tester, pedidos: PedidosDoble());

    expect(find.text('Aún no tienes pedidos'), findsOneWidget);
    expect(find.text('Nuevo pedido'), findsOneWidget);
  });

  testWidgets('en pantalla angosta el detalle se abre en un diálogo', (
    tester,
  ) async {
    await montar(tester, tamano: const Size(700, 900));

    expect(find.text('Elige un pedido'), findsNothing);
    await abrir(tester, '#1043');

    expect(find.text('Pedido #1043'), findsOneWidget);
    await tester.tap(find.byTooltip('Cerrar detalle'));
    await tester.pumpAndSettle();
    expect(find.text('Pedido #1043'), findsNothing);
  });
}
