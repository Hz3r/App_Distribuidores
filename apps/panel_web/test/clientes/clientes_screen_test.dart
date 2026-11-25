import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:panel_web/src/features/clientes/domain/clientes_repositorio.dart';
import 'package:panel_web/src/features/clientes/presentation/clientes_screen.dart';

import '../soporte/dobles_clientes.dart';
import '../soporte/montar.dart';

ClientesDoble clientesDemo() => ClientesDoble(
  clientes: [
    cliente(
      'c1',
      nombre: 'Bodega El Roble',
      documento: '20601234567',
      telefono: '987654321',
      direccion: 'Av. Los Olivos 123',
      limiteCentimos: 500000,
      plazoDias: 15,
    ),
    cliente('c2', nombre: 'Licorería La Esquina'),
    cliente('c3', nombre: 'Minimarket Sol'),
    cliente('c4', nombre: 'Tienda Vieja', activo: false),
  ],
  personas: [persona('c1', nombre: 'Rosa Quispe')],
  invitaciones: [invitacion('i2', clienteId: 'c2')],
);

Finder campoCon(String etiqueta) =>
    find.widgetWithText(TextFormField, etiqueta);

void main() {
  testWidgets('lista los clientes con contacto, forma de pago y si ya '
      'entran a la app', (tester) async {
    await montarSeccion(
      tester,
      const ClientesScreen(),
      clientes: clientesDemo(),
    );

    expect(find.text('4 negocios registrados.'), findsOneWidget);
    expect(find.text('Bodega El Roble'), findsOneWidget);
    expect(find.text('RUC 20601234567'), findsOneWidget);
    expect(find.text('Rosa Quispe · 987654321'), findsOneWidget);
    expect(find.text('Crédito S/ 5,000.00'), findsOneWidget);
    expect(find.text('Paga en 15 días'), findsOneWidget);
    expect(find.text('Contado'), findsNWidgets(3));

    expect(find.text('Ya entra'), findsOneWidget);
    expect(find.text('Invitado'), findsOneWidget);
    expect(find.text('Inactivo'), findsOneWidget);
    // "Sin invitar" sale en la fila de Minimarket Sol y en el filtro.
    expect(find.text('Sin invitar'), findsOneWidget);
    expect(find.text('Sin invitar (1)'), findsOneWidget);
  });

  testWidgets('solo se ofrece invitar a quien todavía no entra', (
    tester,
  ) async {
    await montarSeccion(
      tester,
      const ClientesScreen(),
      clientes: clientesDemo(),
    );

    // Minimarket Sol (sin invitar) y La Esquina (ya tiene un código).
    expect(find.text('Invitar'), findsOneWidget);
    expect(find.text('Otro código'), findsOneWidget);
  });

  testWidgets('filtrar por estado y buscar', (tester) async {
    await montarSeccion(
      tester,
      const ClientesScreen(),
      clientes: clientesDemo(),
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'Inactivos (1)'));
    await tester.pump();
    expect(find.text('Tienda Vieja'), findsOneWidget);
    expect(find.text('Bodega El Roble'), findsNothing);

    await tester.enterText(find.byType(TextField), 'roble');
    await tester.pump();
    expect(find.text('Ningún cliente coincide'), findsOneWidget);

    await tester.tap(find.text('Quitar filtros'));
    await tester.pump();
    expect(find.text('Bodega El Roble'), findsOneWidget);
    expect(find.text('Tienda Vieja'), findsOneWidget);
  });

  testWidgets('sin clientes invita a registrar el primero', (tester) async {
    await montarSeccion(
      tester,
      const ClientesScreen(),
      clientes: ClientesDoble(),
    );

    expect(find.text('Aún no tienes clientes'), findsOneWidget);
    expect(find.text('Nuevo cliente'), findsOneWidget);
  });

  testWidgets('si la lectura falla lo dice y Reintentar vuelve a leer', (
    tester,
  ) async {
    final clientes = clientesDemo()..fallarEn = 'listarClientes';
    await montarSeccion(tester, const ClientesScreen(), clientes: clientes);

    expect(find.text('No pudimos cargar esta sección'), findsOneWidget);

    clientes.fallarEn = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('Bodega El Roble'), findsOneWidget);
  });

  testWidgets('crear un cliente con crédito: valida y guarda límite y '
      'plazo', (tester) async {
    final clientes = clientesDemo();
    await montarSeccion(tester, const ClientesScreen(), clientes: clientes);

    await tester.tap(find.text('Nuevo cliente'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Crear cliente'));
    await tester.pump();
    expect(find.text('Escribe el nombre del negocio.'), findsOneWidget);
    expect(clientes.llamadas, isEmpty);

    await tester.enterText(campoCon('Nombre del negocio'), 'Bodega Nueva');
    await tester.enterText(campoCon('RUC o DNI (opcional)'), '1234');
    await tester.tap(find.text('Puede comprar a crédito'));
    await tester.pump();
    await tester.tap(find.text('Crear cliente'));
    await tester.pump();
    expect(find.text('DNI de 8 cifras o RUC de 11.'), findsOneWidget);
    expect(find.text('Escribe un monto mayor a 0.'), findsOneWidget);
    expect(find.text('Mínimo 1 día.'), findsOneWidget);

    await tester.enterText(campoCon('RUC o DNI (opcional)'), '45678901');
    await tester.enterText(campoCon('Tope de deuda'), '1,500');
    await tester.enterText(campoCon('Plazo para pagar'), '7');
    await tester.tap(find.text('Crear cliente'));
    await tester.pumpAndSettle();

    expect(clientes.llamadas, [
      'crearCliente d1 Bodega Nueva doc=45678901 activo=true '
          'credito=150000/7d',
    ]);
    expect(clientes.lecturasClientes, 2);
    expect(find.text('Cliente creado.'), findsOneWidget);
  });

  testWidgets('editar: quitar el crédito y desactivar', (tester) async {
    final clientes = clientesDemo();
    await montarSeccion(tester, const ClientesScreen(), clientes: clientes);

    await tester.tap(find.byTooltip('Editar Bodega El Roble'));
    await tester.pumpAndSettle();
    expect(find.text('Editar cliente'), findsOneWidget);

    await tester.tap(find.text('Puede comprar a crédito'));
    await tester.pump();
    await tester.ensureVisible(find.text('Activo'));
    await tester.tap(find.text('Activo'));
    await tester.pump();
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    expect(clientes.llamadas, [
      'actualizarCliente c1 Bodega El Roble doc=20601234567 activo=false '
          'credito=no',
    ]);
  });

  testWidgets('el vendedor crea clientes pero no toca el crédito', (
    tester,
  ) async {
    final clientes = clientesDemo();
    await montarSeccion(
      tester,
      const ClientesScreen(),
      clientes: clientes,
      rol: RolMembresia.vendedor,
    );

    await tester.tap(find.text('Nuevo cliente'));
    await tester.pumpAndSettle();
    expect(find.text('Puede comprar a crédito'), findsNothing);
    expect(
      find.text('Compra al contado. El crédito lo habilita el administrador.'),
      findsOneWidget,
    );

    await tester.enterText(campoCon('Nombre del negocio'), 'Bodega Nueva');
    await tester.tap(find.text('Crear cliente'));
    await tester.pumpAndSettle();

    expect(clientes.llamadas, [
      'crearCliente d1 Bodega Nueva doc= activo=true credito=no-tocar',
    ]);
  });

  testWidgets('si guardar falla por permiso, lo explica sin cerrar', (
    tester,
  ) async {
    final clientes = clientesDemo()
      ..fallarEn = 'actualizarCliente'
      ..motivo = MotivoErrorClientes.sinPermiso;
    await montarSeccion(tester, const ClientesScreen(), clientes: clientes);

    await tester.tap(find.byTooltip('Editar Minimarket Sol'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Tu cuenta no puede hacer este cambio. Pídeselo al administrador.',
      ),
      findsOneWidget,
    );
    expect(find.text('Editar cliente'), findsOneWidget);
  });

  testWidgets('invitar: genera el código, lo muestra y el cliente pasa a '
      'Invitado', (tester) async {
    final clientes = clientesDemo();
    await montarSeccion(tester, const ClientesScreen(), clientes: clientes);

    await tester.tap(find.text('Invitar'));
    await tester.pumpAndSettle();
    expect(find.text('Invitar a la app'), findsOneWidget);
    // El cliente ya viene elegido.
    expect(find.text('Minimarket Sol'), findsNWidgets(2));

    await tester.tap(find.text('Generar código'));
    await tester.pumpAndSettle();

    expect(clientes.llamadas, ['crearInvitacion d1 c3 7d']);
    expect(find.text('Código generado'), findsOneWidget);
    expect(find.text('ABCD2345'), findsOneWidget);
    expect(
      find.text('Sirve una sola vez · vence el 2 dic 2026'),
      findsOneWidget,
    );

    await tester.tap(find.text('Listo'));
    await tester.pumpAndSettle();

    expect(find.text('Invitado'), findsNWidgets(2));
    expect(find.text('Invitar'), findsNothing);
  });
}
