import 'package:app_movil/src/features/sesion/domain/acceso.dart';
import 'package:app_movil/src/features/sesion/presentation/control_acceso.dart';
import 'package:app_movil/src/features/sesion/presentation/error_acceso_screen.dart';
import 'package:app_movil/src/shared/widgets/sin_rol_screen.dart';
import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Controlador falso: parte de un acceso fijo y cuenta las llamadas. No toca
/// `Supabase.instance`.
class ControlAccesoFalso extends ControlAcceso {
  ControlAccesoFalso(this.inicial, {this.cierreOk = true});

  final Acceso inicial;
  final bool cierreOk;
  int recargas = 0;
  int cierres = 0;

  @override
  Acceso build() => inicial;

  @override
  Future<void> recargar() async => recargas++;

  @override
  Future<bool> cerrarSesion() async {
    cierres++;
    return cierreOk;
  }
}

Future<void> montar(WidgetTester tester, ControlAcceso control, Widget home) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [controlAccesoProvider.overrideWith(() => control)],
      child: MaterialApp(home: home),
    ),
  );
}

void main() {
  group('SinRolScreen', () {
    testWidgets('muestra el texto; Reintentar recarga y Cerrar sesión cierra', (
      tester,
    ) async {
      final control = ControlAccesoFalso(
        const ConAcceso(membresias: <Membresia>[], activa: null),
      );
      await montar(tester, control, const SinRolScreen());

      expect(find.text('Sin acceso en la app'), findsOneWidget);
      expect(
        find.text(
          'No tienes acceso activo en la app móvil. Si administras o vendes, '
          'usa el panel web. Si eres cliente o repartidor, pide a tu '
          'distribuidor un código de invitación o que revise tu cuenta.',
        ),
        findsOneWidget,
      );

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
      await montar(tester, control, const SinRolScreen());

      await tester.tap(find.text('Cerrar sesión'));
      await tester.pump();

      expect(
        find.text('No pudimos cerrar tu sesión. Inténtalo de nuevo.'),
        findsOneWidget,
      );
    });
  });

  testWidgets('ErrorAccesoScreen: Cerrar sesión usa el control de acceso', (
    tester,
  ) async {
    final control = ControlAccesoFalso(const ErrorAcceso('Falló.'));
    await montar(tester, control, const ErrorAccesoScreen());

    expect(find.text('Falló.'), findsOneWidget);
    await tester.tap(find.text('Cerrar sesión'));
    await tester.pump();

    expect(control.cierres, 1);
  });
}
