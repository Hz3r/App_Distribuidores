import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan.freezed.dart';
part 'plan.g.dart';

/// Plan de suscripción de la plataforma, tabla `planes`. Precio en céntimos.
@freezed
abstract class Plan with _$Plan {
  const factory Plan({
    required String id,
    required String codigo,
    required String nombre,
    required int precioMensualCentimos,
    required String moneda,
    required Map<String, dynamic> limites,
    required bool activo,
    required DateTime creadoEn,
  }) = _Plan;

  factory Plan.fromJson(Map<String, dynamic> json) => _$PlanFromJson(json);
}
