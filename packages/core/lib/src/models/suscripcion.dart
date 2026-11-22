import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'suscripcion.freezed.dart';
part 'suscripcion.g.dart';

/// Suscripción de un distribuidor a un plan, tabla `suscripciones`.
@freezed
abstract class Suscripcion with _$Suscripcion {
  const factory Suscripcion({
    required String id,
    required String distribuidorId,
    required String planId,
    required EstadoSuscripcion estado,
    required DateTime periodoInicio,
    required DateTime periodoFin,
    String? proveedorPago,
    String? referenciaExterna,
    required DateTime creadoEn,
  }) = _Suscripcion;

  factory Suscripcion.fromJson(Map<String, dynamic> json) =>
      _$SuscripcionFromJson(json);
}
