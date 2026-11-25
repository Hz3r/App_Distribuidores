import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:panel_web/src/config/tema_panel.dart';
import 'package:panel_web/src/features/auth/presentation/auth_screen.dart';
import 'package:panel_web/src/features/sesion/domain/autenticacion.dart';
import 'package:panel_web/src/features/sesion/presentation/control_acceso.dart';

import '../soporte/dobles.dart';

Future<void> montar(WidgetTester tester, AutenticacionDoble autenticacion) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [autenticacionProvider.overrideWithValue(autenticacion)],
      child: MaterialApp(theme: temaPanel(), home: const AuthScreen()),
    ),
  );
}

Finder campo(int indice) => find.byType(TextFormField).at(indice);

void main() {
  testWidgets('con los campos vacíos avisa y no intenta ingresar', (
    tester,
  ) async {
    final autenticacion = AutenticacionDoble();
    await montar(tester, autenticacion);

    await tester.tap(find.text('Ingresar'));
    await tester.pump();

    expect(find.text('Escribe tu correo.'), findsOneWidget);
    expect(find.text('Escribe tu contraseña.'), findsOneWidget);
    expect(autenticacion.ingresos, isEmpty);
  });

  testWidgets('un correo sin @ se rechaza antes de enviar', (tester) async {
    final autenticacion = AutenticacionDoble();
    await montar(tester, autenticacion);

    await tester.enterText(campo(0), 'admin.ejemplo.com');
    await tester.enterText(campo(1), 'secreta');
    await tester.tap(find.text('Ingresar'));
    await tester.pump();

    expect(find.text('Revisa el correo: le falta la @.'), findsOneWidget);
    expect(autenticacion.ingresos, isEmpty);
  });

  testWidgets('envía el correo sin espacios y la contraseña tal cual', (
    tester,
  ) async {
    final autenticacion = AutenticacionDoble();
    await montar(tester, autenticacion);

    await tester.enterText(campo(0), 'admin@ejemplo.com');
    await tester.enterText(campo(1), ' con espacios ');
    await tester.tap(find.text('Ingresar'));
    await tester.pump();

    expect(autenticacion.ingresos, [
      (correo: 'admin@ejemplo.com', contrasena: ' con espacios '),
    ]);
    expect(find.text('Correo o contraseña incorrectos.'), findsNothing);
  });

  testWidgets('credenciales inválidas: lo dice y deja reintentar', (
    tester,
  ) async {
    final autenticacion = AutenticacionDoble(
      resultado: ResultadoIngreso.credencialesInvalidas,
    );
    await montar(tester, autenticacion);

    await tester.enterText(campo(0), 'admin@ejemplo.com');
    await tester.enterText(campo(1), 'mala');
    await tester.tap(find.text('Ingresar'));
    await tester.pump();

    expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);

    await tester.tap(find.text('Ingresar'));
    await tester.pump();
    expect(autenticacion.ingresos, hasLength(2));
  });

  testWidgets('otro fallo muestra el mensaje de conexión', (tester) async {
    final autenticacion = AutenticacionDoble(resultado: ResultadoIngreso.fallo);
    await montar(tester, autenticacion);

    await tester.enterText(campo(0), 'admin@ejemplo.com');
    await tester.enterText(campo(1), 'secreta');
    await tester.tap(find.text('Ingresar'));
    await tester.pump();

    expect(
      find.text(
        'No pudimos iniciar sesión. Revisa tu conexión e inténtalo de nuevo.',
      ),
      findsOneWidget,
    );
  });
}
