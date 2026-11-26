import 'package:app_movil/src/features/registro/domain/registro_pendiente.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ida y vuelta por toMetadata y desdeMetadata', () {
    const pendiente = RegistroPendiente(
      codigo: 'AB2CD3E4',
      distribuidorId: 'd1',
      documento: '20601234567',
      direccion: 'Av. Los Olivos 123, Comas',
      referencia: 'Frente al parque',
      telefono: '987654321',
    );

    final metadata = pendiente.toMetadata();
    expect(metadata.keys, ['registro_pendiente']);

    final leido = RegistroPendiente.desdeMetadata({
      'nombre': 'José',
      ...metadata,
    });
    expect(leido, isNotNull);
    expect(leido!.codigo, 'AB2CD3E4');
    expect(leido.distribuidorId, 'd1');
    expect(leido.documento, '20601234567');
    expect(leido.direccion, 'Av. Los Olivos 123, Comas');
    expect(leido.referencia, 'Frente al parque');
    expect(leido.telefono, '987654321');
    expect(leido.tieneDatosNegocio, isTrue);
  });

  test('ida y vuelta sin datos opcionales', () {
    const pendiente = RegistroPendiente(
      codigo: 'AB2CD3E4',
      distribuidorId: 'd1',
    );

    final leido = RegistroPendiente.desdeMetadata(pendiente.toMetadata());

    expect(leido!.codigo, 'AB2CD3E4');
    expect(leido.documento, isNull);
    expect(leido.direccion, isNull);
    expect(leido.referencia, isNull);
    expect(leido.telefono, isNull);
    expect(leido.tieneDatosNegocio, isFalse);
  });

  test('sin metadata, sin la clave o con la clave vacía da null', () {
    expect(RegistroPendiente.desdeMetadata(null), isNull);
    expect(RegistroPendiente.desdeMetadata({}), isNull);
    expect(RegistroPendiente.desdeMetadata({'nombre': 'José'}), isNull);
    // Así queda después de limpiarlo.
    expect(
      RegistroPendiente.desdeMetadata({'registro_pendiente': null}),
      isNull,
    );
  });

  test('datos mal formados dan null', () {
    expect(
      RegistroPendiente.desdeMetadata({'registro_pendiente': 'AB2CD3E4'}),
      isNull,
    );
    expect(
      RegistroPendiente.desdeMetadata({
        'registro_pendiente': {'distribuidor_id': 'd1'},
      }),
      isNull,
    );
    expect(
      RegistroPendiente.desdeMetadata({
        'registro_pendiente': {'codigo': 12345678, 'distribuidor_id': 'd1'},
      }),
      isNull,
    );
    expect(
      RegistroPendiente.desdeMetadata({
        'registro_pendiente': {'codigo': 'AB2CD3E4'},
      }),
      isNull,
    );
    expect(
      RegistroPendiente.desdeMetadata({
        'registro_pendiente': {
          'codigo': 'AB2CD3E4',
          'distribuidor_id': 'd1',
          'telefono': 987654321,
        },
      }),
      isNull,
    );
  });
}
