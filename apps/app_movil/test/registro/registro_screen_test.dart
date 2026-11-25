import 'dart:async';

import 'package:app_movil/src/config/rutas.dart';
import 'package:app_movil/src/features/registro/domain/argumentos_registro.dart';
import 'package:app_movil/src/features/registro/domain/cuentas_repositorio.dart';
import 'package:app_movil/src/features/registro/domain/invitacion_previa.dart';
import 'package:app_movil/src/features/sesion/domain/acceso.dart';
import 'package:app_movil/src/shared/widgets/campo_etiquetado.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'dobles.dart';

const invitacionConDocumento = InvitacionPrevia(
  distribuidorId: 'd1',
  distribuidorNombre: 'Licores del Norte',
  rol: RolMembresia.cliente,
  negocio: NegocioPrevio(
    nombreNegocio: 'Bodega Don Pepe',
    documento: '20601234567',
    direccion: 'Av. Los Olivos 123, Comas',
    referencia: 'Frente al parque',
  ),
);

const invitacionSinDocumento = InvitacionPrevia(
  distribuidorId: 'd1',
  distribuidorNombre: 'Licores del Norte',
  rol: RolMembresia.cliente,
  negocio: NegocioPrevio(nombreNegocio: 'Bodega Don Pepe'),
);

const invitacionEquipo = InvitacionPrevia(
  distribuidorId: 'd1',
  distribuidorNombre: 'Licores del Norte',
  rol: RolMembresia.repartidor,
);

/// El campo de texto que está bajo la etiqueta [etiqueta].
Finder campo(String etiqueta) => find.descendant(
  of: find.widgetWithText(CampoEtiquetado, etiqueta),
  matching: find.byType(TextField),
);

String textoDe(WidgetTester tester, String etiqueta) =>
    tester.widget<TextField>(campo(etiqueta)).controller!.text;

bool soloLectura(WidgetTester tester, String etiqueta) =>
    tester.widget<TextField>(campo(etiqueta)).readOnly;

final crearCuenta = find.widgetWithText(FilledButton, 'Crear cuenta');
final casilla = find.text('Acepto términos y política de privacidad');

Future<GoRouter> abrirRegistro(
  WidgetTester tester, {
  required CuentasRepositorioDoble cuentas,
  InvitacionPrevia invitacion = invitacionConDocumento,
}) async {
  final router = await montarApp(
    tester,
    control: ControlAccesoFalso(const SinSesion()),
    cuentas: cuentas,
  );
  unawaited(
    router.push(
      AppRutas.registro,
      extra: ArgumentosRegistro(codigo: 'AB2CD3E4', invitacion: invitacion),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

/// Llena los campos obligatorios con valores válidos y marca la casilla.
Future<void> llenarValido(WidgetTester tester) async {
  await tester.enterText(campo('Nombre del encargado'), '  José Ramírez ');
  await tester.enterText(campo('Celular'), '+51 987 654 321');
  await tester.enterText(campo('Correo'), ' jose@bodega.pe ');
  await tester.enterText(campo('Contraseña'), 'secreta123');
  await tester.ensureVisible(casilla);
  await tester.tap(casilla);
  await tester.pumpAndSettle();
}

Future<void> tocarCrear(WidgetTester tester) async {
  await tester.ensureVisible(crearCuenta);
  await tester.tap(crearCuenta);
  await tester.pumpAndSettle();
}

void main() {
  late CuentasRepositorioDoble cuentas;

  setUp(() => cuentas = CuentasRepositorioDoble());

  testWidgets('llega precargado con los datos de la invitación', (
    tester,
  ) async {
    await abrirRegistro(tester, cuentas: cuentas);

    expect(find.text('Crea tu cuenta'), findsOneWidget);
    expect(find.text('Te unes a'), findsOneWidget);
    expect(find.text('Licores del Norte'), findsOneWidget);

    expect(textoDe(tester, 'Nombre del negocio'), 'Bodega Don Pepe');
    expect(soloLectura(tester, 'Nombre del negocio'), isTrue);
    expect(textoDe(tester, 'RUC o DNI'), '20601234567');
    expect(soloLectura(tester, 'RUC o DNI'), isTrue);
    expect(
      textoDe(tester, 'Dirección de entrega'),
      'Av. Los Olivos 123, Comas',
    );
    expect(soloLectura(tester, 'Dirección de entrega'), isFalse);
    expect(textoDe(tester, 'Celular'), '');
    expect(soloLectura(tester, 'Nombre del encargado'), isFalse);
    expect(campo('Correo'), findsOneWidget);
    expect(campo('Contraseña'), findsOneWidget);
  });

  testWidgets('el RUC o DNI es editable si la invitación no lo trae', (
    tester,
  ) async {
    await abrirRegistro(
      tester,
      cuentas: cuentas,
      invitacion: invitacionSinDocumento,
    );

    expect(textoDe(tester, 'RUC o DNI'), '');
    expect(soloLectura(tester, 'RUC o DNI'), isFalse);
    expect(soloLectura(tester, 'Nombre del negocio'), isTrue);
  });

  testWidgets('una invitación de personal oculta los campos de la bodega', (
    tester,
  ) async {
    await abrirRegistro(tester, cuentas: cuentas, invitacion: invitacionEquipo);

    expect(find.text('Licores del Norte'), findsOneWidget);
    for (final etiqueta in [
      'Nombre del negocio',
      'RUC o DNI',
      'Celular',
      'Dirección de entrega',
    ]) {
      expect(campo(etiqueta), findsNothing, reason: etiqueta);
    }
    expect(campo('Tu nombre'), findsOneWidget);
    expect(campo('Correo'), findsOneWidget);
    expect(campo('Contraseña'), findsOneWidget);
  });

  testWidgets('con el teclado abierto el formulario se desplaza hasta el '
      'botón', (tester) async {
    await abrirRegistro(tester, cuentas: cuentas);
    // Un teclado de 300 puntos de alto.
    tester.view.viewInsets = const FakeViewPadding(bottom: 900);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();

    await llenarValido(tester);
    await tocarCrear(tester);

    expect(tester.takeException(), isNull);
    expect(cuentas.creaciones, hasLength(1));
  });

  testWidgets('la contraseña se puede mostrar y ocultar', (tester) async {
    await abrirRegistro(tester, cuentas: cuentas);

    expect(tester.widget<TextField>(campo('Contraseña')).obscureText, isTrue);
    await tester.ensureVisible(find.byTooltip('Mostrar contraseña'));
    await tester.tap(find.byTooltip('Mostrar contraseña'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(campo('Contraseña')).obscureText, isFalse);
    expect(find.byTooltip('Ocultar contraseña'), findsOneWidget);
  });

  testWidgets('con la casilla sin marcar no crea la cuenta y lo avisa', (
    tester,
  ) async {
    await abrirRegistro(tester, cuentas: cuentas);
    await tester.enterText(campo('Nombre del encargado'), 'José Ramírez');
    await tester.enterText(campo('Correo'), 'jose@bodega.pe');
    await tester.enterText(campo('Contraseña'), 'secreta123');

    await tocarCrear(tester);

    expect(cuentas.creaciones, isEmpty);
    expect(
      find.text('Acepta los términos y la política de privacidad.'),
      findsOneWidget,
    );
  });

  testWidgets('con campos inválidos no crea la cuenta y muestra los '
      'mensajes', (tester) async {
    await abrirRegistro(
      tester,
      cuentas: cuentas,
      invitacion: invitacionSinDocumento,
    );
    await tester.enterText(campo('RUC o DNI'), '123');
    await tester.enterText(campo('Celular'), '12345');
    await tester.enterText(campo('Correo'), 'a@b');
    await tester.enterText(campo('Contraseña'), '1234567');
    await tester.ensureVisible(casilla);
    await tester.tap(casilla);
    await tester.pumpAndSettle();

    await tocarCrear(tester);

    expect(cuentas.creaciones, isEmpty);
    for (final mensaje in [
      'Escribe tu nombre.',
      'Debe ser un DNI (8 dígitos) o un RUC (11 dígitos).',
      'Escribe un celular de 9 dígitos.',
      'Escribe un correo válido.',
      'La contraseña debe tener al menos 8 caracteres.',
    ]) {
      expect(find.text(mensaje), findsOneWidget, reason: mensaje);
    }
  });

  testWidgets('con todo válido crea la cuenta una sola vez aunque se toque '
      'dos veces', (tester) async {
    cuentas.crearPendiente = Completer<ResultadoCrearCuenta>();
    await abrirRegistro(
      tester,
      cuentas: cuentas,
      invitacion: invitacionSinDocumento,
    );
    await tester.enterText(campo('RUC o DNI'), '12345678');
    await tester.enterText(campo('Dirección de entrega'), ' Jr. Lima 456 ');
    await llenarValido(tester);

    await tester.ensureVisible(crearCuenta);
    await tester.tap(crearCuenta);
    await tester.tap(crearCuenta);
    await tester.pump();

    expect(cuentas.creaciones, hasLength(1));
    expect(tester.widget<FilledButton>(crearCuenta).onPressed, isNull);

    final (datos, pendiente) = cuentas.creaciones.single;
    expect(datos.nombreEncargado, 'José Ramírez');
    expect(datos.correo, 'jose@bodega.pe');
    expect(datos.contrasena, 'secreta123');
    expect(datos.documento, '12345678');
    expect(datos.telefono, '+51 987 654 321');
    expect(datos.direccion, 'Jr. Lima 456');
    expect(pendiente.codigo, 'AB2CD3E4');
    expect(pendiente.distribuidorId, 'd1');
    expect(pendiente.documento, '12345678');
    expect(pendiente.telefono, '+51 987 654 321');
    expect(pendiente.direccion, 'Jr. Lima 456');

    cuentas.crearPendiente!.complete(ResultadoCrearCuenta.error);
    await tester.pumpAndSettle();
    expect(cuentas.creaciones, hasLength(1));
  });

  testWidgets('con documento de solo lectura no lo manda en el pendiente y '
      'conserva la referencia de la invitación', (tester) async {
    await abrirRegistro(tester, cuentas: cuentas);
    await llenarValido(tester);

    await tocarCrear(tester);

    final (datos, pendiente) = cuentas.creaciones.single;
    expect(datos.documento, isNull);
    expect(pendiente.documento, isNull);
    expect(pendiente.direccion, 'Av. Los Olivos 123, Comas');
    expect(pendiente.referencia, 'Frente al parque');
  });

  testWidgets('una invitación de personal crea la cuenta sin datos de la '
      'bodega', (tester) async {
    await abrirRegistro(tester, cuentas: cuentas, invitacion: invitacionEquipo);
    await tester.enterText(campo('Tu nombre'), 'Ana Torres');
    await tester.enterText(campo('Correo'), 'ana@correo.pe');
    await tester.enterText(campo('Contraseña'), 'secreta123');
    await tester.ensureVisible(casilla);
    await tester.tap(casilla);
    await tester.pumpAndSettle();

    await tocarCrear(tester);

    final (datos, pendiente) = cuentas.creaciones.single;
    expect(datos.nombreEncargado, 'Ana Torres');
    expect(pendiente.codigo, 'AB2CD3E4');
    expect(pendiente.tieneDatosNegocio, isFalse);
  });

  group('cada resultado', () {
    testWidgets('con sesión no navega: el control de acceso se encarga', (
      tester,
    ) async {
      final router = await abrirRegistro(tester, cuentas: cuentas);
      await llenarValido(tester);

      await tocarCrear(tester);

      expect(router.state.matchedLocation, AppRutas.registro);
      expect(tester.widget<FilledButton>(crearCuenta).onPressed, isNull);
    });

    testWidgets('requiere confirmar el correo lleva a "Revisa tu correo" y '
        'de ahí a ingresar', (tester) async {
      cuentas.resultadoCrear = ResultadoCrearCuenta.requiereConfirmarCorreo;
      final router = await abrirRegistro(tester, cuentas: cuentas);
      await llenarValido(tester);

      await tocarCrear(tester);

      expect(router.state.matchedLocation, AppRutas.revisaCorreo);
      expect(
        find.text(
          'Te enviamos un enlace a jose@bodega.pe. Ábrelo para confirmar tu '
          'cuenta y luego ingresa.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Ir a ingresar'));
      await tester.pumpAndSettle();
      expect(router.state.matchedLocation, AppRutas.auth);
    });

    testWidgets('correo ya registrado lo avisa y ofrece ingresar', (
      tester,
    ) async {
      cuentas.resultadoCrear = ResultadoCrearCuenta.correoYaRegistrado;
      final router = await abrirRegistro(tester, cuentas: cuentas);
      await llenarValido(tester);

      await tocarCrear(tester);

      expect(find.text('Ya existe una cuenta con este correo.'), findsOne);
      expect(tester.widget<FilledButton>(crearCuenta).onPressed, isNotNull);

      final ingresar = find.widgetWithText(TextButton, 'Ingresar');
      await tester.ensureVisible(ingresar);
      await tester.tap(ingresar);
      await tester.pumpAndSettle();
      expect(router.state.matchedLocation, AppRutas.auth);
    });

    final mensajes = {
      ResultadoCrearCuenta.sinConexion:
          'Revisa tu conexión e inténtalo de nuevo.',
      ResultadoCrearCuenta.error:
          'No pudimos crear tu cuenta. Inténtalo de nuevo.',
    };
    for (final MapEntry(key: resultado, value: mensaje) in mensajes.entries) {
      testWidgets('${resultado.name} muestra "$mensaje"', (tester) async {
        cuentas.resultadoCrear = resultado;
        final router = await abrirRegistro(tester, cuentas: cuentas);
        await llenarValido(tester);

        await tocarCrear(tester);

        expect(find.text(mensaje), findsOneWidget);
        expect(router.state.matchedLocation, AppRutas.registro);
        // Se puede volver a intentar.
        expect(tester.widget<FilledButton>(crearCuenta).onPressed, isNotNull);
      });
    }
  });
}
