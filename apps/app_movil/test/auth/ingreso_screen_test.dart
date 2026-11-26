import 'dart:async';

import 'package:app_movil/src/config/rutas.dart';
import 'package:app_movil/src/features/auth/presentation/ingreso_screen.dart';
import 'package:app_movil/src/features/registro/domain/argumentos_registro.dart';
import 'package:app_movil/src/features/registro/domain/codigo_por_canjear.dart';
import 'package:app_movil/src/features/registro/domain/cuentas_repositorio.dart';
import 'package:app_movil/src/features/registro/domain/invitacion_previa.dart';
import 'package:app_movil/src/features/registro/presentation/codigo_screen.dart';
import 'package:app_movil/src/features/sesion/domain/acceso.dart';
import 'package:app_movil/src/features/sesion/presentation/control_acceso.dart';
import 'package:core/core.dart';
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

  testWidgets('desde el registro, el enlace vuelve a una sola pantalla de '
      'código', (tester) async {
    final router = await montarApp(
      tester,
      control: ControlAccesoFalso(const SinSesion()),
      cuentas: cuentas,
    );
    unawaited(router.push(AppRutas.codigo));
    await tester.pumpAndSettle();
    unawaited(
      router.push(
        AppRutas.registro,
        extra: const ArgumentosRegistro(
          codigo: 'XY7ZW8V9',
          invitacion: InvitacionPrevia(
            distribuidorId: 'd2',
            distribuidorNombre: 'Licores del Sur',
            rol: RolMembresia.cliente,
            negocio: NegocioPrevio(nombreNegocio: 'Bodega Don Pepe'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    unawaited(router.push(AppRutas.auth, extra: codigoPorCanjear));
    await tester.pumpAndSettle();

    final enlace = find.text('Tengo un código de invitación');
    await tester.ensureVisible(enlace);
    await tester.tap(enlace);
    await tester.pumpAndSettle();

    expect(router.state.matchedLocation, AppRutas.codigo);
    expect(find.byType(CodigoScreen, skipOffstage: false), findsOneWidget);
    expect(find.byType(IngresoScreen, skipOffstage: false), findsNothing);
  });

  group('con un código por canjear y el control de acceso real', () {
    late StreamController<bool> sesion;
    late InvitacionesRepositorioDoble invitaciones;
    late MembresiasRepositorioDoble membresias;

    setUp(() {
      sesion = StreamController<bool>();
      invitaciones = InvitacionesRepositorioDoble();
      membresias = MembresiasRepositorioDoble()..membresias = [membresia('d1')];
    });

    tearDown(() => sesion.close());

    /// Abre el ingreso sin sesión, con [extra] como lo deja el registro.
    Future<GoRouter> abrir(WidgetTester tester, {Object? extra}) async {
      // Antes de montar: la pantalla de espera no deja asentar la app.
      sesion.add(false);
      final router = await montarApp(
        tester,
        control: ControlAcceso(),
        repositorio: invitaciones,
        cuentas: cuentas,
        overrides: [
          haySesionProvider.overrideWith((ref) => sesion.stream),
          membresiasRepositorioProvider.overrideWithValue(membresias),
        ],
      );
      unawaited(router.push(AppRutas.auth, extra: extra));
      await tester.pumpAndSettle();
      return router;
    }

    /// Ingresa; si sale bien, llega la sesión como la emite Supabase.
    Future<void> ingresarConSesion(WidgetTester tester) async {
      await llenar(tester);
      await tocarIngresar(tester);
      if (cuentas.resultadoIngreso == ResultadoIngreso.ok) {
        sesion.add(true);
        await tester.pumpAndSettle();
      }
    }

    testWidgets('ingreso correcto: lo canjea una vez y la membresía nueva '
        'aparece', (tester) async {
      final router = await abrir(tester, extra: codigoPorCanjear);
      // El canje crea la membresía en d2.
      membresias.membresias = [membresia('d1'), membresia('d2')];

      await ingresarConSesion(tester);

      expect(invitaciones.canjes, ['XY7ZW8V9']);
      expect(find.byType(IngresoScreen, skipOffstage: false), findsNothing);
      expect(router.state.matchedLocation, AppRutas.seleccionDistribuidor);
      expect(find.text('Distribuidor d2'), findsOneWidget);
      expect(find.textContaining('No pudimos vincular'), findsNothing);
    });

    testWidgets('un código que no vincula: entra y lo avisa', (tester) async {
      invitaciones.canjeOk = false;
      final router = await abrir(tester, extra: codigoPorCanjear);

      await ingresarConSesion(tester);

      expect(invitaciones.canjes, ['XY7ZW8V9']);
      expect(router.state.matchedLocation, AppRutas.inicio);
      expect(
        find.text(
          'No pudimos vincular este código. Pide uno nuevo a tu distribuidor.',
        ),
        findsOneWidget,
      );
      // Deja pasar el tiempo del aviso.
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();
    });

    testWidgets('sin código no canjea nada', (tester) async {
      final router = await abrir(tester);

      await ingresarConSesion(tester);

      expect(invitaciones.canjes, isEmpty);
      expect(router.state.matchedLocation, AppRutas.inicio);
    });

    testWidgets('con credenciales incorrectas el código se conserva para el '
        'siguiente intento', (tester) async {
      cuentas.resultadoIngreso = ResultadoIngreso.credencialesIncorrectas;
      await abrir(tester, extra: codigoPorCanjear);

      await ingresarConSesion(tester);
      expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
      expect(invitaciones.canjes, isEmpty);

      cuentas.resultadoIngreso = ResultadoIngreso.ok;
      await ingresarConSesion(tester);

      expect(cuentas.ingresos, hasLength(2));
      expect(invitaciones.canjes, ['XY7ZW8V9']);
    });
  });
}

const codigoPorCanjear = CodigoPorCanjear(
  codigo: 'XY7ZW8V9',
  distribuidorId: 'd2',
);
