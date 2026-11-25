import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/autenticacion_supabase.dart';
import '../data/membresias_repositorio_supabase.dart';
import '../domain/acceso.dart';
import '../domain/autenticacion.dart';
import '../domain/membresias_repositorio.dart';

part 'control_acceso.g.dart';

// Este archivo es el único lugar de `presentation` que construye las
// implementaciones de `data`: las pantallas dependen solo de estos providers
// y de `domain`. Las pruebas los reemplazan con dobles.

@Riverpod(keepAlive: true)
MembresiasRepositorio membresiasRepositorio(Ref ref) =>
    MembresiasRepositorioSupabase(supabase);

@Riverpod(keepAlive: true)
Autenticacion autenticacion(Ref ref) => AutenticacionSupabase(supabase);

/// Flujo de "hay sesión / no hay sesión"; las pruebas lo reemplazan.
///
/// Empieza con el estado actual de la sesión. Si la sesión pasa directamente
/// a otra persona, emite `false` y luego `true` para forzar una recarga.
@Riverpod(keepAlive: true)
Stream<bool> haySesion(Ref ref) async* {
  final auth = supabase.auth;
  var usuarioId = auth.currentSession?.user.id;
  yield usuarioId != null;
  // Los errores del flujo (por ejemplo, un refresco de token fallido) no
  // cortan la escucha: Supabase emite después el `signedOut` que corresponda.
  await for (final evento in auth.onAuthStateChange.handleError((_) {})) {
    final nuevo = evento.session?.user.id;
    if (usuarioId != null && nuevo != null && nuevo != usuarioId) {
      yield false;
    }
    usuarioId = nuevo;
    yield nuevo != null;
  }
}

/// Estado de la sesión que le importa al control de acceso: `null` mientras
/// el flujo aún no dijo nada. Un error sin valor previo cuenta como sin sesión.
bool? _estadoSesion(AsyncValue<bool> sesion) {
  if (sesion.hasValue) return sesion.value;
  if (sesion.hasError) return false;
  return null;
}

/// Acceso de la persona al panel: decide con qué distribuidor y rol entra
/// según sus membresías. La redirección la hace el router leyendo este estado.
///
/// Mismo diseño que el de `app_movil` (las apps no se importan entre sí).
@Riverpod(keepAlive: true)
class ControlAcceso extends _$ControlAcceso {
  /// Identifica la carga en curso; una carga más nueva descarta las viejas.
  /// Riverpod conserva la instancia del notifier entre reconstrucciones, así
  /// que este contador es lo que descarta una carga lanzada con otra sesión.
  int _carga = 0;

  @override
  Acceso build() {
    // Cada reconstrucción (la sesión cambió) invalida las cargas pendientes.
    _carga++;
    // `select` evita reconstruir con eventos que no cambian la sesión (por
    // ejemplo, el que emite `auth.updateUser` al guardar la preferencia).
    final haySesion = ref.watch(haySesionProvider.select(_estadoSesion));
    switch (haySesion) {
      case null:
        return const Cargando();
      case false:
        return const SinSesion();
      case true:
        unawaited(_cargar());
        return const Cargando();
    }
  }

  /// Vuelve a leer las membresías. Sin sesión no hace nada.
  Future<void> recargar() async {
    if (_estadoSesion(ref.read(haySesionProvider)) != true) return;
    state = const Cargando();
    await _cargar();
  }

  /// Guarda la preferencia y actualiza `activa`. Si [distribuidorId] no está
  /// entre las membresías útiles, no cambia nada.
  Future<void> elegirDistribuidor(String distribuidorId) async {
    final actual = state;
    if (actual is! ConAcceso) return;
    final elegida = actual.membresias
        .where((m) => m.distribuidorId == distribuidorId)
        .firstOrNull;
    if (elegida == null) return;

    // Primero el estado: la elección vale en esta sesión aunque guardarla
    // falle. El error del guardado se propaga a quien llamó.
    state = ConAcceso(membresias: actual.membresias, activa: elegida);
    await ref
        .read(membresiasRepositorioProvider)
        .guardarDistribuidorPreferido(distribuidorId);
  }

  /// Cierra la sesión. Devuelve `false` si falló; el error se registra y no
  /// se propaga.
  Future<bool> cerrarSesion() async {
    try {
      await ref.read(autenticacionProvider).cerrarSesion();
      return true;
    } catch (e, st) {
      developer.log(
        'No se pudo cerrar la sesión.',
        name: 'control_acceso',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  Future<void> _cargar() async {
    final carga = ++_carga;
    final repositorio = ref.read(membresiasRepositorioProvider);
    Acceso resultado;
    try {
      final todas = await repositorio.listarMias();
      resultado = accesoDesde(todas, repositorio.distribuidorPreferido());
    } catch (e, st) {
      // La causa puede ser la red, un 401, un error de PostgREST o de parseo:
      // se registra completa y a la persona se le da un mensaje neutro.
      developer.log(
        'No se pudieron leer las membresías.',
        name: 'control_acceso',
        error: e,
        stackTrace: st,
      );
      resultado = const ErrorAcceso(
        'No pudimos cargar tu acceso. Inténtalo de nuevo.',
      );
    }
    // Si la sesión cambió (el provider se reconstruyó) o empezó otra carga,
    // este resultado ya no vale.
    if (!ref.mounted || carga != _carga) return;
    state = resultado;
  }
}

/// Membresía con la que la persona está usando el panel, o null si todavía
/// no entró a ningún distribuidor.
@riverpod
Membresia? membresiaActiva(Ref ref) {
  final acceso = ref.watch(controlAccesoProvider);
  return acceso is ConAcceso ? acceso.activa : null;
}
