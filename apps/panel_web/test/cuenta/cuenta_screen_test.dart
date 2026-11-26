import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:panel_web/src/features/cuenta/domain/cuenta_repositorio.dart';
import 'package:panel_web/src/features/cuenta/presentation/cuenta_providers.dart';
import 'package:panel_web/src/features/cuenta/presentation/cuenta_screen.dart';

import '../soporte/dobles_configuracion.dart';
import '../soporte/montar.dart';

Finder campo(String etiqueta) => find.widgetWithText(TextFormField, etiqueta);

String textoDe(WidgetTester tester, String etiqueta) =>
    tester.widget<TextFormField>(campo(etiqueta)).controller!.text;

Future<void> tocar(WidgetTester tester, String texto) async {
  final boton = find.text(texto);
  await tester.ensureVisible(boton);
  await tester.pumpAndSettle();
  await tester.tap(boton);
  await tester.pumpAndSettle();
}

Future<CuentaDoble> montar(
  WidgetTester tester, {
  CuentaDoble? cuenta,
  RolMembresia rol = RolMembresia.admin,
}) async {
  final doble = cuenta ?? CuentaDoble();
  await montarSeccion(tester, const CuentaScreen(), cuenta: doble, rol: rol);
  return doble;
}

Future<void> llenarContrasenas(
  WidgetTester tester, {
  String actual = 'Clave2026',
  String nueva = 'NuevaClave7',
  String? repetida,
}) async {
  await tester.enterText(campo('Contraseña actual'), actual);
  await tester.enterText(campo('Contraseña nueva'), nueva);
  await tester.enterText(
    campo('Repite la contraseña nueva'),
    repetida ?? nueva,
  );
}

void main() {
  testWidgets('muestra el nombre, el correo, el teléfono y el rol', (
    tester,
  ) async {
    await montar(tester);

    expect(textoDe(tester, 'Tu nombre'), 'Ana Torres');
    expect(find.text('admin@ejemplo.com'), findsOneWidget);
    expect(find.text('+51987654321'), findsOneWidget);
    expect(find.text('Tu rol en Distribuidor d1'), findsOneWidget);
    expect(find.text('Administrador'), findsOneWidget);
    expect(find.text('Para cambiar tu correo, escríbenos.'), findsOneWidget);
  });

  testWidgets('el vendedor también entra y ve su rol', (tester) async {
    await montar(tester, rol: RolMembresia.vendedor);

    expect(find.text('Vendedor'), findsOneWidget);
    expect(find.text('Cambiar contraseña'), findsOneWidget);
  });

  testWidgets('guardar el nombre: solo con cambios, valida y avisa', (
    tester,
  ) async {
    final cuenta = await montar(tester);
    FilledButton boton() => tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Guardar nombre'),
    );
    expect(boton().onPressed, isNull);

    await tester.enterText(campo('Tu nombre'), '  ');
    await tester.pump();
    await tocar(tester, 'Guardar nombre');
    expect(find.text('Escribe tu nombre.'), findsOneWidget);
    expect(cuenta.llamadas, isEmpty);

    await tester.enterText(campo('Tu nombre'), ' Ana María Torres ');
    await tester.pump();
    await tocar(tester, 'Guardar nombre');

    expect(cuenta.llamadas, ['actualizarNombre Ana María Torres']);
    expect(find.text('Guardamos tu nombre.'), findsOneWidget);
    expect(textoDe(tester, 'Tu nombre'), 'Ana María Torres');
    expect(boton().onPressed, isNull);
  });

  testWidgets('si no se puede leer el perfil ofrece reintentar', (
    tester,
  ) async {
    final cuenta = CuentaDoble()..fallarEn = 'leerPerfil';
    await montar(tester, cuenta: cuenta);
    expect(find.text('No pudimos cargar tus datos.'), findsOneWidget);

    cuenta.fallarEn = null;
    await tocar(tester, 'Reintentar');
    expect(textoDe(tester, 'Tu nombre'), 'Ana Torres');
  });

  group('contraseña', () {
    testWidgets('valida largo, letras y números, que sea distinta y que '
        'coincida', (tester) async {
      final cuenta = await montar(tester);

      await tocar(tester, 'Cambiar contraseña');
      expect(find.text('Escribe tu contraseña actual.'), findsOneWidget);
      expect(find.text('Escribe la contraseña nueva.'), findsOneWidget);
      expect(find.text('Repite la contraseña nueva.'), findsOneWidget);

      await llenarContrasenas(tester, nueva: 'corta1');
      await tester.pump();
      expect(find.text('Usa al menos 8 caracteres.'), findsOneWidget);

      await llenarContrasenas(tester, nueva: 'solamenteletras');
      await tester.pump();
      expect(find.text('Combina letras y números.'), findsOneWidget);

      await llenarContrasenas(tester, nueva: 'Clave2026');
      await tester.pump();
      expect(find.text('Debe ser distinta de la actual.'), findsOneWidget);

      await llenarContrasenas(tester, repetida: 'OtraClave8');
      await tester.pump();
      expect(find.text('No coincide con la contraseña nueva.'), findsOneWidget);

      expect(cuenta.llamadas, isEmpty);
    });

    testWidgets('con la actual equivocada lo dice y no cambia nada', (
      tester,
    ) async {
      final cuenta = await montar(tester);

      await llenarContrasenas(tester, actual: 'Equivocada1');
      await tocar(tester, 'Cambiar contraseña');

      expect(find.text('La contraseña actual no es correcta.'), findsOneWidget);
      expect(cuenta.contrasena, 'Clave2026');
      expect(textoDe(tester, 'Contraseña nueva'), 'NuevaClave7');
    });

    testWidgets('si todo está bien la cambia, limpia y avisa', (tester) async {
      final cuenta = await montar(tester);

      await llenarContrasenas(tester);
      await tocar(tester, 'Cambiar contraseña');

      expect(cuenta.contrasena, 'NuevaClave7');
      expect(find.text('Cambiamos tu contraseña.'), findsOneWidget);
      for (final etiqueta in [
        'Contraseña actual',
        'Contraseña nueva',
        'Repite la contraseña nueva',
      ]) {
        expect(textoDe(tester, etiqueta), isEmpty, reason: etiqueta);
      }
    });

    testWidgets('las contraseñas van ocultas hasta pedir verlas', (
      tester,
    ) async {
      await montar(tester);
      bool oculto() => tester
          .widget<EditableText>(
            find.descendant(
              of: campo('Contraseña actual'),
              matching: find.byType(EditableText),
            ),
          )
          .obscureText;

      expect(oculto(), isTrue);
      await tocar(tester, 'Mostrar contraseñas');
      expect(oculto(), isFalse);
      expect(find.text('Ocultar contraseñas'), findsOneWidget);
    });
  });

  test('mensajes de error en lenguaje simple', () {
    expect(
      mensajeDeCuenta(const ErrorCuenta(MotivoErrorCuenta.mismaContrasena)),
      'La contraseña nueva debe ser distinta de la actual.',
    );
    expect(
      mensajeDeCuenta(const ErrorCuenta(MotivoErrorCuenta.contrasenaDebil)),
      contains('fácil de adivinar'),
    );
    expect(mensajeDeCuenta(StateError('x')), contains('conexión'));
  });

  test('validarContrasenaNueva', () {
    expect(validarContrasenaNueva('NuevaClave7'), isNull);
    expect(validarContrasenaNueva('ñandú2026'), isNull);
    expect(validarContrasenaNueva('12345678'), 'Combina letras y números.');
    expect(validarContrasenaNueva(''), 'Escribe la contraseña nueva.');
  });
}
