import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'pago.freezed.dart';
part 'pago.g.dart';

/// Cobro registrado contra un pedido, tabla `pagos`. Monto en céntimos.
@freezed
abstract class Pago with _$Pago {
  const factory Pago({
    required String id,
    required String distribuidorId,
    required String pedidoId,
    required String clienteId,
    required int montoCentimos,
    required MetodoPago metodo,
    String? referencia,
    String? nota,
    String? registradoPor,
    DateTime? anuladoEn,
    String? anuladoPor,
    required DateTime creadoEn,
  }) = _Pago;

  factory Pago.fromJson(Map<String, dynamic> json) => _$PagoFromJson(json);
}
