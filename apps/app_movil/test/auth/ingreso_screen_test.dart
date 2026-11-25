import 'dart:async';

import 'package:app_movil/src/config/rutas.dart';
import 'package:app_movil/src/features/registro/domain/cuentas_repositorio.dart';
import 'package:app_movil/src/features/sesion/domain/acceso.dart';
import 'package:app_movil/src/shared/widgets/campo_etiquetado.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../registro/dobles.dart';

Finder campo(String etiqueta) => find.descendant(
  of: find.widgetWithText(CampoEtiquetado, etiqueta),
  matching: find.byType(TextField),
);

final ingresar = find.widgetWithText(FilledButton, 'Ingresar');

Future<GoRouter> abrirIngreso(
  WidgetTester tester, {
  required CuentasRepositorioDoble cuentas,
}) async {
  final router = await montarApp(
    tester,
    control: ControlAccesoFalso(const SinSesion()),
    cuentas: cuentas,
  );
  unawaited(router.push(AppRutas.auth));
  await tester.pumpAndSettle();
  return router;
}

Future<void> llenar(WidgetTester tester) async {
  await tester.enterText(campo('Correo'), ' jose@bodega.pe ');
  await tester.enterText(campo('Contraseña'), 'secreta123');
}

Future<void> tocarIngresar(WidgetTester tester) async {
  await tester.ensureVisible(ingresar);
  await tester.tap(ingresar);
  await tester.pumpAndSettle();
}

void main() {
  late CuentasRepositorioDoble cuentas;

  setUp(() => cuentas = CuentasRepositorioDoble());

  testWidgets('muestra el título y los campos', (tester) async {
    await abrirIngreso(tester, cuentas: cuentas);

    expect(find.text('Ingresa a tu cuenta'), findsOneWidget);
    expect(campo('Correo'), findsOneWidget);
    expect(campo('Contraseña'), findsOneWidget);
    expect(tester.widget<TextField>(campo('Contraseña')).obscureText, isTrue);
  });

  testWidgets('con campos inválidos no ingresa y muestra los mensajes', (
    tester,
  ) async {
    await abrirIngreso(tester, cuentas: cuentas);
    await tester.enterText(campo('Correo'), 'a@b');

    await tocarIngresar(tester);

    expect(cuentas.ingresos, isEmpty);
    expect(find.text('Escribe un correo válido.'), findsOneWidget);
    expect(find.text('Escribe tu contraseña.'), findsOneWidget);
  });

  testWidgets('ingresa con el correo limpio; dos toques llaman una sola '
      'vez', (tester) async {
    cuentas.ingresoPendiente = Completer<ResultadoIngreso>();
    await abrirIngreso(tester, cuentas: cuentas);
    await llenar(tester);

    await tester.ensureVisible(ingresar);
    await tester.tap(ingresar);
    await tester.tap(ingresar);
    await tester.pump();

    expect(cuentas.ingresos, [('jose@bodega.pe', 'secreta123')]);
    expect(tester.widget<FilledButton>(ingresar).onPressed, isNull);

    cuentas.ingresoPendiente!.complete(ResultadoIngreso.error);
    await tester.pumpAndSettle();
    expect(cuentas.ingresos, hasLength(1));
  });

  testWidgets('ok no muestra mensajes ni navega: el router entra solo', (
    tester,
  ) async {
    final router = await abrirIngreso(tester, cuentas: cuentas);
    await llenar(tester);

    await tocarIngresar(tester);

    expect(cuentas.ingresos, hasLength(1));
    expect(router.state.matchedLocation, AppRutas.auth);
    expect(tester.widget<FilledButton>(ingresar).onPressed, isNull);
  });

  group('cada fallo muestra su texto', () {
    final mensajes = {
      ResultadoIngreso.credencialesIncorrectas:
          'Correo o contraseña incorrectos.',
      ResultadoIngreso.correoSinConfirmar:
          'Confirma tu correo antes de ingresar.',
      ResultadoIngreso.sinConexion: 'Revisa tu conexión e inténtalo de nuevo.',
      ResultadoIngreso.error: 'No pudimos ingresar. Inténtalo de nuevo.',
    };
    for (final MapEntry(key: resultado, value: mensaje) in mensajes.entries) {
      testWidgets(resultado.name, (tester) async {
        cuentas.resultadoIngreso = resultado;
        await abrirIngreso(tester, cuentas: cuentas);
        await llenar(tester);

        await tocarIngresar(tester);

        expect(find.text(mensaje), findsOneWidget);
        // Se puede volver a intentar.
        expect(tester.widget<FilledButton>(ingresar).onPressed, isNotNull);
      });
    }
  });

  testWidgets('el enlace lleva a la pantalla de código', (tester) async {
    final router = await abrirIngreso(tester, cuentas: cuentas);

    final enlace = find.text('Tengo un código de invitación');
    await tester.ensureVisible(enlace);
    await tester.tap(enlace);
    await tester.pumpAndSettle();

    expect(router.state.matchedLocation, AppRutas.codigo);
  });
}
