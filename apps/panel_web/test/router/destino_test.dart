import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panel_web/src/config/rutas.dart';
import 'package:panel_web/src/router/destino.dart';

void main() {
  group('destinoRedireccion (panel)', () {
    test('sin sesión manda a auth', () {
      expect(
        destinoRedireccion(
          haySesion: false,
          rol: null,
          ubicacion: AppRutas.dashboard,
        ),
        AppRutas.auth,
      );
    });

    test('admin que entra a auth va al dashboard', () {
      expect(
        destinoRedireccion(
          haySesion: true,
          rol: RolUsuario.admin,
          ubicacion: AppRutas.auth,
        ),
        AppRutas.dashboard,
      );
    });

    test('cliente no tiene acceso al panel', () {
      expect(
        destinoRedireccion(
          haySesion: true,
          rol: RolUsuario.cliente,
          ubicacion: AppRutas.productos,
        ),
        AppRutas.sinAcceso,
      );
    });

    test('admin en una ruta válida no se redirige', () {
      expect(
        destinoRedireccion(
          haySesion: true,
          rol: RolUsuario.admin,
          ubicacion: AppRutas.pedidos,
        ),
        isNull,
      );
    });
  });
}
