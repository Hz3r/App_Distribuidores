import 'dart:async';

import 'package:app_movil/src/features/registro/domain/registro_pendiente.dart';
import 'package:app_movil/src/features/registro/presentation/registro_providers.dart';
import 'package:app_movil/src/features/sesion/domain/acceso.dart';
import 'package:app_movil/src/features/sesion/domain/membresias_repositorio.dart';
import 'package:app_movil/src/features/sesion/presentation/control_acceso.dart';
import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../registro/dobles.dart';

/// Constructor auxiliar: membresía activa con su distribuidor embebido.
Membresia membresia(
  String distribuidorId, {
  RolMembresia rol = RolMembresia.cliente,
}) {
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

/// Doble de [MembresiasRepositorio]. Si [respuesta] es un `Completer`, la
/// lectura queda pendiente hasta que la prueba lo complete.
class RepositorioDoble implements MembresiasRepositorio {
  List<Membresia> membresias = [];
  String? preferido;
  Object? error;
  Completer<List<Membresia>>? respuesta;
  final guardados = <String>[];
  int lecturas = 0;

  /// Si no es null, cada lectura se anota aquí.
  List<String>? bitacora;

  @override
  Future<List<Membresia>> listarMias() async {
    lecturas++;
    bitacora?.add('listar');
    final pendiente = respuesta;
    if (pendiente != null) return pendiente.future;
    final fallo = error;
    if (fallo != null) throw fallo;
    return membresias;
  }

  @override
  String? distribuidorPreferido() => preferido;

  @override
  Future<void> guardarDistribuidorPreferido(String distribuidorId) async {
    guardados.add(distribuidorId);
    preferido = distribuidorId;
  }
}

void main() {
  late RepositorioDoble repositorio;
  late InvitacionesRepositorioDoble invitaciones;
  late CuentasRepositorioDoble cuentas;
  late List<String> bitacora;
  late StreamController<bool> sesion;
  late ProviderContainer container;
  late List<Acceso> estados;

  setUp(() {
    bitacora = [];
    repositorio = RepositorioDoble()..bitacora = bitacora;
    invitaciones = InvitacionesRepositorioDoble(bitacora: bitacora);
    cuentas = CuentasRepositorioDoble(bitacora: bitacora);
    sesion = StreamController<bool>();
    container = ProviderContainer(
      overrides: [
        membresiasRepositorioProvider.overrideWithValue(repositorio),
        invitacionesRepositorioProvider.overrideWithValue(invitaciones),
        cuentasRepositorioProvider.overrideWithValue(cuentas),
        haySesionProvider.overrideWith((ref) => sesion.stream),
      ],
    );
    estados = [];
    // Mantiene el provider escuchado y registra cada estado por el que pasa.
    container.listen(
      controlAccesoProvider,
      (_, siguiente) => estados.add(siguiente),
      fireImmediately: true,
    );
  });

  tearDown(() async {
    container.dispose();
    await sesion.close();
  });

  Acceso leer() => container.read(controlAccesoProvider);

  /// Emite en el flujo de sesión y deja correr las microtareas pendientes.
  Future<void> emitir(bool haySesion) async {
    sesion.add(haySesion);
    await pumpEventQueue();
    // Lee para que el provider se reconstruya si quedó marcado.
    leer();
    await pumpEventQueue();
  }

  test('sin sesión queda en SinSesion', () async {
    await emitir(false);

    expect(leer(), isA<SinSesion>());
    expect(repositorio.lecturas, 0);
  });

  test('con sesión y una membresía de cliente pasa por Cargando y termina '
      'en ConAcceso con esa activa', () async {
    final cliente = membresia('d1');
    final respuesta = Completer<List<Membresia>>();
    repositorio.respuesta = respuesta;
    // Solo cuentan los estados a partir de la emisión de la sesión. El
    // `Cargando` de la emisión es la misma constante que el inicial, así que
    // Riverpod no avisa al listener: se lee el estado mientras la lectura de
    // membresías sigue pendiente y otra vez cuando termina.
    final desdeEmision = <Acceso>[];

    await emitir(true);
    expect(repositorio.lecturas, 1);
    desdeEmision.add(leer());

    respuesta.complete([cliente]);
    await pumpEventQueue();
    desdeEmision.add(leer());

    expect(desdeEmision.map((e) => e.runtimeType), [Cargando, ConAcceso]);
    final acceso = leer();
    expect(acceso, isA<ConAcceso>());
    acceso as ConAcceso;
    expect(acceso.membresias, [cliente]);
    expect(acceso.activa, cliente);
  });

  test('si la lectura lanza queda en ErrorAcceso; recargar con el '
      'repositorio sano llega a ConAcceso', () async {
    repositorio.error = Exception('sin red');

    await emitir(true);
    expect(
      leer(),
      isA<ErrorAcceso>().having(
        (e) => e.mensaje,
        'mensaje',
        'No pudimos cargar tu acceso. Inténtalo de nuevo.',
      ),
    );

    repositorio
      ..error = null
      ..membresias = [membresia('d1')];
    await container.read(controlAccesoProvider.notifier).recargar();

    expect(leer(), isA<ConAcceso>());
  });

  test('el StateError de "no hay sesión" también da ErrorAcceso', () async {
    repositorio.error = StateError('No hay sesión para leer las membresías.');

    await emitir(true);

    expect(leer(), isA<ErrorAcceso>());
  });

  test('dos membresías sin preferencia dejan activa nula; elegir d2 la '
      'activa y la guarda', () async {
    final d1 = membresia('d1');
    final d2 = membresia('d2', rol: RolMembresia.repartidor);
    repositorio.membresias = [d1, d2];

    await emitir(true);
    expect((leer() as ConAcceso).activa, isNull);

    await container
        .read(controlAccesoProvider.notifier)
        .elegirDistribuidor('d2');

    final acceso = leer() as ConAcceso;
    expect(acceso.activa, d2);
    expect(acceso.membresias, [d1, d2]);
    expect(repositorio.guardados, ['d2']);
  });

  test('elegir un distribuidor que no está entre las útiles no cambia '
      'nada', () async {
    repositorio.membresias = [membresia('d1'), membresia('d2')];
    await emitir(true);
    final antes = leer();

    await container
        .read(controlAccesoProvider.notifier)
        .elegirDistribuidor('no-existe');

    expect(leer(), same(antes));
    expect(repositorio.guardados, isEmpty);
  });

  test('si se cierra la sesión con la carga pendiente queda en SinSesion '
      'aunque la carga termine después', () async {
    final respuesta = Completer<List<Membresia>>();
    repositorio.respuesta = respuesta;

    await emitir(true);
    expect(leer(), isA<Cargando>());

    await emitir(false);
    expect(leer(), isA<SinSesion>());

    respuesta.complete([membresia('d1')]);
    await pumpEventQueue();

    expect(leer(), isA<SinSesion>());
  });

  test('un nuevo aviso de sesión con la misma sesión no recarga', () async {
    repositorio.membresias = [membresia('d1')];
    await emitir(true);
    final antes = leer();

    // Por ejemplo, el evento que emite `auth.updateUser`.
    await emitir(true);

    expect(leer(), same(antes));
    expect(repositorio.lecturas, 1);
  });

  group('registro pendiente', () {
    const pendiente = RegistroPendiente(
      codigo: 'AB2CD3E4',
      distribuidorId: 'd1',
      direccion: 'Av. Los Olivos 123, Comas',
      telefono: '987654321',
    );
    const aviso =
        'No pudimos vincular tu código. Pide uno nuevo a tu distribuidor.';

    setUp(() => cuentas.pendiente = pendiente);

    test('si el canje vincula: canjea, completa los datos con su '
        'distribuidor, limpia y luego lee las membresías', () async {
      final cliente = membresia('d1');
      repositorio.membresias = [cliente];

      await emitir(true);

      expect(bitacora, [
        'canjear AB2CD3E4',
        'completar d1',
        'limpiar',
        'listar',
      ]);
      expect(cuentas.completados.single.$2, same(pendiente));
      final acceso = leer() as ConAcceso;
      expect(acceso.membresias, [cliente]);
      expect(acceso.activa, cliente);
      expect(acceso.aviso, isNull);
    });

    test('si el canje no vincula y no hay membresía en ese distribuidor: '
        'intenta completar, limpia y deja el aviso', () async {
      invitaciones.canjeOk = false;
      repositorio.membresias = [membresia('d2')];

      await emitir(true);

      // Completar se intenta igual: el canje pudo haberse confirmado antes
      // sin que la app lo supiera. La BD rechaza a quien no es cliente ahí.
      expect(bitacora, [
        'canjear AB2CD3E4',
        'completar d1',
        'limpiar',
        'listar',
      ]);
      final acceso = leer() as ConAcceso;
      expect(acceso.membresias.map((m) => m.distribuidorId), ['d2']);
      expect(acceso.aviso, aviso);
    });

    test('un canje confirmado cuya respuesta se perdió: el reintento no '
        'vincula, pero completa los datos, limpia y entra sin aviso', () async {
      final cliente = membresia('d1');
      repositorio.membresias = [cliente];
      invitaciones.errorCanje = Exception('respuesta perdida');

      await emitir(true);
      expect(leer(), isA<ErrorAcceso>());
      expect(cuentas.completados, isEmpty);
      expect(cuentas.pendiente, same(pendiente));

      // El servidor sí lo canjeó: ahora el código ya está usado.
      invitaciones
        ..errorCanje = null
        ..canjeOk = false;
      bitacora.clear();
      await container.read(controlAccesoProvider.notifier).recargar();

      expect(bitacora, [
        'canjear AB2CD3E4',
        'completar d1',
        'limpiar',
        'listar',
      ]);
      expect(cuentas.completados.single.$1, 'd1');
      expect(cuentas.pendiente, isNull);
      final acceso = leer() as ConAcceso;
      expect(acceso.activa, cliente);
      expect(acceso.aviso, isNull);
    });

    test('un canje de una sesión anterior que termina tarde no completa ni '
        'limpia', () async {
      invitaciones.canjePendiente = Completer<bool>();

      await emitir(true);
      expect(invitaciones.canjes, ['AB2CD3E4']);

      await emitir(false);
      invitaciones.canjePendiente!.complete(true);
      await pumpEventQueue();

      expect(cuentas.completados, isEmpty);
      expect(cuentas.limpiezas, 0);
      expect(leer(), isA<SinSesion>());
    });

    test('si completar los datos falla, entra igual y limpia', () async {
      final cliente = membresia('d1');
      repositorio.membresias = [cliente];
      cuentas.errorCompletar = Exception('sin red');

      await emitir(true);

      expect(bitacora, [
        'canjear AB2CD3E4',
        'completar d1',
        'limpiar',
        'listar',
      ]);
      final acceso = leer() as ConAcceso;
      expect(acceso.activa, cliente);
      expect(acceso.aviso, isNull);
    });

    test('una invitación sin datos de la bodega no los completa', () async {
      cuentas.pendiente = const RegistroPendiente(
        codigo: 'AB2CD3E4',
        distribuidorId: 'd1',
      );
      repositorio.membresias = [membresia('d1', rol: RolMembresia.repartidor)];

      await emitir(true);

      expect(bitacora, ['canjear AB2CD3E4', 'limpiar', 'listar']);
      expect(leer(), isA<ConAcceso>());
    });

    test('sin pendiente no canjea, no completa ni limpia', () async {
      cuentas.pendiente = null;
      repositorio.membresias = [membresia('d1')];

      await emitir(true);

      expect(bitacora, ['listar']);
      expect(invitaciones.canjes, isEmpty);
      expect(cuentas.limpiezas, 0);
    });

    test('una recarga posterior no vuelve a canjear', () async {
      repositorio.membresias = [membresia('d1')];
      await emitir(true);

      await container.read(controlAccesoProvider.notifier).recargar();

      expect(invitaciones.canjes, ['AB2CD3E4']);
      expect(cuentas.limpiezas, 1);
      expect(repositorio.lecturas, 2);
    });

    test('si limpiar falla, una recarga no vuelve a canjear el mismo '
        'código', () async {
      invitaciones.canjeOk = false;
      cuentas.errorLimpiar = Exception('sin red');

      await emitir(true);
      expect(cuentas.completados, hasLength(1));
      expect((leer() as ConAcceso).aviso, aviso);

      await container.read(controlAccesoProvider.notifier).recargar();

      expect(invitaciones.canjes, ['AB2CD3E4']);
      expect(cuentas.completados, hasLength(1));
      expect(leer(), isA<ConAcceso>());
    });

    test('si el canje lanza (sin respuesta), queda en ErrorAcceso y '
        'conserva el pendiente; reintentar lo canjea', () async {
      invitaciones.errorCanje = Exception('sin red');
      repositorio.membresias = [membresia('d1')];

      await emitir(true);

      expect(leer(), isA<ErrorAcceso>());
      expect(cuentas.limpiezas, 0);
      expect(cuentas.pendiente, same(pendiente));
      expect(repositorio.lecturas, 0);

      invitaciones.errorCanje = null;
      await container.read(controlAccesoProvider.notifier).recargar();

      expect(invitaciones.canjes, ['AB2CD3E4', 'AB2CD3E4']);
      expect(cuentas.limpiezas, 1);
      expect((leer() as ConAcceso).activa, isNotNull);
    });

    test('una recarga durante el canje no canjea otra vez y recibe el '
        'mismo resultado', () async {
      invitaciones
        ..canjePendiente = Completer<bool>()
        ..canjeOk = false;

      await emitir(true);
      final recarga = container.read(controlAccesoProvider.notifier).recargar();
      await pumpEventQueue();
      expect(invitaciones.canjes, ['AB2CD3E4']);

      invitaciones.canjePendiente!.complete(false);
      await recarga;
      await pumpEventQueue();

      expect(invitaciones.canjes, ['AB2CD3E4']);
      expect(cuentas.limpiezas, 1);
      expect((leer() as ConAcceso).aviso, aviso);
    });

    test(
      'el aviso de sesión que emite limpiar el pendiente no recarga',
      () async {
        repositorio.membresias = [membresia('d1')];
        await emitir(true);
        final antes = leer();

        // `auth.updateUser` emite `userUpdated` con la misma sesión.
        await emitir(true);

        expect(leer(), same(antes));
        expect(invitaciones.canjes, ['AB2CD3E4']);
        expect(repositorio.lecturas, 1);
      },
    );
  });
}
