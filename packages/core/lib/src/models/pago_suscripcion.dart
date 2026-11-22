import 'package:freezed_annotation/freezed_annotation.dart';

part 'pago_suscripcion.freezed.dart';
part 'pago_suscripcion.g.dart';

/// Pago de un periodo de suscripción, tabla `pagos_suscripcion`. Monto en céntimos.
@freezed
abstract class PagoSuscripcion with _$PagoSuscripcion {
  const factory PagoSuscripcion({
    required String id,
    required String distribuidorId,
    required String suscripcionId,
    required int montoCentimos,
    required String metodo,
    required DateTime periodoInicio,
    required DateTime periodoFin,
    String? registradoPor,
    String? referenciaExterna,
    String? nota,
    required DateTime creadoEn,
  }) = _PagoSuscripcion;

  factory PagoSuscripcion.fromJson(Map<String, dynamic> json) =>
      _$PagoSuscripcionFromJson(json);
}
