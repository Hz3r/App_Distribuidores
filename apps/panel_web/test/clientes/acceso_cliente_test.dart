import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panel_web/src/features/clientes/domain/acceso_cliente.dart';

import '../soporte/dobles_clientes.dart';

void main() {
  group('estadoDe (invitación)', () {
    test('vigente si no se usó, no se anuló y aún no vence', () {
      expect(
        estadoDe(invitacion('i', clienteId: 'c1'), ahoraDePrueba),
        EstadoInvitacion.vigente,
      );
    });

    test('vencida desde el instante exacto en que vence', () {
      final i = invitacion('i', clienteId: 'c1', venceEn: ahoraDePrueba);

      expect(estadoDe(i, ahoraDePrueba), EstadoInvitacion.vencida);
      expect(
        estadoDe(i, ahoraDePrueba.subtract(const Duration(seconds: 1))),
        EstadoInvitacion.vigente,
      );
    });

    test('usada manda sobre vencida y sobre anulada', () {
      final i = invitacion(
        'i',
        clienteId: 'c1',
        usada: true,
        revocada: true,
        venceEn: ahoraDePrueba.subtract(const Duration(days: 30)),
      );

      expect(estadoDe(i, ahoraDePrueba), EstadoInvitacion.usada);
    });

    test('anulada manda sobre vencida', () {
      final i = invitacion(
        'i',
        clienteId: 'c1',
        revocada: true,
        venceEn: ahoraDePrueba.subtract(const Duration(days: 30)),
      );

      expect(estadoDe(i, ahoraDePrueba), EstadoInvitacion.revocada);
    });
  });

  group('accesoDe (cliente)', () {
    AccesoCliente acceso(
      ClienteNegocio c, {
      List<String> conPersona = const [],
      EstadoMembresia estadoPersona = EstadoMembresia.activa,
      List<Invitacion> invitaciones = const [],
    }) {
      return accesoDe(
        c,
        personas: [
          for (final id in conPersona) persona(id, estado: estadoPersona),
        ],
        invitaciones: invitaciones,
        ahora: ahoraDePrueba,
      );
    }

    test('inactivo aunque tenga personas y código', () {
      expect(
        acceso(
          cliente('c1', activo: false),
          conPersona: ['c1'],
          invitaciones: [invitacion('i', clienteId: 'c1')],
        ),
        AccesoCliente.inactivo,
      );
    });

    test('con acceso si alguien entra a su nombre', () {
      expect(
        acceso(cliente('c1'), conPersona: ['c1']),
        AccesoCliente.conAcceso,
      );
    });

    test('la persona de otro cliente o suspendida no cuenta', () {
      expect(
        acceso(cliente('c1'), conPersona: ['c2']),
        AccesoCliente.sinAcceso,
      );
      expect(
        acceso(
          cliente('c1'),
          conPersona: ['c1'],
          estadoPersona: EstadoMembresia.suspendida,
        ),
        AccesoCliente.sinAcceso,
      );
    });

    test('invitado si nadie entra pero tiene un código vigente', () {
      expect(
        acceso(cliente('c1'), invitaciones: [invitacion('i', clienteId: 'c1')]),
        AccesoCliente.invitado,
      );
    });

    test('un código vencido, usado, anulado o de otro cliente no lo deja '
        'como invitado', () {
      expect(
        acceso(
          cliente('c1'),
          invitaciones: [
            invitacion(
              'a',
              clienteId: 'c1',
              venceEn: ahoraDePrueba.subtract(const Duration(days: 1)),
            ),
            invitacion('b', clienteId: 'c1', usada: true),
            invitacion('c', clienteId: 'c1', revocada: true),
            invitacion('d', clienteId: 'c2'),
          ],
        ),
        AccesoCliente.sinAcceso,
      );
    });
  });

  group('filtrarClientes', () {
    final roble = cliente(
      'c1',
      nombre: 'Bodega El Roble',
      documento: '20601234567',
      direccion: 'Av. Los Olivos 123',
    );
    final esquina = cliente('c2', nombre: 'Licorería La Esquina');
    final todos = [roble, esquina];

    test('sin texto devuelve todos', () {
      expect(filtrarClientes(todos, '  '), todos);
    });

    test('busca por nombre sin tildes, por RUC y por dirección', () {
      expect(filtrarClientes(todos, 'licoreria'), [esquina]);
      expect(filtrarClientes(todos, '2060123'), [roble]);
      expect(filtrarClientes(todos, 'olivos'), [roble]);
      expect(filtrarClientes(todos, 'nada'), isEmpty);
    });
  });
}
