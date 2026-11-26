import 'package:app_movil/src/features/sesion/domain/acceso.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dobles.dart';

void main() {
  testWidgets('sin sesión arranca en la bienvenida con sus textos', (
    tester,
  ) async {
    await montarApp(tester, control: ControlAccesoFalso(const SinSesion()));

    expect(find.text('DistriApp'), findsOneWidget);
    expect(find.text('Tu distribuidor · Tu catálogo · Tu pedido'), findsOne);
    expect(find.text('Pide a tu distribuidor en segundos'), findsOneWidget);
    expect(
      find.text(
        'Catálogo, precios mayoristas y seguimiento de tus pedidos, solo con '
        'el código que te dio tu proveedor.',
      ),
      findsOneWidget,
    );
    expect(find.text('Tengo un código de invitación'), findsOneWidget);
    expect(find.text('Ya tengo cuenta · Ingresar'), findsOneWidget);
    expect(
      find.text(
        'No hay directorio público: solo entras con el código de tu '
        'distribuidor.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('"Tengo un código" lleva a la pantalla de código y vuelve', (
    tester,
  ) async {
    await montarApp(tester, control: ControlAccesoFalso(const SinSesion()));

    await tester.tap(find.text('Tengo un código de invitación'));
    await tester.pumpAndSettle();
    expect(find.text('Ingresa tu código'), findsOneWidget);

    await tester.tap(find.byTooltip('Volver'));
    await tester.pumpAndSettle();
    expect(find.text('Pide a tu distribuidor en segundos'), findsOneWidget);
  });

  testWidgets('"Ya tengo cuenta" lleva al ingreso', (tester) async {
    await montarApp(tester, control: ControlAccesoFalso(const SinSesion()));

    await tester.tap(find.text('Ya tengo cuenta · Ingresar'));
    await tester.pumpAndSettle();

    expect(find.text('Ingresa a tu cuenta'), findsOneWidget);
  });
}
