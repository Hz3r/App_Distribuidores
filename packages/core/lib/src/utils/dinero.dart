import 'package:intl/intl.dart';

/// Formateo de montos. Internamente todo son céntimos (enteros).
/// Formato fijo `S/ 1,234.50` independiente del locale del dispositivo.
abstract final class Dinero {
  static const String simbolo = 'S/ ';

  static final NumberFormat _numero = NumberFormat('#,##0.00', 'en_US');

  /// `123450` → `S/ 1,234.50`
  static String formatear(int centimos) =>
      '$simbolo${_numero.format(centimos / 100)}';
}
