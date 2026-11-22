import 'dart:async';

import 'package:app_movil/src/features/sesion/domain/acceso.dart';
import 'package:app_movil/src/features/sesion/domain/membresias_repositorio.dart';
import 'package:app_movil/src/features/sesion/presentation/control_acceso.dart';
import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

  @override
  Future<List<Membresia>> listarMias() async {
    lecturas++;
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
  late StreamController<bool> sesion;
  late ProviderContainer container;
  late List<Acceso> estados;

  setUp(() {
    repositorio = RepositorioDoble();
    sesion = StreamController<bool>();
    container = ProviderContainer(
      overrides: [
        membresiasRepositorioProvider.overrideWithValue(repositorio),
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
    repositorio.membresias = [cliente];

    await emitir(true);

    expect(estados.whereType<Cargando>(), isNotEmpty);
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
    expect(leer(), isA<ErrorAcceso>());

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
}
