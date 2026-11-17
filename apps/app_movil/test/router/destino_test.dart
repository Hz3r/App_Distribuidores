import 'package:app_movil/src/config/rutas.dart';
import 'package:app_movil/src/router/destino.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('destinoRedireccion', () {
    test('sin sesión manda a auth desde cualquier ruta protegida', () {
      expect(
        destinoRedireccion(
          haySesion: false,
          rol: null,
          ubicacion: AppRutas.catalogo,
        ),
        AppRutas.auth,
      );
    });

    test('sin sesión en auth no redirige (evita bucles)', () {
      expect(
        destinoRedireccion(
          haySesion: false,
          rol: null,
          ubicacion: AppRutas.auth,
        ),
        isNull,
      );
    });

    test('con sesión y sin rol manda a sin-rol', () {
      expect(
        destinoRedireccion(
          haySesion: true,
          rol: null,
          ubicacion: AppRutas.catalogo,
        ),
        AppRutas.sinRol,
      );
    });

    test('cliente que entra a auth va al catálogo', () {
      expect(
        destinoRedireccion(
          haySesion: true,
          rol: RolUsuario.cliente,
          ubicacion: AppRutas.auth,
        ),
        AppRutas.catalogo,
      );
    });

    test('repartidor que entra a auth va a su zona', () {
      expect(
        destinoRedireccion(
          haySesion: true,
          rol: RolUsuario.repartidor,
          ubicacion: AppRutas.auth,
        ),
        AppRutas.repartidor,
      );
    });

    test('cliente no puede entrar a la zona de repartidor', () {
      expect(
        destinoRedireccion(
          haySesion: true,
          rol: RolUsuario.cliente,
          ubicacion: AppRutas.repartidor,
        ),
        AppRutas.catalogo,
      );
    });

    test('repartidor fuera de su zona es enviado a su zona', () {
      expect(
        destinoRedireccion(
          haySesion: true,
          rol: RolUsuario.repartidor,
          ubicacion: AppRutas.catalogo,
        ),
        AppRutas.repartidor,
      );
    });

    test('repartidor puede ver su perfil fuera de su zona', () {
      expect(
        destinoRedireccion(
          haySesion: true,
          rol: RolUsuario.repartidor,
          ubicacion: AppRutas.perfil,
        ),
        isNull,
      );
    });

    test('cliente en una ruta válida no se redirige', () {
      expect(
        destinoRedireccion(
          haySesion: true,
          rol: RolUsuario.cliente,
          ubicacion: AppRutas.pedidos,
        ),
        isNull,
      );
    });
  });
}
