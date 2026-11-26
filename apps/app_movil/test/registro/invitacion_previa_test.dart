import 'package:app_movil/src/features/registro/domain/invitacion_previa.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InvitacionPrevia.desdeJson', () {
    test('invitación de cliente, con los datos de la bodega', () {
      final invitacion = InvitacionPrevia.desdeJson({
        'distribuidor_id': 'd1',
        'distribuidor_nombre': 'Licores del Norte',
        'rol': 'cliente',
        'negocio': {
          'nombre_negocio': 'Bodega Don Pepe',
          'documento': null,
          'direccion': 'Av. Los Olivos 123',
          'referencia': null,
          'telefono': null,
        },
      });

      expect(invitacion.distribuidorId, 'd1');
      expect(invitacion.distribuidorNombre, 'Licores del Norte');
      expect(invitacion.rol, RolMembresia.cliente);
      final negocio = invitacion.negocio!;
      expect(negocio.nombreNegocio, 'Bodega Don Pepe');
      expect(negocio.documento, isNull);
      expect(negocio.direccion, 'Av. Los Olivos 123');
      expect(negocio.referencia, isNull);
      expect(negocio.telefono, isNull);
    });

    test('invitación de otro rol, con negocio null', () {
      final invitacion = InvitacionPrevia.desdeJson({
        'distribuidor_id': 'd1',
        'distribuidor_nombre': 'Licores del Norte',
        'rol': 'repartidor',
        'negocio': null,
      });

      expect(invitacion.rol, RolMembresia.repartidor);
      expect(invitacion.negocio, isNull);
    });

    test('un rol desconocido es un error de formato', () {
      expect(
        () => InvitacionPrevia.desdeJson({
          'distribuidor_id': 'd1',
          'distribuidor_nombre': 'Licores del Norte',
          'rol': 'gerente',
          'negocio': null,
        }),
        throwsFormatException,
      );
    });
  });
}
