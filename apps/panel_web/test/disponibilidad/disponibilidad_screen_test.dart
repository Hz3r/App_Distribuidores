import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:panel_web/src/features/disponibilidad/presentation/disponibilidad_screen.dart';
import 'package:panel_web/src/features/productos/domain/catalogo_repositorio.dart';

import '../soporte/dobles.dart';
import '../soporte/montar.dart';

CatalogoDoble catalogoDemo() => CatalogoDoble(
  productos: [
    producto('p1', nombre: 'Cerveza Lager', fisico: 200, comprometido: 100),
    producto('p2', nombre: 'Ron Añejo', fisico: 100, comprometido: 90),
    producto('p3', nombre: 'Vodka', fisico: 50, comprometido: 50),
  ],
);

Future<void> abrirDialogo(WidgetTester tester, {int fila = 0}) async {
  await tester.tap(find.text('Actualizar').at(fila));
  await tester.pumpAndSettle();
}

Finder get campoTotal =>
    find.widgetWithText(TextFormField, 'Cuánto tienes ahora en total');

void main() {
  testWidgets('muestra lo ofrecido, lo reservado y lo disponible, y cuenta '
      'los niveles', (tester) async {
    await montarSeccion(
      tester,
      const DisponibilidadScreen(),
      catalogo: catalogoDemo(),
    );

    expect(find.text('Cerveza Lager'), findsOneWidget);
    expect(find.text('Todos (3)'), findsOneWidget);
    expect(find.text('Poca disponibilidad (1)'), findsOneWidget);
    expect(find.text('Agotados (1)'), findsOneWidget);
    // Vodka: 50 ofrecidas, 50 reservadas, 0 disponibles.
    expect(find.text('Agotado'), findsOneWidget);
  });

  testWidgets('el filtro Agotados deja solo los agotados', (tester) async {
    await montarSeccion(
      tester,
      const DisponibilidadScreen(),
      catalogo: catalogoDemo(),
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'Agotados (1)'));
    await tester.pump();

    expect(find.text('Vodka'), findsOneWidget);
    expect(find.text('Cerveza Lager'), findsNothing);
  });

  testWidgets('subir la cantidad registra un ingreso por la diferencia', (
    tester,
  ) async {
    final catalogo = catalogoDemo();
    await montarSeccion(
      tester,
      const DisponibilidadScreen(),
      catalogo: catalogo,
    );
    await abrirDialogo(tester);

    expect(
      find.text('Hoy ofreces 200 botellas; hay 100 en pedidos sin entregar.'),
      findsOneWidget,
    );

    await tester.enterText(campoTotal, '260');
    await tester.pump();
    expect(
      find.text('Sumas 60 botellas. Quedarán 160 para pedir.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Guardar cantidad'));
    await tester.pumpAndSettle();

    expect(catalogo.llamadas, ['registrarMovimiento p1 ingreso 60 null']);
    expect(catalogo.lecturasProductos, 2);
    expect(
      find.text('Disponibilidad de Cerveza Lager actualizada.'),
      findsOneWidget,
    );
  });

  testWidgets('bajarla registra un ajuste negativo con la nota', (
    tester,
  ) async {
    final catalogo = catalogoDemo();
    await montarSeccion(
      tester,
      const DisponibilidadScreen(),
      catalogo: catalogo,
    );
    await abrirDialogo(tester);

    await tester.enterText(campoTotal, '150');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nota (opcional)'),
      ' merma ',
    );
    await tester.tap(find.text('Guardar cantidad'));
    await tester.pumpAndSettle();

    expect(catalogo.llamadas, ['registrarMovimiento p1 ajuste -50 merma']);
  });

  testWidgets('no deja bajar de lo reservado ni guardar sin cambio', (
    tester,
  ) async {
    final catalogo = catalogoDemo();
    await montarSeccion(
      tester,
      const DisponibilidadScreen(),
      catalogo: catalogo,
    );
    await abrirDialogo(tester);

    await tester.tap(find.text('Guardar cantidad'));
    await tester.pump();
    expect(find.text('Es la cantidad que ya tienes.'), findsOneWidget);

    await tester.enterText(campoTotal, '99');
    await tester.tap(find.text('Guardar cantidad'));
    await tester.pump();
    expect(
      find.text('Mínimo 100: ya está reservado en pedidos.'),
      findsOneWidget,
    );
    expect(catalogo.llamadas, isEmpty);
  });

  testWidgets('si la base de datos lo rechaza, explica y deja el diálogo '
      'abierto', (tester) async {
    final catalogo = catalogoDemo()
      ..fallarEn = 'registrarMovimiento'
      ..motivo = MotivoErrorCatalogo.stockBajoReservado;
    await montarSeccion(
      tester,
      const DisponibilidadScreen(),
      catalogo: catalogo,
    );
    await abrirDialogo(tester);

    await tester.enterText(campoTotal, '120');
    await tester.tap(find.text('Guardar cantidad'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'No puedes dejar menos de lo que ya está reservado en pedidos.',
      ),
      findsOneWidget,
    );
    expect(find.text('Actualizar disponibilidad'), findsOneWidget);
  });

  testWidgets('el vendedor ve las cantidades pero no puede actualizarlas', (
    tester,
  ) async {
    await montarSeccion(
      tester,
      const DisponibilidadScreen(),
      catalogo: catalogoDemo(),
      rol: RolMembresia.vendedor,
    );

    expect(find.text('Cerveza Lager'), findsOneWidget);
    expect(find.text('Actualizar'), findsNothing);
  });
}
