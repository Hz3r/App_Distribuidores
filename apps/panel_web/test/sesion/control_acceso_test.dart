import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panel_web/src/features/sesion/domain/acceso.dart';
import 'package:panel_web/src/features/sesion/presentation/control_acceso.dart';

import '../soporte/dobles.dart';

void main() {
  late RepositorioDoble repositorio;
  late AutenticacionDoble autenticacion;
  late StreamController<bool> sesion;
  late ProviderContainer container;

  setUp(() {
    repositorio = RepositorioDoble();
    autenticacion = AutenticacionDoble();
    sesion = StreamController<bool>();
    container = ProviderContainer(
      overrides: [
        membresiasRepositorioProvider.overrideWithValue(repositorio),
        autenticacionProvider.overrideWithValue(autenticacion),
        haySesionProvider.overrideWith((ref) => sesion.stream),
      ],
    );
    // Mantiene el provider escuchado durante la prueba.
    container.listen(controlAccesoProvider, (_, _) {}, fireImmediately: true);
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

  test('sin sesión queda en SinSesion y no lee membresías', () async {
    await emitir(false);

    expect(leer(), isA<SinSesion>());
    expect(repositorio.lecturas, 0);
  });

  test('con sesión pasa por Cargando y termina en ConAcceso con el admin '
      'activo', () async {
    final admin = membresia('d1');
    final respuesta = Completer<List<Membresia>>();
    repositorio.respuesta = respuesta;

    await emitir(true);
    expect(leer(), isA<Cargando>());
    expect(repositorio.lecturas, 1);

    respuesta.complete([admin]);
    await pumpEventQueue();

    final acceso = leer() as ConAcceso;
    expect(acceso.membresias, [admin]);
    expect(acceso.activa, admin);
  });

  test('una cuenta que solo es cliente queda sin membresías útiles', () async {
    repositorio.membresias = [membresia('d1', rol: RolMembresia.cliente)];

    await emitir(true);

    final acceso = leer() as ConAcceso;
    expect(acceso.membresias, isEmpty);
    expect(acceso.activa, isNull);
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

  test('dos distribuidores sin preferencia dejan activa nula; elegir d2 la '
      'activa y la guarda', () async {
    final d1 = membresia('d1');
    final d2 = membresia('d2', rol: RolMembresia.vendedor);
    repositorio.membresias = [d1, d2];

    await emitir(true);
    expect((leer() as ConAcceso).activa, isNull);

    await container
        .read(controlAccesoProvider.notifier)
        .elegirDistribuidor('d2');

    final acceso = leer() as ConAcceso;
    expect(acceso.activa, d2);
    expect(repositorio.guardados, ['d2']);
  });

  test('con preferencia guardada entra directo a ese distribuidor', () async {
    final d2 = membresia('d2');
    repositorio
      ..membresias = [membresia('d1'), d2]
      ..preferido = 'd2';

    await emitir(true);

    expect((leer() as ConAcceso).activa, d2);
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

  test('cerrarSesion devuelve true si cerró y false si falló', () async {
    final control = container.read(controlAccesoProvider.notifier);

    expect(await control.cerrarSesion(), isTrue);
    expect(autenticacion.cierres, 1);

    autenticacion.errorAlCerrar = Exception('sin red');
    expect(await control.cerrarSesion(), isFalse);
  });
}
