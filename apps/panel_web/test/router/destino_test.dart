import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panel_web/src/config/rutas.dart';
import 'package:panel_web/src/features/sesion/domain/acceso.dart';
import 'package:panel_web/src/router/destino.dart';

import '../soporte/dobles.dart';

void main() {
  final admin = membresia('d1');
  final vendedor = membresia('d1', rol: RolMembresia.vendedor);

  group('destinoRedireccion (panel)', () {
    test('sin sesión en una ruta de paso manda a auth, sin "desde"', () {
      expect(
        destinoRedireccion(
          acceso: const SinSesion(),
          ubicacion: AppRutas.cargando,
        ),
        AppRutas.auth,
      );
    });

    test('sin sesión en una sección manda a auth recordando la sección', () {
      expect(
        destinoRedireccion(
          acceso: const SinSesion(),
          ubicacion: AppRutas.pedidos,
        ),
        '/auth?desde=%2Fpedidos',
      );
    });

    test('sin sesión y ya en auth no redirige', () {
      expect(
        destinoRedireccion(
          acceso: const SinSesion(),
          ubicacion: AppRutas.auth,
          desde: AppRutas.pedidos,
        ),
        isNull,
      );
    });

    test('cargando conserva el "desde" que ya traía', () {
      expect(
        destinoRedireccion(
          acceso: const Cargando(),
          ubicacion: AppRutas.auth,
          desde: AppRutas.pedidos,
        ),
        '/cargando?desde=%2Fpedidos',
      );
    });

    test('un error de acceso manda a su pantalla', () {
      expect(
        destinoRedireccion(
          acceso: const ErrorAcceso('x'),
          ubicacion: AppRutas.cargando,
        ),
        AppRutas.errorAcceso,
      );
    });

    test('sin membresías útiles manda a sin acceso', () {
      expect(
        destinoRedireccion(
          acceso: const ConAcceso(membresias: <Membresia>[], activa: null),
          ubicacion: AppRutas.dashboard,
        ),
        '/sin-acceso?desde=%2Fdashboard',
      );
    });

    test('con varias membresías y ninguna elegida manda a elegir', () {
      expect(
        destinoRedireccion(
          acceso: ConAcceso(membresias: [admin, membresia('d2')], activa: null),
          ubicacion: AppRutas.cargando,
        ),
        AppRutas.seleccionDistribuidor,
      );
    });

    test('con membresía activa sale de una ruta de paso al dashboard', () {
      for (final paso in [
        AppRutas.auth,
        AppRutas.cargando,
        AppRutas.errorAcceso,
        AppRutas.sinAcceso,
      ]) {
        expect(
          destinoRedireccion(acceso: accesoCon(admin), ubicacion: paso),
          AppRutas.dashboard,
          reason: paso,
        );
      }
    });

    test('con membresía activa vuelve a la sección que se pidió', () {
      expect(
        destinoRedireccion(
          acceso: accesoCon(admin),
          ubicacion: AppRutas.cargando,
          desde: AppRutas.pedidos,
        ),
        AppRutas.pedidos,
      );
    });

    test('un "desde" que no es una sección del panel se ignora', () {
      for (final malo in [
        'https://ejemplo.com',
        '//ejemplo.com',
        '/auth',
        '/pedidos?x=1',
        'pedidos',
      ]) {
        expect(
          destinoRedireccion(
            acceso: accesoCon(admin),
            ubicacion: AppRutas.cargando,
            desde: malo,
          ),
          AppRutas.dashboard,
          reason: malo,
        );
      }
    });

    test('en una sección válida no redirige', () {
      expect(
        destinoRedireccion(
          acceso: accesoCon(admin),
          ubicacion: AppRutas.pedidos,
        ),
        isNull,
      );
    });

    test('el vendedor no entra a Configuración, ni volviendo con "desde"', () {
      expect(
        destinoRedireccion(
          acceso: accesoCon(vendedor),
          ubicacion: AppRutas.configuracion,
        ),
        AppRutas.dashboard,
      );
      expect(
        destinoRedireccion(
          acceso: accesoCon(vendedor),
          ubicacion: AppRutas.cargando,
          desde: AppRutas.configuracion,
        ),
        AppRutas.dashboard,
      );
    });

    test('el admin sí entra a Configuración', () {
      expect(
        destinoRedireccion(
          acceso: accesoCon(admin),
          ubicacion: AppRutas.configuracion,
        ),
        isNull,
      );
    });

    test('Mi cuenta: entran el admin y el vendedor, también con "desde"', () {
      for (final m in [admin, vendedor]) {
        expect(
          destinoRedireccion(acceso: accesoCon(m), ubicacion: AppRutas.cuenta),
          isNull,
          reason: m.rol.name,
        );
        expect(
          destinoRedireccion(
            acceso: accesoCon(m),
            ubicacion: AppRutas.cargando,
            desde: AppRutas.cuenta,
          ),
          AppRutas.cuenta,
          reason: m.rol.name,
        );
      }
    });

    test('elegir distribuidor solo se queda si hay más de uno', () {
      expect(
        destinoRedireccion(
          acceso: accesoCon(admin),
          ubicacion: AppRutas.seleccionDistribuidor,
        ),
        AppRutas.dashboard,
      );
      expect(
        destinoRedireccion(
          acceso: ConAcceso(
            membresias: [admin, membresia('d2')],
            activa: admin,
          ),
          ubicacion: AppRutas.seleccionDistribuidor,
        ),
        isNull,
      );
    });
  });
}
