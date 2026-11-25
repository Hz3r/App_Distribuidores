import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:panel_web/src/features/clientes/domain/clientes_repositorio.dart';
import 'package:panel_web/src/features/invitaciones/presentation/invitaciones_screen.dart';

import '../soporte/dobles_clientes.dart';
import '../soporte/montar.dart';

ClientesDoble clientesDemo() => ClientesDoble(
  clientes: [
    cliente('c1', nombre: 'Bodega El Roble'),
    cliente('c2', nombre: 'Licorería La Esquina'),
    cliente('c3', nombre: 'Tienda Vieja', activo: false),
  ],
  invitaciones: [
    invitacion('v', clienteId: 'c2', codigo: 'DEMA2345'),
    invitacion('u', clienteId: 'c1', codigo: 'USAD2222', usada: true),
    invitacion(
      'x',
      clienteId: 'c1',
      codigo: 'VENC3333',
      venceEn: ahoraDePrueba.subtract(const Duration(days: 3)),
    ),
    invitacion('r', clienteId: 'c3', codigo: 'ANUL4444', revocada: true),
  ],
);

/// Captura lo que la pantalla copia al portapapeles.
List<String> escucharPortapapeles(WidgetTester tester) {
  final copiados = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (llamada) async {
      if (llamada.method == 'Clipboard.setData') {
        copiados.add((llamada.arguments as Map)['text'] as String);
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return copiados;
}

void main() {
  testWidgets('lista los códigos con su cliente, su vencimiento y su estado', (
    tester,
  ) async {
    await montarSeccion(
      tester,
      const InvitacionesScreen(),
      clientes: clientesDemo(),
    );

    expect(find.text('DEMA2345'), findsOneWidget);
    expect(find.text('Licorería La Esquina'), findsOneWidget);
    // Tres de los cuatro vencen el mismo día; el vencido, antes.
    expect(find.text('2 dic 2026'), findsNWidgets(3));
    expect(find.text('22 nov 2026'), findsOneWidget);
    expect(find.text('Vigente'), findsOneWidget);
    expect(find.text('Usada'), findsOneWidget);
    expect(find.text('Vencida'), findsOneWidget);
    expect(find.text('Anulada'), findsOneWidget);
    expect(find.text('Todas (4)'), findsOneWidget);
    expect(find.text('Vigentes (1)'), findsOneWidget);
    // Solo el código vigente se puede anular.
    expect(find.text('Anular'), findsOneWidget);
  });

  testWidgets('filtrar por estado; un estado sin códigos deja volver a '
      'todas', (tester) async {
    final clientes = clientesDemo()
      ..invitaciones = [invitacion('v', clienteId: 'c2', codigo: 'DEMA2345')];
    await montarSeccion(tester, const InvitacionesScreen(), clientes: clientes);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Usadas (0)'));
    await tester.pump();
    expect(find.text('No hay códigos en este estado'), findsOneWidget);

    await tester.tap(find.text('Ver todas'));
    await tester.pump();
    expect(find.text('DEMA2345'), findsOneWidget);
  });

  testWidgets('copiar deja el código en el portapapeles y avisa', (
    tester,
  ) async {
    final copiados = escucharPortapapeles(tester);
    await montarSeccion(
      tester,
      const InvitacionesScreen(),
      clientes: clientesDemo(),
    );

    await tester.tap(find.byTooltip('Copiar código DEMA2345'));
    await tester.pump();

    expect(copiados, ['DEMA2345']);
    expect(find.text('Código copiado.'), findsOneWidget);
  });

  testWidgets('anular pide confirmación; conservar no hace nada', (
    tester,
  ) async {
    final clientes = clientesDemo();
    await montarSeccion(tester, const InvitacionesScreen(), clientes: clientes);

    await tester.tap(find.text('Anular'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('El código DEMA2345 de Licorería La Esquina'),
      findsOneWidget,
    );

    await tester.tap(find.text('Conservar código'));
    await tester.pumpAndSettle();
    expect(clientes.llamadas, isEmpty);

    await tester.tap(find.text('Anular'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Anular código'));
    await tester.pumpAndSettle();

    expect(clientes.llamadas, ['revocarInvitacion v']);
    expect(clientes.lecturasInvitaciones, 2);
    expect(find.text('Código anulado.'), findsOneWidget);
  });

  testWidgets('si el código ya fue usado, anular lo explica', (tester) async {
    final clientes = clientesDemo()
      ..fallarEn = 'revocarInvitacion'
      ..motivo = MotivoErrorClientes.invitacionUsada;
    await montarSeccion(tester, const InvitacionesScreen(), clientes: clientes);

    await tester.tap(find.text('Anular'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Anular código'));
    await tester.pumpAndSettle();

    expect(
      find.text('Ese código ya fue usado, así que no se puede anular.'),
      findsOneWidget,
    );
  });

  testWidgets('nueva invitación: exige elegir cliente, ofrece solo los '
      'activos y genera el código con la vigencia elegida', (tester) async {
    final copiados = escucharPortapapeles(tester);
    final clientes = clientesDemo();
    await montarSeccion(tester, const InvitacionesScreen(), clientes: clientes);

    await tester.tap(find.text('Nueva invitación'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Generar código'));
    await tester.pump();
    expect(find.text('Elige un cliente.'), findsOneWidget);
    expect(clientes.llamadas, isEmpty);

    await tester.tap(
      find.widgetWithText(DropdownButtonFormField<String>, 'Cliente'),
    );
    await tester.pumpAndSettle();
    // "Tienda Vieja" sigue en la tabla de atrás, pero no entre las opciones.
    expect(
      find.descendant(
        of: find.byType(DropdownMenuItem<String>),
        matching: find.text('Tienda Vieja'),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byType(DropdownMenuItem<String>),
        matching: find.text('Licorería La Esquina'),
      ),
      findsWidgets,
    );
    await tester.tap(find.text('Bodega El Roble').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('7 días'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15 días').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Generar código'));
    await tester.pumpAndSettle();

    expect(clientes.llamadas, ['crearInvitacion d1 c1 15d']);
    // En el diálogo y, ya releída, en la tabla de atrás.
    expect(find.text('ABCD2345'), findsNWidgets(2));

    await tester.tap(find.text('Copiar mensaje para WhatsApp'));
    await tester.pump();
    expect(copiados.single, contains('ABCD2345'));
    expect(copiados.single, contains('Distribuidor d1'));
    expect(copiados.single, contains('Vence el 10 dic 2026'));
  });

  testWidgets('sin códigos y sin clientes manda primero a registrar '
      'clientes', (tester) async {
    await montarSeccion(
      tester,
      const InvitacionesScreen(),
      clientes: ClientesDoble(),
    );

    expect(find.text('Aún no generaste códigos'), findsOneWidget);
    expect(
      find.text('Primero registra a tus clientes en la sección Clientes.'),
      findsOneWidget,
    );
    expect(find.text('Nueva invitación'), findsNothing);
  });
}
