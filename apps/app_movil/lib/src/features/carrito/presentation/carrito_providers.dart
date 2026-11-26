import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../sesion/presentation/sesion_activa.dart';
import '../domain/carrito.dart';

part 'carrito_providers.g.dart';

/// Carrito de la sesión, solo en memoria. Se vacía cuando cambia la
/// membresía activa: otro distribuidor, otra persona o cierre de sesión.
@Riverpod(keepAlive: true)
class CarritoActual extends _$CarritoActual {
  @override
  Carrito build() {
    // Releer la misma membresía (mismo id) no vacía el carrito.
    ref.watch(membresiaActivaProvider.select((m) => m?.id));
    return const Carrito.vacio();
  }

  void agregar(
    String presentacionId,
    int cantidad, {
    required int disponible,
  }) => state = state.agregar(presentacionId, cantidad, disponible: disponible);

  void fijar(String presentacionId, int cantidad, {required int disponible}) =>
      state = state.fijar(presentacionId, cantidad, disponible: disponible);

  void quitar(String presentacionId) => state = state.quitar(presentacionId);

  void vaciar() => state = state.vaciar();
}
