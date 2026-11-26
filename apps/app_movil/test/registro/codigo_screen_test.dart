import 'dart:async';

import 'package:app_movil/src/config/rutas.dart';
import 'package:app_movil/src/features/registro/domain/argumentos_registro.dart';
import 'package:app_movil/src/features/registro/domain/invitacion_previa.dart';
import 'package:app_movil/src/features/registro/domain/invitaciones_repositorio.dart';
import 'package:app_movil/src/features/sesion/domain/acceso.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'dobles.dart';

const invitacionBodega = InvitacionPrevia(
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

/// Con una membresía vacía: hay sesión y `codigo` se permite.
const conSesion = ConAcceso(membresias: [], activa: null);

final campo = find.byType(TextField);
final continuar = find.widgetWithText(FilledButton, 'Continuar');
final reintentar = find.widgetWithText(TextButton, 'Reintentar');

/// Monta la app y abre la pantalla de código.
Future<GoRouter> abrirCodigo(
  WidgetTester tester, {
  required InvitacionesRepositorioDoble repositorio,
  ControlAccesoFalso? control,
}) async {
  final router = await montarApp(
    tester,
    control: control ?? ControlAccesoFalso(const SinSesion()),
    repositorio: repositorio,
  );
  unawaited(router.push(AppRutas.codigo));
  await tester.pumpAndSettle();
  return router;
}

bool continuarHabilitado(WidgetTester tester) =>
    tester.widget<FilledButton>(continuar).onPressed != null;

void main() {
  late InvitacionesRepositorioDoble repositorio;

  setUp(() => repositorio = InvitacionesRepositorioDoble());

  testWidgets('muestra los textos de la pantalla', (tester) async {
    await abrirCodigo(tester, repositorio: repositorio);

    expect(find.text('Ingresa tu código'), findsOneWidget);
    expect(
      find.text(
        'Tu distribuidor te entregó un código único para vincular tu negocio '
        'con su catálogo.',
      ),
      findsOneWidget,
    );
    expect(find.text('¿No tienes código? Pídelo a tu distribuidor.'), findsOne);
  });

  testWidgets('consulta una sola vez, con el código normalizado, al llegar a '
      '8 caracteres', (tester) async {
    await abrirCodigo(tester, repositorio: repositorio);

    await tester.enterText(campo, 'ab2c');
    await tester.pumpAndSettle();
    expect(repositorio.consultas, isEmpty);

    await tester.enterText(campo, 'ab2cd3e4');
    await tester.pumpAndSettle();
    expect(repositorio.consultas, ['AB2CD3E4']);

    // El mismo código otra vez no vuelve a consultar.
    await tester.enterText(campo, 'AB2CD3E4');
    await tester.pumpAndSettle();
    expect(repositorio.consultas, ['AB2CD3E4']);

    // Cada casilla muestra su carácter.
    for (final letra in ['A', 'B', '2', 'C', 'D', '3', 'E', '4']) {
      expect(find.text(letra), findsOneWidget, reason: 'casilla $letra');
    }
  });

  testWidgets('pegar un código con guion consulta el código normalizado', (
    tester,
  ) async {
    await abrirCodigo(tester, repositorio: repositorio);

    await tester.enterText(campo, 'ab2c-d3e4');
    await tester.pumpAndSettle();

    expect(repositorio.consultas, ['AB2CD3E4']);
    expect(tester.widget<TextField>(campo).controller!.text, 'AB2CD3E4');
  });

  testWidgets('si el código cambia vuelve a consultar', (tester) async {
    await abrirCodigo(tester, repositorio: repositorio);

    await tester.enterText(campo, 'AB2CD3E4');
    await tester.pumpAndSettle();
    await tester.enterText(campo, 'AB2CD3E');
    await tester.pumpAndSettle();
    await tester.enterText(campo, 'AB2CD3E5');
    await tester.pumpAndSettle();

    expect(repositorio.consultas, ['AB2CD3E4', 'AB2CD3E5']);
  });

  group('cada resultado muestra su texto', () {
    // Los fallos que se pueden reintentar muestran el botón "Reintentar".
    final casos = <String, (ResultadoConsulta, List<String>)>{
      'válido con bodega': (
        const CodigoValido(invitacionBodega),
        ['Código válido', 'Licores del Norte te invita como Bodega Don Pepe'],
      ),
      'válido sin bodega': (
        const CodigoValido(invitacionEquipo),
        ['Código válido', 'Licores del Norte te invita a su equipo'],
      ),
      'no válido': (
        const CodigoNoValido(),
        ['Este código no es válido o ya fue usado.'],
      ),
      'frenada': (
        const ConsultaFrenada(),
        ['Demasiados intentos. Espera unos minutos y vuelve a probar.'],
      ),
      'sin conexión': (
        const ConsultaSinConexion(),
        ['No pudimos comprobar el código. Revisa tu conexión.'],
      ),
      'con error': (
        const ConsultaConError(),
        ['No pudimos comprobar el código. Inténtalo de nuevo.'],
      ),
    };
    bool sePuedeReintentar(ResultadoConsulta r) => switch (r) {
      ConsultaFrenada() || ConsultaSinConexion() || ConsultaConError() => true,
      CodigoValido() || CodigoNoValido() => false,
    };

    for (final MapEntry(key: nombre, value: (resultado, textos))
        in casos.entries) {
      testWidgets(nombre, (tester) async {
        repositorio.respuesta = resultado;
        await abrirCodigo(tester, repositorio: repositorio);

        await tester.enterText(campo, 'AB2CD3E4');
        await tester.pumpAndSettle();

        for (final texto in textos) {
          expect(find.text(texto), findsOneWidget, reason: texto);
        }
        expect(continuarHabilitado(tester), resultado is CodigoValido);
        expect(
          reintentar,
          sePuedeReintentar(resultado) ? findsOneWidget : findsNothing,
        );
      });
    }
  });

  testWidgets('tras "sin conexión", Reintentar consulta de nuevo el mismo '
      'código una sola vez, aunque se toque dos veces', (tester) async {
    repositorio.respuesta = const ConsultaSinConexion();
    await abrirCodigo(tester, repositorio: repositorio);

    await tester.enterText(campo, 'AB2CD3E4');
    await tester.pumpAndSettle();
    expect(repositorio.consultas, ['AB2CD3E4']);

    repositorio.respuesta = const CodigoValido(invitacionBodega);
    await tester.tap(reintentar);
    await tester.tap(reintentar, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(repositorio.consultas, ['AB2CD3E4', 'AB2CD3E4']);
    expect(find.text('Código válido'), findsOneWidget);
    expect(reintentar, findsNothing);
  });

  testWidgets('Continuar está deshabilitado hasta que el código es válido', (
    tester,
  ) async {
    final respuesta = Completer<ResultadoConsulta>();
    repositorio.pendientes['AB2CD3E4'] = respuesta;
    await abrirCodigo(tester, repositorio: repositorio);
    expect(continuarHabilitado(tester), isFalse);

    await tester.enterText(campo, 'AB2CD3E4');
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(continuarHabilitado(tester), isFalse);

    respuesta.complete(const CodigoValido(invitacionBodega));
    await tester.pumpAndSettle();
    expect(continuarHabilitado(tester), isTrue);

    // Al borrar un carácter el resultado deja de valer.
    await tester.enterText(campo, 'AB2CD3E');
    await tester.pumpAndSettle();
    expect(continuarHabilitado(tester), isFalse);
    expect(find.text('Código válido'), findsNothing);
  });

  testWidgets('una respuesta tardía de un código viejo no pisa la del nuevo', (
    tester,
  ) async {
    final vieja = Completer<ResultadoConsulta>();
    repositorio.pendientes['AB2CD3E4'] = vieja;
    repositorio.respuesta = const CodigoNoValido();
    await abrirCodigo(tester, repositorio: repositorio);

    await tester.enterText(campo, 'AB2CD3E4');
    await tester.pump();
    await tester.enterText(campo, 'AB2CD3E5');
    await tester.pumpAndSettle();
    expect(find.text('Este código no es válido o ya fue usado.'), findsOne);

    vieja.complete(const CodigoValido(invitacionBodega));
    await tester.pumpAndSettle();

    expect(find.text('Este código no es válido o ya fue usado.'), findsOne);
    expect(find.text('Código válido'), findsNothing);
    expect(continuarHabilitado(tester), isFalse);
  });

  testWidgets('sin sesión, Continuar lleva al registro con el código y la '
      'invitación', (tester) async {
    repositorio.respuesta = const CodigoValido(invitacionBodega);
    final router = await abrirCodigo(tester, repositorio: repositorio);

    await tester.enterText(campo, 'AB2CD3E4');
    await tester.pumpAndSettle();
    await tester.tap(continuar);
    await tester.pumpAndSettle();

    final estado = router.state;
    expect(estado.matchedLocation, AppRutas.registro);
    final argumentos = estado.extra! as ArgumentosRegistro;
    expect(argumentos.codigo, 'AB2CD3E4');
    expect(argumentos.invitacion, same(invitacionBodega));
    expect(repositorio.canjes, isEmpty);
  });

  testWidgets('sin sesión, dos toques en Continuar abren el registro una '
      'sola vez', (tester) async {
    repositorio.respuesta = const CodigoValido(invitacionBodega);
    final router = await abrirCodigo(tester, repositorio: repositorio);

    await tester.enterText(campo, 'AB2CD3E4');
    await tester.pumpAndSettle();
    await tester.tap(continuar);
    await tester.tap(continuar);
    await tester.pumpAndSettle();
    expect(router.state.matchedLocation, AppRutas.registro);

    // Con un solo registro apilado, volver deja en la pantalla de código.
    router.pop();
    await tester.pumpAndSettle();
    expect(router.state.matchedLocation, AppRutas.codigo);

    // Y se puede volver a continuar.
    await tester.tap(continuar);
    await tester.pumpAndSettle();
    expect(router.state.matchedLocation, AppRutas.registro);
  });

  testWidgets('el registro sin datos vuelve a la pantalla de código', (
    tester,
  ) async {
    final router = await montarApp(
      tester,
      control: ControlAccesoFalso(const SinSesion()),
      repositorio: repositorio,
    );

    router.go(AppRutas.registro);
    await tester.pumpAndSettle();

    expect(router.state.matchedLocation, AppRutas.codigo);
    expect(find.text('Ingresa tu código'), findsOneWidget);
  });

  testWidgets('con sesión, dos toques en Continuar canjean una sola vez y '
      'recargan el acceso', (tester) async {
    repositorio
      ..respuesta = const CodigoValido(invitacionBodega)
      ..canjePendiente = Completer<bool>();
    final control = ControlAccesoFalso(conSesion);
    await abrirCodigo(tester, repositorio: repositorio, control: control);

    await tester.enterText(campo, 'AB2CD3E4');
    await tester.pumpAndSettle();
    await tester.tap(continuar);
    await tester.tap(continuar);
    await tester.pump();

    expect(repositorio.canjes, ['AB2CD3E4']);
    expect(continuarHabilitado(tester), isFalse);
    expect(control.recargas, 0);

    repositorio.canjePendiente!.complete(true);
    await tester.pumpAndSettle();

    expect(repositorio.canjes, ['AB2CD3E4']);
    expect(control.recargas, 1);
  });

  testWidgets('con sesión, si el canje no vincula lo avisa', (tester) async {
    repositorio
      ..respuesta = const CodigoValido(invitacionBodega)
      ..canjeOk = false;
    final control = ControlAccesoFalso(conSesion);
    await abrirCodigo(tester, repositorio: repositorio, control: control);

    await tester.enterText(campo, 'AB2CD3E4');
    await tester.pumpAndSettle();
    await tester.tap(continuar);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'No pudimos vincular este código. Pide uno nuevo a tu distribuidor.',
      ),
      findsOneWidget,
    );
    expect(control.recargas, 0);
  });
}
