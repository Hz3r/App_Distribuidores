import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'invitacion.freezed.dart';
part 'invitacion.g.dart';

/// Código de invitación para unirse a un distribuidor, tabla `invitaciones`.
@freezed
abstract class Invitacion with _$Invitacion {
  const factory Invitacion({
    required String id,
    required String distribuidorId,
    required String codigo,
    required RolMembresia rol,
    String? clienteNegocioId,
    String? creadaPor,
    required DateTime venceEn,
    String? usadaPor,
    DateTime? usadaEn,
    DateTime? revocadaEn,
    required DateTime creadoEn,
  }) = _Invitacion;

  factory Invitacion.fromJson(Map<String, dynamic> json) =>
      _$InvitacionFromJson(json);
}
