import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:panel_web/src/config/tema_panel.dart';
import 'package:panel_web/src/features/seleccion_distribuidor/presentation/seleccion_distribuidor_screen.dart';
import 'package:panel_web/src/features/sesion/domain/acceso.dart';
import 'package:panel_web/src/features/sesion/presentation/control_acceso.dart';
import 'package:panel_web/src/features/sesion/presentation/error_acceso_screen.dart';
import 'package:panel_web/src/shared/widgets/sin_acceso_screen.dart';

import '../soporte/dobles.dart';

Future<void> montar(WidgetTester tester, ControlAcceso control, Widget home) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [controlAccesoProvider.overrideWith(() => control)],
      child: MaterialApp(theme: temaPanel(), home: home),
    ),
  );
}

void main() {
  group('SinAccesoScreen', () {
    testWidgets('Reintentar recarga y Cerrar sesión cierra', (tester) async {
      final control = ControlAccesoFalso(
        const ConAcceso(membresias: <Membresia>[], activa: null),
      );
      await montar(tester, control, const SinAccesoScreen());

      expect(find.text('Sin acceso al panel'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      await tester.pump();
      expect(control.recargas, 1);

      await tester.tap(find.text('Cerrar sesión'));
      await tester.pump();
      expect(control.cierres, 1);
    });

    testWidgets('si cerrar sesión falla lo avisa', (tester) async {
      final control = ControlAccesoFalso(
        const ConAcceso(membresias: <Membresia>[], activa: null),
        cierreOk: false,
      );
      await montar(tester, control, const SinAccesoScreen());

      await tester.tap(find.text('Cerrar sesión'));
      await tester.pump();

      expect(
        find.text('No pudimos cerrar tu sesión. Inténtalo de nuevo.'),
        findsOneWidget,
      );
    });
  });

  testWidgets('ErrorAccesoScreen muestra el mensaje y deja reintentar', (
    tester,
  ) async {
    final control = ControlAccesoFalso(const ErrorAcceso('Falló.'));
    await montar(tester, control, const ErrorAccesoScreen());

    expect(find.text('Falló.'), findsOneWidget);
    await tester.tap(find.text('Reintentar'));
    await tester.pump();

    expect(control.recargas, 1);
  });

  testWidgets('SeleccionDistribuidorScreen lista los distribuidores con su '
      'rol y elige el que se toca', (tester) async {
    final control = ControlAccesoFalso(
      ConAcceso(
        membresias: [
          membresia('d1'),
          membresia('d2', rol: RolMembresia.vendedor),
        ],
        activa: null,
      ),
    );
    await montar(tester, control, const SeleccionDistribuidorScreen());

    expect(find.text('Distribuidor d1'), findsOneWidget);
    expect(find.text('Administrador'), findsOneWidget);
    expect(find.text('Vendedor'), findsOneWidget);

    await tester.tap(find.text('Distribuidor d2'));
    await tester.pump();

    expect(control.elegidos, ['d2']);
  });
}
