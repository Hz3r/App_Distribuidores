import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  /// Sin un valor vigente, si mostrar el error en vez de "cargando": cuando
  /// ya no se está volviendo a pedir.
  bool get mostrarError => hasError && !isLoading;
}
