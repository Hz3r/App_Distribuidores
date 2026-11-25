import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../registro/presentation/registro_providers.dart';
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

  /// Cambia con cada reconstrucción, es decir, con cada cambio de sesión (a
  /// diferencia de [_carga], que también cambia con `recargar`). Un canje
  /// que termina con otra generación no ejecuta sus efectos.
  int _generacionSesion = 0;

  /// Canje del registro pendiente en curso. Las cargas que empiezan mientras
  /// tanto esperan este mismo canje en vez de lanzar otro. Devuelve el
  /// distribuidor de un código que no vinculó, o `null`.
  Future<String?>? _canjeEnCurso;

  /// Códigos de registros pendientes ya canjeados (vinculen o no). Si
  /// limpiar el pendiente falló, el código no se vuelve a canjear.
  final _codigosCanjeados = <String>{};

  /// Aviso para un registro pendiente cuyo código no vinculó.
  static const avisoNoVinculado =
      'No pudimos vincular tu código. Pide uno nuevo a tu distribuidor.';

  @override
  Acceso build() {
    // Cada reconstrucción (la sesión cambió) invalida las cargas pendientes.
    _carga++;
    _generacionSesion++;
    // `select` evita reconstruir con eventos que no cambian la sesión (por
    // ejemplo, el que emite `auth.updateUser` al guardar la preferencia o al
    // limpiar el registro pendiente).
    final haySesion = ref.watch(haySesionProvider.select(_estadoSesion));
    switch (haySesion) {
      case null:
        _canjeEnCurso = null;
        return const Cargando();
      case false:
        // Un canje en curso era de la sesión anterior: la siguiente no lo
        // espera.
        _canjeEnCurso = null;
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

  /// Cierra la sesión con el cliente de `core`. Devuelve `false` si falló;
  /// el error se registra y no se propaga. Las pruebas lo sobreescriben con
  /// un controlador falso para no tocar `Supabase.instance`.
  Future<bool> cerrarSesion() async {
    try {
      await supabase.auth.signOut();
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
      // Antes de leer las membresías: el canje puede crear una.
      final sinVincular = await _canjearPendienteUnaVez();
      final todas = await repositorio.listarMias();
      final acceso = accesoDesde(todas, repositorio.distribuidorPreferido());
      // "No vinculó" puede ser el reintento de un canje que sí se confirmó
      // (se perdió la respuesta): solo se avisa si de verdad no hay acceso
      // en ese distribuidor.
      final vinculada =
          sinVincular == null ||
          acceso.membresias.any((m) => m.distribuidorId == sinVincular);
      resultado = vinculada
          ? acceso
          : ConAcceso(
              membresias: acceso.membresias,
              activa: acceso.activa,
              aviso: avisoNoVinculado,
            );
    } catch (e, st) {
      // La causa puede ser la red, un 401, un error de PostgREST o de parseo,
      // también del canje del registro pendiente (que entonces se conserva
      // para el reintento): se registra completa y a la persona se le da un
      // mensaje neutro.
      developer.log(
        'No se pudo cargar el acceso.',
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

  /// Canjea el registro pendiente, si hay, compartiendo el canje en curso
  /// con las cargas que se solapen. Devuelve el distribuidor de un código
  /// que no vinculó, o `null`.
  Future<String?> _canjearPendienteUnaVez() async {
    final canje = _canjeEnCurso ??= _canjearPendiente();
    try {
      return await canje;
    } finally {
      if (identical(_canjeEnCurso, canje)) _canjeEnCurso = null;
    }
  }

  /// Canjea el código del registro pendiente, completa los datos de la
  /// bodega y limpia el pendiente, vincule o no: un código que no vincula no
  /// se reintenta. Si el canje lanza (sin respuesta, freno), el error se
  /// propaga y el pendiente se conserva para el próximo intento.
  ///
  /// Los datos se completan aunque el canje diga que no vinculó: puede ser el
  /// reintento de un canje que el servidor sí confirmó (respuesta perdida, o
  /// la app se cerró antes de completar). Si de verdad no es cliente ahí, la
  /// BD lo rechaza con `42501`, que se registra y no bloquea.
  Future<String?> _canjearPendiente() async {
    final generacion = _generacionSesion;
    final cuentas = ref.read(cuentasRepositorioProvider);
    final pendiente = cuentas.pendienteActual();
    if (pendiente == null) return null;

    String? sinVincular;
    if (_codigosCanjeados.add(pendiente.codigo)) {
      final bool vinculada;
      try {
        vinculada = await ref
            .read(invitacionesRepositorioProvider)
            .canjear(pendiente.codigo);
      } catch (_) {
        // Sin respuesta: se podrá canjear en el próximo intento.
        _codigosCanjeados.remove(pendiente.codigo);
        rethrow;
      }
      // La sesión cambió mientras se canjeaba: los efectos que siguen
      // actuarían sobre otra cuenta.
      if (!ref.mounted || generacion != _generacionSesion) return null;
      if (!vinculada) sinVincular = pendiente.distribuidorId;

      if (pendiente.tieneDatosNegocio) {
        // El canje crea la membresía en el distribuidor de la invitación,
        // que es el que guardó el pendiente.
        try {
          await cuentas.completarDatosNegocio(
            pendiente.distribuidorId,
            pendiente,
          );
        } catch (e, st) {
          // No bloquea la entrada.
          developer.log(
            'No se pudieron completar los datos de la bodega.',
            name: 'control_acceso',
            error: e,
            stackTrace: st,
          );
        }
        if (!ref.mounted || generacion != _generacionSesion) return null;
      }
    }

    try {
      await cuentas.limpiarPendiente();
    } catch (e, st) {
      // `_codigosCanjeados` evita canjearlo otra vez en esta ejecución.
      developer.log(
        'No se pudo limpiar el registro pendiente.',
        name: 'control_acceso',
        error: e,
        stackTrace: st,
      );
    }
    return sinVincular;
  }
}
