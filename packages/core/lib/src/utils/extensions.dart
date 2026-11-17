import 'dinero.dart';

extension EnteroDinero on int {
  /// Interpreta el entero como céntimos y lo formatea: `1050.formatoSoles` → `S/ 10.50`.
  String get formatoSoles => Dinero.formatear(this);
}

extension TextoNoVacio on String? {
  /// `true` si es nulo o solo espacios.
  bool get estaVacio => this == null || this!.trim().isEmpty;
}
