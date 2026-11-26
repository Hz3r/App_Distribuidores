import 'package:app_movil/src/config/rutas.dart';
import 'package:app_movil/src/features/sesion/domain/acceso.dart';
import 'package:app_movil/src/router/destino.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

/// Constructor auxiliar: membresía activa con su distribuidor embebido.
Membresia membresia(String distribuidorId, RolMembresia rol) {
  return Membresia(
    id: 'm-$distribuidorId-${rol.name}',
    perfilId: 'p1',
    distribuidorId: distribuidorId,
    rol: rol,
    estado: EstadoMembresia.activa,
    creadoEn: DateTime.utc(2026),
    distribuidor: Distribuidor(
      id: distribuidorId,
      nombre: 'Distribuidor $distribuidorId',
      slug: distribuidorId,
      estado: EstadoDistribuidor.activo,
      moneda: 'PEN',
      zonaHoraria: 'America/Lima',
      configTema: const ConfigTema(),
      creadoEn: DateTime.utc(2026),
    ),
  );
}

/// Una ruta de detalle de producto.
final detalle = AppRutas.detalleProducto('p1');

/// El carrito abierto desde ese detalle.
final carritoDelDetalle = AppRutas.carritoDesdeDetalle('p1');

/// Todas las rutas de [AppRutas].
final todasLasRutas = [
  AppRutas.bienvenida,
  AppRutas.codigo,
  AppRutas.registro,
  AppRutas.revisaCorreo,
  AppRutas.auth,
  AppRutas.cargando,
  AppRutas.errorAcceso,
  AppRutas.sinRol,
  AppRutas.seleccionDistribuidor,
  AppRutas.inicio,
  AppRutas.catalogo,
  detalle,
  carritoDelDetalle,
  AppRutas.carrito,
  AppRutas.checkout,
  AppRutas.pedidos,
  AppRutas.perfil,
  AppRutas.repartidor,
];

/// Rutas válidas sin sesión.
const rutasPublicas = [
  AppRutas.bienvenida,
  AppRutas.codigo,
  AppRutas.registro,
  AppRutas.revisaCorreo,
  AppRutas.auth,
];

void main() {
  final cliente = membresia('d1', RolMembresia.cliente);
  final repartidor = membresia('d2', RolMembresia.repartidor);

  /// Una sola membresía, ya activa.
  ConAcceso soloCon(Membresia m) => ConAcceso(membresias: [m], activa: m);

  /// Dos membresías, con [activa] elegida.
  ConAcceso dosCon(Membresia activa) =>
      ConAcceso(membresias: [cliente, repartidor], activa: activa);

  String? destino(Acceso acceso, String ubicacion) =>
      destinoRedireccion(acceso: acceso, ubicacion: ubicacion);

  group('destinoRedireccion, una prueba por regla', () {
    test('sin sesión, las rutas públicas son válidas', () {
      for (final ubicacion in rutasPublicas) {
        expect(
          destino(const SinSesion(), ubicacion),
          isNull,
          reason: 'sin sesión en $ubicacion',
        );
      }
    });

    test('sin sesión, cualquier otra ruta manda a bienvenida', () {
      expect(
        destino(const SinSesion(), AppRutas.catalogo),
        AppRutas.bienvenida,
      );
      expect(destino(const SinSesion(), AppRutas.sinRol), AppRutas.bienvenida);
    });

    test('cargando manda a cargando, salvo que ya esté ahí', () {
      expect(destino(const Cargando(), AppRutas.auth), AppRutas.cargando);
      expect(destino(const Cargando(), AppRutas.cargando), isNull);
    });

    test('error manda a errorAcceso, salvo que ya esté ahí', () {
      const error = ErrorAcceso('sin red');
      expect(destino(error, AppRutas.catalogo), AppRutas.errorAcceso);
      expect(destino(error, AppRutas.errorAcceso), isNull);
    });

    test('con acceso y sin membresías manda a sinRol, salvo que ya esté', () {
      const vacio = ConAcceso(membresias: [], activa: null);
      expect(destino(vacio, AppRutas.catalogo), AppRutas.sinRol);
      expect(destino(vacio, AppRutas.sinRol), isNull);
    });

    test('con acceso y sin membresías, codigo se permite', () {
      const vacio = ConAcceso(membresias: [], activa: null);
      expect(destino(vacio, AppRutas.codigo), isNull);
    });

    test('sin activa manda a seleccionDistribuidor, salvo que ya esté', () {
      final sinElegir = ConAcceso(
        membresias: [cliente, repartidor],
        activa: null,
      );
      expect(
        destino(sinElegir, AppRutas.catalogo),
        AppRutas.seleccionDistribuidor,
      );
      expect(destino(sinElegir, AppRutas.seleccionDistribuidor), isNull);
    });

    test('sin activa, codigo se permite para sumar otro distribuidor', () {
      final sinElegir = ConAcceso(
        membresias: [cliente, repartidor],
        activa: null,
      );
      expect(destino(sinElegir, AppRutas.codigo), isNull);
    });

    test('con activa, desde las rutas de paso va al inicio del rol', () {
      for (final ubicacion in [
        AppRutas.bienvenida,
        AppRutas.registro,
        AppRutas.revisaCorreo,
        AppRutas.auth,
        AppRutas.cargando,
        AppRutas.errorAcceso,
        AppRutas.sinRol,
      ]) {
        expect(
          destino(soloCon(cliente), ubicacion),
          AppRutas.inicio,
          reason: 'cliente en $ubicacion',
        );
        expect(
          destino(soloCon(repartidor), ubicacion),
          AppRutas.repartidor,
          reason: 'repartidor en $ubicacion',
        );
      }
    });

    test('con activa, codigo se permite para sumar otro distribuidor', () {
      expect(destino(soloCon(cliente), AppRutas.codigo), isNull);
      expect(destino(soloCon(repartidor), AppRutas.codigo), isNull);
      expect(destino(dosCon(cliente), AppRutas.codigo), isNull);
    });

    test(
      'seleccionDistribuidor con una sola membresía va al inicio del rol',
      () {
        expect(
          destino(soloCon(cliente), AppRutas.seleccionDistribuidor),
          AppRutas.inicio,
        );
        expect(
          destino(soloCon(repartidor), AppRutas.seleccionDistribuidor),
          AppRutas.repartidor,
        );
      },
    );

    test('repartidor fuera de su zona va a repartidor, salvo perfil', () {
      expect(
        destino(soloCon(repartidor), AppRutas.pedidos),
        AppRutas.repartidor,
      );
      expect(destino(soloCon(repartidor), AppRutas.perfil), isNull);
    });

    test('cliente dentro de la zona de repartidor va a inicio', () {
      expect(destino(soloCon(cliente), AppRutas.repartidor), AppRutas.inicio);
    });

    test('cualquier otro caso no redirige', () {
      expect(destino(soloCon(cliente), AppRutas.pedidos), isNull);
      expect(destino(soloCon(repartidor), AppRutas.repartidor), isNull);
    });
  });

  group('destinoRedireccion, casos puntuales', () {
    test('repartidor en perfil no redirige', () {
      expect(destino(soloCon(repartidor), AppRutas.perfil), isNull);
    });

    test('repartidor en catálogo va a repartidor', () {
      expect(
        destino(soloCon(repartidor), AppRutas.catalogo),
        AppRutas.repartidor,
      );
    });

    test('cliente en repartidor va a inicio', () {
      expect(destino(soloCon(cliente), AppRutas.repartidor), AppRutas.inicio);
    });

    test('cliente activo en auth, bienvenida, registro y cargando va a '
        'inicio', () {
      for (final ubicacion in [
        AppRutas.auth,
        AppRutas.bienvenida,
        AppRutas.registro,
        AppRutas.cargando,
      ]) {
        expect(
          destino(soloCon(cliente), ubicacion),
          AppRutas.inicio,
          reason: 'cliente en $ubicacion',
        );
      }
    });

    test('cliente en inicio, catálogo y detalle no redirige', () {
      expect(destino(soloCon(cliente), AppRutas.inicio), isNull);
      expect(destino(soloCon(cliente), AppRutas.catalogo), isNull);
      expect(destino(soloCon(cliente), detalle), isNull);
      expect(destino(soloCon(cliente), carritoDelDetalle), isNull);
    });

    test('repartidor en inicio y en un detalle va a repartidor', () {
      expect(
        destino(soloCon(repartidor), AppRutas.inicio),
        AppRutas.repartidor,
      );
      expect(destino(soloCon(repartidor), detalle), AppRutas.repartidor);
      expect(
        destino(soloCon(repartidor), carritoDelDetalle),
        AppRutas.repartidor,
      );
    });

    test('sin sesión, inicio y el detalle mandan a bienvenida', () {
      expect(destino(const SinSesion(), AppRutas.inicio), AppRutas.bienvenida);
      expect(destino(const SinSesion(), detalle), AppRutas.bienvenida);
    });

    test('con dos membresías y activa elegida, seleccionDistribuidor se '
        'permite', () {
      expect(destino(dosCon(cliente), AppRutas.seleccionDistribuidor), isNull);
      expect(
        destino(dosCon(repartidor), AppRutas.seleccionDistribuidor),
        isNull,
      );
    });
  });

  test('ninguna combinación produce un bucle: el destino es estable', () {
    final accesos = <Acceso>[
      const SinSesion(),
      const Cargando(),
      const ErrorAcceso('fallo'),
      const ConAcceso(membresias: [], activa: null),
      ConAcceso(membresias: [cliente, repartidor], activa: null),
      soloCon(cliente),
      soloCon(repartidor),
      dosCon(cliente),
      dosCon(repartidor),
    ];

    for (final acceso in accesos) {
      for (final ubicacion in todasLasRutas) {
        final primero = destino(acceso, ubicacion);
        if (primero == null) continue;
        expect(
          destino(acceso, primero),
          isNull,
          reason: '$acceso en $ubicacion → $primero no es estable',
        );
      }
    }
  });
}
