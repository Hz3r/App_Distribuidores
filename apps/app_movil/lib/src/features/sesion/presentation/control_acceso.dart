import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/membresias_repositorio_supabase.dart';
import '../domain/acceso.dart';
import '../domain/membresias_repositorio.dart';

part 'control_acceso.g.dart';

/// Repositorio inyectable; las pruebas lo reemplazan con un doble.
///
/// Es el único lugar de `presentation` que construye la implementación de
/// `data`: las pantallas dependen solo de este provider y de `domain`.
@Riverpod(keepAlive: true)
MembresiasRepositorio membresiasRepositorio(Ref ref) =>
    MembresiasRepositorioSupabase(supabase);

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

/// Acceso de la persona en la app móvil: decide a qué zona entra según sus
/// membresías. La redirección la hace el router leyendo este estado.
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

  Future<void> _cargar() async {
    final carga = ++_carga;
    final repositorio = ref.read(membresiasRepositorioProvider);
    Acceso resultado;
    try {
      final todas = await repositorio.listarMias();
      resultado = accesoDesde(todas, repositorio.distribuidorPreferido());
    } catch (_) {
      resultado = const ErrorAcceso(
        'No se pudieron leer tus accesos. Revisa tu conexión e inténtalo '
        'de nuevo.',
      );
    }
    // Si la sesión cambió (el provider se reconstruyó) o empezó otra carga,
    // este resultado ya no vale.
    if (!ref.mounted || carga != _carga) return;
    state = resultado;
  }
}
