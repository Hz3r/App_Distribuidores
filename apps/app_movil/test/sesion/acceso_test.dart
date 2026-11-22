import 'package:app_movil/src/features/sesion/domain/acceso.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

/// Constructor auxiliar: membresía activa de cliente con su distribuidor
/// embebido, salvo que se indique otra cosa.
Membresia membresia({
  String distribuidorId = 'd1',
  RolMembresia rol = RolMembresia.cliente,
  EstadoMembresia estado = EstadoMembresia.activa,
  bool conDistribuidor = true,
}) {
  return Membresia(
    id: 'm-$distribuidorId-${rol.name}',
    perfilId: 'p1',
    distribuidorId: distribuidorId,
    rol: rol,
    estado: estado,
    creadoEn: DateTime.utc(2026),
    distribuidor: conDistribuidor
        ? Distribuidor(
            id: distribuidorId,
            nombre: 'Distribuidor $distribuidorId',
            slug: distribuidorId,
            estado: EstadoDistribuidor.activo,
            moneda: 'PEN',
            zonaHoraria: 'America/Lima',
            configTema: const ConfigTema(),
            creadoEn: DateTime.utc(2026),
          )
        : null,
  );
}

void main() {
  group('membresiasUtiles', () {
    test('descarta suspendidas', () {
      final suspendida = membresia(estado: EstadoMembresia.suspendida);
      expect(membresiasUtiles([suspendida]), isEmpty);
    });

    test('descarta rol admin', () {
      expect(membresiasUtiles([membresia(rol: RolMembresia.admin)]), isEmpty);
    });

    test('descarta rol vendedor', () {
      expect(
        membresiasUtiles([membresia(rol: RolMembresia.vendedor)]),
        isEmpty,
      );
    });

    test('descarta las que no traen distribuidor visible', () {
      expect(membresiasUtiles([membresia(conDistribuidor: false)]), isEmpty);
    });

    test('conserva cliente y repartidor activas en el orden de entrada', () {
      final repartidor = membresia(
        distribuidorId: 'd2',
        rol: RolMembresia.repartidor,
      );
      final admin = membresia(distribuidorId: 'd3', rol: RolMembresia.admin);
      final cliente = membresia(distribuidorId: 'd1');

      expect(membresiasUtiles([repartidor, admin, cliente]), [
        repartidor,
        cliente,
      ]);
    });
  });

  group('elegirActiva', () {
    final d1 = membresia(distribuidorId: 'd1');
    final d2 = membresia(distribuidorId: 'd2', rol: RolMembresia.repartidor);

    test('lista vacía devuelve null', () {
      expect(elegirActiva([], 'd1'), isNull);
    });

    test('con una sola, esa, aunque la preferencia sea otra', () {
      expect(elegirActiva([d1], 'd2'), d1);
    });

    test('con dos y sin preferencia devuelve null', () {
      expect(elegirActiva([d1, d2], null), isNull);
    });

    test('con dos y preferencia que coincide devuelve esa', () {
      expect(elegirActiva([d1, d2], 'd2'), d2);
    });

    test('con dos y preferencia de un distribuidor que no está, null', () {
      expect(elegirActiva([d1, d2], 'd9'), isNull);
    });
  });

  group('accesoDesde', () {
    test('solo membresías de admin: sin membresías útiles ni activa', () {
      final acceso = accesoDesde([
        membresia(rol: RolMembresia.admin),
        membresia(distribuidorId: 'd2', rol: RolMembresia.admin),
      ], 'd1');

      expect(acceso.membresias, isEmpty);
      expect(acceso.activa, isNull);
    });

    test('filtra y elige con la preferencia', () {
      final d1 = membresia(distribuidorId: 'd1');
      final d2 = membresia(distribuidorId: 'd2');
      final acceso = accesoDesde([
        d1,
        membresia(distribuidorId: 'd3', rol: RolMembresia.vendedor),
        d2,
      ], 'd2');

      expect(acceso.membresias, [d1, d2]);
      expect(acceso.activa, d2);
    });
  });
}
