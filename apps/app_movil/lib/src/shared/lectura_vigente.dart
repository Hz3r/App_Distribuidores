import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Política de reintento de las lecturas que muestran "Reintentar": ninguno
/// automático, para que un fallo llegue de inmediato al estado de error. Se
/// usa en el `retry` de cada provider (`@Riverpod(retry: sinReintentos)`);
/// la política global del `ProviderScope` no cambia.
Duration? sinReintentos(int intentos, Object error) => null;

/// Cómo leer en una pantalla un provider que depende de la membresía
/// activa.
extension LecturaVigente<T> on AsyncValue<T> {
  /// El valor, solo si [esVigente] lo acepta; si no, `null`.
  ///
  /// Al cambiar de membresía (otro distribuidor, otra bodega, otra cuenta),
  /// Riverpod conserva el valor anterior mientras recarga, y también si la
  /// recarga falla: ese valor es de otra membresía y no se muestra.
  T? valorVigente(bool Function(T valor) esVigente) {
    final actual = value;
    return actual != null && esVigente(actual) ? actual : null;
  }

  /// Sin un valor vigente, si mostrar el error en vez de "cargando". El
  /// error va primero: también mientras Riverpod lo reintenta solo
  /// ([retrying]). Solo un nuevo pedido a mano ("Reintentar", deslizar o el
  /// cambio de membresía) se muestra como carga.
  bool get mostrarError => hasError && (!isLoading || retrying);
}
