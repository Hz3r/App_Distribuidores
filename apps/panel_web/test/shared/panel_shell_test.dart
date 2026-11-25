import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:panel_web/src/config/rutas.dart';
import 'package:panel_web/src/config/tema_panel.dart';
import 'package:panel_web/src/features/sesion/domain/acceso.dart';
import 'package:panel_web/src/features/sesion/presentation/control_acceso.dart';
import 'package:panel_web/src/shared/widgets/panel_shell.dart';

import '../soporte/dobles.dart';

Future<ControlAccesoFalso> montar(
  WidgetTester tester,
  Acceso acceso, {
  Size tamano = const Size(1440, 900),
  String ubicacion = AppRutas.pedidos,
}) async {
  tester.view.physicalSize = tamano;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final control = ControlAccesoFalso(acceso);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        controlAccesoProvider.overrideWith(() => control),
        autenticacionProvider.overrideWithValue(AutenticacionDoble()),
      ],
      child: MaterialApp(
        theme: temaPanel(),
        home: PanelShell(
          ubicacion: ubicacion,
          child: const Text('contenido de la sección'),
        ),
      ),
    ),
  );
  return control;
}

void main() {
  testWidgets('el admin ve las 8 secciones, su distribuidor y su cuenta', (
    tester,
  ) async {
    await montar(tester, accesoCon(membresia('d1')));

    for (final etiqueta in [
      'Dashboard',
      'Productos',
      'Disponibilidad',
      'Clientes',
      'Invitaciones',
      'Pedidos',
      'Reportes',
      'Configuración',
    ]) {
      expect(find.text(etiqueta), findsOneWidget, reason: etiqueta);
    }
    expect(find.text('Distribuidor d1'), findsOneWidget);
    expect(find.text('Activo'), findsOneWidget);
    expect(find.text('admin@ejemplo.com'), findsOneWidget);
    expect(find.text('Administrador'), findsOneWidget);
    expect(find.text('contenido de la sección'), findsOneWidget);
  });

  testWidgets('el vendedor no ve Configuración', (tester) async {
    await montar(
      tester,
      accesoCon(membresia('d1', rol: RolMembresia.vendedor)),
    );

    expect(find.text('Configuración'), findsNothing);
    expect(find.text('Pedidos'), findsOneWidget);
    expect(find.text('Vendedor'), findsOneWidget);
  });

  testWidgets('Cerrar sesión usa el control de acceso', (tester) async {
    final control = await montar(tester, accesoCon(membresia('d1')));

    await tester.tap(find.byTooltip('Cerrar sesión'));
    await tester.pump();

    expect(control.cierres, 1);
  });

  testWidgets('con un solo distribuidor no ofrece cambiarlo', (tester) async {
    await montar(tester, accesoCon(membresia('d1')));

    expect(find.byTooltip('Cambiar de distribuidor'), findsNothing);
  });

  testWidgets('con varios distribuidores ofrece cambiarlo', (tester) async {
    final d1 = membresia('d1');
    await montar(
      tester,
      ConAcceso(membresias: [d1, membresia('d2')], activa: d1),
    );

    expect(find.byTooltip('Cambiar de distribuidor'), findsOneWidget);
  });

  testWidgets('distribuidor suspendido: avisa que no entran pedidos nuevos', (
    tester,
  ) async {
    await montar(
      tester,
      accesoCon(
        membresia('d1', estadoDistribuidor: EstadoDistribuidor.suspendido),
      ),
    );

    expect(
      find.textContaining('tus clientes no pueden hacer pedidos nuevos'),
      findsOneWidget,
    );
  });

  testWidgets('en pantalla angosta el menú va en un cajón', (tester) async {
    await montar(
      tester,
      accesoCon(membresia('d1')),
      tamano: const Size(600, 900),
    );

    // Sin abrir el cajón solo está el nombre del negocio en la barra.
    expect(find.text('Distribuidor d1'), findsOneWidget);
    expect(find.text('Pedidos'), findsNothing);
    expect(find.text('Dashboard'), findsNothing);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Pedidos'), findsOneWidget);
    expect(find.text('Configuración'), findsOneWidget);
  });
}
